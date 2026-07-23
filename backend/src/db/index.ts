import 'dotenv/config';
import { Pool } from 'pg';
import { drizzle } from 'drizzle-orm/node-postgres';
import * as schema from './schema.js';

const DATABASE_URL = process.env.DATABASE_URL;

if (!DATABASE_URL) {
  throw new Error('DATABASE_URL environment variable is required');
}

// Create a connection pool with production-ready configuration
const pool = new Pool({
  connectionString: DATABASE_URL,
  // Connection pool settings optimized for production
  max: Number(process.env.DB_POOL_MAX) || 20,           // Maximum connections in pool
  min: Number(process.env.DB_POOL_MIN) || 0,            // Minimum connections in pool (0 recommended for Neon)
  idleTimeoutMillis: 30000,                             // Close idle connections after 30s
  connectionTimeoutMillis: 5000,                       // 5 second connection timeout
  maxLifetimeSeconds: 60 * 60,                         // Recycle connections after 1 hour
  // SSL configuration for production
  ssl: process.env.NODE_ENV === 'production' ? {
    rejectUnauthorized: false, // For self-signed certificates (Neon DB)
  } : undefined,
});

// Log connection events for debugging
pool.on('connect', () => {
  console.log('✅ Connected to PostgreSQL');
});

pool.on('error', (err) => {
  console.error('❌ PostgreSQL connection error:', err);
});

// Log pool statistics in development
if (process.env.NODE_ENV === 'development') {
  pool.on('connect', () => {
    console.log(`Pool stats: total=${pool.totalCount}, idle=${pool.idleCount}, waiting=${pool.waitingCount}`);
  });
}

// Export the pool for graceful shutdown
export { pool };

// Export the Drizzle ORM instance for the rest of the app
export const db = drizzle(pool, { schema });
