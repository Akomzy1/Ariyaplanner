import { fileURLToPath } from "node:url";
import { defineConfig } from "vitest/config";

export default defineConfig({
  resolve: {
    // Mirror the tsconfig "@/*" path alias for test imports.
    alias: {
      "@": fileURLToPath(new URL(".", import.meta.url)),
    },
  },
  test: {
    include: ["tests/**/*.test.ts"],
    // PGlite loads a WASM Postgres on first use; give setup room.
    hookTimeout: 60_000,
    testTimeout: 30_000,
  },
});
