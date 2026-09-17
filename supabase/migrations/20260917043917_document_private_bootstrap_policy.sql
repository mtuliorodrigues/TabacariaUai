-- Defense in depth: direct access to the temporary digest is never allowed.
create policy "bootstrap digest has no direct access" on private.initial_admin_bootstrap
  for all to authenticated, anon using (false) with check (false);
