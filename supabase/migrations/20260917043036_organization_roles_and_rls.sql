-- Multi-tenant foundation. Existing ERP rows are retained and attached to Tabacaria Uai.
create schema if not exists private;

create type public.app_role as enum ('ADMIN', 'OPERADOR');

create table public.organizations (
  id uuid primary key default extensions.gen_random_uuid(),
  name text not null,
  slug text not null unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

insert into public.organizations (name, slug)
values ('Tabacaria Uai', 'tabacaria-uai')
on conflict (slug) do nothing;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.organization_memberships (
  organization_id uuid not null references public.organizations(id) on delete restrict,
  user_id uuid not null references auth.users(id) on delete cascade,
  role public.app_role not null,
  status text not null default 'ACTIVE' check (status in ('ACTIVE', 'SUSPENDED')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (organization_id, user_id)
);

-- Stores only a SHA-256 digest. The matching bearer token is supplied out of band
-- and can be consumed once by a confirmed Supabase Auth user.
create table public.initial_admin_bootstrap (
  organization_id uuid primary key references public.organizations(id) on delete restrict,
  token_hash text not null,
  used_at timestamptz,
  used_by uuid references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  check ((used_at is null and used_by is null) or (used_at is not null and used_by is not null))
);

insert into public.initial_admin_bootstrap (organization_id, token_hash)
select id, 'a05315eb8f085a85df6aa46f38f58ffa56276a2ded82a7989be39c55d5b42d89'
from public.organizations
where slug = 'tabacaria-uai'
on conflict (organization_id) do nothing;

insert into public.profiles (id)
select id from auth.users
on conflict (id) do nothing;

create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, nullif(trim(new.raw_user_meta_data ->> 'display_name'), ''))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure private.handle_new_user();

create or replace function private.is_org_member(p_organization_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.organization_memberships membership
    where membership.organization_id = p_organization_id
      and membership.user_id = (select auth.uid())
      and membership.status = 'ACTIVE'
  );
$$;

create or replace function private.is_org_admin(p_organization_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.organization_memberships membership
    where membership.organization_id = p_organization_id
      and membership.user_id = (select auth.uid())
      and membership.status = 'ACTIVE'
      and membership.role = 'ADMIN'
  );
$$;

create or replace function private.current_organization_id()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select case when count(*) = 1 then (array_agg(membership.organization_id))[1] else null end
  from public.organization_memberships membership
  where membership.user_id = (select auth.uid())
    and membership.status = 'ACTIVE';
$$;

-- Temporary, single-use bootstrap. Remove this function and table after the first
-- administrator confirms access; no email address or password is stored here.
create or replace function public.claim_initial_admin(p_token text)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  bootstrap public.initial_admin_bootstrap%rowtype;
  current_user_id uuid := auth.uid();
begin
  if current_user_id is null then
    raise exception 'Authentication is required';
  end if;

  if not exists (
    select 1 from auth.users where id = current_user_id and email_confirmed_at is not null
  ) then
    raise exception 'Confirm your email before claiming administrator access';
  end if;

  select * into bootstrap
  from public.initial_admin_bootstrap
  where used_at is null
    and token_hash = encode(extensions.digest(p_token, 'sha256'), 'hex')
  for update;

  if not found then
    raise exception 'The administrator bootstrap token is invalid or has already been used';
  end if;

  if exists (
    select 1 from public.organization_memberships
    where organization_id = bootstrap.organization_id and role = 'ADMIN' and status = 'ACTIVE'
  ) then
    raise exception 'An active administrator already exists';
  end if;

  insert into public.organization_memberships (organization_id, user_id, role)
  values (bootstrap.organization_id, current_user_id, 'ADMIN')
  on conflict (organization_id, user_id)
  do update set role = 'ADMIN', status = 'ACTIVE', updated_at = now();

  update public.initial_admin_bootstrap
  set used_at = now(), used_by = current_user_id
  where organization_id = bootstrap.organization_id;

  return true;
end;
$$;

revoke all on function private.handle_new_user() from public;
revoke all on function private.is_org_member(uuid) from public;
revoke all on function private.is_org_admin(uuid) from public;
revoke all on function private.current_organization_id() from public;
grant execute on function private.current_organization_id() to authenticated;
revoke all on function public.claim_initial_admin(text) from public;
grant execute on function public.claim_initial_admin(text) to authenticated;

alter table public.customers add column if not exists organization_id uuid references public.organizations(id) on delete restrict;
alter table public.products add column if not exists organization_id uuid references public.organizations(id) on delete restrict;
alter table public.inventory_movements add column if not exists organization_id uuid references public.organizations(id) on delete restrict;

update public.customers set organization_id = (select id from public.organizations where slug = 'tabacaria-uai') where organization_id is null;
update public.products set organization_id = (select id from public.organizations where slug = 'tabacaria-uai') where organization_id is null;
update public.inventory_movements set organization_id = (select id from public.organizations where slug = 'tabacaria-uai') where organization_id is null;

alter table public.customers alter column organization_id set default private.current_organization_id();
alter table public.products alter column organization_id set default private.current_organization_id();
alter table public.inventory_movements alter column organization_id set default private.current_organization_id();
alter table public.customers alter column organization_id set not null;
alter table public.products alter column organization_id set not null;
alter table public.inventory_movements alter column organization_id set not null;

create index if not exists customers_organization_name_idx on public.customers(organization_id, name);
create index if not exists products_organization_name_idx on public.products(organization_id, name);
create index if not exists inventory_movements_organization_created_idx on public.inventory_movements(organization_id, created_at desc);
create index if not exists organization_memberships_user_idx on public.organization_memberships(user_id) where status = 'ACTIVE';

alter table public.organizations enable row level security;
alter table public.profiles enable row level security;
alter table public.organization_memberships enable row level security;
alter table public.initial_admin_bootstrap enable row level security;

revoke all on public.organizations, public.profiles, public.organization_memberships, public.initial_admin_bootstrap from anon;
revoke all on public.organizations, public.profiles, public.organization_memberships, public.initial_admin_bootstrap from authenticated;
grant select on public.organizations, public.profiles, public.organization_memberships to authenticated;
grant select, insert, update, delete on public.customers, public.products, public.inventory_movements to authenticated;

create policy "members can view their organization" on public.organizations
  for select to authenticated using ((select private.is_org_member(id)));
create policy "users can view their own profile" on public.profiles
  for select to authenticated using ((select auth.uid()) = id);
create policy "users can update their own profile" on public.profiles
  for update to authenticated using ((select auth.uid()) = id) with check ((select auth.uid()) = id);
create policy "members can view relevant memberships" on public.organization_memberships
  for select to authenticated using (
    user_id = (select auth.uid()) or (select private.is_org_admin(organization_id))
  );

drop policy if exists "customers are private to owner" on public.customers;
drop policy if exists "products are private to owner" on public.products;
drop policy if exists "inventory movements are private to owner" on public.inventory_movements;

create policy "members can read organization customers" on public.customers
  for select to authenticated using ((select private.is_org_member(organization_id)));
create policy "members can add organization customers" on public.customers
  for insert to authenticated with check ((select private.is_org_member(organization_id)));
create policy "members can update organization customers" on public.customers
  for update to authenticated using ((select private.is_org_member(organization_id))) with check ((select private.is_org_member(organization_id)));
create policy "admins can delete organization customers" on public.customers
  for delete to authenticated using ((select private.is_org_admin(organization_id)));

create policy "members can read organization products" on public.products
  for select to authenticated using ((select private.is_org_member(organization_id)));
create policy "members can add organization products" on public.products
  for insert to authenticated with check ((select private.is_org_member(organization_id)));
create policy "members can update organization products" on public.products
  for update to authenticated using ((select private.is_org_member(organization_id))) with check ((select private.is_org_member(organization_id)));
create policy "admins can delete organization products" on public.products
  for delete to authenticated using ((select private.is_org_admin(organization_id)));

create policy "members can read organization inventory movements" on public.inventory_movements
  for select to authenticated using ((select private.is_org_member(organization_id)));
create policy "members can add organization inventory movements" on public.inventory_movements
  for insert to authenticated with check ((select private.is_org_member(organization_id)));
create policy "admins can update organization inventory movements" on public.inventory_movements
  for update to authenticated using ((select private.is_org_admin(organization_id))) with check ((select private.is_org_admin(organization_id)));
create policy "admins can delete organization inventory movements" on public.inventory_movements
  for delete to authenticated using ((select private.is_org_admin(organization_id)));
