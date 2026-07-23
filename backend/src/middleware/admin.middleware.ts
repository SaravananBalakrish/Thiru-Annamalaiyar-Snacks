import { Context } from 'hono';
import { db } from '../db/index.js';
import { users } from '../db/schema.js';
import { eq } from 'drizzle-orm';

export const adminMiddleware = async (c: Context, next: () => Promise<void>) => {
    const userId = c.get('userId');
    if (!userId) {
        return c.json({ success: false, code: 'UNAUTHORIZED', message: 'User ID missing in context' }, 401);
    }

    const [user] = await db.select().from(users).where(eq(users.id, userId)).limit(1);
    
    if (!user) {
        return c.json({ success: false, code: 'NOT_FOUND', message: 'User not found' }, 404);
    }

    if (user.role !== 'admin') {
        return c.json({ success: false, code: 'FORBIDDEN', message: 'Requires admin privileges' }, 403);
    }

    // Pass user to context for convenience
    c.set('user', user);

    await next();
};
