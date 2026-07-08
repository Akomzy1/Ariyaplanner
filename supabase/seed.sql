-- AriyaPlanner — DEV-ONLY demo data. Run by `supabase db reset` (config.toml
-- [db.seed]); never applied to production by `db push`. Two demo events exercise
-- both registers once the UI exists. Idempotent (fixed IDs + ON CONFLICT).
--
-- Profiles are created by the on_auth_user_created trigger when we insert the
-- auth.users rows — exactly like real signup.

-- ── demo users ────────────────────────────────────────────────────────────────
insert into auth.users (id, email, phone, raw_user_meta_data) values
  ('d0000000-0000-0000-0000-000000000001','bola@demo.test','+2348030000001','{"full_name":"Bola Adeyemi"}'),
  ('d0000000-0000-0000-0000-000000000002','tunde@demo.test','+2348030000002','{"full_name":"Tunde Adeyemi"}'),
  ('d0000000-0000-0000-0000-000000000003','ada@demo.test','+2348030000003','{"full_name":"Ada Okoro"}'),
  ('d0000000-0000-0000-0000-000000000004','chidi@demo.test','+2348030000004','{"full_name":"Chidi Nwosu"}'),
  ('d0000000-0000-0000-0000-000000000011','emeka@demo.test','+2348030000011','{"full_name":"Emeka Obi"}'),
  ('d0000000-0000-0000-0000-000000000012','ngozi@demo.test','+2348030000012','{"full_name":"Ngozi Obi"}'),
  ('d0000000-0000-0000-0000-000000000013','uche@demo.test','+2348030000013','{"full_name":"Uche Obi"}'),
  ('d0000000-0000-0000-0000-000000000014','ifeoma@demo.test','+2348030000014','{"full_name":"Ifeoma Obi"}')
on conflict (id) do nothing;

-- ════════════════════════════════════════════════════════════════════════════
-- Demo 1 — "Mummy's 70th" (celebration / birthday)
-- ════════════════════════════════════════════════════════════════════════════
insert into events (id, created_by, type, mode, title, culture, religion, dates, city, budget_band, guest_band, status, event_coordinator_id) values
  ('da000000-0000-0000-0000-000000000001','d0000000-0000-0000-0000-000000000001','birthday','celebration','Mummy''s 70th','neutral','christian','{2026-10-17}','lagos','standard','100_300','active','d0000000-0000-0000-0000-000000000002')
on conflict (id) do nothing;

insert into workstreams (id, event_id, name, slug, budget_allocation_kobo, position) values
  ('d1000000-0000-0000-0000-000000000001','da000000-0000-0000-0000-000000000001','Catering','catering',180000000,1),
  ('d1000000-0000-0000-0000-000000000002','da000000-0000-0000-0000-000000000001','Decor','decor',80000000,2),
  ('d1000000-0000-0000-0000-000000000003','da000000-0000-0000-0000-000000000001','Logistics','logistics',40000000,3),
  ('d1000000-0000-0000-0000-000000000004','da000000-0000-0000-0000-000000000001','Finance','finance',0,4)
on conflict (id) do nothing;

insert into committee_members (id, event_id, user_id, role, workstream_id, status) values
  ('d2000000-0000-0000-0000-000000000001','da000000-0000-0000-0000-000000000001','d0000000-0000-0000-0000-000000000001','chief_host',null,'active'),
  ('d2000000-0000-0000-0000-000000000002','da000000-0000-0000-0000-000000000001','d0000000-0000-0000-0000-000000000002','event_coordinator',null,'active'),
  ('d2000000-0000-0000-0000-000000000003','da000000-0000-0000-0000-000000000001','d0000000-0000-0000-0000-000000000003','workstream_lead','d1000000-0000-0000-0000-000000000004','active'),
  ('d2000000-0000-0000-0000-000000000004','da000000-0000-0000-0000-000000000001','d0000000-0000-0000-0000-000000000004','member',null,'active')
on conflict (id) do nothing;

insert into ceremonies (id, event_id, template_id, template_version, name, ceremony_date, blocks, position)
select 'd5000000-0000-0000-0000-000000000001','da000000-0000-0000-0000-000000000001', pt.id, pt.version,
       'Mummy''s 70th — Celebration', date '2026-10-17', pt.blocks, 1
from program_templates pt
where pt.name = 'Milestone Birthday (40th / 50th / 70th)' and pt.version = 1
on conflict (id) do nothing;

insert into tasks (id, event_id, workstream_id, title, lead_time_days, criticality, due_date, status, owner_id) values
  ('d3000000-0000-0000-0000-000000000001','da000000-0000-0000-0000-000000000001','d1000000-0000-0000-0000-000000000001','Confirm caterer and pay deposit',42,'blocking',date '2026-09-05','todo','d0000000-0000-0000-0000-000000000002'),
  ('d3000000-0000-0000-0000-000000000002','da000000-0000-0000-0000-000000000001','d1000000-0000-0000-0000-000000000002','Book decorator',35,'important',date '2026-09-12','todo','d0000000-0000-0000-0000-000000000002'),
  ('d3000000-0000-0000-0000-000000000003','da000000-0000-0000-0000-000000000001','d1000000-0000-0000-0000-000000000001','Order the cake',21,'important',date '2026-09-26','todo','d0000000-0000-0000-0000-000000000004'),
  ('d3000000-0000-0000-0000-000000000004','da000000-0000-0000-0000-000000000001','d1000000-0000-0000-0000-000000000003','Confirm venue and canopy',30,'blocking',date '2026-09-17','todo','d0000000-0000-0000-0000-000000000002')
on conflict (id) do nothing;

insert into contributions (id, event_id, contributor_member_id, kind, amount_kobo, status, recorded_by) values
  ('d4000000-0000-0000-0000-000000000001','da000000-0000-0000-0000-000000000001','d2000000-0000-0000-0000-000000000004','pledge',10000000,'pledged','d0000000-0000-0000-0000-000000000003'),
  ('d4000000-0000-0000-0000-000000000002','da000000-0000-0000-0000-000000000001','d2000000-0000-0000-0000-000000000002','payment',25000000,'received','d0000000-0000-0000-0000-000000000003')
on conflict (id) do nothing;

-- ════════════════════════════════════════════════════════════════════════════
-- Demo 2 — "Papa's farewell" (memorial / burial)
-- ════════════════════════════════════════════════════════════════════════════
insert into events (id, created_by, type, mode, title, culture, religion, dates, city, budget_band, guest_band, status, date_mode, event_coordinator_id) values
  ('da000000-0000-0000-0000-000000000002','d0000000-0000-0000-0000-000000000011','burial','memorial','Papa''s farewell','igbo','christian','{2026-08-01}','lagos','standard','300_600','active','fixed','d0000000-0000-0000-0000-000000000012')
on conflict (id) do nothing;

insert into workstreams (id, event_id, name, slug, budget_allocation_kobo, position) values
  ('d1000000-0000-0000-0000-000000000011','da000000-0000-0000-0000-000000000002','Logistics','logistics',120000000,1),
  ('d1000000-0000-0000-0000-000000000012','da000000-0000-0000-0000-000000000002','Catering','catering',150000000,2),
  ('d1000000-0000-0000-0000-000000000013','da000000-0000-0000-0000-000000000002','Support','finance',0,3),
  ('d1000000-0000-0000-0000-000000000014','da000000-0000-0000-0000-000000000002','Programme','programme',30000000,4)
on conflict (id) do nothing;

insert into committee_members (id, event_id, user_id, role, workstream_id, status) values
  ('d2000000-0000-0000-0000-000000000011','da000000-0000-0000-0000-000000000002','d0000000-0000-0000-0000-000000000011','chief_host',null,'active'),
  ('d2000000-0000-0000-0000-000000000012','da000000-0000-0000-0000-000000000002','d0000000-0000-0000-0000-000000000012','event_coordinator',null,'active'),
  ('d2000000-0000-0000-0000-000000000013','da000000-0000-0000-0000-000000000002','d0000000-0000-0000-0000-000000000013','workstream_lead','d1000000-0000-0000-0000-000000000013','active'),
  ('d2000000-0000-0000-0000-000000000014','da000000-0000-0000-0000-000000000002','d0000000-0000-0000-0000-000000000014','member',null,'active')
on conflict (id) do nothing;

insert into ceremonies (id, event_id, template_id, template_version, name, ceremony_date, blocks, position)
select 'd5000000-0000-0000-0000-000000000002','da000000-0000-0000-0000-000000000002', pt.id, pt.version,
       'Papa''s farewell — Service', date '2026-08-01', pt.blocks, 1
from program_templates pt
where pt.name = 'Christian Burial' and pt.version = 1
on conflict (id) do nothing;

insert into tasks (id, event_id, workstream_id, title, lead_time_days, criticality, due_date, status, owner_id) values
  ('d3000000-0000-0000-0000-000000000011','da000000-0000-0000-0000-000000000002','d1000000-0000-0000-0000-000000000011','Confirm funeral home and hearse',10,'blocking',date '2026-07-22','todo','d0000000-0000-0000-0000-000000000012'),
  ('d3000000-0000-0000-0000-000000000012','da000000-0000-0000-0000-000000000002','d1000000-0000-0000-0000-000000000014','Print order of service',7,'important',date '2026-07-25','todo','d0000000-0000-0000-0000-000000000014'),
  ('d3000000-0000-0000-0000-000000000013','da000000-0000-0000-0000-000000000002','d1000000-0000-0000-0000-000000000012','Confirm reception catering numbers',9,'blocking',date '2026-07-23','todo','d0000000-0000-0000-0000-000000000012')
on conflict (id) do nothing;

insert into contributions (id, event_id, contributor_member_id, branch, kind, amount_kobo, status, recorded_by) values
  ('d4000000-0000-0000-0000-000000000011','da000000-0000-0000-0000-000000000002','d2000000-0000-0000-0000-000000000014','Lagos branch','pledge',20000000,'pledged','d0000000-0000-0000-0000-000000000013'),
  ('d4000000-0000-0000-0000-000000000012','da000000-0000-0000-0000-000000000002','d2000000-0000-0000-0000-000000000012','Enugu branch','payment',35000000,'received','d0000000-0000-0000-0000-000000000013')
on conflict (id) do nothing;
