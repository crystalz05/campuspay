-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- ========================
-- ENUMS
-- ========================
create type transaction_type as enum ('fee', 'data', 'transfer', 'deposit');
create type transaction_status as enum ('pending', 'success', 'failed');
create type notification_type as enum ('transfer', 'fee', 'data', 'system');

-- ========================
-- USERS
-- ========================
create table users (
  id               uuid primary key default uuid_generate_v4(),
  email            text not null unique,
  full_name        text not null,
  matric_number    text not null unique,
  institution      text not null,
  wallet_balance   numeric(12, 2) not null default 10000.00,
  transaction_pin  text not null,
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
alter table users          enable row level security;
alter table transactions   enable row level security;
alter table fee_payments   enable row level security;
alter table data_purchases enable row level security;
alter table transfers      enable row level security;
alter table notifications  enable row level security;

-- users: own row only
create policy "users_select_own" on users
  for select using (auth.uid() = id);
create policy "users_update_own" on users
  for update using (auth.uid() = id);

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
create policy "fee_payments_insert_own" on fee_payments
  for insert with check (
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
create policy "data_purchases_insert_own" on data_purchases
  for insert with check (
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
create policy "transfers_insert_sender" on transfers
  for insert with check (auth.uid() = sender_id);

-- notifications: own only
create policy "notifications_select_own" on notifications
  for select using (auth.uid() = user_id);
create policy "notifications_update_own" on notifications
  for update using (auth.uid() = user_id);
create policy "notifications_insert_own" on notifications
  for insert with check (auth.uid() = user_id);

-- ========================
-- TRANSFER RPC (atomic)
-- ========================
create or replace function process_transfer(
  p_sender_id    uuid,
  p_receiver_id  uuid,
  p_amount       numeric,
  p_note         text default null
)
returns uuid
language plpgsql
security definer
as $$
declare
  v_sender_balance  numeric;
  v_transaction_id  uuid;
  v_transfer_id     uuid;
begin
  -- Lock sender row and check balance
  select wallet_balance into v_sender_balance
  from users
  where id = p_sender_id
  for update;

  if v_sender_balance < p_amount then
    raise exception 'Insufficient balance';
  end if;

  -- Debit sender
  update users set wallet_balance = wallet_balance - p_amount
  where id = p_sender_id;

  -- Credit receiver
  update users set wallet_balance = wallet_balance + p_amount
  where id = p_receiver_id;

  -- Create transaction record for sender
  insert into transactions (user_id, type, amount, status, description)
  values (p_sender_id, 'transfer', p_amount, 'success', 'Transfer sent')
  returning id into v_transaction_id;

  -- Create transfer record
  insert into transfers (transaction_id, sender_id, receiver_id, note, status)
  values (v_transaction_id, p_sender_id, p_receiver_id, p_note, 'success')
  returning id into v_transfer_id;

  -- Notification for receiver
  insert into notifications (user_id, title, body, type)
  values (
    p_receiver_id,
    'Money Received',
    'You received ₦' || p_amount::text || ' from a CampusPay user',
    'transfer'
  );

  return v_transaction_id;
end;
$$;
