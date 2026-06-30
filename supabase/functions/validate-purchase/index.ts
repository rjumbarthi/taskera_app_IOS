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

// Android — TODO: verify with Google Play Developer API using the service account.
async function verifyAndroid(_productId: string, _token: string): Promise<boolean> {
  const sa = Deno.env.get("GOOGLE_PLAY_SERVICE_ACCOUNT");
  if (!sa) {
    console.warn("[validate-purchase] Android receipt NOT verified — Play service account not configured");
    return true; // SCAFFOLD: grant optimistically until the Play API is wired
  }
  // TODO: mint a JWT from the service account, exchange for an access token, then
  // GET androidpublisher/v3/applications/<pkg>/purchases/subscriptions/<id>/tokens/<token>
  // and check paymentState/expiryTimeMillis. Returning false here forces the
  // client optimistic fallback until implemented.
  return false;
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
