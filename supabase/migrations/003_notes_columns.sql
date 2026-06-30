-- 003_notes_columns.sql
-- Adds a freeform `notes` field to habits and goals (tasks already has one).
-- These power the unified Notes tab — notes written on a task/habit/goal are
-- surfaced there — and keep that text in sync across devices.
--
-- Idempotent: safe to run more than once. Run AFTER 001 + 002.

alter table public.habits add column if not exists notes text;
alter table public.goals  add column if not exists notes text;
