import { Context } from 'hono';
import { verifyToken, isTokenBlacklisted, isTokenExpired } from '../auth/jwt.js';

export const authMiddleware = async (c: Context, next: () => Promise<void>) => {
    const auth = c.req.header('authorization') || '';
    const match = auth.match(/^Bearer\s+(.+)$/i);
    if (!match) {
        return c.json({ success: false, code: 'UNAUTHORIZED', message: 'Unauthorized' }, 401);
    }

    const token = match[1];
    
    // Check if token is blacklisted (explicit logout)
    const isBlacklisted = await isTokenBlacklisted(token);
    if (isBlacklisted) {
        return c.json({ success: false, code: 'TOKEN_REVOKED', message: 'Token has been revoked. Please log in again.' }, 401);
    }
    
    const payload = verifyToken(token);
    if (!payload || !payload.sub) {
        // Distinguish expired vs. structurally invalid so the mobile app
        // can silently refresh instead of forcing a re-login with OTP.
        if (isTokenExpired(token)) {
            return c.json(
                { success: false, code: 'TOKEN_EXPIRED', message: 'Access token has expired. Use your refresh token to get a new one.' },
                401
            );
        }
        return c.json({ success: false, code: 'TOKEN_INVALID', message: 'Invalid token' }, 401);
    }

    // Set user id on context for downstream handlers
    c.set('userId', Number(payload.sub));

    await next();
};
