import { readdirSync, readFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { PGlite } from "@electric-sql/pglite";

const here = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(here, "..", "..");
const migrationsDir = join(repoRoot, "supabase", "migrations");
const bootstrapPath = join(here, "bootstrap.sql");

/** Read a SQL file by its path relative to the repo root. */
export function readSql(relPath: string): string {
  return readFileSync(join(repoRoot, relPath), "utf8");
}

export type Claims = { sub?: string; role?: string };

export interface TestDb {
  db: PGlite;
  /**
   * Run `fn` inside a transaction as the given role, with request.jwt.claims
   * set so auth.uid()/auth.role() resolve as they do on Supabase. The
   * transaction is always rolled back, keeping seeded data isolated between
   * tests. Pass no claims (or role 'anon') to act as an anonymous visitor.
   */
  asRole<T>(claims: Claims, fn: (q: Query) => Promise<T>): Promise<T>;
  /** Run `fn` as the seeding superuser (bypasses RLS). */
  asAdmin<T>(fn: (q: Query) => Promise<T>): Promise<T>;
  close(): Promise<void>;
}

export type Query = <R = Record<string, unknown>>(
  sql: string,
  params?: unknown[],
) => Promise<{ rows: R[]; affectedRows: number }>;

function migrationFiles(includeSeeds: boolean): string[] {
  return readdirSync(migrationsDir)
    .filter((f) => f.endsWith(".sql"))
    .filter((f) => includeSeeds || !f.includes("seed"))
    .sort();
}

export interface CreateTestDbOptions {
  /** Apply data-seed migrations (files whose name contains "seed"). Default false
   *  so RLS tests run against schema only, with their own fixtures. */
  includeSeeds?: boolean;
}

/** Fresh in-memory database with the shim + migrations applied. */
export async function createTestDb(
  opts: CreateTestDbOptions = {},
): Promise<TestDb> {
  const db = new PGlite();
  await db.exec(readFileSync(bootstrapPath, "utf8"));
  for (const file of migrationFiles(opts.includeSeeds ?? false)) {
    await db.exec(readFileSync(join(migrationsDir, file), "utf8"));
  }

  const makeQuery =
    (client: PGlite): Query =>
    async (sql, params = []) => {
      const res = await client.query(sql, params);
      return {
        rows: (res.rows ?? []) as never[],
        affectedRows: res.affectedRows ?? 0,
      };
    };

  const asRole: TestDb["asRole"] = async (claims, fn) => {
    await db.exec("begin");
    try {
      const role = claims.role ?? (claims.sub ? "authenticated" : "anon");
      const jwt = JSON.stringify({ ...claims, role });
      // set_config(local=true) scopes the claims to this transaction.
      await db.query("select set_config('request.jwt.claims', $1, true)", [jwt]);
      await db.exec(`set local role ${role}`);
      return await fn(makeQuery(db));
    } finally {
      await db.exec("rollback");
    }
  };

  const asAdmin: TestDb["asAdmin"] = async (fn) => {
    return fn(makeQuery(db));
  };

  return {
    db,
    asRole,
    asAdmin,
    close: () => db.close(),
  };
}
