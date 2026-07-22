import { config } from "dotenv";

// Load correct env file before anything else
config({
  path: process.env.NODE_ENV === "production" ? ".env.production" : ".env",
});

import { drizzle } from "drizzle-orm/neon-http";
import { migrate } from "drizzle-orm/neon-http/migrator";
import { neon } from "@neondatabase/serverless";
import path from "path";
import { fileURLToPath } from "url";

// Resolve the migrations folder relative to this file
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const migrationsFolder = path.resolve(__dirname, "../../drizzle");

/**
 * DATABASE_DIRECT_URL must be a non-pooled (direct) Neon connection string.
 *
 * We use Neon's HTTP driver here because:
 *  - It is stateless and works perfectly for migrations (no persistent session)
 *  - It bypasses PgBouncer's transaction-mode limitations entirely
 *  - It correctly maintains schema context across the migration transaction
 *
 * Local dev: DATABASE_DIRECT_URL = same as DATABASE_URL (localhost, no pooler)
 * Production: DATABASE_DIRECT_URL = Neon direct (non-pooler) URL
 */
const connectionString = process.env.DATABASE_DIRECT_URL || process.env.DATABASE_URL || '';

if (!connectionString) {
  console.error(
    "❌ DATABASE_DIRECT_URL is not set.\n" +
    "   Set it in your .env file (local) or as an environment variable (production).\n" +
    "   For production: use the Neon direct (non-pooler) connection string."
  );
  process.exit(1);
}

async function runMigrations(): Promise<void> {
  console.log("🔄 Running database migrations...");
  console.log(`   Migrations folder: ${migrationsFolder}`);
  console.log(`   Environment: ${process.env.NODE_ENV ?? "development"}`);

  // For local dev (non-Neon), fall back to node-postgres
  const isNeon = connectionString.includes("neon.tech");

  if (isNeon) {
    const sql = neon(connectionString as string);
    const db = drizzle(sql);
    try {
      await migrate(db, { migrationsFolder });
      console.log("✅ All migrations applied successfully.");
    } catch (error) {
      console.error("❌ Migration failed:", (error as Error).message);
      throw error;
    }
  } else {
    // Local PostgreSQL — use node-postgres driver
    const { Pool } = await import("pg");
    const { drizzle: pgDrizzle } = await import("drizzle-orm/node-postgres");
    const { migrate: pgMigrate } = await import("drizzle-orm/node-postgres/migrator");

    const pool = new Pool({ connectionString: connectionString as string, max: 1 });
    const db = pgDrizzle(pool);
    try {
      await pgMigrate(db, { migrationsFolder });
      console.log("✅ All migrations applied successfully.");
    } catch (error) {
      console.error("❌ Migration failed:", (error as Error).message);
      throw error;
    } finally {
      await pool.end();
      console.log("🔌 Database connection closed.");
    }
  }
}

runMigrations().catch(() => process.exit(1));
