-- ===========================================================
-- Migration: Fix Transfer-related RLS and process_transfer RPC
-- Run this in your Supabase SQL Editor
-- ===========================================================

-- 1. Allow authenticated users to read other users' public info
--    (required for recipient lookup in transfer flow)
drop policy if exists "users_select_for_transfer_search" on public.users;
create policy "users_select_for_transfer_search" on public.users
  for select using (auth.uid() is not null);

-- 2. Update process_transfer:
--    - Returns text (UUID serialized as string) so Flutter can safely call .toString()
--    - Creates a transaction record for BOTH sender and receiver so both have history
--    - Transfer record links to the sender's transaction_id (the debit leg)
create or replace function public.process_transfer(
  p_sender_id   uuid,
  p_receiver_id uuid,
  p_amount      numeric,
  p_note        text default null
)
returns text
language plpgsql
security definer
as $$
declare
  v_sender_balance    numeric;
  v_sender_txn_id     uuid;
  v_receiver_txn_id   uuid;
begin
  -- Lock sender row and check balance
  select wallet_balance into v_sender_balance
  from public.users
  where id = p_sender_id
  for update;

  if v_sender_balance < p_amount then
    raise exception 'Insufficient balance';
  end if;

  -- Debit sender
  update public.users set wallet_balance = wallet_balance - p_amount
  where id = p_sender_id;

  -- Credit receiver
  update public.users set wallet_balance = wallet_balance + p_amount
  where id = p_receiver_id;

  -- Transaction record for sender (debit)
  insert into public.transactions (user_id, type, amount, status, description)
  values (p_sender_id, 'transfer', p_amount, 'success', 'Transfer sent')
  returning id into v_sender_txn_id;

  -- Transaction record for receiver (credit)
  insert into public.transactions (user_id, type, amount, status, description)
  values (p_receiver_id, 'transfer', p_amount, 'success', 'Transfer received')
  returning id into v_receiver_txn_id;

  -- Transfer record linking both (anchored to sender's transaction_id)
  insert into public.transfers (transaction_id, sender_id, receiver_id, note, status)
  values (v_sender_txn_id, p_sender_id, p_receiver_id, p_note, 'success');

  -- Notification for receiver
  insert into public.notifications (user_id, title, body, type)
  values (
    p_receiver_id,
    'Money Received',
    'You received ₦' || p_amount::text || ' from a CampusPay user',
    'transfer'
  );

  return v_sender_txn_id::text;
end;
$$;
