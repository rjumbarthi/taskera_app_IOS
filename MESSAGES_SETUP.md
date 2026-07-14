# Messages / Announcements — setup

Settings → **Messages · What's New** shows broadcast announcements you post. It
works for **every** user (including anonymous "Skip — local storage" users),
because it's fetched with the public anon key. An unread badge shows on the
Settings row until the user opens the screen.

## 1. Create the table (once) — Supabase → SQL Editor

```sql
create table public.announcements (
  id         bigint generated always as identity primary key,
  title      text        not null,
  body       text        not null,
  kind       text        not null default 'update',   -- fix | feature | update | notice
  created_at timestamptz not null default now(),
  published  boolean     not null default true
);

alter table public.announcements enable row level security;

-- Everyone (incl. anonymous) may READ published announcements:
create policy "read published announcements"
  on public.announcements
  for select
  using (published = true);

-- No insert/update/delete policy = only you (via dashboard / service role)
-- can post. Users can never write.
```

## 2. Post a message

**Easiest — Supabase dashboard:** Table editor → `announcements` → **Insert row**.
Fill `title`, `body`, and pick a `kind`. Leave `published = true`.

**Or SQL:**
```sql
insert into public.announcements (title, body, kind) values
  ('Fixed the sync crash you reported', 'Notes now sync reliably on slow networks. Thanks for the report! 🙏', 'fix'),
  ('New: Databases', 'Table / board / list views are live under the Notes tab.', 'feature');
```

### `kind` values → badge shown in-app
| kind | badge | emoji |
|---|---|---|
| `fix` | Fixed | 🛠️ |
| `feature` | New | ✨ |
| `notice` | Notice | 📣 |
| `update` (default) | Update | 🔔 |

## 3. Hide / edit a message
- Hide: set `published = false` (it disappears for everyone).
- Edit: change `title`/`body` in the table editor.

## Notes
- Users see the newest 100 published messages, newest first.
- "Unread" = any message newer (higher `id`) than the last one the user opened;
  opening the Messages screen clears the badge (stored locally per device).
- **Future option:** targeted replies to a specific reporter (requires the user
  to be signed in). Ask and I can add a per-user `recipient_id` + RLS
  `auth.uid() = recipient_id` path alongside the broadcast feed.
```
