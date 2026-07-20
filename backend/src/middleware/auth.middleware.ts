import { Context } from 'hono';
import { verifyToken, isTokenBlacklisted } from '../auth/jwt.js';

export const authMiddleware = async (c: Context, next: () => Promise<void>) => {
    const auth = c.req.header('authorization') || '';
    const match = auth.match(/^Bearer\s+(.+)$/i);
    if (!match) {
        return c.json({ success: false, message: 'Unauthorized' }, 401);
    }

    const token = match[1];
    
    // Check if token is blacklisted
    const isBlacklisted = await isTokenBlacklisted(token);
    if (isBlacklisted) {
        return c.json({ success: false, message: 'Token invalidated. Please login again.' }, 401);
    }
    
    const payload = verifyToken(token);
    if (!payload || !payload.sub) {
        return c.json({ success: false, message: 'Invalid token' }, 401);
    }

    // set user id on context for downstream handlers
    c.set('userId', Number(payload.sub));

    await next();
};
