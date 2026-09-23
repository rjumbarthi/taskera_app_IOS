# Supabase backend

Cloud backend for TaskEra — the shared source of truth that syncs tasks, habits,
goals, notes and calendar events across Android, iOS, Windows and Web.

```
supabase/
├── functions/ai-proxy/        Edge function proxying Claude/OpenAI (AI features)
└── migrations/
    ├── 001_initial_schema.sql      Tables + RLS
    └── 002_sync_labels_realtime.sql Task labels + realtime + replica identity
```

Project ref: `dutlcoxtxmnqekttffg` (public identifier, decoded from the anon key).

## Applying migrations

Apply migrations **in order**: `001` (creates the tables, RLS, policies,
triggers) **then** `002` (labels + realtime). Both are idempotent — safe to
re-run. If `001` was never applied, sync silently does nothing (every push/pull
hits a missing table), so a brand-new project must run `001` first.

A migration must be applied **before** the matching app build relies on it.
For `002`, the app guards against the missing `labels` column, but realtime and
label sync stay off until it runs.

### Option A — SQL editor (no install)
1. Open <https://supabase.com/dashboard/project/dutlcoxtxmnqekttffg/sql/new>
2. Paste the migration's SQL (e.g. `migrations/002_sync_labels_realtime.sql`)
   and **Run**. All migrations here are idempotent — safe to re-run.

### Option B — Supabase CLI
```bash
npm i -g supabase            # or: scoop install supabase / brew install supabase
supabase login               # interactive — opens the browser for your token
supabase link --project-ref dutlcoxtxmnqekttffg
supabase db push             # applies any un-applied migrations
```

> Never commit or paste the **service-role key** or **DB password**. The app
> only ships the public **anon** key (`lib/config/app_config.dart`), which
> cannot run DDL — schema changes need the SQL editor or CLI above.

## Web OAuth (Dashboard, not SQL)
Authentication → URL Configuration:
- **Site URL**: deployed web origin (e.g. `https://app.jumbarthi.com`)
- **Redirect URLs**: add that origin (+ any staging origins).

The app sends `redirectTo = page origin` on web automatically; Supabase only
honours origins in this allow-list. (See `docs/supabase_sync_setup.sql`.)

## Verifying cross-device sync
1. Apply `002` (above).
2. `flutter run` on two devices signed into the **same** account.
3. Console should log `[TaskEra sync] realtime SUBSCRIBED` on both (debug builds).
4. Create/edit/delete a task on one → `[TaskEra sync] tasks …` fires on the other
   within ~1 s and the UI updates live.
5. `CHANNEL_ERROR` instead → the realtime publication or RLS isn't set up;
   re-check that `002` ran.
