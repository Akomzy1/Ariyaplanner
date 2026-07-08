-- AriyaPlanner — aso-ebi palette reference table (PRD F1c).
-- Named colour combinations rendered as deterministic colour-chip cards by the
-- palette-card component (P11) — no generative imagery. Public read; content is
-- curated (service-role writes / admin in P25).
-- NOTE: not in CLAUDE.md §3's summary; added to back the F1c palette-card feature.

create table aso_ebi_palettes (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  hexes text[] not null, -- ordered chips, e.g. {'#0B6B3A','#C9A227'}
  description text,
  register event_mode, -- suggested register; null = suits both
  position int not null default 0,
  created_at timestamptz not null default now()
);

alter table aso_ebi_palettes enable row level security;

grant select on aso_ebi_palettes to anon, authenticated;
grant all on aso_ebi_palettes to service_role;

create policy aso_ebi_palettes_select on aso_ebi_palettes for select
  using (true);
