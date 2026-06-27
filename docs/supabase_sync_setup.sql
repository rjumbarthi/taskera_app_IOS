-- ─────────────────────────────────────────────────────────────────────────────
-- Kaal — Supabase setup for cross-device cloud sync
-- Run this ONCE in the Supabase SQL editor (Dashboard → SQL → New query).
-- It is required for the app changes shipped alongside it:
--   1. task labels now sync         → needs the `labels` column
--   2. realtime cross-device sync   → needs the realtime publication
--   3. realtime deletes by user     → needs REPLICA IDENTITY FULL
-- Safe to re-run (uses IF NOT EXISTS / idempotent statements).
-- ─────────────────────────────────────────────────────────────────────────────

-- 1) Task labels column (comma-separated, e.g. "work,health"). Without this,
--    pushing tasks fails server-side until the column exists.
alter table public.tasks add column if not exists labels text;

-- 2) Enable Postgres realtime so edits on one device stream to the others.
--    (Adding an already-present table errors, so guard each one.)
do $$
declare t text;
begin
  foreach t in array array['tasks','habits','goals','notes','calendar_events'] loop
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = t
    ) then
      execute format('alter publication supabase_realtime add table public.%I', t);
    end if;
  end loop;
end $$;

-- 3) REPLICA IDENTITY FULL so DELETE realtime payloads include user_id (needed
--    because the client subscribes with a user_id filter) and the row id.
alter table public.tasks            replica identity full;
alter table public.habits           replica identity full;
alter table public.goals            replica identity full;
alter table public.notes            replica identity full;
alter table public.calendar_events  replica identity full;

-- ── Web OAuth (do this in the Dashboard UI, not SQL) ─────────────────────────
-- Authentication → URL Configuration:
--   • Site URL: your deployed web origin (e.g. https://app.jumbarthi.com)
--   • Redirect URLs: add the same web origin (and any preview/staging origins).
-- The app sends redirectTo = the page origin on web automatically; Supabase
-- only honours origins that appear in this allow-list.
