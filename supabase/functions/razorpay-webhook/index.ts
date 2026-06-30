// Supabase Edge Function — razorpay-webhook
//
// Verifies the Razorpay webhook signature and grants / revokes Kaal Pro by
// upserting public.pro_entitlements (server-authoritative; the app reads its
// own row to unlock Pro across devices).
//
// Deploy:  supabase functions deploy razorpay-webhook --no-verify-jwt
//          (--no-verify-jwt because Razorpay doesn't send a Supabase JWT)
// Secret:  supabase secrets set RAZORPAY_WEBHOOK_SECRET=whsec_...
//          (SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY are injected automatically)
//
// Razorpay Dashboard → Settings → Webhooks: add this function's URL, set the
// SAME secret, and subscribe to: payment.captured, subscription.activated,
// subscription.charged, subscription.cancelled, subscription.completed.
//
// IMPORTANT: when you create the Payment Link / Checkout from the app, pass the
// Supabase user id in `notes.user_id` so this function knows who to grant.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const secret = Deno.env.get("RAZORPAY_WEBHOOK_SECRET") ?? "";
const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

// HMAC-SHA256(rawBody, secret), compared (length-safe) to x-razorpay-signature.
async function verifySignature(body: string, signature: string): Promise<boolean> {
  if (!secret || !signature) return false;
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const mac = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(body));
  const hex = Array.from(new Uint8Array(mac))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
  if (hex.length !== signature.length) return false;
  let diff = 0;
  for (let i = 0; i < hex.length; i++) diff |= hex.charCodeAt(i) ^ signature.charCodeAt(i);
  return diff === 0;
}

const GRANT = new Set([
  "payment.captured",
  "subscription.activated",
  "subscription.charged",
  "subscription.resumed",
]);
const REVOKE = new Set([
  "subscription.cancelled",
  "subscription.halted",
  "subscription.paused",
  "subscription.completed",
]);

Deno.serve(async (req) => {
  if (req.method !== "POST") return new Response("Method not allowed", { status: 405 });

  const raw = await req.text();
  const signature = req.headers.get("x-razorpay-signature") ?? "";
  if (!(await verifySignature(raw, signature))) {
    return new Response("Invalid signature", { status: 401 });
  }

  let event: any;
  try {
    event = JSON.parse(raw);
  } catch {
    return new Response("Bad JSON", { status: 400 });
  }

  const type = event.event as string;
  const payment = event?.payload?.payment?.entity;
  const subscription = event?.payload?.subscription?.entity;
  const notes = payment?.notes ?? subscription?.notes ?? {};
  const userId = notes.user_id as string | undefined;

  // Ack (200) even when we can't act, so Razorpay stops retrying.
  if (!userId || (!GRANT.has(type) && !REVOKE.has(type))) {
    return new Response(JSON.stringify({ ok: true, skipped: type }), {
      headers: { "Content-Type": "application/json" },
    });
  }

  const grant = GRANT.has(type);
  const { error } = await supabase.from("pro_entitlements").upsert(
    {
      user_id: userId,
      is_pro: grant,
      provider: "razorpay",
      source: type,
      updated_at: new Date().toISOString(),
    },
    { onConflict: "user_id" },
  );
  if (error) return new Response(`DB error: ${error.message}`, { status: 500 });

  return new Response(JSON.stringify({ ok: true, is_pro: grant }), {
    headers: { "Content-Type": "application/json" },
  });
});
