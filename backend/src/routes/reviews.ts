import { Hono, Context } from 'hono';
import { eq, and } from 'drizzle-orm';
import { db } from '../db/index.js';
import { reviews, products } from '../db/schema.js';
import { z } from 'zod';
import { authMiddleware } from '../middleware/auth.middleware.js';

const router = new Hono();

const reviewSchema = z.object({
  productId: z.number().int().positive(),
  rating: z.number().int().min(1).max(5),
  comment: z.string().optional(),
});

const reviewUpdateSchema = z.object({
  rating: z.number().int().min(1).max(5).optional(),
  comment: z.string().optional(),
});

// Public route - anyone can view reviews for a product
router.get('/product/:productId', async (c: Context) => {
  try {
    const productId = Number(c.req.param('productId'));
    if (isNaN(productId)) return c.json({ error: 'Invalid productId' }, 400);
    
    const reviewList = await db
      .select({
        id: reviews.id,
        productId: reviews.productId,
        userId: reviews.userId,
        rating: reviews.rating,
        comment: reviews.comment,
        createdAt: reviews.createdAt,
      })
      .from(reviews)
      .where(eq(reviews.productId, productId))
      .orderBy(reviews.createdAt);
    
    return c.json(reviewList);
  } catch (err) {
    console.error('[reviews] GET /product/:productId', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// Public route - anyone can view a single review
router.get('/:id', async (c: Context) => {
  try {
    const id = Number(c.req.param('id'));
    if (isNaN(id)) return c.json({ error: 'Invalid id' }, 400);
    
    const review = await db
      .select({
        id: reviews.id,
        productId: reviews.productId,
        userId: reviews.userId,
        rating: reviews.rating,
        comment: reviews.comment,
        createdAt: reviews.createdAt,
      })
      .from(reviews)
      .where(eq(reviews.id, id))
      .limit(1);
    
    if (review.length === 0) return c.notFound();
    return c.json(review[0]);
  } catch (err) {
    console.error('[reviews] GET /:id', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// Protected routes - require authentication
const protectedRouter = new Hono();
protectedRouter.use('*', authMiddleware);

// GET / - list all reviews (authenticated users)
protectedRouter.get('/', async (c: Context) => {
  try {
    const reviewList = await db
      .select({
        id: reviews.id,
        productId: reviews.productId,
        userId: reviews.userId,
        rating: reviews.rating,
        comment: reviews.comment,
        createdAt: reviews.createdAt,
      })
      .from(reviews)
      .orderBy(reviews.createdAt);
    
    return c.json(reviewList);
  } catch (err) {
    console.error('[reviews] GET /', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// POST / - create a review (authenticated users only)
protectedRouter.post('/', async (c: Context) => {
  try {
    const userId = c.get('userId');
    const body = await c.req.json();
    const parsed = reviewSchema.safeParse(body);
    if (!parsed.success) return c.json({ error: parsed.error.format() }, 400);
    
    // Check if product exists
    const product = await db.select().from(products).where(eq(products.id, parsed.data.productId)).limit(1);
    if (product.length === 0) return c.json({ error: 'Product not found' }, 404);
    
    // Create review with authenticated user's ID
    const [newReview] = await db.insert(reviews).values({
      ...parsed.data,
      userId,
    }).returning();
    return c.json(newReview, 201);
  } catch (err) {
    console.error('[reviews] POST /', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// PUT /:id - update review (owner only)
protectedRouter.put('/:id', async (c: Context) => {
  try {
    const userId = c.get('userId');
    const id = Number(c.req.param('id'));
    if (isNaN(id)) return c.json({ error: 'Invalid id' }, 400);
    
    const body = await c.req.json();
    const parsed = reviewUpdateSchema.safeParse(body);
    if (!parsed.success) return c.json({ error: parsed.error.format() }, 400);
    
    // Check if review exists and belongs to user
    const existing = await db
      .select()
      .from(reviews)
      .where(and(eq(reviews.id, id), eq(reviews.userId, userId)))
      .limit(1);
    
    if (existing.length === 0) return c.json({ error: 'Review not found or not authorized' }, 404);
    
    const updated = await db
      .update(reviews)
      .set(parsed.data)
      .where(eq(reviews.id, id))
      .returning({
        id: reviews.id,
        productId: reviews.productId,
        userId: reviews.userId,
        rating: reviews.rating,
        comment: reviews.comment,
        createdAt: reviews.createdAt,
      });
    
    return c.json(updated[0]);
  } catch (err) {
    console.error('[reviews] PUT /:id', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// DELETE /:id - delete review (owner only)
protectedRouter.delete('/:id', async (c: Context) => {
  try {
    const userId = c.get('userId');
    const id = Number(c.req.param('id'));
    if (isNaN(id)) return c.json({ error: 'Invalid id' }, 400);
    
    // Check if review exists and belongs to user
    const existing = await db
      .select()
      .from(reviews)
      .where(and(eq(reviews.id, id), eq(reviews.userId, userId)))
      .limit(1);
    
    if (existing.length === 0) return c.json({ error: 'Review not found or not authorized' }, 404);
    
    await db.delete(reviews).where(eq(reviews.id, id));
    return c.json({ message: 'Review deleted successfully' });
  } catch (err) {
    console.error('[reviews] DELETE /:id', err);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// Mount protected routes
router.route('/', protectedRouter);

export default router;
