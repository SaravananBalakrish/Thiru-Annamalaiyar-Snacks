import { config } from "dotenv";
import { defineConfig } from "drizzle-kit";

config({
  path: process.env.NODE_ENV === "production"
    ? ".env.production"
    : ".env",
});

/**
 * DATABASE_DIRECT_URL is the Neon direct (non-pooler) connection string.
 * drizzle-kit CLI tools require a direct connection — Neon's pooler (PgBouncer)
 * does not support the session-level protocol these tools rely on.
 *
 * Fallback to DATABASE_URL for local dev where no pooler is involved.
 */
export default defineConfig({
  schema: "./src/db/schema.ts",
  out: "./drizzle",
  dialect: "postgresql",
  dbCredentials: {
    url: process.env.DATABASE_DIRECT_URL ?? process.env.DATABASE_URL!,
  },
});