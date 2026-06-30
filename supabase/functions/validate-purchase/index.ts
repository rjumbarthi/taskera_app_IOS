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

// iOS — App Store verifyReceipt (auto sandbox fallback on 21007).
async function verifyApple(receipt: string): Promise<boolean> {
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
  return json.status === 0; // 0 = valid receipt
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
async function verifyAndroid(productId: string, token: string): Promise<boolean> {
  const saRaw = Deno.env.get("GOOGLE_PLAY_SERVICE_ACCOUNT");
  if (!saRaw) {
    console.warn("[validate-purchase] Play service account not set — granting optimistically (UNVERIFIED)");
    return true; // fallback until the secret is configured
  }
  try {
    const sa = JSON.parse(saRaw);
    const pkg = Deno.env.get("ANDROID_PACKAGE") ?? "com.port443.kaal";
    const accessToken = await googleAccessToken(sa);
    const url =
      `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${pkg}` +
      `/purchases/subscriptions/${productId}/tokens/${token}`;
    const res = await fetch(url, { headers: { Authorization: `Bearer ${accessToken}` } });
    if (!res.ok) return false;
    const sub = await res.json();
    // paymentState 1=received, 2=free trial; active while not expired.
    const paid = sub.paymentState === 1 || sub.paymentState === 2;
    return paid && Number(sub.expiryTimeMillis ?? 0) > Date.now();
  } catch (e) {
    console.error("[validate-purchase] Android verify failed", e);
    return false;
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

  const valid = platform === "ios"
    ? await verifyApple(token)
    : await verifyAndroid(productId ?? "", token);

  if (!valid) {
    return new Response(JSON.stringify({ is_pro: false }), {
      status: 200,
      headers: { ...cors, "Content-Type": "application/json" },
    });
  }

  const { error } = await admin.from("pro_entitlements").upsert(
    {
      user_id: userId,
      is_pro: true,
      provider: platform === "ios" ? "appstore" : "play",
      source: "store",
      updated_at: new Date().toISOString(),
    },
    { onConflict: "user_id" },
  );
  if (error) return new Response(`DB error: ${error.message}`, { status: 500, headers: cors });

  return new Response(JSON.stringify({ is_pro: true }), {
    headers: { ...cors, "Content-Type": "application/json" },
  });
});
