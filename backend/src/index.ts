import 'dotenv/config';
import { serve } from '@hono/node-server';
import { pool } from './db/index.js';
import app from './app.js';

const PORT = Number(process.env.PORT) || 3000;

const server = serve({
  fetch: app.fetch,
  port: PORT,
  hostname: '0.0.0.0',
});

console.log(`🚀 Server running at http://localhost:${PORT}`);
console.log(`📚 API docs at    http://localhost:${PORT}/v1/docs`);
console.log(`📄 OpenAPI JSON  http://localhost:${PORT}/v1/openapi.json`);

// =============================================================================
// Graceful Shutdown Handler
// =============================================================================
// Handle SIGTERM (sent by Kubernetes, Docker, etc.)
process.on('SIGTERM', async () => {
  console.log('\n🔄 SIGTERM received, shutting down gracefully...');
  
  // Close the HTTP server
  server.close();
  
  // Close all database connections
  try {
    await pool.end();
    console.log('✅ Database connections closed');
  } catch (err) {
    console.error('❌ Error closing database pool:', err);
  }
  
  console.log('✅ Server shutdown complete');
  process.exit(0);
});

// Handle SIGINT (Ctrl+C)
process.on('SIGINT', async () => {
  console.log('\n🔄 SIGINT received, shutting down gracefully...');
  
  // Close the HTTP server
  server.close();
  
  // Close all database connections
  try {
    await pool.end();
    console.log('✅ Database connections closed');
  } catch (err) {
    console.error('❌ Error closing database pool:', err);
  }
  
  console.log('✅ Server shutdown complete');
  process.exit(0);
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  console.error('❌ Uncaught Exception:', err);
  process.exit(1);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason) => {
  console.error('❌ Unhandled Rejection:', reason);
  process.exit(1);
});
