-- AriyaPlanner — Row Level Security (CLAUDE.md §2.4, §0).
-- Every table has RLS enabled. Access is event-scoped via committee_members;
-- contribution amounts are readable only by the Chief Host and the Finance
-- workstream lead. Helper functions are SECURITY DEFINER so they read
-- committee_members without triggering RLS recursion.

-- ── Base privileges (RLS still gates every row) ───────────────────────────────
grant usage on schema public to anon, authenticated, service_role;
grant select on all tables in schema public to anon;
grant select, insert, update, delete on all tables in schema public to authenticated;
grant all on all tables in schema public to service_role;
-- Re-assert append-only after the broad grant above.
revoke update, delete on contributions from anon, authenticated, service_role;
revoke update, delete on audit_log from anon, authenticated, service_role;

-- ── RLS helper functions ──────────────────────────────────────────────────────
-- Membership: an active committee member, or the event creator (Chief Host).
create or replace function app.is_member(e uuid)
returns boolean language sql stable security definer
set search_path = public, app as $$
  select exists (select 1 from events ev where ev.id = e and ev.created_by = auth.uid())
      or exists (
        select 1 from committee_members cm
        where cm.event_id = e and cm.user_id = auth.uid() and cm.status = 'active'
      );
$$;

-- Does the caller hold any of the given roles on the event? The creator is
-- always treated as chief_host.
create or replace function app.has_role(e uuid, roles committee_role[])
returns boolean language sql stable security definer
set search_path = public, app as $$
  select (
      'chief_host' = any (roles)
      and exists (select 1 from events ev where ev.id = e and ev.created_by = auth.uid())
    )
    or exists (
      select 1 from committee_members cm
      where cm.event_id = e and cm.user_id = auth.uid()
        and cm.status = 'active' and cm.role = any (roles)
    );
$$;

-- Coordinators who may edit the plan directly (F2a).
create or replace function app.can_manage(e uuid)
returns boolean language sql stable security definer
set search_path = public, app as $$
  select app.has_role(e, array['chief_host', 'event_coordinator']::committee_role[]);
$$;

-- Finance lead = workstream_lead of the workstream with slug 'finance'.
create or replace function app.is_finance_lead(e uuid)
returns boolean language sql stable security definer
set search_path = public, app as $$
  select exists (
    select 1
    from committee_members cm
    join workstreams w on w.id = cm.workstream_id
    where cm.event_id = e and cm.user_id = auth.uid() and cm.status = 'active'
      and cm.role = 'workstream_lead' and w.slug = 'finance'
  );
$$;

-- Who may read contribution amounts: Chief Host + Finance lead.
create or replace function app.can_see_amounts(e uuid)
returns boolean language sql stable security definer
set search_path = public, app as $$
  select app.has_role(e, array['chief_host']::committee_role[]) or app.is_finance_lead(e);
$$;

-- Do the caller and `other` share any event (for reading co-members' profiles)?
create or replace function app.shares_event(other uuid)
returns boolean language sql stable security definer
set search_path = public, app as $$
  select exists (
    select 1
    from committee_members a
    join committee_members b on a.event_id = b.event_id
    where a.user_id = auth.uid() and a.status = 'active'
      and b.user_id = other and b.status = 'active'
  )
  or exists (
    select 1 from events ev join committee_members b on b.event_id = ev.id
    where ev.created_by = auth.uid() and b.user_id = other and b.status = 'active'
  )
  or exists (
    select 1 from events ev join committee_members a on a.event_id = ev.id
    where ev.created_by = other and a.user_id = auth.uid() and a.status = 'active'
  );
$$;

grant usage on schema app to anon, authenticated, service_role;
grant execute on all functions in schema app to anon, authenticated, service_role;

-- ── Enable RLS on every table ─────────────────────────────────────────────────
alter table users enable row level security;
alter table events enable row level security;
alter table program_templates enable row level security;
alter table price_bands enable row level security;
alter table tips enable row level security;
alter table idea_assets enable row level security;
alter table workstreams enable row level security;
alter table committee_members enable row level security;
alter table ceremonies enable row level security;
alter table suggestions enable row level security;
alter table tasks enable row level security;
alter table contributions enable row level security;
alter table vendors enable row level security;
alter table vendor_engagements enable row level security;
alter table aso_ebi_items enable row level security;
alter table aso_ebi_orders enable row level security;
alter table event_ideas enable row level security;
alter table milestones enable row level security;
alter table wa_messages enable row level security;
alter table audit_log enable row level security;

-- ── users ─────────────────────────────────────────────────────────────────────
create policy users_select on users for select
  using (id = auth.uid() or app.shares_event(id));
create policy users_insert on users for insert
  with check (id = auth.uid());
create policy users_update on users for update
  using (id = auth.uid()) with check (id = auth.uid());

-- ── events ────────────────────────────────────────────────────────────────────
create policy events_select on events for select
  using (app.is_member(id));
create policy events_insert on events for insert
  with check (created_by = auth.uid());
create policy events_update on events for update
  using (app.can_manage(id)) with check (app.can_manage(id));
create policy events_delete on events for delete
  using (app.has_role(id, array['chief_host']::committee_role[]));

-- ── reference content (public / authenticated read; writes are service-role) ──
create policy program_templates_select on program_templates for select
  using (is_live);
create policy price_bands_select on price_bands for select
  using (true);
create policy tips_select on tips for select
  using (is_live);
create policy idea_assets_select on idea_assets for select
  using (auth.uid() is not null);

-- ── workstreams ───────────────────────────────────────────────────────────────
create policy workstreams_select on workstreams for select
  using (app.is_member(event_id));
create policy workstreams_insert on workstreams for insert
  with check (app.can_manage(event_id));
create policy workstreams_update on workstreams for update
  using (app.can_manage(event_id)) with check (app.can_manage(event_id));
create policy workstreams_delete on workstreams for delete
  using (app.can_manage(event_id));

-- ── committee_members ─────────────────────────────────────────────────────────
create policy committee_members_select on committee_members for select
  using (app.is_member(event_id));
create policy committee_members_insert on committee_members for insert
  with check (app.can_manage(event_id));
create policy committee_members_update on committee_members for update
  using (app.can_manage(event_id) or user_id = auth.uid())
  with check (app.can_manage(event_id) or user_id = auth.uid());
create policy committee_members_delete on committee_members for delete
  using (app.can_manage(event_id));

-- ── ceremonies ────────────────────────────────────────────────────────────────
create policy ceremonies_select on ceremonies for select
  using (app.is_member(event_id));
create policy ceremonies_insert on ceremonies for insert
  with check (app.can_manage(event_id));
create policy ceremonies_update on ceremonies for update
  using (app.can_manage(event_id)) with check (app.can_manage(event_id));
create policy ceremonies_delete on ceremonies for delete
  using (app.can_manage(event_id));

-- ── suggestions (F2a: private to suggester + coordinators) ────────────────────
create policy suggestions_select on suggestions for select
  using (suggester_id = auth.uid() or app.can_manage(event_id));
create policy suggestions_insert on suggestions for insert
  with check (app.is_member(event_id) and suggester_id = auth.uid());
create policy suggestions_update on suggestions for update
  using (app.can_manage(event_id)) with check (app.can_manage(event_id));
create policy suggestions_delete on suggestions for delete
  using (app.can_manage(event_id));

-- ── tasks ─────────────────────────────────────────────────────────────────────
create policy tasks_select on tasks for select
  using (app.is_member(event_id));
create policy tasks_insert on tasks for insert
  with check (app.can_manage(event_id));
create policy tasks_update on tasks for update
  using (app.can_manage(event_id) or owner_id = auth.uid())
  with check (app.can_manage(event_id) or owner_id = auth.uid());
create policy tasks_delete on tasks for delete
  using (app.can_manage(event_id));

-- ── contributions (append-only; amount privacy) ───────────────────────────────
create policy contributions_select on contributions for select
  using (
    app.can_see_amounts(event_id)
    or recorded_by = auth.uid()
    or exists (
      select 1 from committee_members cm
      where cm.id = contributor_member_id and cm.user_id = auth.uid()
    )
  );
create policy contributions_insert on contributions for insert
  with check (app.is_member(event_id) and recorded_by = auth.uid());
-- No UPDATE/DELETE policies: append-only (also enforced by trigger + revoke).

-- ── vendors (shared registry) ─────────────────────────────────────────────────
create policy vendors_select on vendors for select
  using (auth.uid() is not null);
create policy vendors_insert on vendors for insert
  with check (auth.uid() is not null);
create policy vendors_update on vendors for update
  using (claimed_by = auth.uid()) with check (claimed_by = auth.uid());

-- ── vendor_engagements ────────────────────────────────────────────────────────
create policy vendor_engagements_select on vendor_engagements for select
  using (app.is_member(event_id));
create policy vendor_engagements_insert on vendor_engagements for insert
  with check (app.has_role(event_id,
    array['chief_host', 'event_coordinator', 'workstream_lead']::committee_role[]));
create policy vendor_engagements_update on vendor_engagements for update
  using (app.has_role(event_id,
    array['chief_host', 'event_coordinator', 'workstream_lead']::committee_role[]))
  with check (app.has_role(event_id,
    array['chief_host', 'event_coordinator', 'workstream_lead']::committee_role[]));
create policy vendor_engagements_delete on vendor_engagements for delete
  using (app.can_manage(event_id));

-- ── aso-ebi ───────────────────────────────────────────────────────────────────
create policy aso_ebi_items_select on aso_ebi_items for select
  using (app.is_member(event_id));
create policy aso_ebi_items_write on aso_ebi_items for all
  using (app.can_manage(event_id)) with check (app.can_manage(event_id));

create policy aso_ebi_orders_select on aso_ebi_orders for select
  using (app.is_member(event_id));
create policy aso_ebi_orders_write on aso_ebi_orders for all
  using (app.can_manage(event_id)) with check (app.can_manage(event_id));

-- ── event_ideas ───────────────────────────────────────────────────────────────
create policy event_ideas_select on event_ideas for select
  using (app.is_member(event_id));
create policy event_ideas_insert on event_ideas for insert
  with check (app.is_member(event_id));
create policy event_ideas_update on event_ideas for update
  using (app.is_member(event_id)) with check (app.is_member(event_id));
create policy event_ideas_delete on event_ideas for delete
  using (app.can_manage(event_id));

-- ── milestones (event-scoped + public platform counter) ───────────────────────
create policy milestones_select on milestones for select
  using (event_id is null or app.is_member(event_id));

-- ── wa_messages (private thread + coordinators) ───────────────────────────────
create policy wa_messages_select on wa_messages for select
  using (user_id = auth.uid() or app.can_manage(event_id));

-- ── audit_log (append-only; coordinators read) ────────────────────────────────
create policy audit_log_select on audit_log for select
  using (app.can_manage(event_id));
create policy audit_log_insert on audit_log for insert
  with check (app.is_member(event_id) and (actor_id = auth.uid() or actor_id is null));
