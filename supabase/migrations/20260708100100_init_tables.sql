-- AriyaPlanner — tables (data model per CLAUDE.md §3, v1.5).
-- Money is integer kobo everywhere (never floats). Created in dependency order.

-- Shared updated_at trigger.
create or replace function app.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ── users ─────────────────────────────────────────────────────────────────────
-- Profile row mirroring auth.users (WhatsApp-number OTP auth lands in P3).
create table users (
  id uuid primary key references auth.users (id) on delete cascade,
  phone text unique, -- E.164, e.g. +234803...
  full_name text,
  city text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ── program_templates (skills/cultural-programs) ──────────────────────────────
-- Human-curated, versioned, immutable-once-live. The LLM selects; never writes.
create table program_templates (
  id uuid primary key default gen_random_uuid(),
  event_type event_type not null,
  culture culture,
  religion religion,
  name text not null,
  version int not null default 1,
  reviewed_by text, -- cultural consultant sign-off, required before is_live
  is_live boolean not null default false,
  blocks jsonb not null default '[]',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (event_type, culture, religion, name, version)
);

-- ── price_bands (skills/price-bands) ──────────────────────────────────────────
create table price_bands (
  id uuid primary key default gen_random_uuid(),
  category text not null,
  city text not null,
  tier tier not null,
  low_kobo bigint not null check (low_kobo >= 0),
  high_kobo bigint not null check (high_kobo >= low_kobo),
  unit price_unit not null default 'flat',
  source text not null default 'seed-2026-research',
  effective_from date not null default current_date,
  version int not null default 1,
  created_at timestamptz not null default now(),
  unique (category, city, tier, version)
);

-- ── tips (advisory library, PRD F1c) ──────────────────────────────────────────
-- Curated advice keyed by context; register variants. No free-generated wisdom.
create table tips (
  id uuid primary key default gen_random_uuid(),
  event_type event_type,
  workstream_slug text,
  runway_stage runway_stage,
  guest_band guest_band,
  body_celebration text not null,
  body_memorial text, -- memorial register variant (null = celebration-only)
  version int not null default 1,
  is_live boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ── idea_assets (owned/licensed reference images, PRD F1c) ─────────────────────
create table idea_assets (
  id uuid primary key default gen_random_uuid(),
  category text not null,
  title text,
  storage_path text not null,
  license_source text,
  license_note text,
  created_at timestamptz not null default now()
);

-- ── events ────────────────────────────────────────────────────────────────────
create table events (
  id uuid primary key default gen_random_uuid(),
  created_by uuid not null references users (id),
  type event_type not null,
  mode event_mode not null default 'celebration',
  title text not null,
  culture culture, -- skipped for office events
  religion religion, -- skipped for office events
  dates date[] not null default '{}',
  city text,
  budget_band tier,
  guest_band guest_band,
  status event_status not null default 'draft',
  runway_days int,
  date_mode date_mode not null default 'fixed',
  expected_window_start date, -- birth_plus_n mode
  expected_window_end date,
  trigger_recorded_at timestamptz, -- "baby is here" date-lock (F1b)
  event_coordinator_id uuid references users (id),
  day_of_coordinator_id uuid references users (id),
  trial_started_at timestamptz,
  pass_paid_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index events_created_by_idx on events (created_by);

-- ── workstreams ───────────────────────────────────────────────────────────────
-- The finance/contributions workstream is identified by slug = 'finance'; its
-- workstream_lead is the only non-chief-host who may read contribution amounts.
create table workstreams (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references events (id) on delete cascade,
  name text not null,
  slug text,
  budget_allocation_kobo bigint not null default 0 check (budget_allocation_kobo >= 0),
  position int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (event_id, slug)
);
create index workstreams_event_idx on workstreams (event_id);

-- ── committee_members ─────────────────────────────────────────────────────────
create table committee_members (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references events (id) on delete cascade,
  user_id uuid references users (id) on delete set null, -- null until invite accepted
  invited_phone text, -- pending invite target
  role committee_role not null default 'member',
  workstream_id uuid references workstreams (id) on delete set null,
  status member_status not null default 'pending',
  invited_by uuid references users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index committee_members_event_idx on committee_members (event_id);
create unique index committee_members_event_user_uk
  on committee_members (event_id, user_id) where user_id is not null;

-- ── ceremonies ────────────────────────────────────────────────────────────────
create table ceremonies (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references events (id) on delete cascade,
  template_id uuid references program_templates (id),
  template_version int, -- pinned; events keep the version they generated with
  name text not null,
  ceremony_date date,
  start_time time,
  blocks jsonb not null default '[]', -- personalised copy of template blocks
  position int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index ceremonies_event_idx on ceremonies (event_id);

-- ── suggestions (F2a) ─────────────────────────────────────────────────────────
create table suggestions (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references events (id) on delete cascade,
  suggester_id uuid not null references users (id),
  workstream_id uuid references workstreams (id) on delete set null,
  item text not null,
  detail text,
  est_kobo bigint check (est_kobo is null or est_kobo >= 0), -- null = estimate-pending
  status suggestion_status not null default 'pending',
  resolved_by uuid references users (id),
  resolved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index suggestions_event_idx on suggestions (event_id);

-- ── tasks ─────────────────────────────────────────────────────────────────────
create table tasks (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references events (id) on delete cascade,
  workstream_id uuid references workstreams (id) on delete set null,
  title text not null,
  description text,
  lead_time_days int not null default 0 check (lead_time_days >= 0),
  dependencies uuid[] not null default '{}',
  criticality task_criticality not null default 'important',
  parallelisable_by_workstream boolean not null default false,
  due_date date,
  earliest_start date,
  latest_start date,
  slack_days int,
  status task_status not null default 'todo',
  owner_id uuid references users (id),
  credited_suggestion_id uuid references suggestions (id) on delete set null,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index tasks_event_idx on tasks (event_id);
create index tasks_workstream_idx on tasks (workstream_id);

-- ── contributions (append-only ledger; corrects_id) ───────────────────────────
create table contributions (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references events (id) on delete cascade,
  contributor_member_id uuid references committee_members (id) on delete set null,
  contributor_name text, -- display for non-member contributors
  branch text, -- memorial per-branch rollup label
  kind contribution_kind not null,
  amount_kobo bigint not null check (amount_kobo >= 0),
  status contribution_status not null default 'pledged',
  method text,
  note text,
  corrects_id uuid references contributions (id), -- a correction points to the original
  recorded_by uuid references users (id),
  created_at timestamptz not null default now()
);
create index contributions_event_idx on contributions (event_id);

-- ── vendors (global, phone-deduped) ───────────────────────────────────────────
create table vendors (
  id uuid primary key default gen_random_uuid(),
  phone text not null,
  name text not null,
  category text,
  city text,
  verified boolean not null default false,
  claimed boolean not null default false,
  claimed_by uuid references users (id),
  events_served int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create unique index vendors_phone_uk on vendors (phone); -- phone-dedup / merge signal

-- ── vendor_engagements (per-event) ────────────────────────────────────────────
create table vendor_engagements (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references events (id) on delete cascade,
  vendor_id uuid not null references vendors (id),
  workstream_id uuid references workstreams (id) on delete set null,
  quotes jsonb not null default '[]',
  selected_quote_kobo bigint check (selected_quote_kobo is null or selected_quote_kobo >= 0),
  deposit_kobo bigint not null default 0 check (deposit_kobo >= 0),
  balance_kobo bigint not null default 0 check (balance_kobo >= 0),
  status vendor_engagement_status not null default 'shortlisted',
  check_in_at timestamptz,
  rating int check (rating is null or rating between 1 and 5),
  engaged_by uuid references users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (event_id, vendor_id)
);
create index vendor_engagements_event_idx on vendor_engagements (event_id);

-- ── aso_ebi_items + aso_ebi_orders ────────────────────────────────────────────
create table aso_ebi_items (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references events (id) on delete cascade,
  name text not null,
  photo_path text, -- supabase storage
  unit_price_kobo bigint not null check (unit_price_kobo >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index aso_ebi_items_event_idx on aso_ebi_items (event_id);

create table aso_ebi_orders (
  id uuid primary key default gen_random_uuid(),
  item_id uuid not null references aso_ebi_items (id) on delete cascade,
  event_id uuid not null references events (id) on delete cascade, -- denormalised for RLS
  buyer_member_id uuid references committee_members (id) on delete set null,
  buyer_name text,
  buyer_phone text,
  quantity int not null default 1 check (quantity > 0),
  amount_kobo bigint not null check (amount_kobo >= 0),
  status aso_ebi_order_status not null default 'reserved',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index aso_ebi_orders_event_idx on aso_ebi_orders (event_id);

-- ── event_ideas (F1c) ─────────────────────────────────────────────────────────
create table event_ideas (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references events (id) on delete cascade,
  prompt_context text,
  title text not null,
  detail text,
  est_kobo bigint check (est_kobo is null or est_kobo >= 0), -- null = estimate-pending
  asset_ids uuid[] not null default '{}',
  status event_idea_status not null default 'shown',
  materialised_suggestion_id uuid references suggestions (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index event_ideas_event_idx on event_ideas (event_id);

-- ── milestones ────────────────────────────────────────────────────────────────
-- event_id null = platform-level milestone (e.g. the success-qualified counter).
create table milestones (
  id uuid primary key default gen_random_uuid(),
  event_id uuid references events (id) on delete cascade,
  kind text not null,
  label text,
  city text,
  achieved_at timestamptz,
  metadata jsonb not null default '{}',
  created_at timestamptz not null default now()
);
create index milestones_event_idx on milestones (event_id);

-- ── wa_messages (in/out log) ──────────────────────────────────────────────────
create table wa_messages (
  id uuid primary key default gen_random_uuid(),
  event_id uuid references events (id) on delete cascade,
  user_id uuid references users (id), -- the 1:1 counterpart
  wa_phone text,
  direction wa_direction not null,
  template_name text,
  body text,
  payload jsonb not null default '{}',
  window_state wa_window_state,
  status wa_message_status not null default 'queued',
  error text,
  wa_message_id text, -- Meta message id
  scheduled_for timestamptz,
  sent_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index wa_messages_event_idx on wa_messages (event_id);
create index wa_messages_user_idx on wa_messages (user_id);

-- ── audit_log (append-only) ───────────────────────────────────────────────────
create table audit_log (
  id uuid primary key default gen_random_uuid(),
  event_id uuid references events (id) on delete cascade,
  actor_id uuid references users (id),
  action audit_action not null,
  entity text not null,
  entity_id uuid,
  summary text,
  metadata jsonb not null default '{}',
  created_at timestamptz not null default now()
);
create index audit_log_event_idx on audit_log (event_id);

-- ── updated_at triggers ───────────────────────────────────────────────────────
create trigger set_updated_at before update on users
  for each row execute function app.set_updated_at();
create trigger set_updated_at before update on program_templates
  for each row execute function app.set_updated_at();
create trigger set_updated_at before update on tips
  for each row execute function app.set_updated_at();
create trigger set_updated_at before update on events
  for each row execute function app.set_updated_at();
create trigger set_updated_at before update on workstreams
  for each row execute function app.set_updated_at();
create trigger set_updated_at before update on committee_members
  for each row execute function app.set_updated_at();
create trigger set_updated_at before update on ceremonies
  for each row execute function app.set_updated_at();
create trigger set_updated_at before update on suggestions
  for each row execute function app.set_updated_at();
create trigger set_updated_at before update on tasks
  for each row execute function app.set_updated_at();
create trigger set_updated_at before update on vendors
  for each row execute function app.set_updated_at();
create trigger set_updated_at before update on vendor_engagements
  for each row execute function app.set_updated_at();
create trigger set_updated_at before update on aso_ebi_items
  for each row execute function app.set_updated_at();
create trigger set_updated_at before update on aso_ebi_orders
  for each row execute function app.set_updated_at();
create trigger set_updated_at before update on event_ideas
  for each row execute function app.set_updated_at();
create trigger set_updated_at before update on wa_messages
  for each row execute function app.set_updated_at();
