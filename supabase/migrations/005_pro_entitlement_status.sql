-- 005_pro_entitlement_status.sql
-- Adds real subscription-state tracking to pro_entitlements so a cancelled
-- subscription keeps Pro until its paid period actually ends, and so billing
-- retry / grace period can be told apart from a hard expiry or revoke.
-- Idempotent — safe to re-run. Run after 004.

alter table public.pro_entitlements
  add column if not exists status text not null default 'expired',
  -- 'active' | 'grace_period' | 'billing_retry' | 'expired' | 'revoked' | 'cancelled'
  -- ('cancelled' = user turned off auto-renew but the current period hasn't ended yet;
  --  still counts as Pro until current_period_end.)
  add column if not exists will_renew boolean not null default false;

comment on column public.pro_entitlements.status is
  'active | cancelled | grace_period | billing_retry | expired | revoked. '
  'cancelled/active/grace_period/billing_retry all still grant Pro while '
  'current_period_end (plus, for grace/retry, the store''s own grace window) '
  'is in the future.';
