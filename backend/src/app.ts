import 'dotenv/config';
import { OpenAPIHono } from '@hono/zod-openapi';
import { cors } from 'hono/cors';
import { Scalar } from '@scalar/hono-api-reference';
import productRoutes from './routes/products.js';
import categoryRoutes from './routes/categories.js';
import cartRoutes from './routes/cart.js';
import orderRoutes from './routes/orders.js';
import authRoutes from './routes/auth.js';
import addressRoutes from './routes/addresses.js';
import reviewRoutes from './routes/reviews.js';
import { openapiSpec } from './openapi.js';

const app = new OpenAPIHono();

// Global CORS – adjust origins as needed
app.use('*', cors());

// Register versioned API routes
app.route('/v1/products', productRoutes);
app.route('/v1/categories', categoryRoutes);
app.route('/v1/cart', cartRoutes);
app.route('/v1/orders', orderRoutes);
app.route('/v1/auth', authRoutes);
app.route('/v1/addresses', addressRoutes);
app.route('/v1/reviews', reviewRoutes);

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

// Interactive API reference UI (Scalar)
app.get(
  '/v1/docs',
  Scalar({
    spec: { url: '/v1/openapi.json' },
    theme: 'default',
    darkMode: false,
  }),
);

// Health check
app.get('/', (c) => c.json({ status: 'ok', message: 'e‑Shop API is running' }));

export default app;
