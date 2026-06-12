import { Hono, Context } from 'hono';
import { eq } from 'drizzle-orm';
import { db } from '../db/index.js';
import { categories } from '../db/schema.js';
import { z } from 'zod';

const router = new Hono();

const categorySchema = z.object({
  name: z.string().min(1).max(100),
});

// GET / - list all categories
router.get('/', async (c: Context) => {
  try {
    const all = await db.select().from(categories);
    return c.json(all);
  } catch (err) {
    console.error('[categories] GET /', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// GET /:id - get single category
router.get('/:id', async (c: Context) => {
  try {
    const id = Number(c.req.param('id'));
    if (isNaN(id)) return c.json({ error: 'Invalid id' }, 400);
    const cat = await db.select().from(categories).where(eq(categories.id, id)).limit(1);
    if (cat.length === 0) return c.notFound();
    return c.json(cat[0]);
  } catch (err) {
    console.error('[categories] GET /:id', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// POST / - create category
router.post('/', async (c: Context) => {
  try {
    const body = await c.req.json();
    const parsed = categorySchema.safeParse(body);
    if (!parsed.success) return c.json({ error: parsed.error.format() }, 400);
    const [created] = await db.insert(categories).values(parsed.data).returning();
    return c.json(created, 201);
  } catch (err) {
    console.error('[categories] POST /', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// PUT /:id - update category
router.put('/:id', async (c: Context) => {
  try {
    const id = Number(c.req.param('id'));
    if (isNaN(id)) return c.json({ error: 'Invalid id' }, 400);
    const body = await c.req.json();
    const parsed = categorySchema.safeParse(body);
    if (!parsed.success) return c.json({ error: parsed.error.format() }, 400);
    const updated = await db
      .update(categories)
      .set(parsed.data)
      .where(eq(categories.id, id))
      .returning();
    if (updated.length === 0) return c.notFound();
    return c.json(updated[0]);
  } catch (err) {
    console.error('[categories] PUT /:id', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// DELETE /:id - delete category
router.delete('/:id', async (c: Context) => {
  try {
    const id = Number(c.req.param('id'));
    if (isNaN(id)) return c.json({ error: 'Invalid id' }, 400);
    const del = await db.delete(categories).where(eq(categories.id, id)).returning();
    if (del.length === 0) return c.notFound();
    return c.json({ message: 'Category deleted successfully' });
  } catch (err) {
    console.error('[categories] DELETE /:id', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

export default router;
