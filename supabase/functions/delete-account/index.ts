// delete-account
// Permanently deletes the calling user's auth account. All of the user's app
// data (profiles, tasks, subtasks, habits, sub_habits, goals, links, notes,
// note_tags, calendar_events, pro_entitlements) is removed automatically via the
// `on delete cascade` foreign keys to auth.users — so deleting the auth user is
// a complete account+data wipe.
//
// Auth: the client invokes this with the user's session JWT (functions.invoke
// attaches it). We re-derive the user from that JWT using the service role, so a
// caller can only ever delete their OWN account. No request body is trusted.
//
// Uses the platform-provided SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY secrets —
// no extra configuration needed.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });

  try {
    const jwt = (req.headers.get("Authorization") ?? "").replace("Bearer ", "").trim();
    if (!jwt) return json({ error: "Missing authorization" }, 401);

    const admin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // Identify the caller from their JWT — never from the request body.
    const { data, error } = await admin.auth.getUser(jwt);
    if (error || !data?.user) return json({ error: "Invalid or expired session" }, 401);

    const { error: delErr } = await admin.auth.admin.deleteUser(data.user.id);
    if (delErr) return json({ error: delErr.message }, 500);

    return json({ ok: true });
  } catch (err) {
    return json({ error: String(err) }, 500);
  }
});
