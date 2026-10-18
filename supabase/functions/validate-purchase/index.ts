// Supabase Edge Function — validate-purchase
//
// The app calls this after a Play/App Store purchase (with the buyer's Supabase
// JWT). We derive the user from the JWT (so the client can't spoof who to grant),
// verify the receipt/token with the store, then upsert public.pro_entitlements.
// The realtime subscription on that row unlocks Pro in the app.
//
// iOS: in_app_purchase_storekit uses StoreKit2 on modern iOS, so
// verificationData.serverVerificationData is a StoreKit2 transaction JWS, NOT
// a legacy base64 receipt — the old verifyReceipt endpoint always rejects it
// as malformed (status 21002). We call Apple's modern App Store Server API
// instead, authenticated with our own ES256-signed JWT (APPLE_IAP_* secrets,
// from the In-App Purchase key in App Store Connect → Users and Access →
// Integrations → Keys).
//
// IMPORTANT: until Kaal is actually released on the App Store, Apple's
// PRODUCTION App Store Server API returns 401 (not 404) for every request,
// regardless of environment — confirmed by other developers hitting the same
// issue pre-release. So the sandbox fallback must trigger on ANY non-OK
// response, not just 404, or it never actually reaches sandbox. Once Kaal is
// live on the App Store this still works correctly (production will then
// return real 404s for genuinely-sandbox-only transactions).
//
// Secrets: supabase secrets set APPLE_IAP_KEY_ID=... APPLE_IAP_ISSUER_ID=...
//          APPLE_IAP_PRIVATE_KEY='-----BEGIN PRIVATE KEY-----...' APPLE_BUNDLE_ID=...
//          GOOGLE_PLAY_SERVICE_ACCOUNT='{...}' (Play, JSON)
//
// NOTE: ANDROID VALIDATION IS A SCAFFOLD — wire the Google Play Developer API
// (androidpublisher purchases.subscriptions.get) before going live; until then
// it grants optimistically and logs a warning.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const admin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface Entitlement {
  valid: boolean;
  status: "active" | "cancelled" | "grace_period" | "billing_retry" | "expired" | "revoked";
  currentPeriodEnd: string | null;
  willRenew: boolean;
  debug?: string;
}

const EXPIRED: Entitlement = { valid: false, status: "expired", currentPeriodEnd: null, willRenew: false };

function b64url(s: string): string {
  return btoa(s).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}
function b64urlBytes(bytes: Uint8Array): string {
  let s = "";
  for (const b of bytes) s += String.fromCharCode(b);
  return b64url(s);
}

function decodeJwsPayload(jws: string): any {
  const parts = jws.split(".");
  if (parts.length < 2) throw new Error("not a JWS");
  const payload = parts[1].replace(/-/g, "+").replace(/_/g, "/");
  const padded = payload + "=".repeat((4 - (payload.length % 4)) % 4);
  return JSON.parse(atob(padded));
}

// Our own ES256-signed JWT to authenticate to Apple's App Store Server API.
// `bundleIdOverride` is the calling app's own id (TaskEra and Kaal share this
// function/project, so a single APPLE_BUNDLE_ID secret can't serve both —
// the client tells us which app it is; absent that we fall back to the env
// default for older clients that don't send it yet).
async function appStoreServerJwt(bundleIdOverride?: string): Promise<string> {
  const keyId = Deno.env.get("APPLE_IAP_KEY_ID")!;
  const issuerId = Deno.env.get("APPLE_IAP_ISSUER_ID")!;
  const bundleId = bundleIdOverride || Deno.env.get("APPLE_BUNDLE_ID") || "com.port443.kaal";
  const pem = Deno.env.get("APPLE_IAP_PRIVATE_KEY")!;

  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "ES256", kid: keyId, typ: "JWT" };
  const payload = {
    iss: issuerId, iat: now, exp: now + 1200, aud: "appstoreconnect-v1", bid: bundleId,
    nonce: crypto.randomUUID(),
  };
  const unsigned = `${b64url(JSON.stringify(header))}.${b64url(JSON.stringify(payload))}`;

  const pkcs8 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s/g, "");
  const der = Uint8Array.from(atob(pkcs8), (c) => c.charCodeAt(0));
  const key = await crypto.subtle.importKey(
    "pkcs8", der, { name: "ECDSA", namedCurve: "P-256" }, false, ["sign"],
  );
  const sig = await crypto.subtle.sign(
    { name: "ECDSA", hash: "SHA-256" }, key, new TextEncoder().encode(unsigned),
  );
  return `${unsigned}.${b64urlBytes(new Uint8Array(sig))}`;
}

// iOS — App Store Server API. `transactionJws` is the StoreKit2 transaction
// JWS from the client. We decode it locally only to extract the transaction
// id; the entitlement decision comes from Apple's authoritative
// /inApps/v1/subscriptions lookup (real subscription status + auto-renew).
async function verifyApple(transactionJws: string, productId: string, bundleId?: string): Promise<Entitlement> {
  try {
    const decoded = decodeJwsPayload(transactionJws);
    const originalTransactionId = decoded.originalTransactionId ?? decoded.transactionId;
    if (!originalTransactionId) return { ...EXPIRED, debug: "no_transaction_id_in_jws" };

    const lookup = async (base: string) => {
      const jwt = await appStoreServerJwt(bundleId); // fresh JWT (with new nonce) per call
      return fetch(`${base}/inApps/v1/subscriptions/${originalTransactionId}`, {
        headers: { Authorization: `Bearer ${jwt}`, Accept: "application/json" },
      });
    };

    let res = await lookup("https://api.storekit.itunes.apple.com");
    let usedSandbox = false;
    // Pre-release apps get 401 from production regardless of environment, and
    // even post-release a genuinely-wrong-environment lookup can 404 — so any
    // non-OK production response falls back to sandbox rather than only 404.
    if (!res.ok) {
      usedSandbox = true;
      res = await lookup("https://api.storekit-sandbox.itunes.apple.com");
    }
    if (!res.ok) {
      const text = await res.text();
      return { ...EXPIRED, debug: `appstore_api_${res.status}_sb_${usedSandbox}_${text.slice(0, 120)}` };
    }

    const body = await res.json();
    const groups: any[] = body.data ?? [];
    let latestTxn: any = null;
    let latestRenewal: any = null;
    for (const g of groups) {
      for (const t of g.lastTransactions ?? []) {
        const info = t.signedTransactionInfo ? decodeJwsPayload(t.signedTransactionInfo) : null;
        if (productId && info?.productId !== productId) continue;
        if (!latestTxn || (info?.expiresDate ?? 0) > (latestTxn.expiresDate ?? 0)) {
          latestTxn = { ...info, status: t.status };
          latestRenewal = t.signedRenewalInfo ? decodeJwsPayload(t.signedRenewalInfo) : null;
        }
      }
    }
    if (!latestTxn) return { ...EXPIRED, debug: `no_matching_txn_sb_${usedSandbox}` };

    const expiresMs = Number(latestTxn.expiresDate ?? 0);
    const willRenew = latestRenewal?.autoRenewStatus === 1;
    const currentPeriodEnd = expiresMs ? new Date(expiresMs).toISOString() : null;

    // Apple subscription status: 1 active, 2 expired, 3 billing retry, 4 billing grace period, 5 revoked.
    switch (latestTxn.status) {
      case 1: return { valid: true, status: willRenew ? "active" : "cancelled", currentPeriodEnd, willRenew };
      case 3: return { valid: true, status: "billing_retry", currentPeriodEnd, willRenew };
      case 4: return { valid: true, status: "grace_period", currentPeriodEnd, willRenew };
      case 5: return { valid: false, status: "revoked", currentPeriodEnd, willRenew: false };
      case 2:
      default: return { valid: false, status: "expired", currentPeriodEnd, willRenew };
    }
  } catch (e) {
    console.error("[validate-purchase] Apple verify threw", e);
    return { ...EXPIRED, debug: `exception_${e instanceof Error ? e.message : String(e)}`.slice(0, 200) };
  }
}

// Exchange the service-account key for a short-lived androidpublisher token.
async function googleAccessToken(sa: { client_email: string; private_key: string }): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const claim = {
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/androidpublisher",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };
  const unsigned = `${b64url(JSON.stringify({ alg: "RS256", typ: "JWT" }))}.${b64url(JSON.stringify(claim))}`;
  const pem = sa.private_key
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s/g, "");
  const der = Uint8Array.from(atob(pem), (c) => c.charCodeAt(0));
  const key = await crypto.subtle.importKey(
    "pkcs8", der, { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" }, false, ["sign"],
  );
  const sig = await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, new TextEncoder().encode(unsigned));
  const jwt = `${unsigned}.${b64urlBytes(new Uint8Array(sig))}`;
  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  });
  const json = await res.json();
  return json.access_token as string;
}

// Android — verify the subscription token via the Play Developer API.
async function verifyAndroid(productId: string, token: string, packageOverride?: string): Promise<Entitlement> {
  const saRaw = Deno.env.get("GOOGLE_PLAY_SERVICE_ACCOUNT");
  if (!saRaw) {
    console.warn("[validate-purchase] Play service account not set — granting optimistically (UNVERIFIED)");
    return { valid: true, status: "active", currentPeriodEnd: null, willRenew: true };
  }
  try {
    const sa = JSON.parse(saRaw);
    const pkg = packageOverride || Deno.env.get("ANDROID_PACKAGE") || "com.port443.kaal";
    const accessToken = await googleAccessToken(sa);
    const url =
      `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${pkg}` +
      `/purchases/subscriptions/${productId}/tokens/${token}`;
    const res = await fetch(url, { headers: { Authorization: `Bearer ${accessToken}` } });
    if (!res.ok) return EXPIRED;
    const sub = await res.json();
    const expiresMs = Number(sub.expiryTimeMillis ?? 0);
    const expired = expiresMs > 0 && expiresMs <= Date.now();
    const currentPeriodEnd = expiresMs ? new Date(expiresMs).toISOString() : null;
    const willRenew = sub.autoRenewing === true;
    if (sub.paymentState === 0) {
      return { valid: false, status: "billing_retry", currentPeriodEnd, willRenew };
    }
    if (expired) return { valid: false, status: "expired", currentPeriodEnd, willRenew };
    return { valid: true, status: willRenew ? "active" : "cancelled", currentPeriodEnd, willRenew };
  } catch (e) {
    console.error("[validate-purchase] Android verify failed", e);
    return EXPIRED;
  }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return new Response("Method not allowed", { status: 405 });

  try {
    const authHeader = req.headers.get("Authorization") ?? "";
    const jwt = authHeader.replace("Bearer ", "");
    const { data: userData } = await admin.auth.getUser(jwt);
    const userId = userData?.user?.id;
    if (!userId) return new Response("Unauthorized", { status: 401, headers: cors });

    let payload: { platform?: string; productId?: string; token?: string; bundleId?: string };
    try {
      payload = await req.json();
    } catch {
      return new Response("Bad JSON", { status: 400, headers: cors });
    }
    const { platform, productId, token, bundleId } = payload;
    if (!platform || !token) return new Response("Missing fields", { status: 400, headers: cors });

    const entitlement = platform === "ios"
      ? await verifyApple(token, productId ?? "", bundleId)
      : await verifyAndroid(productId ?? "", token, bundleId);

    const { error } = await admin.from("pro_entitlements").upsert(
      {
        user_id: userId,
        is_pro: entitlement.valid,
        status: entitlement.status,
        current_period_end: entitlement.currentPeriodEnd,
        will_renew: entitlement.willRenew,
        provider: platform === "ios" ? "appstore" : "play",
        source: entitlement.debug ?? "store", // TEMP diagnostic; revert to 'store' once confirmed working
        updated_at: new Date().toISOString(),
      },
      { onConflict: "user_id" },
    );
    if (error) {
      console.error("[validate-purchase] DB upsert failed", error);
      return new Response(`DB error: ${error.message}`, { status: 500, headers: cors });
    }

    return new Response(JSON.stringify({
      is_pro: entitlement.valid,
      status: entitlement.status,
      current_period_end: entitlement.currentPeriodEnd,
      debug: entitlement.debug,
    }), {
      headers: { ...cors, "Content-Type": "application/json" },
    });
  } catch (e) {
    console.error("[validate-purchase] Unhandled error", e);
    return new Response(JSON.stringify({
      is_pro: false,
      error: e instanceof Error ? e.message : String(e),
    }), {
      status: 500,
      headers: { ...cors, "Content-Type": "application/json" },
    });
  }
});
