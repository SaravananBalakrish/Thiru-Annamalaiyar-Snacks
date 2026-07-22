import { Hono, Context } from 'hono';
import { eq, and, desc } from 'drizzle-orm';
import { db } from '../db/index.js';
import { addresses } from '../db/schema.js';
import { z } from 'zod';
import { authMiddleware } from '../middleware/auth.middleware.js';

const router = new Hono();

// Require Bearer authentication for all address routes
router.use('*', authMiddleware);

const addressSchema = z.object({
  fullName: z.string().trim().min(1, 'Full name is required').max(100),
  phoneNumber: z.string().trim().min(5, 'Phone number is invalid').max(20),
  street: z.string().trim().min(1, 'Street address is required').max(255),
  landmark: z.string().trim().max(255).optional().nullable(),
  city: z.string().trim().min(1, 'City is required').max(100),
  state: z.string().trim().min(1, 'State is required').max(100),
  zipCode: z.string().trim().min(1, 'Zip code is required').max(20),
  country: z.string().trim().min(1).max(100).optional().default('India'),
  latitude: z.union([z.number().min(-90).max(90), z.string()]).optional().nullable(),
  longitude: z.union([z.number().min(-180).max(180), z.string()]).optional().nullable(),
  addressType: z.enum(['home', 'work', 'billing', 'shipping', 'other']).optional().default('home'),
  isDefault: z.boolean().optional().default(false),
});

const updateAddressSchema = addressSchema.partial();

const formatCoord = (val: number | string | null | undefined): number | null | undefined => {
  if (val === undefined) return undefined;
  if (val === null || val === '') return null;
  const num = Number(val);
  return isNaN(num) ? null : num;
};

// GET / - List all addresses for the authenticated user
router.get('/', async (c: Context) => {
  try {
    const userId = c.get('userId');
    const userAddresses = await db
      .select()
      .from(addresses)
      .where(eq(addresses.userId, userId))
      .orderBy(desc(addresses.isDefault), desc(addresses.createdAt));
      
    return c.json({ success: true, data: userAddresses });
  } catch (err) {
    console.error('[addresses] GET /', err);
    return c.json({ success: false, error: 'Internal server error' }, 500);
  }
});

// GET /:id - Get a single address by ID
router.get('/:id', async (c: Context) => {
  try {
    const userId = c.get('userId');
    const id = Number(c.req.param('id'));
    if (isNaN(id)) {
      return c.json({ success: false, error: 'Invalid address ID' }, 400);
    }

    const addr = await db
      .select()
      .from(addresses)
      .where(and(eq(addresses.id, id), eq(addresses.userId, userId)))
      .limit(1);

    if (addr.length === 0) {
      return c.json({ success: false, error: 'Address not found' }, 404);
    }
    return c.json({ success: true, data: addr[0] });
  } catch (err) {
    console.error('[addresses] GET /:id', err);
    return c.json({ success: false, error: 'Internal server error' }, 500);
  }
});

// POST / - Create a new address
router.post('/', async (c: Context) => {
  try {
    const userId = c.get('userId');
    const body = await c.req.json();
    const parsed = addressSchema.safeParse(body);
    
    if (!parsed.success) {
      return c.json({ success: false, error: 'Validation failed', details: parsed.error.format() }, 400);
    }

    const result = await db.transaction(async (tx) => {
      // Check existing addresses count to decide default state
      const existingAddresses = await tx
        .select({ id: addresses.id })
        .from(addresses)
        .where(eq(addresses.userId, userId));

      const isFirstAddress = existingAddresses.length === 0;
      const willBeDefault = isFirstAddress ? true : parsed.data.isDefault ?? false;

      if (willBeDefault) {
        await tx
          .update(addresses)
          .set({ isDefault: false, updatedAt: new Date() })
          .where(and(eq(addresses.userId, userId), eq(addresses.isDefault, true)));
      }

      const insertValues = {
        ...parsed.data,
        latitude: formatCoord(parsed.data.latitude),
        longitude: formatCoord(parsed.data.longitude),
        userId,
        isDefault: willBeDefault,
      };

      const [created] = await tx
        .insert(addresses)
        .values(insertValues)
        .returning();

      return created;
    });

    return c.json({ success: true, data: result }, 201);
  } catch (err) {
    console.error('[addresses] POST /', err);
    return c.json({ success: false, error: 'Internal server error' }, 500);
  }
});

// Helper for updating address
const handleUpdate = async (c: Context) => {
  try {
    const userId = c.get('userId');
    const id = Number(c.req.param('id'));
    if (isNaN(id)) {
      return c.json({ success: false, error: 'Invalid address ID' }, 400);
    }

    const body = await c.req.json();
    const parsed = updateAddressSchema.safeParse(body);
    if (!parsed.success) {
      return c.json({ success: false, error: 'Validation failed', details: parsed.error.format() }, 400);
    }

    const updatedAddress = await db.transaction(async (tx) => {
      const existing = await tx
        .select()
        .from(addresses)
        .where(and(eq(addresses.id, id), eq(addresses.userId, userId)))
        .limit(1);

      if (existing.length === 0) {
        return null;
      }

      const updateData: Record<string, any> = { ...parsed.data, updatedAt: new Date() };

      if (parsed.data.latitude !== undefined) {
        updateData.latitude = formatCoord(parsed.data.latitude);
      }
      if (parsed.data.longitude !== undefined) {
        updateData.longitude = formatCoord(parsed.data.longitude);
      }

      if (updateData.isDefault === true) {
        await tx
          .update(addresses)
          .set({ isDefault: false, updatedAt: new Date() })
          .where(and(eq(addresses.userId, userId), eq(addresses.isDefault, true)));
      }

      const [updated] = await tx
        .update(addresses)
        .set(updateData)
        .where(and(eq(addresses.id, id), eq(addresses.userId, userId)))
        .returning();

      return updated;
    });

    if (!updatedAddress) {
      return c.json({ success: false, error: 'Address not found' }, 404);
    }

    return c.json({ success: true, data: updatedAddress });
  } catch (err) {
    console.error('[addresses] PUT/PATCH /:id', err);
    return c.json({ success: false, error: 'Internal server error' }, 500);
  }
};

// PUT /:id - Full update of an address
router.put('/:id', handleUpdate);

// PATCH /:id - Partial update of an address
router.patch('/:id', handleUpdate);

// DELETE /:id - Delete an address
router.delete('/:id', async (c: Context) => {
  try {
    const userId = c.get('userId');
    const id = Number(c.req.param('id'));
    if (isNaN(id)) {
      return c.json({ success: false, error: 'Invalid address ID' }, 400);
    }

    const deleted = await db.transaction(async (tx) => {
      const [del] = await tx
        .delete(addresses)
        .where(and(eq(addresses.id, id), eq(addresses.userId, userId)))
        .returning();

      if (!del) return null;

      // If deleted address was default, make the most recent remaining address default
      if (del.isDefault) {
        const remaining = await tx
          .select()
          .from(addresses)
          .where(eq(addresses.userId, userId))
          .orderBy(desc(addresses.createdAt))
          .limit(1);

        if (remaining.length > 0) {
          await tx
            .update(addresses)
            .set({ isDefault: true, updatedAt: new Date() })
            .where(eq(addresses.id, remaining[0].id));
        }
      }

      return del;
    });

    if (!deleted) {
      return c.json({ success: false, error: 'Address not found' }, 404);
    }

    return c.json({ success: true, message: 'Address deleted successfully' });
  } catch (err) {
    console.error('[addresses] DELETE /:id', err);
    return c.json({ success: false, error: 'Internal server error' }, 500);
  }
});

// POST /:id/set-default - Set address as default
router.post('/:id/set-default', async (c: Context) => {
  try {
    const userId = c.get('userId');
    const id = Number(c.req.param('id'));
    if (isNaN(id)) {
      return c.json({ success: false, error: 'Invalid address ID' }, 400);
    }

    const updated = await db.transaction(async (tx) => {
      const existing = await tx
        .select()
        .from(addresses)
        .where(and(eq(addresses.id, id), eq(addresses.userId, userId)))
        .limit(1);

      if (existing.length === 0) {
        return null;
      }

      // Unset all defaults for this user
      await tx
        .update(addresses)
        .set({ isDefault: false, updatedAt: new Date() })
        .where(and(eq(addresses.userId, userId), eq(addresses.isDefault, true)));

      // Set target address as default
      const [newDefault] = await tx
        .update(addresses)
        .set({ isDefault: true, updatedAt: new Date() })
        .where(eq(addresses.id, id))
        .returning();

      return newDefault;
    });

    if (!updated) {
      return c.json({ success: false, error: 'Address not found' }, 404);
    }

    return c.json({ success: true, message: 'Default address updated', data: updated });
  } catch (err) {
    console.error('[addresses] POST /:id/set-default', err);
    return c.json({ success: false, error: 'Internal server error' }, 500);
  }
});

export default router;
