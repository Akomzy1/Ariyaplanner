-- AriyaPlanner — extensions, private schema, and enum types.
-- Implements the data model in CLAUDE.md §3 (v1.5) together with the domain
-- skills (cultural-programs, price-bands, runway-scheduler, whatsapp-flows).

-- gen_random_uuid() is built into Postgres 13+ (Supabase is PG15), so no
-- extension is required for UUID defaults.

-- Private schema for RLS helper functions. Not exposed via PostgREST, so these
-- helpers never become callable RPCs.
create schema if not exists app;

-- ── Event shape ───────────────────────────────────────────────────────────────
create type event_type as enum ('wedding', 'burial', 'birthday', 'naming', 'office');
create type event_mode as enum ('celebration', 'memorial');
create type culture as enum ('yoruba', 'igbo', 'hausa', 'edo', 'cross', 'neutral');
create type religion as enum ('christian', 'muslim', 'traditional', 'mixed', 'neutral');
create type event_status as enum ('draft', 'active', 'completed', 'archived');
-- Anticipated-date mode for naming ceremonies (PRD F1b / skills/runway-scheduler).
create type date_mode as enum ('fixed', 'birth_plus_n');

-- ── Money / sizing bands ──────────────────────────────────────────────────────
create type tier as enum ('manage', 'standard', 'premium');
create type guest_band as enum ('under_100', '100_300', '300_600', '600_plus');
create type price_unit as enum ('flat', 'per_head', 'per_unit');
-- Aligns with the scheduler's runway modes; keys the advisory tips library.
create type runway_stage as enum ('comfortable', 'tight', 'sprint', 'triage');

-- ── People / coordination ─────────────────────────────────────────────────────
create type committee_role as enum (
  'chief_host', 'event_coordinator', 'workstream_lead', 'member', 'viewer'
);
create type member_status as enum ('pending', 'active', 'removed');

-- ── Tasks ─────────────────────────────────────────────────────────────────────
create type task_criticality as enum ('blocking', 'important', 'nice');
create type task_status as enum ('todo', 'in_progress', 'done', 'blocked', 'cancelled');

-- ── Money movement ────────────────────────────────────────────────────────────
create type contribution_kind as enum ('pledge', 'payment');
create type contribution_status as enum ('pledged', 'received', 'cancelled');

-- ── Suggestions & ideas (F2a / F1c) ───────────────────────────────────────────
create type suggestion_status as enum ('pending', 'approved', 'declined');
create type event_idea_status as enum ('shown', 'accepted', 'dismissed');

-- ── Vendors & aso-ebi ─────────────────────────────────────────────────────────
create type vendor_engagement_status as enum (
  'shortlisted', 'quoted', 'engaged', 'confirmed', 'checked_in', 'completed', 'cancelled'
);
create type aso_ebi_order_status as enum ('reserved', 'paid', 'picked_up', 'cancelled');

-- ── WhatsApp & audit ──────────────────────────────────────────────────────────
create type wa_direction as enum ('inbound', 'outbound');
create type wa_window_state as enum ('open', 'closed');
create type wa_message_status as enum (
  'queued', 'sent', 'delivered', 'read', 'failed', 'received'
);
create type audit_action as enum (
  'create', 'update', 'delete', 'send', 'pay', 'confirm', 'gate'
);
