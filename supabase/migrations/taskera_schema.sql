-- TaskEra schema, isolated inside Kaal's Supabase project (dutlcoxtxmnqektttffg).
-- Mirrors the combined state of Kaal's public/001-005 migrations, under its own
-- `taskera` schema so no tables, data, or policies are shared with `public`.
-- auth.users IS shared (one Supabase Auth per project) — see the two added
-- triggers at the bottom, which only add a taskera.profiles row and never
-- touch public.profiles or public's own trigger.
-- Idempotent: safe to re-run.

create schema if not exists taskera;

-- ── Profiles ──────────────────────────────────────────────────────────────────
create table if not exists taskera.profiles (
  id           uuid references auth.users(id) on delete cascade primary key,
  display_name text,
  avatar_url   text,
  created_at   timestamptz default now()
);

-- ── Tasks ─────────────────────────────────────────────────────────────────────
create table if not exists taskera.tasks (
  id               bigint primary key,
  user_id          uuid references auth.users(id) on delete cascade not null,
  title            text    not null,
  quadrant         int     not null check (quadrant between 1 and 4),
  due_date         timestamptz,
  due_label        text,
  is_overdue       boolean default false,
  has_ai           boolean default false,
  urgency_score    real,
  recurrence_label text,
  has_pomodoro     boolean default false,
  is_done          boolean default false,
  done_at          timestamptz,
  sort_order       int     default 0,
  labels           text,
  created_at       timestamptz default now(),
  updated_at       timestamptz default now()
);

create table if not exists taskera.subtasks (
  id         bigint primary key,
  user_id    uuid references auth.users(id) on delete cascade not null,
  task_id    bigint references taskera.tasks(id) on delete cascade not null,
  title      text    not null,
  is_done    boolean default false,
  sort_order int     default 0
);

-- ── Habits ────────────────────────────────────────────────────────────────────
create table if not exists taskera.habits (
  id                  bigint primary key,
  user_id             uuid references auth.users(id) on delete cascade not null,
  emoji               text    not null default '⭐',
  name                text    not null,
  frequency_label     text    not null default 'Daily',
  duration_minutes    int,
  quadrant            int     not null check (quadrant between 1 and 4),
  streak_label        text    not null default '0 days',
  streak_color_value  bigint  not null,
  accent_color_value  bigint  not null,
  weekly_filled_count int     not null default 0 check (weekly_filled_count between 0 and 7),
  sub_label           text,
  notes               text,
  created_at          timestamptz default now(),
  updated_at          timestamptz default now()
);

create table if not exists taskera.sub_habits (
  id         bigint primary key,
  user_id    uuid references auth.users(id) on delete cascade not null,
  habit_id   bigint references taskera.habits(id) on delete cascade not null,
  title      text    not null,
  is_done    boolean default false,
  sort_order int     default 0
);

-- ── Goals ─────────────────────────────────────────────────────────────────────
create table if not exists taskera.goals (
  id                  bigint primary key,
  user_id             uuid references auth.users(id) on delete cascade not null,
  emoji               text   not null default '🎯',
  emoji_bg            text   not null default '',
  title               text   not null,
  subtitle            text   not null default '',
  progress_pct        real   not null default 0.0 check (progress_pct between 0.0 and 1.0),
  accent_color_value  bigint not null,
  bar_color_value     bigint not null,
  border_color_value  bigint not null,
  linked_label        text   not null default '0 linked tasks',
  link_type           text   not null default 'task' check (link_type in ('task','habit')),
  dot_color_value     bigint not null,
  notes               text,
  created_at          timestamptz default now(),
  updated_at          timestamptz default now()
);

create table if not exists taskera.goal_task_links (
  goal_id bigint references taskera.goals(id) on delete cascade not null,
  task_id bigint references taskera.tasks(id) on delete cascade not null,
  primary key (goal_id, task_id)
);

create table if not exists taskera.goal_habit_links (
  goal_id  bigint references taskera.goals(id)  on delete cascade not null,
  habit_id bigint references taskera.habits(id) on delete cascade not null,
  primary key (goal_id, habit_id)
);

-- ── Notes ─────────────────────────────────────────────────────────────────────
create table if not exists taskera.notes (
  id         bigint primary key,
  user_id    uuid references auth.users(id) on delete cascade not null,
  title      text    not null,
  body       text    not null default '',
  is_pinned  boolean default false,
  ai_label   text,
  ai_summary text,
  time_label text    not null default 'now',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists taskera.note_tags (
  id             bigint primary key,
  user_id        uuid references auth.users(id) on delete cascade not null,
  note_id        bigint references taskera.notes(id) on delete cascade not null,
  label          text   not null,
  bg_color_value bigint not null,
  fg_color_value bigint not null,
  sort_order     int    default 0
);

-- ── Calendar events ───────────────────────────────────────────────────────────
create table if not exists taskera.calendar_events (
  id          bigint primary key,
  user_id     uuid references auth.users(id) on delete cascade not null,
  title       text   not null,
  subtitle    text   not null default '',
  time_slot   text   not null,
  color_value bigint not null,
  is_overdue  boolean default false,
  is_invite   boolean default false,
  event_date  date,
  external_id text,
  source      text default 'local' check (source in ('local','google','microsoft')),
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

-- ── Pro entitlement ───────────────────────────────────────────────────────────
create table if not exists taskera.pro_entitlements (
  user_id            uuid primary key references auth.users (id) on delete cascade,
  is_pro             boolean not null default false,
  provider           text,          -- 'razorpay' | 'play' | 'appstore'
  source             text,
  current_period_end timestamptz,
  status             text not null default 'expired',
  will_renew         boolean not null default false,
  updated_at         timestamptz not null default now()
);

comment on column taskera.pro_entitlements.status is
  'active | cancelled | grace_period | billing_retry | expired | revoked. '
  'cancelled/active/grace_period/billing_retry all still grant Pro while '
  'current_period_end (plus, for grace/retry, the store''s own grace window) '
  'is in the future.';

-- ── Admin-managed config (read-only to clients) ──────────────────────────────
create table if not exists taskera.announcements (
  id         bigint generated always as identity primary key,
  title      text not null,
  body       text not null,
  kind       text not null default 'update',
  created_at timestamptz not null default now(),
  published  boolean not null default true
);

create table if not exists taskera.app_flags (
  key     text primary key,
  enabled boolean not null default false
);

-- ── Row Level Security ────────────────────────────────────────────────────────
alter table taskera.profiles        enable row level security;
alter table taskera.tasks           enable row level security;
alter table taskera.subtasks        enable row level security;
alter table taskera.habits          enable row level security;
alter table taskera.sub_habits      enable row level security;
alter table taskera.goals           enable row level security;
alter table taskera.goal_task_links enable row level security;
alter table taskera.goal_habit_links enable row level security;
alter table taskera.notes           enable row level security;
alter table taskera.note_tags       enable row level security;
alter table taskera.calendar_events enable row level security;
alter table taskera.pro_entitlements enable row level security;
alter table taskera.announcements   enable row level security;
alter table taskera.app_flags       enable row level security;

drop policy if exists "own profile" on taskera.profiles;
create policy "own profile" on taskera.profiles for all
  using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists "own tasks" on taskera.tasks;
create policy "own tasks" on taskera.tasks for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "own subtasks" on taskera.subtasks;
create policy "own subtasks" on taskera.subtasks for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "own habits" on taskera.habits;
create policy "own habits" on taskera.habits for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "own sub_habits" on taskera.sub_habits;
create policy "own sub_habits" on taskera.sub_habits for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "own goals" on taskera.goals;
create policy "own goals" on taskera.goals for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "own goal_task_links" on taskera.goal_task_links;
create policy "own goal_task_links" on taskera.goal_task_links for all
  using (exists (select 1 from taskera.goals where id = goal_id and user_id = auth.uid()));
drop policy if exists "own goal_habit_links" on taskera.goal_habit_links;
create policy "own goal_habit_links" on taskera.goal_habit_links for all
  using (exists (select 1 from taskera.goals where id = goal_id and user_id = auth.uid()));
drop policy if exists "own notes" on taskera.notes;
create policy "own notes" on taskera.notes for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "own note_tags" on taskera.note_tags;
create policy "own note_tags" on taskera.note_tags for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "own calendar_events" on taskera.calendar_events;
create policy "own calendar_events" on taskera.calendar_events for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "read own entitlement" on taskera.pro_entitlements;
create policy "read own entitlement" on taskera.pro_entitlements
  for select using (auth.uid() = user_id);

drop policy if exists "read published announcements" on taskera.announcements;
create policy "read published announcements" on taskera.announcements
  for select using (published = true);

drop policy if exists "read flags" on taskera.app_flags;
create policy "read flags" on taskera.app_flags
  for select using (true);

-- ── Auto-create TaskEra profile on signup ────────────────────────────────────
-- Separate from Kaal's own public.handle_new_user()/on_auth_user_created — this
-- adds a second, independent trigger on auth.users. Both fire on every signup
-- (auth is shared), but each only ever writes to its own schema.
create or replace function taskera.handle_new_user()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  insert into taskera.profiles (id, display_name, avatar_url)
  values (
    new.id,
    coalesce(
      new.raw_user_meta_data ->> 'full_name',
      new.raw_user_meta_data ->> 'name',
      split_part(new.email, '@', 1)
    ),
    coalesce(
      new.raw_user_meta_data ->> 'avatar_url',
      new.raw_user_meta_data ->> 'picture'
    )
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_taskera on auth.users;
create trigger on_auth_user_created_taskera
  after insert on auth.users
  for each row execute procedure taskera.handle_new_user();

-- ── updated_at auto-stamp (own copy, no dependency on public's function) ────
create or replace function taskera.set_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end;
$$;

drop trigger if exists tasks_updated_at on taskera.tasks;
create trigger tasks_updated_at           before update on taskera.tasks           for each row execute procedure taskera.set_updated_at();
drop trigger if exists habits_updated_at on taskera.habits;
create trigger habits_updated_at          before update on taskera.habits          for each row execute procedure taskera.set_updated_at();
drop trigger if exists goals_updated_at on taskera.goals;
create trigger goals_updated_at           before update on taskera.goals           for each row execute procedure taskera.set_updated_at();
drop trigger if exists notes_updated_at on taskera.notes;
create trigger notes_updated_at           before update on taskera.notes           for each row execute procedure taskera.set_updated_at();
drop trigger if exists calendar_events_updated_at on taskera.calendar_events;
create trigger calendar_events_updated_at before update on taskera.calendar_events for each row execute procedure taskera.set_updated_at();

-- ── Realtime (cross-device sync) ──────────────────────────────────────────────
do $$
declare t text;
begin
  foreach t in array array['tasks','habits','goals','notes','calendar_events','pro_entitlements'] loop
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'taskera' and tablename = t
    ) then
      execute format('alter publication supabase_realtime add table taskera.%I', t);
    end if;
  end loop;
end $$;

alter table taskera.tasks           replica identity full;
alter table taskera.habits          replica identity full;
alter table taskera.goals           replica identity full;
alter table taskera.notes           replica identity full;
alter table taskera.calendar_events replica identity full;
