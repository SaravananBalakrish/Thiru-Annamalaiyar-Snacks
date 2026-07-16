import type { OpenAPIObject } from 'openapi3-ts/oas31';

const PORT = Number(process.env.PORT) || 3000;

export const openapiSpec: OpenAPIObject = {
  openapi: '3.1.0',
  info: {
    title: 'e‑Shop API',
    version: '1.0.0',
    description: 'REST API for the e‑shop demo application.',
  },
  // Absolute URL so Scalar "Test request" works
  servers: [{ url: `http://localhost:${PORT}` }],
  paths: {
    // ─── Auth ─────────────────────────────────────────────────────────────────
    '/v1/auth/request-otp': {
      post: {
        tags: ['Auth'],
        summary: 'Request OTP via phone',
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['phone'],
                properties: {
                  phone: { type: 'string', minLength: 10, maxLength: 20, description: 'Phone number (e.g., +918681020301 or 8681020301)' },
                },
              },
            },
          },
        },
        responses: {
          '200': { description: 'OTP sent successfully' },
          '400': { description: 'Invalid phone number' },
        },
      },
    },
    '/v1/auth/verify-otp': {
      post: {
        tags: ['Auth'],
        summary: 'Verify OTP and receive JWT',
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['phone', 'code'],
                properties: {
                  phone: { type: 'string', minLength: 10, maxLength: 20, description: 'Phone number' },
                  code: { type: 'string', minLength: 6, maxLength: 6, description: '6-digit OTP code' },
                },
              },
            },
          },
        },
        responses: {
          '200': { description: 'OTP valid, returns JWT token' },
          '400': { description: 'Invalid or expired OTP' },
        },
      },
    },

    // ─── Products ────────────────────────────────────────────────────────────
    '/v1/products': {
      get: {
        tags: ['Products'],
        summary: 'List all products',
        responses: {
          '200': {
            description: 'A list of products',
            content: { 'application/json': { schema: { type: 'array', items: { $ref: '#/components/schemas/Product' } } } },
          },
        },
      },
      post: {
        tags: ['Products'],
        summary: 'Create a new product',
        requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/ProductInput' } } } },
        responses: {
          '201': { description: 'Product created', content: { 'application/json': { schema: { $ref: '#/components/schemas/Product' } } } },
          '400': { description: 'Invalid input' },
        },
      },
    },
    '/v1/products/{id}': {
      parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'integer' } }],
      get: {
        tags: ['Products'],
        summary: 'Get a product by ID',
        responses: {
          '200': { description: 'Product object', content: { 'application/json': { schema: { $ref: '#/components/schemas/Product' } } } },
          '400': { description: 'Invalid id' },
          '404': { description: 'Not found' },
        },
      },
      put: {
        tags: ['Products'],
        summary: 'Update a product',
        requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/ProductInput' } } } },
        responses: {
          '200': { description: 'Product updated', content: { 'application/json': { schema: { $ref: '#/components/schemas/Product' } } } },
          '400': { description: 'Invalid input' },
          '404': { description: 'Not found' },
        },
      },
      delete: {
        tags: ['Products'],
        summary: 'Delete a product',
        responses: {
          '200': { description: 'Product deleted' },
          '404': { description: 'Not found' },
        },
      },
    },

    // ─── Categories ──────────────────────────────────────────────────────────
    '/v1/categories': {
      get: {
        tags: ['Categories'],
        summary: 'List all categories',
        responses: {
          '200': { description: 'Categories list', content: { 'application/json': { schema: { type: 'array', items: { $ref: '#/components/schemas/Category' } } } } },
        },
      },
      post: {
        tags: ['Categories'],
        summary: 'Create a category',
        requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/CategoryInput' } } } },
        responses: {
          '201': { description: 'Created', content: { 'application/json': { schema: { $ref: '#/components/schemas/Category' } } } },
          '400': { description: 'Invalid input' },
        },
      },
    },
    '/v1/categories/{id}': {
      parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'integer' } }],
      get: {
        tags: ['Categories'],
        summary: 'Get category by ID',
        responses: {
          '200': { description: 'Category object', content: { 'application/json': { schema: { $ref: '#/components/schemas/Category' } } } },
          '400': { description: 'Invalid id' },
          '404': { description: 'Not found' },
        },
      },
      put: {
        tags: ['Categories'],
        summary: 'Update category',
        requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/CategoryInput' } } } },
        responses: {
          '200': { description: 'Updated', content: { 'application/json': { schema: { $ref: '#/components/schemas/Category' } } } },
          '400': { description: 'Invalid input' },
          '404': { description: 'Not found' },
        },
      },
      delete: {
        tags: ['Categories'],
        summary: 'Delete category',
        responses: {
          '200': { description: 'Category deleted' },
          '404': { description: 'Not found' },
        },
      },
    },

    // ─── Cart ─────────────────────────────────────────────────────────────────
    '/v1/cart': {
      get: {
        tags: ['Cart'],
        summary: 'List cart items (with product details)',
        responses: {
          '200': { description: 'Cart items', content: { 'application/json': { schema: { type: 'array', items: { $ref: '#/components/schemas/CartItem' } } } } },
        },
      },
      post: {
        tags: ['Cart'],
        summary: 'Add item to cart (upserts quantity if already present)',
        requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/CartAdd' } } } },
        responses: {
          '200': { description: 'Quantity updated (item already existed)' },
          '201': { description: 'Item added to cart' },
          '400': { description: 'Invalid input' },
          '404': { description: 'Product not found' },
        },
      },
    },
    '/v1/cart/{id}': {
      parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'integer' } }],
      patch: {
        tags: ['Cart'],
        summary: 'Update cart item quantity',
        requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/CartPatch' } } } },
        responses: {
          '200': { description: 'Quantity updated' },
          '400': { description: 'Invalid input' },
          '404': { description: 'Cart item not found' },
        },
      },
      delete: {
        tags: ['Cart'],
        summary: 'Remove item from cart',
        responses: {
          '200': { description: 'Item removed' },
          '404': { description: 'Cart item not found' },
        },
      },
    },

    // ─── Orders ───────────────────────────────────────────────────────────────
    '/v1/orders': {
      get: {
        tags: ['Orders'],
        summary: 'List all orders (optionally filter by userId)',
        parameters: [{ name: 'userId', in: 'query', required: false, schema: { type: 'integer' } }],
        responses: {
          '200': {
            description: 'A list of orders',
            content: { 'application/json': { schema: { type: 'array', items: { $ref: '#/components/schemas/Order' } } } },
          },
          '400': { description: 'Invalid userId query parameter' },
        },
      },
      post: {
        tags: ['Orders'],
        summary: 'Place an order (checkout the current cart)',
        requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/OrderInput' } } } },
        responses: {
          '201': {
            description: 'Order placed successfully',
            content: { 'application/json': { schema: { $ref: '#/components/schemas/Order' } } },
          },
          '400': { description: 'Cart is empty or invalid input' },
        },
      },
    },
    '/v1/orders/{id}': {
      parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'integer' } }],
      get: {
        tags: ['Orders'],
        summary: 'Get order details by ID',
        responses: {
          '200': {
            description: 'Order details with items',
            content: { 'application/json': { schema: { $ref: '#/components/schemas/Order' } } },
          },
          '400': { description: 'Invalid id parameter' },
          '404': { description: 'Order not found' },
        },
      },
    },
    '/v1/orders/{id}/pay': {
      parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'integer' } }],
      post: {
        tags: ['Orders'],
        summary: 'Confirm UPI/digital payment for an order using transaction reference',
        requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/PayOrderInput' } } } },
        responses: {
          '200': {
            description: 'Payment successful, order marked as paid',
            content: { 'application/json': { schema: { $ref: '#/components/schemas/Order' } } },
          },
          '400': { description: 'Invalid input or transaction reference' },
          '404': { description: 'Order not found' },
        },
      },
    },
    // ---- Reviews ----
    '/v1/reviews': {
      get: {
        tags: ['Reviews'],
        summary: 'List all reviews (Admin)',
        security: [{ Bearer: [] }],
        responses: {
          '200': {
            description: 'A list of reviews',
            content: { 'application/json': { schema: { type: 'array', items: { $ref: '#/components/schemas/Review' } } } },
          },
          '401': { description: 'Unauthorized' },
        },
      },
      post: {
        tags: ['Reviews'],
        summary: 'Create a new review',
        security: [{ Bearer: [] }],
        requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/ReviewInput' } } } },
        responses: {
          '201': { description: 'Review created', content: { 'application/json': { schema: { $ref: '#/components/schemas/Review' } } } },
          '400': { description: 'Invalid input' },
          '401': { description: 'Unauthorized' },
          '404': { description: 'Product not found' },
        },
      },
    },
    '/v1/reviews/product/{productId}': {
      get: {
        tags: ['Reviews'],
        summary: 'List all reviews for a product',
        parameters: [{ name: 'productId', in: 'path', required: true, schema: { type: 'integer' } }],
        responses: {
          '200': {
            description: 'A list of reviews for the product',
            content: { 'application/json': { schema: { type: 'array', items: { $ref: '#/components/schemas/Review' } } } },
          },
          '400': { description: 'Invalid productId' },
        },
      },
    },
    '/v1/reviews/{id}': {
      get: {
        tags: ['Reviews'],
        summary: 'Get a review by ID',
        parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'integer' } }],
        responses: {
          '200': { description: 'Review object', content: { 'application/json': { schema: { $ref: '#/components/schemas/Review' } } } },
          '400': { description: 'Invalid id' },
          '404': { description: 'Review not found' },
        },
      },
      put: {
        tags: ['Reviews'],
        summary: 'Update a review (Owner only)',
        security: [{ Bearer: [] }],
        parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'integer' } }],
        requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/ReviewUpdate' } } } },
        responses: {
          '200': { description: 'Review updated', content: { 'application/json': { schema: { $ref: '#/components/schemas/Review' } } } },
          '400': { description: 'Invalid input' },
          '401': { description: 'Unauthorized' },
          '404': { description: 'Review not found or not authorized' },
        },
      },
      delete: {
        tags: ['Reviews'],
        summary: 'Delete a review (Owner only)',
        security: [{ Bearer: [] }],
        parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'integer' } }],
        responses: {
          '200': { description: 'Review deleted' },
          '400': { description: 'Invalid id' },
          '401': { description: 'Unauthorized' },
          '404': { description: 'Review not found or not authorized' },
        },
      },
    },
  },

  components: {
    schemas: {
      // ── Domain models ────────────────────────────────────────────────────
      Product: {
        type: 'object',
        properties: {
          id: { type: 'integer' },
          name: { type: 'string' },
          description: { type: 'string' },
          price: { type: 'string', description: 'Decimal value as string (e.g. "9.99")' },
          imageUrl: { type: 'string', format: 'uri' },
          categoryId: { type: 'integer' },
        },
      },
      Category: {
        type: 'object',
        properties: {
          id: { type: 'integer' },
          name: { type: 'string' },
        },
      },
      CartItem: {
        type: 'object',
        properties: {
          id: { type: 'integer' },
          quantity: { type: 'integer' },
          product: { $ref: '#/components/schemas/Product' },
        },
      },
      Order: {
        type: 'object',
        properties: {
          id: { type: 'integer' },
          userId: { type: 'integer' },
          totalPrice: { type: 'string', description: 'Decimal total price (e.g. "49.95")' },
          createdAt: { type: 'string', format: 'date-time' },
          paymentMethod: { type: 'string', description: 'e.g. "gpay", "phonepe", "upi"' },
          paymentStatus: { type: 'string', description: 'e.g. "pending", "paid"' },
          transactionRef: { type: 'string', description: 'UPI transaction reference / UTR number' },
          upiUri: { type: 'string', description: 'UPI deep link for GPay/PhonePe' },
          qrCodeUrl: { type: 'string', description: 'URL to the scan-and-pay QR code' },
          items: {
            type: 'array',
            items: { $ref: '#/components/schemas/OrderItem' },
          },
        },
      },
      OrderItem: {
        type: 'object',
        properties: {
          id: { type: 'integer' },
          orderId: { type: 'integer' },
          productId: { type: 'integer' },
          quantity: { type: 'integer' },
          price: { type: 'string', description: 'Decimal price of product at order time (e.g. "24.98")' },
        },
      },

      // ── Input schemas ────────────────────────────────────────────────────
      ProductInput: {
        type: 'object',
        required: ['name', 'price'],
        properties: {
          name: { type: 'string', minLength: 1 },
          description: { type: 'string' },
          price: { type: 'number', minimum: 0, example: 9.99 },
          imageUrl: { type: 'string', format: 'uri' },
          categoryId: { type: 'integer' },
        },
      },
      CategoryInput: {
        type: 'object',
        required: ['name'],
        properties: {
          name: { type: 'string', minLength: 1, maxLength: 100 },
        },
      },
      CartAdd: {
        type: 'object',
        required: ['productId'],
        properties: {
          productId: { type: 'integer', minimum: 1 },
          quantity: { type: 'integer', minimum: 1, default: 1 },
        },
      },
      CartPatch: {
        type: 'object',
        required: ['quantity'],
        properties: {
          quantity: { type: 'integer', minimum: 1 },
        },
      },
      OrderInput: {
        type: 'object',
        required: ['userId'],
        properties: {
          userId: { type: 'integer', minimum: 1 },
          paymentMethod: { type: 'string', default: 'upi', description: 'e.g. "gpay", "phonepe", "upi"' },
        },
      },
      PayOrderInput: {
        type: 'object',
        required: ['transactionRef'],
        properties: {
          transactionRef: { type: 'string', minLength: 1, description: 'UPI Transaction Reference / UTR number' },
        },
      },
      // --- Reviews ---
      Review: {
        type: 'object',
        properties: {
          id: { type: 'integer' },
          productId: { type: 'integer' },
          userId: { type: 'integer' },
          rating: { type: 'integer', minimum: 1, maximum: 5, description: 'Rating from 1 to 5' },
          comment: { type: 'string', description: 'Review comment' },
          createdAt: { type: 'string', format: 'date-time' },
        },
      },
      ReviewInput: {
        type: 'object',
        required: ['productId', 'rating'],
        properties: {
          productId: { type: 'integer', minimum: 1 },
          rating: { type: 'integer', minimum: 1, maximum: 5 },
          comment: { type: 'string' },
        },
      },
      ReviewUpdate: {
        type: 'object',
        properties: {
          rating: { type: 'integer', minimum: 1, maximum: 5 },
          comment: { type: 'string' },
        },
      },
    },
  },
};
