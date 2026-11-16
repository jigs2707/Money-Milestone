-- Money Milestone – Supabase schema
-- Run this in the Supabase SQL editor to set up all tables.
-- After running, enable Realtime replication for:
--   users, goals, transactions, categories
-- (Database → Replication → toggle each table on)

create table if not exists public.users (
  id            text primary key,          -- Firebase Auth UID
  name          text,
  currency_code text not null default 'USD',
  current_streak  integer not null default 0,
  longest_streak  integer not null default 0,
  last_deposit_date text,
  fcm_token       text,                    -- device push token, set on app open
  fcm_updated_at  timestamptz,
  date_format     text not null default 'dd/MM/yyyy'  -- display only; storage stays yyyy-MM-dd
);

-- Existing databases: create table if not exists won't add the columns above.
alter table public.users add column if not exists fcm_token text;
alter table public.users add column if not exists fcm_updated_at timestamptz;
alter table public.users add column if not exists date_format text not null default 'dd/MM/yyyy';

create table if not exists public.goals (
  id                uuid primary key default gen_random_uuid(),
  user_id           text not null references public.users(id) on delete cascade,
  goal_name         text,
  goal_amount       text,
  goal_date         text,
  goal_saved_amount text,
  category_id       text,
  created_at        timestamptz not null default now()
);

create table if not exists public.transactions (
  id     uuid primary key default gen_random_uuid(),
  user_id text not null references public.users(id) on delete cascade,
  goal_id uuid not null references public.goals(id) on delete cascade,
  amount text,
  date   text,
  note   text,
  type   text,
  created_at timestamptz not null default now()
);

create table if not exists public.categories (
  id          uuid primary key default gen_random_uuid(),
  user_id     text not null references public.users(id) on delete cascade,
  name        text,
  code_point  integer,
  font_family text default 'MaterialIcons',
  color_value integer,
  is_custom   boolean default true
);

create table if not exists public.app_config (
  id               text primary key default 'version',
  latest_version   text,
  is_force_update  boolean not null default false,
  store_url        text
);

create table if not exists public.app_sessions (
  id         uuid primary key default gen_random_uuid(),
  user_id    text not null,
  opened_at  timestamptz not null default now(),
  date       text,
  type       text,
  platform   text
);

create table if not exists public.user_badges (
  user_id    text not null references public.users(id) on delete cascade,
  badge_key  text not null,
  unlocked_at timestamptz not null default now(),
  primary key (user_id, badge_key)
);

-- Realtime DELETE events
-- Supabase evaluates a stream's filter against the row's OLD image. Under the
-- default replica identity that image contains only the primary key, so a
-- stream filtered on any other column never receives the delete and the row
-- lingers in the UI until a reload. FULL puts every column in the old image.
-- Needed by: goals (.eq user_id), transactions (.eq goal_id), categories (.eq user_id).
-- users is streamed by its primary key, so it does not need this.
alter table public.goals        replica identity full;
alter table public.transactions replica identity full;
alter table public.categories   replica identity full;

-- Insert a default app_config row (update values as needed)
insert into public.app_config (id, latest_version, is_force_update, store_url)
values ('version', '1.1.0', false, 'https://play.google.com/store/apps/details?id=com.myfinancial.goal')
on conflict (id) do nothing;
