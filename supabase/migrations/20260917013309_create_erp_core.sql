create table public.customers (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null check (char_length(trim(name)) >= 2), phone text not null default '', email text not null default '',
  last_purchase_at timestamptz, total_spent numeric(12,2) not null default 0 check (total_spent >= 0),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.products (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null check (char_length(trim(name)) >= 2), category text not null default 'Sem categoria', sku text not null,
  quantity integer not null default 0 check (quantity >= 0), minimum_stock integer not null default 0 check (minimum_stock >= 0),
  price numeric(12,2) not null default 0 check (price >= 0), created_at timestamptz not null default now(), updated_at timestamptz not null default now(), unique (owner_id, sku)
);
create table public.inventory_movements (
  id uuid primary key default gen_random_uuid(), owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete restrict, kind text not null check (kind in ('IN', 'OUT', 'ADJUSTMENT')),
  quantity integer not null check (quantity <> 0), note text, created_at timestamptz not null default now()
);
create index customers_owner_name_idx on public.customers(owner_id, name);
create index products_owner_name_idx on public.products(owner_id, name);
create index inventory_movements_product_created_idx on public.inventory_movements(product_id, created_at desc);
create index inventory_movements_owner_created_idx on public.inventory_movements(owner_id, created_at desc);
alter table public.customers enable row level security;
alter table public.products enable row level security;
alter table public.inventory_movements enable row level security;
revoke all on public.customers, public.products, public.inventory_movements from anon;
grant select, insert, update, delete on public.customers, public.products, public.inventory_movements to authenticated;
create policy "customers are private to owner" on public.customers for all to authenticated using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
create policy "products are private to owner" on public.products for all to authenticated using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
create policy "inventory movements are private to owner" on public.inventory_movements for all to authenticated using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
create or replace function public.set_updated_at() returns trigger language plpgsql set search_path = '' as $$ begin new.updated_at = now(); return new; end; $$;
create trigger customers_set_updated_at before update on public.customers for each row execute function public.set_updated_at();
create trigger products_set_updated_at before update on public.products for each row execute function public.set_updated_at();
grant execute on function public.set_updated_at() to authenticated;
