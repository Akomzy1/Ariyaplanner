import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { createTestDb, type TestDb } from "./db/harness";
import { ids, seed } from "./db/seed";

let t: TestDb;
const U = ids.users;

beforeAll(async () => {
  t = await createTestDb();
  await t.asAdmin(seed);
});

afterAll(async () => {
  await t.close();
});

// Count rows a given user can see from `table` (optionally filtered).
async function countAs(sub: string | null, sql: string, params: unknown[] = []) {
  return t.asRole(sub ? { sub } : { role: "anon" }, async (q) => {
    const { rows } = await q<{ n: string }>(
      `select count(*)::text as n from (${sql}) s`,
      params,
    );
    return Number(rows[0]!.n);
  });
}

describe("events — event-scoped visibility", () => {
  it("members and the creator see Event A; outsiders do not", async () => {
    const q = "select 1 from events where id = $1";
    expect(await countAs(U.host, q, [ids.eventA])).toBe(1);
    expect(await countAs(U.coord, q, [ids.eventA])).toBe(1);
    expect(await countAs(U.finance, q, [ids.eventA])).toBe(1);
    expect(await countAs(U.member, q, [ids.eventA])).toBe(1);
    expect(await countAs(U.outsider, q, [ids.eventA])).toBe(0);
  });

  it("a member of A cannot see the outsider's Event B", async () => {
    expect(
      await countAs(U.member, "select 1 from events where id = $1", [
        ids.eventB,
      ]),
    ).toBe(0);
  });

  it("insert is allowed only with created_by = self", async () => {
    // Self as creator — allowed.
    const affected = await t.asRole({ sub: U.member }, async (q) => {
      const { affectedRows } = await q(
        `insert into events (created_by, type, title) values ($1, 'naming', 'Mine')`,
        [U.member],
      );
      return affectedRows;
    });
    expect(affected).toBe(1);

    // Creating on someone else's behalf — blocked by WITH CHECK.
    await expect(
      t.asRole({ sub: U.member }, (q) =>
        q(
          `insert into events (created_by, type, title) values ($1, 'naming', 'NotMine')`,
          [U.host],
        ),
      ),
    ).rejects.toThrow(/row-level security/i);
  });

  it("only coordinators can update; a plain member cannot", async () => {
    const coordAffected = await t.asRole({ sub: U.coord }, async (q) => {
      const { affectedRows } = await q(
        `update events set title = 'Renamed' where id = $1`,
        [ids.eventA],
      );
      return affectedRows;
    });
    expect(coordAffected).toBe(1);

    const memberAffected = await t.asRole({ sub: U.member }, async (q) => {
      const { affectedRows } = await q(
        `update events set title = 'Hacked' where id = $1`,
        [ids.eventA],
      );
      return affectedRows;
    });
    expect(memberAffected).toBe(0);
  });
});

describe("contributions — amount privacy", () => {
  const q = "select 1 from contributions where event_id = $1";

  it("Chief Host and Finance lead see all amounts", async () => {
    expect(await countAs(U.host, q, [ids.eventA])).toBe(2);
    expect(await countAs(U.finance, q, [ids.eventA])).toBe(2);
  });

  it("a plain member sees none", async () => {
    expect(await countAs(U.member, q, [ids.eventA])).toBe(0);
  });

  it("the event_coordinator (not finance lead) sees none", async () => {
    expect(await countAs(U.coord, q, [ids.eventA])).toBe(0);
  });

  it("a contributor sees only their own", async () => {
    expect(await countAs(U.contributor, q, [ids.eventA])).toBe(1);
  });

  it("an outsider sees none", async () => {
    expect(await countAs(U.outsider, q, [ids.eventA])).toBe(0);
  });
});

describe("contributions — append-only", () => {
  it("UPDATE and DELETE are blocked at the DB level (trigger)", async () => {
    await expect(
      t.asAdmin((q) =>
        q(`update contributions set note = 'x' where event_id = $1`, [
          ids.eventA,
        ]),
      ),
    ).rejects.toThrow(/append-only/i);

    await expect(
      t.asAdmin((q) =>
        q(`delete from contributions where event_id = $1`, [ids.eventA]),
      ),
    ).rejects.toThrow(/append-only/i);
  });

  it("a correction is a new row referencing the original", async () => {
    const affected = await t.asRole({ sub: U.finance }, async (q) => {
      const { affectedRows } = await q(
        `insert into contributions
           (event_id, kind, amount_kobo, status, recorded_by, corrects_id)
         values ($1, 'pledge', 45000000, 'pledged', $2, $3)`,
        [ids.eventA, U.finance, ids.contrib.fromContributor],
      );
      return affectedRows;
    });
    expect(affected).toBe(1);
  });
});

describe("suggestions — F2a privacy", () => {
  const q = "select 1 from suggestions where event_id = $1";

  it("the suggester and coordinators see it; other members do not", async () => {
    expect(await countAs(U.member, q, [ids.eventA])).toBe(1); // suggester
    expect(await countAs(U.coord, q, [ids.eventA])).toBe(1); // coordinator
    expect(await countAs(U.host, q, [ids.eventA])).toBe(1); // chief host
    expect(await countAs(U.contributor, q, [ids.eventA])).toBe(0); // other member
  });

  it("a member may submit a suggestion for themselves", async () => {
    const affected = await t.asRole({ sub: U.contributor }, async (q) => {
      const { affectedRows } = await q(
        `insert into suggestions (event_id, suggester_id, item)
         values ($1, $2, 'Extra ushers')`,
        [ids.eventA, U.contributor],
      );
      return affectedRows;
    });
    expect(affected).toBe(1);
  });

  it("an outsider cannot submit a suggestion", async () => {
    await expect(
      t.asRole({ sub: U.outsider }, (q) =>
        q(
          `insert into suggestions (event_id, suggester_id, item)
           values ($1, $2, 'Intruder')`,
          [ids.eventA, U.outsider],
        ),
      ),
    ).rejects.toThrow(/row-level security/i);
  });
});

describe("committee & roster", () => {
  it("members see the roster; outsiders see nothing", async () => {
    const q = "select 1 from committee_members where event_id = $1";
    expect(await countAs(U.member, q, [ids.eventA])).toBe(4);
    expect(await countAs(U.outsider, q, [ids.eventA])).toBe(0);
  });
});

describe("reference content — public vs gated", () => {
  it("anonymous visitors can read the price index", async () => {
    expect(await countAs(null, "select 1 from price_bands")).toBeGreaterThan(0);
  });

  it("only is_live templates and tips are visible to anon", async () => {
    expect(await countAs(null, "select 1 from program_templates")).toBe(1);
    expect(await countAs(null, "select 1 from tips")).toBe(1);
  });

  it("idea assets and the vendor registry require authentication", async () => {
    expect(await countAs(null, "select 1 from idea_assets")).toBe(0);
    expect(await countAs(U.member, "select 1 from idea_assets")).toBe(1);
    expect(await countAs(null, "select 1 from vendors")).toBe(0);
    expect(await countAs(U.member, "select 1 from vendors")).toBe(1);
  });
});

describe("service role", () => {
  it("bypasses RLS to read all contributions across events", async () => {
    const n = await t.asRole({ role: "service_role" }, async (q) => {
      const { rows } = await q<{ n: string }>(
        "select count(*)::text as n from contributions",
      );
      return Number(rows[0]!.n);
    });
    // 2 on Event A + 1 on Event B.
    expect(n).toBe(3);
  });
});
