import 'dotenv/config';
import { serve } from '@hono/node-server';
import app from './app.js';

const PORT = Number(process.env.PORT) || 3000;

const server = serve({
  fetch: app.fetch,
  port: PORT,
});

console.log(`🚀 Server running at http://localhost:${PORT}`);
console.log(`📚 API docs at    http://localhost:${PORT}/v1/docs`);
console.log(`📄 OpenAPI JSON  http://localhost:${PORT}/v1/openapi.json`);
