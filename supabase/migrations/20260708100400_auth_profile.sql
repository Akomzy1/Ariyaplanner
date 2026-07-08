-- AriyaPlanner — auto-create a public.users profile when an auth user signs up
-- (P3, WhatsApp-number OTP). The profile row is required because every app
-- table's ownership/RLS resolves through public.users.

create or replace function app.handle_new_user()
returns trigger language plpgsql security definer
set search_path = public, app as $$
begin
  insert into public.users (id, phone, full_name)
  values (
    new.id,
    new.phone,
    nullif(new.raw_user_meta_data ->> 'full_name', '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function app.handle_new_user();
