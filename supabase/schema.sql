-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- ========================
-- ENUMS
-- ========================
create type transaction_type as enum ('fee', 'data', 'airtime', 'transfer', 'deposit');
create type transaction_status as enum ('pending', 'success', 'failed');
create type notification_type as enum ('transfer', 'fee', 'data', 'airtime', 'deposit', 'system');
create type network_provider as enum ('mtn', 'airtel', 'glo', '9mobile', 'smile', 'swift');

-- ========================
-- USERS
-- ========================
create table users (
  id               uuid primary key default uuid_generate_v4(),
  email            text not null unique,
  full_name        text not null,
  matric_number    text unique,          -- null until profile is completed
  institution      text,                 -- null until profile is completed
  wallet_balance   numeric(12, 2) not null default 10000.00,
  transaction_pin  text,                 -- null until PIN is set
  created_at       timestamptz not null default now()
);

-- ========================
-- TRANSACTIONS
-- ========================
create table transactions (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid not null references users(id) on delete cascade,
  type        transaction_type not null,
  amount      numeric(12, 2) not null,
  status      transaction_status not null default 'pending',
  reference   text unique,
  description text,
  created_at  timestamptz not null default now()
);

create index idx_transactions_user_id on transactions(user_id);
create index idx_transactions_created_at on transactions(created_at desc);

-- ========================
-- FEE PAYMENTS
-- ========================
create table fee_payments (
  id               uuid primary key default uuid_generate_v4(),
  transaction_id   uuid not null unique references transactions(id) on delete cascade,
  rrr_number       text not null,
  institution_name text not null,
  fee_purpose      text,
  remita_response  jsonb
);

-- ========================
-- DATA PURCHASES
-- ========================
create table data_purchases (
  id               uuid primary key default uuid_generate_v4(),
  transaction_id   uuid not null unique references transactions(id) on delete cascade,
  network          text not null,
  phone_number     text not null,
  bundle_name      text not null,
  bundle_gb        numeric(5, 2) not null,
  mock_response    jsonb
);

-- ========================
-- TRANSFERS
-- ========================
create table transfers (
  id             uuid primary key default uuid_generate_v4(),
  transaction_id uuid not null unique references transactions(id) on delete cascade,
  sender_id      uuid not null references users(id),
  receiver_id    uuid not null references users(id),
  note           text,
  status         transaction_status not null default 'pending',
  constraint no_self_transfer check (sender_id != receiver_id)
);

create index idx_transfers_sender on transfers(sender_id);
create index idx_transfers_receiver on transfers(receiver_id);

-- ========================
-- AIRTIME PURCHASES
-- ========================
create table airtime_purchases (
  id               uuid primary key default uuid_generate_v4(),
  transaction_id   uuid not null unique references transactions(id) on delete cascade,
  network          network_provider not null,
  phone_number     text not null,
  amount           numeric(12, 2) not null,
  mock_response    jsonb
);

create index idx_airtime_transaction on airtime_purchases(transaction_id);

-- ========================
-- NOTIFICATIONS
-- ========================
create table notifications (
  id         uuid primary key default uuid_generate_v4(),
  user_id    uuid not null references users(id) on delete cascade,
  title      text not null,
  body       text not null,
  read       boolean not null default false,
  type       notification_type not null,
  created_at timestamptz not null default now()
);

create index idx_notifications_user_id on notifications(user_id);

-- ========================
-- RLS
-- ========================
alter table users               enable row level security;
alter table transactions        enable row level security;
alter table fee_payments        enable row level security;
alter table data_purchases      enable row level security;
alter table transfers           enable row level security;
alter table airtime_purchases   enable row level security;
alter table notifications       enable row level security;

-- users: own row only
create policy "users_select_own" on users
  for select using (auth.uid() = id);
create policy "users_update_own" on users
  for update using (auth.uid() = id);

-- Allow any authenticated user to search other users by email or matric number
-- (needed for transfer recipient lookup — only exposes id, full_name, email, matric, institution)
create policy "users_select_for_transfer_search" on users
  for select using (auth.uid() is not null);

-- transactions: own only
create policy "transactions_select_own" on transactions
  for select using (auth.uid() = user_id);
create policy "transactions_insert_own" on transactions
  for insert with check (auth.uid() = user_id);

-- fee_payments: via transaction ownership
create policy "fee_payments_select_own" on fee_payments
  for select using (
    exists (
      select 1 from transactions t
      where t.id = fee_payments.transaction_id
      and t.user_id = auth.uid()
    )
  );

-- data_purchases: via transaction ownership
create policy "data_purchases_select_own" on data_purchases
  for select using (
    exists (
      select 1 from transactions t
      where t.id = data_purchases.transaction_id
      and t.user_id = auth.uid()
    )
  );

-- transfers: sender OR receiver can see
create policy "transfers_select_own" on transfers
  for select using (
    auth.uid() = sender_id or auth.uid() = receiver_id
  );

-- airtime_purchases: via transaction ownership
create policy "airtime_purchases_select_own" on airtime_purchases
  for select using (
    exists (
      select 1 from transactions t
      where t.id = airtime_purchases.transaction_id
      and t.user_id = auth.uid()
    )
  );

-- notifications: own only
create policy "notifications_select_own" on notifications
  for select using (auth.uid() = user_id);
create policy "notifications_update_own" on notifications
  for update using (auth.uid() = user_id);

-- ========================
-- RPCs (Atomic)
-- ========================

-- 1. PROCESS TRANSFER
create or replace function process_transfer(
  p_sender_id uuid,
  p_receiver_id uuid,
  p_amount numeric,
  p_note text
) returns text
language plpgsql
security definer
as $$
declare
  v_sender_txn_id uuid;
  v_receiver_txn_id uuid;
  v_sender_name text;
begin
  -- 1. Check sender balance
  if (select wallet_balance from users where id = p_sender_id) < p_amount then
    raise exception 'Insufficient balance';
  end if;

  -- 2. Deduct from sender
  update users set wallet_balance = wallet_balance - p_amount where id = p_sender_id;

  -- 3. Add to receiver
  update users set wallet_balance = wallet_balance + p_amount where id = p_receiver_id;

  -- 4. Get sender name for notification
  select full_name into v_sender_name from users where id = p_sender_id;

  -- 5. Create dual transaction records
  insert into transactions (user_id, type, amount, status, description)
  values (p_sender_id, 'transfer', p_amount, 'success', 'Transfer to recipient')
  returning id into v_sender_txn_id;

  insert into transactions (user_id, type, amount, status, description)
  values (p_receiver_id, 'transfer', p_amount, 'success', 'Transfer from ' || v_sender_name)
  returning id into v_receiver_txn_id;

  -- 6. Log in transfers table
  insert into transfers (transaction_id, sender_id, receiver_id, note, status)
  values (v_sender_txn_id, p_sender_id, p_receiver_id, p_note, 'success');

  -- 7. Notifications
  insert into notifications (user_id, title, body, type)
  values (p_sender_id, 'Transfer Successful', 'You sent ₦' || p_amount::text || ' successfully', 'transfer');

  insert into notifications (user_id, title, body, type)
  values (p_receiver_id, 'Money Received', 'You received ₦' || p_amount::text || ' from ' || v_sender_name, 'transfer');

  return v_sender_txn_id::text;
end;
$$;

-- 2. FUND WALLET
create or replace function fund_wallet(
  p_user_id uuid,
  p_amount numeric
) returns uuid
language plpgsql
security definer
as $$
declare
  v_txn_id uuid;
begin
  -- 1. Update balance
  update users set wallet_balance = wallet_balance + p_amount where id = p_user_id;

  -- 2. Create transaction record
  insert into transactions (user_id, type, amount, status, description)
  values (p_user_id, 'deposit', p_amount, 'success', 'Wallet Funding')
  returning id into v_txn_id;

  -- 3. Notification
  insert into notifications (user_id, title, body, type)
  values (p_user_id, 'Wallet Funded', 'Your wallet has been credited with ₦' || p_amount::text, 'deposit');

  return v_txn_id;
end;
$$;

-- 3. PROCESS DATA PURCHASE
create or replace function process_data_purchase(
  p_user_id uuid,
  p_network text,
  p_phone text,
  p_bundle_name text,
  p_bundle_gb numeric,
  p_amount numeric
) returns uuid
language plpgsql
security definer
as $$
declare
  v_txn_id uuid;
begin
  -- 1. Check balance
  if (select wallet_balance from users where id = p_user_id) < p_amount then
    raise exception 'Insufficient balance';
  end if;

  -- 2. Deduct amount
  update users set wallet_balance = wallet_balance - p_amount where id = p_user_id;

  -- 3. Create transaction record
  insert into transactions (user_id, type, amount, status, description)
  values (p_user_id, 'data', p_amount, 'success', p_bundle_name || ' Data Purchase (' || p_phone || ')')
  returning id into v_txn_id;

  -- 4. Log in data_purchases table
  insert into data_purchases (transaction_id, network, phone_number, bundle_name, bundle_gb)
  values (v_txn_id, p_network, p_phone, p_bundle_name, p_bundle_gb);

  -- 5. Notification
  insert into notifications (user_id, title, body, type)
  values (p_user_id, 'Data Purchase', 'Successfully purchased ' || p_bundle_name || ' for ' || p_phone, 'data');

  return v_txn_id;
end;
$$;

-- 4. PROCESS AIRTIME PURCHASE
create or replace function process_airtime_purchase(
  p_user_id uuid,
  p_network network_provider,
  p_phone text,
  p_amount numeric
) returns uuid
language plpgsql
security definer
as $$
declare
  v_txn_id uuid;
begin
  -- 1. Check balance
  if (select wallet_balance from users where id = p_user_id) < p_amount then
    raise exception 'Insufficient balance';
  end if;

  -- 2. Deduct amount
  update users set wallet_balance = wallet_balance - p_amount where id = p_user_id;

  -- 3. Create transaction record
  insert into transactions (user_id, type, amount, status, description)
  values (p_user_id, 'airtime', p_amount, 'success', p_network::text || ' Airtime (' || p_phone || ')')
  returning id into v_txn_id;

  -- 4. Log in airtime_purchases table
  insert into airtime_purchases (transaction_id, network, phone_number, amount)
  values (v_txn_id, p_network, p_phone, p_amount);

  -- 5. Notification
  insert into notifications (user_id, title, body, type)
  values (p_user_id, 'Airtime Purchase', 'Successfully recharged ₦' || p_amount::text || ' on ' || p_phone, 'airtime');

  return v_txn_id;
end;
$$;

-- 5. PROCESS FEE PAYMENT
create or replace function process_fee_payment(
  p_user_id uuid,
  p_rrr_number text,
  p_institution text,
  p_fee_purpose text,
  p_amount numeric,
  p_remita_response jsonb
) returns uuid
language plpgsql
security definer
as $$
declare
  v_txn_id uuid;
begin
  -- 1. Check balance
  if (select wallet_balance from users where id = p_user_id) < p_amount then
    raise exception 'Insufficient balance';
  end if;

  -- 2. Deduct amount
  update users set wallet_balance = wallet_balance - p_amount where id = p_user_id;

  -- 3. Create transaction record
  insert into transactions (user_id, type, amount, status, reference, description)
  values (p_user_id, 'fee', p_amount, 'success', p_rrr_number, p_fee_purpose || ' - ' || p_institution)
  returning id into v_txn_id;

  -- 4. Log in fee_payments table
  insert into fee_payments (transaction_id, rrr_number, institution_name, fee_purpose, remita_response)
  values (v_txn_id, p_rrr_number, p_institution, p_fee_purpose, p_remita_response);

  -- 5. Notification
  insert into notifications (user_id, title, body, type)
  values (p_user_id, 'Fee Payment', 'Successfully paid ₦' || p_amount::text || ' for ' || p_fee_purpose, 'fee');

  return v_txn_id;
end;
$$;
