import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    include: ["tests/**/*.test.ts"],
    // PGlite loads a WASM Postgres on first use; give setup room.
    hookTimeout: 60_000,
    testTimeout: 30_000,
  },
});
