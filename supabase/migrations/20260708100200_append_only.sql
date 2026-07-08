-- AriyaPlanner — append-only enforcement (CLAUDE.md §2.3).
-- contributions and audit_log never UPDATE or DELETE; corrections are new rows
-- referencing the original via corrects_id. Enforced two ways:
--   1. a BEFORE UPDATE/DELETE trigger that raises — role-independent, so it holds
--      even for the service role / table owner;
--   2. revoked UPDATE/DELETE privileges (defence in depth; see also the absence
--      of UPDATE/DELETE RLS policies in the RLS migration).

create or replace function app.block_mutation()
returns trigger language plpgsql as $$
begin
  raise exception
    'append-only table "%": rows cannot be %. Insert a correcting row instead (see corrects_id).',
    tg_table_name, tg_op;
end;
$$;

create trigger contributions_no_update
  before update on contributions
  for each row execute function app.block_mutation();
create trigger contributions_no_delete
  before delete on contributions
  for each row execute function app.block_mutation();

create trigger audit_log_no_update
  before update on audit_log
  for each row execute function app.block_mutation();
create trigger audit_log_no_delete
  before delete on audit_log
  for each row execute function app.block_mutation();

revoke update, delete on contributions from anon, authenticated, service_role;
revoke update, delete on audit_log from anon, authenticated, service_role;
