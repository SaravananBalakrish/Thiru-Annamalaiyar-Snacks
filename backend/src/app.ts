import 'dotenv/config';
import { OpenAPIHono } from '@hono/zod-openapi';
import { cors } from 'hono/cors';
import { swaggerUI } from '@hono/swagger-ui';
import { db } from './db/index.js';
import { requestLogger } from './middleware/logger.middleware.js';
import { apiRateLimiter } from './middleware/rateLimiter.middleware.js';
import { apiSecurityHeaders } from './middleware/security.middleware.js';
import productRoutes from './routes/products.js';
import categoryRoutes from './routes/categories.js';
import cartRoutes from './routes/cart.js';
import orderRoutes from './routes/orders.js';
import authRoutes from './routes/auth.js';
import addressRoutes from './routes/addresses.js';
import reviewRoutes from './routes/reviews.js';
import adminRoutes from './routes/admin.js';
import { openapiSpec } from './openapi.js';

const app = new OpenAPIHono();

// =============================================================================
// Global Middleware (executed in order)
// =============================================================================

// 1. Request logging middleware (must be first to capture all requests)
app.use('*', requestLogger);

// 2. Rate limiting middleware (applied to all routes)
app.use('*', apiRateLimiter);

// 3. Security headers middleware (protects against common vulnerabilities)
app.use('*', apiSecurityHeaders);

// 4. Configure CORS with client URL from environment
const clientUrl = process.env.CLIENT_URL || 'http://localhost:5173';
app.use('*', cors({
  origin: clientUrl,
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
}));

// Register versioned API routes
app.route('/v1/auth', authRoutes);
app.route('/v1/products', productRoutes);
app.route('/v1/categories', categoryRoutes);
app.route('/v1/cart', cartRoutes);
app.route('/v1/orders', orderRoutes);
app.route('/v1/addresses', addressRoutes);
app.route('/v1/reviews', reviewRoutes);
app.route('/v1/admin', adminRoutes);

// Base OpenAPI configuration
const PORT = Number(process.env.PORT) || 3000;

const openapiConfig = {
  openapi: '3.1.0',
  info: {
    title: 'e‑Shop API',
    version: '1.0.0',
    description: 'REST API for the e‑shop demo application.',
  },
  servers: [{ url: `http://localhost:${PORT}` }],
};

const getOpenApiDocument = () => {
  const baseDoc = app.getOpenAPIDocument(openapiConfig);
  const mergedComponents = {
    ...baseDoc.components,
    ...(openapiSpec.components ?? {}),
    securitySchemes: {
      ...(baseDoc.components?.securitySchemes ?? {}),
      Bearer: {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
      },
    },
  };
  return {
    ...baseDoc,
    paths: {
      ...openapiSpec.paths,
      ...(baseDoc.paths ?? {}),
    },
    components: mergedComponents,
  } as const;
};

// Serve OpenAPI JSON (no‑cache)
app.get('/v1/openapi.json', (c) => {
  const response = c.json(getOpenApiDocument());
  response.headers.set('Cache-Control', 'no-store');
  return response;
});

// Interactive API reference UI (Swagger UI) - Industry standard & reliable
app.get('/v1/docs', swaggerUI({ url: '/v1/openapi.json' }));

// Modern Scalar API Reference UI (Web Component)
app.get('/v1/scalar', (c) => {
  return c.html(`<!doctype html>
<html>
  <head>
    <title>e‑Shop API Reference (Scalar)</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
  </head>
  <body>
    <script
      id="api-reference"
      type="application/json"
      data-url="/v1/openapi.json">
    </script>
    <script src="https://cdn.jsdelivr.net/npm/@scalar/api-reference"></script>
  </body>
</html>`);
});

// =============================================================================
// Health Checks
// =============================================================================

// Basic liveness probe - always returns 200 if server is running
app.get('/health/live', (c) => {
  return c.json({
    status: 'live',
    timestamp: new Date().toISOString(),
  });
});

// Readiness probe - checks database connectivity
app.get('/health/ready', async (c) => {
  try {
    // Test database connection by running a simple query
    const start = Date.now();
    await db.query.users.findFirst();
    const duration = Date.now() - start;

    return c.json({
      status: 'ready',
      timestamp: new Date().toISOString(),
      checks: {
        database: {
          status: 'ok',
          responseTimeMs: duration,
        },
      },
    });
  } catch (error) {
    console.error('Health check failed:', error);
    return c.json({
      status: 'not_ready',
      timestamp: new Date().toISOString(),
      checks: {
        database: {
          status: 'error',
          error: error instanceof Error ? error.message : 'Unknown error',
        },
      },
    }, 503);
  }
});

// Detailed health check with all dependencies
app.get('/health', async (c) => {
  const health: Record<string, any> = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
    checks: {},
  };

  try {
    // Database check
    const dbStart = Date.now();
    await db.query.users.findFirst();
    health.checks.database = {
      status: 'ok',
      responseTimeMs: Date.now() - dbStart,
    };
  } catch (error) {
    health.status = 'degraded';
    health.checks.database = {
      status: 'error',
      error: error instanceof Error ? error.message : 'Unknown error',
    };
  }

  // Cache check (placeholder for future Redis check)
  health.checks.cache = {
    status: 'not_configured',
    note: 'Redis health check not implemented',
  };

  // Determine overall status
  const allChecks = Object.values(health.checks) as Array<{ status: string }>;
  const hasErrors = allChecks.some(check => check.status === 'error');
  const hasDegraded = allChecks.some(check => check.status === 'degraded');

  if (hasErrors) {
    health.status = 'unhealthy';
    return c.json(health, 503);
  }
  if (hasDegraded) {
    health.status = 'degraded';
    return c.json(health, 200);
  }

  return c.json(health);
});

// Legacy root health check (keep for backward compatibility)
app.get('/', (c) => c.json({ status: 'ok', message: 'e‑Shop API is running' }));

export default app;
