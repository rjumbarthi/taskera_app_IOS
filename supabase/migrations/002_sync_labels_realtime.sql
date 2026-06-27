-- 002 — cross-device cloud sync: task labels + realtime
-- Apply via `supabase db push`, or paste into the SQL editor. Idempotent.
-- (Web OAuth needs a Dashboard change too — see docs/supabase_sync_setup.sql.)

-- Task labels (comma-separated, e.g. "work,health"). Required for label sync;
-- the app guards against its absence, but tasks won't carry labels until this
-- column exists.
alter table public.tasks add column if not exists labels text;

-- Stream row changes to other signed-in devices.
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

-- DELETE realtime payloads must include user_id (subscription is filtered by
-- it) and the row id.
alter table public.tasks            replica identity full;
alter table public.habits           replica identity full;
alter table public.goals            replica identity full;
alter table public.notes            replica identity full;
alter table public.calendar_events  replica identity full;
