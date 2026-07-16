import { Hono, Context } from 'hono';
import { eq, and } from 'drizzle-orm';
import { db } from '../db/index.js';
import { addresses } from '../db/schema.js';
import { z } from 'zod';
import { authMiddleware } from '../middleware/auth.middleware.js';

const router = new Hono();

// Apply auth middleware to all address routes
router.use('*', authMiddleware);

const addressSchema = z.object({
  street: z.string().min(1).max(255),
  city: z.string().min(1).max(100),
  state: z.string().min(1).max(100),
  zipCode: z.string().min(1).max(20),
  country: z.string().min(1).max(100),
  addressType: z.string().min(1).max(50).optional().default('home'),
  isDefault: z.boolean().optional().default(false),
});

const updateAddressSchema = z.object({
  street: z.string().min(1).max(255).optional(),
  city: z.string().min(1).max(100).optional(),
  state: z.string().min(1).max(100).optional(),
  zipCode: z.string().min(1).max(20).optional(),
  country: z.string().min(1).max(100).optional(),
  addressType: z.string().min(1).max(50).optional(),
  isDefault: z.boolean().optional(),
});

// GET / - List all addresses for the authenticated user
router.get('/', async (c: Context) => {
  try {
    const userId = c.get('userId');
    const all = await db
      .select()
      .from(addresses)
      .where(eq(addresses.userId, userId))
      .orderBy(addresses.isDefault, addresses.createdAt);
    return c.json(all);
  } catch (err) {
    console.error('[addresses] GET /', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// GET /:id - Get a single address by ID
router.get('/:id', async (c: Context) => {
  try {
    const userId = c.get('userId');
    const id = Number(c.req.param('id'));
    if (isNaN(id)) return c.json({ error: 'Invalid id' }, 400);

    const addr = await db
      .select()
      .from(addresses)
      .where(and(eq(addresses.id, id), eq(addresses.userId, userId)))
      .limit(1);
    if (addr.length === 0) return c.notFound();
    return c.json(addr[0]);
  } catch (err) {
    console.error('[addresses] GET /:id', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// POST / - Create a new address
router.post('/', async (c: Context) => {
  try {
    const userId = c.get('userId');
    const body = await c.req.json();
    const parsed = addressSchema.safeParse(body);
    if (!parsed.success) return c.json({ error: parsed.error.format() }, 400);

    // If this is the first address, set it as default
    const existingAddresses = await db
      .select()
      .from(addresses)
      .where(eq(addresses.userId, userId));

    const data = {
      ...parsed.data,
      userId,
      isDefault: existingAddresses.length === 0 ? true : parsed.data.isDefault,
    };

    // If setting as default, unset other defaults
    if (data.isDefault) {
      await db
        .update(addresses)
        .set({ isDefault: false })
        .where(and(eq(addresses.userId, userId), eq(addresses.isDefault, true)));
    }

    const [created] = await db.insert(addresses).values(data).returning();
    return c.json(created, 201);
  } catch (err) {
    console.error('[addresses] POST /', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// PUT /:id - Update an address
router.put('/:id', async (c: Context) => {
  try {
    const userId = c.get('userId');
    const id = Number(c.req.param('id'));
    if (isNaN(id)) return c.json({ error: 'Invalid id' }, 400);

    const body = await c.req.json();
    const parsed = updateAddressSchema.safeParse(body);
    if (!parsed.success) return c.json({ error: parsed.error.format() }, 400);

    // Check address exists and belongs to user
    const existing = await db
      .select()
      .from(addresses)
      .where(and(eq(addresses.id, id), eq(addresses.userId, userId)))
      .limit(1);
    if (existing.length === 0) return c.notFound();

    const updateData = parsed.data;

    // If setting as default, unset other defaults
    if (updateData.isDefault === true) {
      await db
        .update(addresses)
        .set({ isDefault: false })
        .where(and(eq(addresses.userId, userId), eq(addresses.isDefault, true)));
    }

    const updated = await db
      .update(addresses)
      .set(updateData)
      .where(eq(addresses.id, id))
      .returning();
    return c.json(updated[0]);
  } catch (err) {
    console.error('[addresses] PUT /:id', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// DELETE /:id - Delete an address
router.delete('/:id', async (c: Context) => {
  try {
    const userId = c.get('userId');
    const id = Number(c.req.param('id'));
    if (isNaN(id)) return c.json({ error: 'Invalid id' }, 400);

    const del = await db
      .delete(addresses)
      .where(and(eq(addresses.id, id), eq(addresses.userId, userId)))
      .returning();
    if (del.length === 0) return c.notFound();

    // If deleted address was default, set another as default
    if (del[0].isDefault) {
      const remaining = await db
        .select()
        .from(addresses)
        .where(eq(addresses.userId, userId))
        .orderBy(addresses.createdAt)
        .limit(1);
      if (remaining.length > 0) {
        await db
          .update(addresses)
          .set({ isDefault: true })
          .where(eq(addresses.id, remaining[0].id));
      }
    }

    return c.json({ message: 'Address deleted successfully' });
  } catch (err) {
    console.error('[addresses] DELETE /:id', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// POST /:id/set-default - Set an address as the default
router.post('/:id/set-default', async (c: Context) => {
  try {
    const userId = c.get('userId');
    const id = Number(c.req.param('id'));
    if (isNaN(id)) return c.json({ error: 'Invalid id' }, 400);

    // Check address exists and belongs to user
    const existing = await db
      .select()
      .from(addresses)
      .where(and(eq(addresses.id, id), eq(addresses.userId, userId)))
      .limit(1);
    if (existing.length === 0) return c.notFound();

    // Unset all defaults for this user
    await db
      .update(addresses)
      .set({ isDefault: false })
      .where(and(eq(addresses.userId, userId), eq(addresses.isDefault, true)));

    // Set this address as default
    const [updated] = await db
      .update(addresses)
      .set({ isDefault: true })
      .where(eq(addresses.id, id))
      .returning();

    return c.json({ message: 'Default address updated', address: updated });
  } catch (err) {
    console.error('[addresses] POST /:id/set-default', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

export default router;
