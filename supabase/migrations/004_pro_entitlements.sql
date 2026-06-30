-- 004_pro_entitlements.sql
-- Server-authoritative Kaal Pro entitlement. Written by the `razorpay-webhook`
-- edge function (and any future store receipt validator); the app reads its own
-- row to unlock Pro across devices. Idempotent — safe to re-run. Run after 001–003.

create table if not exists public.pro_entitlements (
  user_id            uuid primary key references auth.users (id) on delete cascade,
  is_pro             boolean not null default false,
  provider           text,          -- 'razorpay' | 'play' | 'appstore'
  source             text,          -- event/source that last changed it
  current_period_end timestamptz,
  updated_at         timestamptz not null default now()
);

alter table public.pro_entitlements enable row level security;

-- Users may READ their own entitlement; only the service role (edge functions)
-- may write it — so a client can never grant itself Pro.
drop policy if exists "read own entitlement" on public.pro_entitlements;
create policy "read own entitlement" on public.pro_entitlements
  for select using (auth.uid() = user_id);

-- Broadcast changes over realtime so a just-paid user unlocks Pro mid-session
-- (RLS still limits each client to its own row). Idempotent.
do $$
begin
  alter publication supabase_realtime add table public.pro_entitlements;
exception when others then null;
end $$;
