-- TEST-ONLY Supabase-compatibility shim.
-- Recreates the pieces the Supabase platform provides at runtime so the exact
-- production migrations can be applied and their RLS exercised on a plain
-- Postgres (PGlite). This file is NEVER part of the deployed migrations.

-- Platform roles (Supabase pre-creates these).
do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then
    create role anon nologin noinherit;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then
    create role authenticated nologin noinherit;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'service_role') then
    create role service_role nologin noinherit bypassrls;
  end if;
end
$$;

-- The auth schema + a minimal auth.users (FK target for public.users).
create schema if not exists auth;

create table if not exists auth.users (
  id uuid primary key,
  email text
);

-- auth.uid() / auth.role() read the request JWT claims GUC, exactly like
-- Supabase. Tests set request.jwt.claims per role.
create or replace function auth.uid()
returns uuid language sql stable as $$
  select nullif(
    current_setting('request.jwt.claims', true)::json ->> 'sub', ''
  )::uuid;
$$;

create or replace function auth.role()
returns text language sql stable as $$
  select coalesce(
    current_setting('request.jwt.claims', true)::json ->> 'role', 'anon'
  );
$$;

grant usage on schema auth to anon, authenticated, service_role;
grant execute on function auth.uid() to anon, authenticated, service_role;
grant execute on function auth.role() to anon, authenticated, service_role;
grant select on auth.users to anon, authenticated, service_role;
