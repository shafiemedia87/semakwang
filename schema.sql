-- ============================================================
-- Buku Wang — skema Supabase
-- Jalankan fail ini dalam Supabase Dashboard -> SQL Editor -> New query -> Run
-- ============================================================

create extension if not exists "pgcrypto";

-- 1) Satu baris "config" bagi setiap pengguna: profil gaji, akaun,
--    komitmen, hutang, sasaran simpanan — semua disimpan sebagai JSONB
--    (struktur sama macam yang app guna, senang untuk sync).
create table if not exists public.finance_config (
  user_id     uuid primary key references auth.users(id) on delete cascade,
  profile     jsonb not null default '{"salaryAmount":0,"salaryDay":28,"defaultAccountId":null}'::jsonb,
  accounts    jsonb not null default '[]'::jsonb,
  commitments jsonb not null default '[]'::jsonb,
  debts       jsonb not null default '[]'::jsonb,
  savings     jsonb not null default '[]'::jsonb,
  updated_at  timestamptz not null default now()
);

alter table public.finance_config enable row level security;

drop policy if exists "select own config" on public.finance_config;
create policy "select own config" on public.finance_config
  for select using (auth.uid() = user_id);

drop policy if exists "insert own config" on public.finance_config;
create policy "insert own config" on public.finance_config
  for insert with check (auth.uid() = user_id);

drop policy if exists "update own config" on public.finance_config;
create policy "update own config" on public.finance_config
  for update using (auth.uid() = user_id);

-- 2) Log transaksi — satu baris bagi setiap pergerakan wang.
create table if not exists public.transactions (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users(id) on delete cascade,
  date          date not null,
  type          text not null check (type in ('income','expense','transfer','debt_payment','debt_new','saving_add','saving_use')),
  amount        numeric not null check (amount > 0),
  account_id    text,
  to_account_id text,
  ref_id        text,
  category      text,
  note          text,
  created_at    timestamptz not null default now()
);

alter table public.transactions enable row level security;

drop policy if exists "select own transactions" on public.transactions;
create policy "select own transactions" on public.transactions
  for select using (auth.uid() = user_id);

drop policy if exists "insert own transactions" on public.transactions;
create policy "insert own transactions" on public.transactions
  for insert with check (auth.uid() = user_id);

drop policy if exists "delete own transactions" on public.transactions;
create policy "delete own transactions" on public.transactions
  for delete using (auth.uid() = user_id);

create index if not exists transactions_user_created_idx
  on public.transactions (user_id, created_at desc);

-- 3) Aktifkan Realtime supaya perubahan disegerak automatik antara peranti/tab.
--    (Boleh juga aktifkan ini melalui Dashboard -> Database -> Replication -> UI toggle
--    untuk jadual finance_config dan transactions, sebagai alternatif kepada arahan di bawah.)
alter publication supabase_realtime add table public.finance_config;
alter publication supabase_realtime add table public.transactions;
