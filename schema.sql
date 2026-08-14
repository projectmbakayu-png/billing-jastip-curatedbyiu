-- =============================================
-- BILLING JASTIP — Schema Supabase
-- Jalankan SEKALI di SQL Editor Supabase
-- =============================================

-- Drop tabel lama jika ada
drop table if exists payments cascade;
drop table if exists orders cascade;
drop table if exists customers cascade;
drop table if exists history cascade;

-- Tabel pelanggan
create table customers (
  hp    text primary key,  -- no HP apa adanya dari Excel
  nama  text default '',
  kota  text default '',
  note  text default '',
  created_at timestamptz default now()
);

-- Tabel orders (1 baris per pelanggan / no HP)
create table orders (
  hp           text primary key,  -- no HP = primary key, persis dari Excel
  nama_pelanggan text default '',
  items        jsonb  default '[]',   -- array semua item (termasuk WL)
  total_tagihan numeric default 0,    -- total item BELUM LUNAS saja
  status       text   default 'BELUM LUNAS', -- BELUM LUNAS / LUNAS / WL
  created_at   timestamptz default now(),
  updated_at   timestamptz default now()
);

-- Tabel pembayaran
create table payments (
  id         uuid primary key default gen_random_uuid(),
  hp         text references orders(hp) on delete cascade,
  jumlah     numeric not null,
  metode     text default 'Transfer BCA',
  catatan    text default '',
  tgl        date default current_date,
  created_at timestamptz default now()
);

-- Tabel history (log tagihan terkirim & perubahan)
create table history (
  id         uuid primary key default gen_random_uuid(),
  hp         text,
  pelanggan  text,
  aksi       text,
  detail     text,
  created_at timestamptz default now()
);

-- RLS: izinkan semua via anon key
alter table customers enable row level security;
alter table orders    enable row level security;
alter table payments  enable row level security;
alter table history   enable row level security;

create policy "all_customers" on customers for all using (true) with check (true);
create policy "all_orders"    on orders    for all using (true) with check (true);
create policy "all_payments"  on payments  for all using (true) with check (true);
create policy "all_history"   on history   for all using (true) with check (true);
