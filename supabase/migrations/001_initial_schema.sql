-- Kaal — initial Supabase schema
-- Run via: supabase db push   (or paste into the SQL editor in the dashboard)

-- ── Extensions ────────────────────────────────────────────────────────────────
create extension if not exists "uuid-ossp";

-- ── Profiles ──────────────────────────────────────────────────────────────────
create table public.profiles (
  id           uuid references auth.users(id) on delete cascade primary key,
  display_name text,
  avatar_url   text,
  created_at   timestamptz default now()
);

-- ── Tasks ─────────────────────────────────────────────────────────────────────
create table public.tasks (
  id               bigint primary key,          -- same as Drift local ID
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
  created_at       timestamptz default now(),
  updated_at       timestamptz default now()
);

create table public.subtasks (
  id        bigint primary key,
  user_id   uuid references auth.users(id) on delete cascade not null,
  task_id   bigint references public.tasks(id) on delete cascade not null,
  title     text    not null,
  is_done   boolean default false,
  sort_order int    default 0
);

-- ── Habits ────────────────────────────────────────────────────────────────────
create table public.habits (
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
  created_at          timestamptz default now(),
  updated_at          timestamptz default now()
);

create table public.sub_habits (
  id         bigint primary key,
  user_id    uuid references auth.users(id) on delete cascade not null,
  habit_id   bigint references public.habits(id) on delete cascade not null,
  title      text    not null,
  is_done    boolean default false,
  sort_order int     default 0
);

-- ── Goals ─────────────────────────────────────────────────────────────────────
create table public.goals (
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
  created_at          timestamptz default now(),
  updated_at          timestamptz default now()
);

create table public.goal_task_links (
  goal_id bigint references public.goals(id) on delete cascade not null,
  task_id bigint references public.tasks(id) on delete cascade not null,
  primary key (goal_id, task_id)
);

create table public.goal_habit_links (
  goal_id  bigint references public.goals(id)  on delete cascade not null,
  habit_id bigint references public.habits(id) on delete cascade not null,
  primary key (goal_id, habit_id)
);

-- ── Notes ─────────────────────────────────────────────────────────────────────
create table public.notes (
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

create table public.note_tags (
  id             bigint primary key,
  user_id        uuid references auth.users(id) on delete cascade not null,
  note_id        bigint references public.notes(id) on delete cascade not null,
  label          text   not null,
  bg_color_value bigint not null,
  fg_color_value bigint not null,
  sort_order     int    default 0
);

-- ── Calendar events ───────────────────────────────────────────────────────────
create table public.calendar_events (
  id          bigint primary key,
  user_id     uuid references auth.users(id) on delete cascade not null,
  title       text   not null,
  subtitle    text   not null default '',
  time_slot   text   not null,
  color_value bigint not null,
  is_overdue  boolean default false,
  is_invite   boolean default false,
  event_date  date,
  external_id text,    -- Google / Microsoft event ID for dedup
  source      text default 'local' check (source in ('local','google','microsoft')),
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

-- ── Row Level Security ────────────────────────────────────────────────────────
alter table public.profiles        enable row level security;
alter table public.tasks           enable row level security;
alter table public.subtasks        enable row level security;
alter table public.habits          enable row level security;
alter table public.sub_habits      enable row level security;
alter table public.goals           enable row level security;
alter table public.goal_task_links enable row level security;
alter table public.goal_habit_links enable row level security;
alter table public.notes           enable row level security;
alter table public.note_tags       enable row level security;
alter table public.calendar_events enable row level security;

-- Profiles
create policy "own profile" on public.profiles for all
  using (auth.uid() = id) with check (auth.uid() = id);

-- All other tables: full CRUD for the owner
create policy "own tasks"           on public.tasks           for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own subtasks"        on public.subtasks        for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own habits"          on public.habits          for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own sub_habits"      on public.sub_habits      for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own goals"           on public.goals           for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own goal_task_links" on public.goal_task_links for all
  using  (exists (select 1 from public.goals where id = goal_id and user_id = auth.uid()));
create policy "own goal_habit_links" on public.goal_habit_links for all
  using  (exists (select 1 from public.goals where id = goal_id and user_id = auth.uid()));
create policy "own notes"           on public.notes           for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own note_tags"       on public.note_tags       for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own calendar_events" on public.calendar_events for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ── Auto-create profile on signup ─────────────────────────────────────────────
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name, avatar_url)
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
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ── updated_at auto-stamp ─────────────────────────────────────────────────────
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end;
$$;

create trigger tasks_updated_at           before update on public.tasks           for each row execute procedure public.set_updated_at();
create trigger habits_updated_at          before update on public.habits          for each row execute procedure public.set_updated_at();
create trigger goals_updated_at           before update on public.goals           for each row execute procedure public.set_updated_at();
create trigger notes_updated_at           before update on public.notes           for each row execute procedure public.set_updated_at();
create trigger calendar_events_updated_at before update on public.calendar_events for each row execute procedure public.set_updated_at();
