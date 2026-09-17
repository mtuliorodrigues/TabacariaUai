-- The temporary token digest is implementation detail, not a Data API table.
alter table public.initial_admin_bootstrap set schema private;
create index if not exists initial_admin_bootstrap_used_by_idx on private.initial_admin_bootstrap(used_by);

create or replace function public.claim_initial_admin(p_token text)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  bootstrap private.initial_admin_bootstrap%rowtype;
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
  from private.initial_admin_bootstrap
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

  update private.initial_admin_bootstrap
  set used_at = now(), used_by = current_user_id
  where organization_id = bootstrap.organization_id;

  return true;
end;
$$;

revoke all on function public.claim_initial_admin(text) from public;
revoke all on function public.claim_initial_admin(text) from anon;
grant execute on function public.claim_initial_admin(text) to authenticated;
