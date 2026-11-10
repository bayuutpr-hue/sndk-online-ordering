-- SNDK Online Ordering: skema awal Supabase
-- Jalankan setelah membuat project Supabase. Jangan masukkan service_role key ke HTML.
create extension if not exists pgcrypto;

create table if not exists public.sndk_products (
  id bigint primary key,
  name text not null,
  price integer not null default 0 check (price >= 0),
  category text not null default 'Lainnya',
  emoji text default '🍽️',
  image_url text,
  option_group_ids bigint[] not null default '{}',
  is_available boolean not null default true,
  sort_order integer not null default 0,
  updated_at timestamptz not null default now()
);

create table if not exists public.sndk_option_groups (
  id bigint primary key,
  name text not null,
  options jsonb not null default '[]'::jsonb,
  required boolean not null default false,
  multiple boolean not null default false,
  updated_at timestamptz not null default now()
);

create table if not exists public.sndk_orders (
  id uuid primary key default gen_random_uuid(),
  order_code text unique not null,
  customer_name text not null,
  customer_phone text,
  order_type text not null check (order_type in ('Makan di tempat','Bawa pulang')),
  table_number text,
  payment_method text not null check (payment_method in ('Tunai','QRIS','Transfer bank')),
  payment_status text not null default 'Menunggu konfirmasi',
  order_status text not null default 'Pesanan baru',
  items jsonb not null,
  subtotal integer not null check (subtotal >= 0),
  notes text,
  source text not null default 'online',
  created_at timestamptz not null default now()
);

alter table public.sndk_products enable row level security;
alter table public.sndk_option_groups enable row level security;
alter table public.sndk_orders enable row level security;

-- Katalog bisa dibaca publik. Penulisan produk harus melalui akun admin terautentikasi.
drop policy if exists "Public can read available SNDK products" on public.sndk_products;
create policy "Public can read available SNDK products" on public.sndk_products
for select to anon, authenticated using (is_available = true);
drop policy if exists "Public can read SNDK option groups" on public.sndk_option_groups;
create policy "Public can read SNDK option groups" on public.sndk_option_groups
for select to anon, authenticated using (true);

-- Pelanggan dapat mengirim order; pembacaan/perubahan order hanya melalui admin terautentikasi.
drop policy if exists "Public can submit SNDK orders" on public.sndk_orders;
create policy "Public can submit SNDK orders" on public.sndk_orders
for insert to anon, authenticated with check (true);
drop policy if exists "Authenticated admin can read SNDK orders" on public.sndk_orders;
create policy "Authenticated admin can read SNDK orders" on public.sndk_orders
for select to authenticated using (true);
drop policy if exists "Authenticated admin can update SNDK orders" on public.sndk_orders;
create policy "Authenticated admin can update SNDK orders" on public.sndk_orders
for update to authenticated using (true) with check (true);

-- Catatan keamanan: sebelum produksi, batasi akses authenticated dengan role/admin claim.
-- Harga harus diverifikasi ulang di server/Edge Function saat order disimpan.
