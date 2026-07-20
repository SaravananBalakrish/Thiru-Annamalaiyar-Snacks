import { Hono, Context } from 'hono';
import { eq } from 'drizzle-orm';
import { db } from '../db/index.js';
import { products } from '../db/schema.js';
import { z } from 'zod';
import { authMiddleware } from '../middleware/auth.middleware.js';

const router = new Hono();

const productSchema = z.object({
  name: z.string().min(1),
  description: z.string().optional(),
  price: z.number().nonnegative(),
  imageUrl: z.string().url().optional(),
  categoryId: z.number().int().positive().optional(),
});

// GET / - list all products
router.get('/', async (c: Context) => {
  try {
    const productList = await db.select().from(products);
    return c.json(productList);
  } catch (err) {
    console.error('[products] GET /', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// GET /:id - get product by id
router.get('/:id', async (c: Context) => {
  try {
    const id = Number(c.req.param('id'));
    if (isNaN(id)) return c.json({ error: 'Invalid id' }, 400);
    const product = await db.select().from(products).where(eq(products.id, id)).limit(1);
    if (product.length === 0) return c.notFound();
    return c.json(product[0]);
  } catch (err) {
    console.error('[products] GET /:id', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// POST / - create product (admin only)
router.post('/', authMiddleware, async (c: Context) => {
  try {
    const body = await c.req.json();
    const parsed = productSchema.safeParse(body);
    if (!parsed.success) return c.json({ error: parsed.error.format() }, 400);
    const values = { ...parsed.data, price: parsed.data.price.toString() };
    const [newProduct] = await db.insert(products).values(values).returning();
    return c.json(newProduct, 201);
  } catch (err) {
    console.error('[products] POST /', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// PUT /:id - update product (admin only)
router.put('/:id', authMiddleware, async (c: Context) => {
  try {
    const id = Number(c.req.param('id'));
    if (isNaN(id)) return c.json({ error: 'Invalid id' }, 400);
    const body = await c.req.json();
    const parsed = productSchema.safeParse(body);
    if (!parsed.success) return c.json({ error: parsed.error.format() }, 400);
    const values = { ...parsed.data, price: parsed.data.price.toString() };
    const updated = await db.update(products).set(values).where(eq(products.id, id)).returning();
    if (updated.length === 0) return c.notFound();
    return c.json(updated[0]);
  } catch (err) {
    console.error('[products] PUT /:id', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// DELETE /:id - delete product (admin only)
router.delete('/:id', authMiddleware, async (c: Context) => {
  try {
    const id = Number(c.req.param('id'));
    if (isNaN(id)) return c.json({ error: 'Invalid id' }, 400);
    const del = await db.delete(products).where(eq(products.id, id)).returning();
    if (del.length === 0) return c.notFound();
    return c.json({ message: 'Product deleted successfully' });
  } catch (err) {
    console.error('[products] DELETE /:id', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

export default router;
