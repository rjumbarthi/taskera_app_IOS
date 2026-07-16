# Remote feature flags (Gmail & Calendar on/off)

Gmail and Google Calendar are controlled by a Supabase table, so you can turn
them **on/off without shipping a new app build** — e.g. flip Gmail on the moment
Google OAuth verification + CASA clear. Both **default to OFF** (fail-closed), so
an un-verified OAuth scope is never exposed in production.

## 1. Create the table (once) — Supabase → SQL Editor

```sql
create table if not exists public.app_flags (
  key     text primary key,
  enabled boolean not null default false
);

alter table public.app_flags enable row level security;

-- Everyone (incl. anonymous) may READ flags:
drop policy if exists "read flags" on public.app_flags;
create policy "read flags" on public.app_flags for select using (true);

-- Seed every gated feature/integration OFF:
insert into public.app_flags (key, enabled) values
  ('gmail', false), ('calendar', false), ('microsoft', false),
  ('notion', false), ('todoist', false), ('slack', false),
  ('jira', false), ('asana', false), ('linear', false),
  ('teams', false), ('github', false),
  ('openai', false), ('anthropic', false)
on conflict (key) do nothing;
```

Already created the table with only some keys? This same INSERT is safe to
re-run — `on conflict do nothing` adds only the missing rows.

> `apple_reminders`, `outlook`, `icloud`, `sms` are intentionally omitted —
> they're unbuilt placeholders (no code), so a flag can't turn them on.

No insert/update policy = users can't change flags; only you (dashboard) can.

## 2. Turn a feature on / off

Supabase → Table editor → `app_flags` → set `enabled` to `true`/`false` for the
`gmail` or `calendar` row. Or SQL:

```sql
update public.app_flags set enabled = true  where key = 'calendar';  -- turn Calendar ON
update public.app_flags set enabled = false where key = 'gmail';     -- keep Gmail OFF
```

The app picks up the change on next launch/refresh — no rebuild, no store review.

## How it maps in the app
| Flag key | Controls | Scope | Notes |
|---|---|---|---|
| `gmail` | Gmail inbox (connect + parsing) | `gmail.readonly` (**restricted**) | Keep OFF until OAuth verification **+ CASA** clear. |
| `calendar` | Google Calendar sync | `calendar.readonly` (sensitive) | Turn ON once Calendar OAuth verification clears. |
| `microsoft` | Microsoft sign-in (sign-in/sign-up) | Azure OAuth | Turn ON once the Azure provider + client id are configured in Supabase. |
| `notion`, `todoist`, `slack`, `github` | Settings → Integrations rows | OAuth **with client secret** | ⚠️ Keep OFF until token exchange is moved to a backend proxy (client secret currently ships in the app — see SECURITY.md). |
| `jira`, `asana`, `linear`, `teams` | Settings → Integrations rows | OAuth (PKCE, no secret) | Turn ON once each provider's client id is configured. |
| `openai`, `anthropic` | Settings → Integrations (AI, bring-your-own-key) | none | Safe to turn ON anytime — the user pastes their own API key. |

### Adding new flags for future features
Any gated feature can read `ref.watch(featureEnabledProvider('<key>'))` (default
OFF). To make a *new* "coming soon" feature remotely switchable: (1) build the
feature, (2) gate its entry point on `featureEnabledProvider('<key>')`, (3)
`insert into public.app_flags (key, enabled) values ('<key>', false);`.

> Note: a flag only reveals a feature that **exists in code**. Placeholder
> "coming soon" items with no implementation yet (Apple sign-in, Outlook, iCloud,
> SMS, auto-sort, saved filters, etc.) must be built first — a flag alone can't
> turn them on.

- Code: `lib/data/providers/feature_flags_provider.dart` (`gmailEnabledProvider`,
  `calendarEnabledProvider`). When off, entry points show **"Soon"** / "Coming soon"
  and the OAuth connect is blocked.
- If Supabase is unreachable or the table is missing, both stay **off** (safe).

## Recommended launch sequence
1. Ship the production app now with both flags **OFF** (users see "Soon").
2. Get Calendar OAuth verified → set `calendar = true`.
3. Get Gmail OAuth verified **+ CASA** → set `gmail = true`.

No app update required for steps 2–3.
