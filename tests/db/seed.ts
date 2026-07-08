import type { Query } from "./harness";

// Deterministic fixture IDs. Event A is the system-under-test; Event B is a
// separate event owned by an outsider, used to prove cross-event isolation.
export const ids = {
  users: {
    host: "00000000-0000-0000-0000-000000000001", // creator / chief_host of A
    coord: "00000000-0000-0000-0000-000000000002", // event_coordinator of A
    finance: "00000000-0000-0000-0000-000000000003", // finance workstream_lead of A
    member: "00000000-0000-0000-0000-000000000004", // plain member of A
    contributor: "00000000-0000-0000-0000-000000000005", // member of A who contributed
    outsider: "00000000-0000-0000-0000-000000000006", // not a member of A; owns B
  },
  eventA: "00000000-0000-0000-0000-00000000000a",
  eventB: "00000000-0000-0000-0000-00000000000b",
  ws: {
    finance: "00000000-0000-0000-0000-0000000000f1",
    catering: "00000000-0000-0000-0000-0000000000c1",
  },
  cm: {
    coord: "00000000-0000-0000-0000-000000001002",
    finance: "00000000-0000-0000-0000-000000001003",
    member: "00000000-0000-0000-0000-000000001004",
    contributor: "00000000-0000-0000-0000-000000001005",
  },
  contrib: {
    fromContributor: "00000000-0000-0000-0000-000000002001",
    anonymous: "00000000-0000-0000-0000-000000002002",
  },
} as const;

/** Seed the fixture as the superuser (bypasses RLS). */
export async function seed(q: Query): Promise<void> {
  const u = ids.users;

  for (const [key, id] of Object.entries(u)) {
    await q("insert into auth.users (id, email) values ($1, $2)", [
      id,
      `${key}@example.test`,
    ]);
    await q(
      "insert into users (id, phone, full_name) values ($1, $2, $3)",
      [id, `+23480000000${Object.keys(u).indexOf(key)}`, key],
    );
  }

  // Event A (host is chief host via created_by).
  await q(
    `insert into events (id, created_by, type, mode, title, event_coordinator_id)
     values ($1, $2, 'wedding', 'celebration', 'Test Wedding', $3)`,
    [ids.eventA, u.host, u.coord],
  );

  await q(
    `insert into workstreams (id, event_id, name, slug) values
       ($1, $3, 'Finance', 'finance'),
       ($2, $3, 'Catering', 'catering')`,
    [ids.ws.finance, ids.ws.catering, ids.eventA],
  );

  await q(
    `insert into committee_members (id, event_id, user_id, role, workstream_id, status) values
       ($1, $6, $7, 'event_coordinator', null, 'active'),
       ($2, $6, $8, 'workstream_lead', $5, 'active'),
       ($3, $6, $9, 'member', null, 'active'),
       ($4, $6, $10, 'member', null, 'active')`,
    [
      ids.cm.coord,
      ids.cm.finance,
      ids.cm.member,
      ids.cm.contributor,
      ids.ws.finance,
      ids.eventA,
      u.coord,
      u.finance,
      u.member,
      u.contributor,
    ],
  );

  // Contributions on Event A.
  await q(
    `insert into contributions
       (id, event_id, contributor_member_id, kind, amount_kobo, status, recorded_by)
     values
       ($1, $3, $4, 'pledge', 50000000, 'pledged', $5),
       ($2, $3, null, 'payment', 100000000, 'received', $6)`,
    [
      ids.contrib.fromContributor,
      ids.contrib.anonymous,
      ids.eventA,
      ids.cm.contributor,
      u.finance, // recorded by the finance lead
      u.host, // recorded by the host
    ],
  );

  // Event B — a separate event owned by the outsider (isolation control).
  await q(
    `insert into events (id, created_by, type, mode, title)
     values ($1, $2, 'birthday', 'celebration', 'Other Event')`,
    [ids.eventB, u.outsider],
  );
  await q(
    `insert into contributions (event_id, kind, amount_kobo, status, recorded_by)
     values ($1, 'pledge', 9900000, 'pledged', $2)`,
    [ids.eventB, u.outsider],
  );

  // A suggestion from the plain member (F2a privacy fixture).
  await q(
    `insert into suggestions (event_id, suggester_id, item, est_kobo, status)
     values ($1, $2, 'Standby generator', 25000000, 'pending')`,
    [ids.eventA, u.member],
  );

  // Reference content: public price index + templates + tips (is_live gating).
  await q(
    `insert into price_bands (category, city, tier, low_kobo, high_kobo, unit)
     values ('catering_per_head', 'lagos', 'standard', 600000, 1000000, 'per_head')`,
  );
  await q(
    `insert into program_templates (event_type, culture, religion, name, is_live)
     values
       ('office', 'neutral', 'neutral', 'Office Celebration', true),
       ('wedding', 'yoruba', 'traditional', 'Yoruba Engagement (draft)', false)`,
  );
  await q(
    `insert into tips (event_type, workstream_slug, runway_stage, body_celebration, is_live)
     values ('wedding', 'catering', 'comfortable', 'Book catering early to lock the price.', true)`,
  );

  // Shared vendor registry + one licensed idea asset.
  await q(
    `insert into vendors (phone, name, category, city)
     values ('+2348030000001', 'Bloom Decor', 'decor', 'lagos')`,
  );
  await q(
    `insert into idea_assets (category, storage_path, license_source)
     values ('decor', 'idea-assets/decor/arch-01.jpg', 'owned')`,
  );
}
