// Supabase Edge Function — validate-purchase
//
// The app calls this after a Play/App Store purchase (with the buyer's Supabase
// JWT). We derive the user from the JWT (so the client can't spoof who to grant),
// verify the receipt/token with the store, then upsert public.pro_entitlements.
// The realtime subscription on that row unlocks Pro in the app.
//
// Deploy:  supabase functions deploy validate-purchase
// Secrets: supabase secrets set APPLE_SHARED_SECRET=...           (App Store)
//          supabase secrets set GOOGLE_PLAY_SERVICE_ACCOUNT='{...}' (Play, JSON)
//
// NOTE: iOS uses the legacy verifyReceipt endpoint (works; for production prefer
// the App Store Server API). ANDROID VALIDATION IS A SCAFFOLD — wire the Google
// Play Developer API (androidpublisher purchases.subscriptions.get) before
// going live; until then it grants optimistically and logs a warning.

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
  currentPeriodEnd: string | null; // ISO
  willRenew: boolean;
}

const EXPIRED: Entitlement = { valid: false, status: "expired", currentPeriodEnd: null, willRenew: false };

// iOS — App Store verifyReceipt (auto sandbox fallback on 21007). Reads
// latest_receipt_info + pending_renewal_info so a cancelled subscription still
// grants Pro until its paid period actually ends, and grace/billing-retry are
// distinguishable from a hard expiry.
async function verifyApple(receipt: string, productId: string): Promise<Entitlement> {
  const password = Deno.env.get("APPLE_SHARED_SECRET") ?? "";
  const body = JSON.stringify({
    "receipt-data": receipt,
    password,
    "exclude-old-transactions": true,
  });
  let res = await fetch("https://buy.itunes.apple.com/verifyReceipt", { method: "POST", body });
  let json = await res.json();
  if (json.status === 21007) {
    res = await fetch("https://sandbox.itunes.apple.com/verifyReceipt", { method: "POST", body });
    json = await res.json();
  }
  if (json.status !== 0) return EXPIRED;

  const infos: any[] = json.latest_receipt_info ?? [];
  // Latest transaction for this product (or the most recent overall as a fallback).
  const matching = infos.filter((i) => !productId || i.product_id === productId);
  const pool = matching.length ? matching : infos;
  const latest = pool.reduce((a, b) =>
    Number(a?.expires_date_ms ?? 0) > Number(b?.expires_date_ms ?? 0) ? a : b, pool[0]);
  if (!latest) return EXPIRED;

  const expiresMs = Number(latest.expires_date_ms ?? 0);
  const expired = expiresMs > 0 && expiresMs <= Date.now();

  const renewalInfos: any[] = json.pending_renewal_info ?? [];
  const renewal = renewalInfos.find((r) => r.product_id === latest.product_id) ?? renewalInfos[0];
  const willRenew = renewal?.auto_renew_status === "1";
  const inBillingRetry = renewal?.is_in_billing_retry_period === "1";
  const inGrace = expired && inBillingRetry; // Apple grace period surfaces as billing-retry + not-yet-expired-for-access

  if (expired && !inGrace) {
    return { valid: false, status: "expired", currentPeriodEnd: new Date(expiresMs).toISOString(), willRenew };
  }
  return {
    valid: true,
    status: inBillingRetry ? "billing_retry" : willRenew ? "active" : "cancelled",
    currentPeriodEnd: new Date(expiresMs).toISOString(),
    willRenew,
  };
}

function b64url(s: string): string {
  return btoa(s).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}
function b64urlBytes(bytes: Uint8Array): string {
  let s = "";
  for (const b of bytes) s += String.fromCharCode(b);
  return b64url(s);
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
async function verifyAndroid(productId: string, token: string): Promise<Entitlement> {
  const saRaw = Deno.env.get("GOOGLE_PLAY_SERVICE_ACCOUNT");
  if (!saRaw) {
    console.warn("[validate-purchase] Play service account not set — granting optimistically (UNVERIFIED)");
    // Fallback until the secret is configured. No real expiry known, so don't
    // pretend to have one — the client should re-validate once this is wired up.
    return { valid: true, status: "active", currentPeriodEnd: null, willRenew: true };
  }
  try {
    const sa = JSON.parse(saRaw);
    const pkg = Deno.env.get("ANDROID_PACKAGE") ?? "com.port443.kaal";
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
    // paymentState: 0=pending, 1=received, 2=free trial, 3=pending deferred upgrade/downgrade.
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

  // Identify the user from their JWT — never trust a client-sent user id.
  const authHeader = req.headers.get("Authorization") ?? "";
  const jwt = authHeader.replace("Bearer ", "");
  const { data: userData } = await admin.auth.getUser(jwt);
  const userId = userData?.user?.id;
  if (!userId) return new Response("Unauthorized", { status: 401, headers: cors });

  let payload: { platform?: string; productId?: string; token?: string };
  try {
    payload = await req.json();
  } catch {
    return new Response("Bad JSON", { status: 400, headers: cors });
  }
  const { platform, productId, token } = payload;
  if (!platform || !token) return new Response("Missing fields", { status: 400, headers: cors });

  const entitlement = platform === "ios"
    ? await verifyApple(token, productId ?? "")
    : await verifyAndroid(productId ?? "", token);

  const { error } = await admin.from("pro_entitlements").upsert(
    {
      user_id: userId,
      is_pro: entitlement.valid,
      status: entitlement.status,
      current_period_end: entitlement.currentPeriodEnd,
      will_renew: entitlement.willRenew,
      provider: platform === "ios" ? "appstore" : "play",
      source: "store",
      updated_at: new Date().toISOString(),
    },
    { onConflict: "user_id" },
  );
  if (error) return new Response(`DB error: ${error.message}`, { status: 500, headers: cors });

  return new Response(JSON.stringify({
    is_pro: entitlement.valid,
    status: entitlement.status,
    current_period_end: entitlement.currentPeriodEnd,
  }), {
    headers: { ...cors, "Content-Type": "application/json" },
  });
});
