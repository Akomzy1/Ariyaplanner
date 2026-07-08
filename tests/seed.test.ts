import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { createTestDb, readSql, type TestDb } from "./db/harness";

const REFERENCE_SEED = "supabase/migrations/20260708100600_seed_reference.sql";
const DEMO_SEED = "supabase/seed.sql";

let t: TestDb;

async function count(sql: string): Promise<number> {
  return t.asRole({ role: "service_role" }, async (q) => {
    const { rows } = await q<{ n: string }>(
      `select count(*)::text as n from (${sql}) s`,
    );
    return Number(rows[0]!.n);
  });
}

beforeAll(async () => {
  // includeSeeds applies the reference-seed migration.
  t = await createTestDb({ includeSeeds: true });
  // The demo events live in supabase/seed.sql (not a migration) — apply here.
  await t.db.exec(readSql(DEMO_SEED));
});

afterAll(async () => {
  await t.close();
});

describe("reference seed — program templates", () => {
  it("seeds 13 templates; only Office ships live", async () => {
    expect(await count("select 1 from program_templates")).toBe(13);
    expect(await count("select 1 from program_templates where is_live")).toBe(1);
    expect(
      await count("select 1 from program_templates where not is_live"),
    ).toBe(12);
    expect(
      await count(
        "select 1 from program_templates where is_live and event_type = 'office'",
      ),
    ).toBe(1);
  });

  it("naming templates carry the mandated procurement blocks", async () => {
    // Yoruba symbolic items, officiant, and the Muslim aqiqah ram.
    expect(
      await count(
        `select 1 from program_templates
         where event_type='naming' and blocks::text ilike '%symbolic items%'`,
      ),
    ).toBe(1);
    expect(
      await count(
        `select 1 from program_templates
         where event_type='naming' and blocks::text ilike '%aqiqah ram%'`,
      ),
    ).toBe(1);
  });
});

describe("reference seed — price bands", () => {
  it("seeds Lagos in full and derives Abuja at +10%", async () => {
    expect(await count("select 1 from price_bands where city='lagos'")).toBe(60);
    expect(await count("select 1 from price_bands where city='abuja'")).toBe(60);

    // Abuja = round(Lagos * 1.1) for a known row. `order by city` → Abuja, Lagos.
    const [abuja, lagos] = await t.asRole({ role: "service_role" }, async (q) => {
      const { rows } = await q<{ city: string; low: string }>(
        `select city, low_kobo::text as low from price_bands
         where category='catering_per_head' and tier='standard'
         order by city`,
      );
      return rows;
    });
    expect(Number(abuja!.low)).toBe(Math.round(Number(lagos!.low) * 1.1));
  });
});

describe("reference seed — advisory content", () => {
  it("seeds tips, idea assets, and aso-ebi palettes", async () => {
    expect(await count("select 1 from tips")).toBe(14);
    expect(await count("select 1 from idea_assets")).toBe(8);
    expect(await count("select 1 from aso_ebi_palettes")).toBe(8);
    // Memorial-register palettes exist for burial events.
    expect(
      await count("select 1 from aso_ebi_palettes where register='memorial'"),
    ).toBe(2);
  });
});

describe("reference seed — idempotency", () => {
  it("re-applying the reference seed changes nothing", async () => {
    const before = await count("select 1 from program_templates");
    await t.db.exec(readSql(REFERENCE_SEED));
    await t.db.exec(readSql(REFERENCE_SEED));
    expect(await count("select 1 from program_templates")).toBe(before);
    expect(await count("select 1 from price_bands")).toBe(120);
    expect(await count("select 1 from tips")).toBe(14);
  });
});

describe("demo events (supabase/seed.sql)", () => {
  it("creates both demo events with profiles via the signup trigger", async () => {
    expect(await count("select 1 from events")).toBe(2);
    expect(await count("select 1 from events where mode='memorial'")).toBe(1);
    expect(await count("select 1 from events where mode='celebration'")).toBe(1);
    // 8 demo users, created by the on_auth_user_created trigger.
    expect(await count("select 1 from users")).toBe(8);
    expect(await count("select 1 from committee_members")).toBe(8);
    expect(await count("select 1 from tasks")).toBe(7);
    expect(await count("select 1 from contributions")).toBe(4);
    // Each demo event has a finance workstream (drives contribution privacy).
    expect(await count("select 1 from workstreams where slug='finance'")).toBe(2);
  });

  it("is idempotent — re-running seed.sql does not duplicate", async () => {
    await t.db.exec(readSql(DEMO_SEED));
    expect(await count("select 1 from events")).toBe(2);
    expect(await count("select 1 from users")).toBe(8);
    expect(await count("select 1 from contributions")).toBe(4);
  });
});
