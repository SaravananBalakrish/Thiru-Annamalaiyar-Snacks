import { Hono, Context } from 'hono';
import { eq, and } from 'drizzle-orm';
import { db } from '../db/index.js';
import { cartItems, products } from '../db/schema.js';
import { z } from 'zod';
import { authMiddleware } from '../middleware/auth.middleware.js';

const router = new Hono();

// Apply auth middleware to all cart routes
router.use('*', authMiddleware);

const addItemSchema = z.object({
  productId: z.number().int().positive(),
  quantity: z.number().int().min(1).optional().default(1),
});

// GET / - list cart items with product details for authenticated user
router.get('/', async (c: Context) => {
  try {
    const userId = c.get('userId');
    const items = await db
      .select({
        id: cartItems.id,
        quantity: cartItems.quantity,
        product: {
          id: products.id,
          name: products.name,
          price: products.price,
          imageUrl: products.imageUrl,
        },
      })
      .from(cartItems)
      .leftJoin(products, eq(cartItems.productId, products.id))
      .where(eq(cartItems.userId, userId));
    return c.json(items);
  } catch (err) {
    console.error('[cart] GET /', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// POST / - add item to cart (upserts if product already in cart for this user)
router.post('/', async (c: Context) => {
  try {
    const userId = c.get('userId');
    const body = await c.req.json();
    const parsed = addItemSchema.safeParse(body);
    if (!parsed.success) return c.json({ error: parsed.error.format() }, 400);

    const { productId, quantity } = parsed.data;

    // Validate the product exists
    const product = await db.select().from(products).where(eq(products.id, productId)).limit(1);
    if (product.length === 0) return c.json({ error: 'Product not found' }, 404);

    // Upsert: if item exists for this user, increase quantity
    const existing = await db
      .select()
      .from(cartItems)
      .where(and(eq(cartItems.productId, productId), eq(cartItems.userId, userId)))
      .limit(1);

    if (existing.length > 0) {
      const updated = await db
        .update(cartItems)
        .set({ quantity: existing[0].quantity + quantity })
        .where(eq(cartItems.id, existing[0].id))
        .returning();
      return c.json(updated[0]);
    }

    const [created] = await db.insert(cartItems).values({ userId, productId, quantity }).returning();
    return c.json(created, 201);
  } catch (err) {
    console.error('[cart] POST /', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// PATCH /:id - update cart item quantity
router.patch('/:id', async (c: Context) => {
  try {
    const userId = c.get('userId');
    const id = Number(c.req.param('id'));
    if (isNaN(id)) return c.json({ error: 'Invalid id' }, 400);
    const body = await c.req.json();
    const parsed = z.object({ quantity: z.number().int().min(1) }).safeParse(body);
    if (!parsed.success) return c.json({ error: parsed.error.format() }, 400);
    const updated = await db
      .update(cartItems)
      .set({ quantity: parsed.data.quantity })
      .where(and(eq(cartItems.id, id), eq(cartItems.userId, userId)))
      .returning();
    if (updated.length === 0) return c.notFound();
    return c.json(updated[0]);
  } catch (err) {
    console.error('[cart] PATCH /:id', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// DELETE /:id - remove cart item
router.delete('/:id', async (c: Context) => {
  try {
    const userId = c.get('userId');
    const id = Number(c.req.param('id'));
    if (isNaN(id)) return c.json({ error: 'Invalid id' }, 400);
    const del = await db.delete(cartItems).where(and(eq(cartItems.id, id), eq(cartItems.userId, userId))).returning();
    if (del.length === 0) return c.notFound();
    return c.json({ message: 'Cart item removed successfully' });
  } catch (err) {
    console.error('[cart] DELETE /:id', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

export default router;
