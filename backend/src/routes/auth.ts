import { OpenAPIHono } from '@hono/zod-openapi';
import { Context } from 'hono';
import { z } from 'zod';
import { generateAndSendOtp, verifyOtp } from '../auth/otp.service.js';
import {
    signToken,
    blacklistToken,
    issueRefreshToken,
    rotateRefreshToken,
    revokeRefreshToken,
} from '../auth/jwt.js';
import { db } from '../db/index.js';
import { users } from '../db/schema.js';
import { eq } from 'drizzle-orm';
import { authMiddleware } from '../middleware/auth.middleware.js';

const authRoutes = new OpenAPIHono();

// Use phone as the field name
const reqOtpSchema = z.object({
    phone: z.string().min(10).max(20),
});

const verifyOtpSchema = z.object({
    phone: z.string().min(10).max(20),
    code: z.string().length(6),
});

// =============================================================================
// Request OTP
// =============================================================================

authRoutes.post('/request-otp', async (c: Context) => {
    const body = await c.req.json();
    console.log('📥 Request:', JSON.stringify(body));
    
    const data = reqOtpSchema.parse(body);
    const phone = data.phone;

    let user = await db.select().from(users).where(eq(users.phoneNumber, phone)).limit(1);
    if (user.length === 0) {
        const [newUser] = await db.insert(users).values({ phoneNumber: phone }).returning();
        user = [newUser];
    }

    await generateAndSendOtp(phone);

    return c.json({ 
        success: true, 
        message: 'OTP sent successfully',
        sentTo: phone 
    });
});

// =============================================================================
// Verify OTP — issues BOTH an access token and a refresh token
// =============================================================================

authRoutes.post('/verify-otp', async (c: Context) => {
    const body = await c.req.json();
    const data = verifyOtpSchema.parse(body);
    
    const phone = data.phone;

    const ok = await verifyOtp(phone, data.code);
    if (!ok) return c.json({ success: false, message: 'Invalid or expired OTP' }, 400);

    let user = await db.select().from(users).where(eq(users.phoneNumber, phone)).limit(1);
    if (!user.length) {
        const [newUser] = await db.insert(users).values({ phoneNumber: phone }).returning();
        user = [newUser];
    }

    const userId = user[0].id;

    // Issue a short-lived access token (15 minutes) and a long-lived refresh token (30 days)
    const accessToken = signToken(userId);
    const refreshToken = await issueRefreshToken(userId);

    return c.json({
        success: true,
        accessToken,
        refreshToken,
        expiresIn: 15 * 60,        // 900 seconds — tells the mobile app when to refresh
        tokenType: 'Bearer',
        userPhone: phone,
    });
});

// =============================================================================
// Refresh — silently renew access token using a valid refresh token
// No auth middleware needed — the refresh token IS the credential here.
// =============================================================================

const refreshSchema = z.object({
    refreshToken: z.string().min(1),
});

authRoutes.post('/refresh', async (c: Context) => {
    const body = await c.req.json();

    let data: z.infer<typeof refreshSchema>;
    try {
        data = refreshSchema.parse(body);
    } catch {
        return c.json({ success: false, message: 'refreshToken is required' }, 400);
    }

    // Rotate: revoke old token and issue a new one atomically
    const result = await rotateRefreshToken(data.refreshToken);

    if (!result) {
        return c.json(
            { success: false, code: 'REFRESH_TOKEN_INVALID', message: 'Refresh token is invalid or expired. Please log in again.' },
            401
        );
    }

    const { userId, newRefreshToken } = result;
    const accessToken = signToken(userId);

    return c.json({
        success: true,
        accessToken,
        refreshToken: newRefreshToken,
        expiresIn: 15 * 60,
        tokenType: 'Bearer',
    });
});

// =============================================================================
// Validate — verify the current access token is still valid
// =============================================================================

authRoutes.post('/validate', authMiddleware, async (c: Context) => {
    const userId = c.get('userId');
    return c.json({ 
        success: true, 
        message: 'Token is valid',
        userId 
    });
});

// =============================================================================
// Logout — revoke refresh token + blacklist the current access token
// =============================================================================

const logoutSchema = z.object({
    refreshToken: z.string().min(1).optional(),
});

authRoutes.post('/logout', authMiddleware, async (c: Context) => {
    // Blacklist the current access token
    const auth = c.req.header('authorization') || '';
    const match = auth.match(/^Bearer\s+(.+)$/i);
    if (match) {
        await blacklistToken(match[1]);
    }

    // Also revoke the refresh token if provided
    const body = await c.req.json().catch(() => ({}));
    const parsed = logoutSchema.safeParse(body);
    if (parsed.success && parsed.data.refreshToken) {
        await revokeRefreshToken(parsed.data.refreshToken);
    }
    
    return c.json({ success: true, message: 'Logged out successfully' });
});

// =============================================================================
// Test SMS — verify Twilio configuration
// =============================================================================

authRoutes.get('/test-sms', async (c: Context) => {
    try {
        const testPhone = process.env.TWILIO_PHONE_NUMBER || '+1234567890';
        const accountSid = process.env.TWILIO_ACCOUNT_SID;
        const authToken = process.env.TWILIO_AUTH_TOKEN;
        
        if (!accountSid || !authToken) {
            return c.json({ 
                success: false, 
                message: 'Twilio credentials are not configured in .env file',
            }, 400);
        }
        
        const twilio = await import('twilio');
        const client = twilio.default(accountSid, authToken);
        
        await client.messages.create({
            body: 'Test SMS: Your SMS configuration is working correctly!',
            from: testPhone,
            to: testPhone,
        });
        
        console.log('Test SMS sent successfully!');
        return c.json({ 
            success: true, 
            message: 'Test SMS sent! Check your phone.',
            sentTo: testPhone 
        });
    } catch (error: any) {
        console.error('Twilio Test Failed:', error.message);
        return c.json({ 
            success: false, 
            error: error.message,
            message: 'Twilio configuration error. Check your .env settings.',
            help: 'Make sure TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, and TWILIO_PHONE_NUMBER are correctly set'
        }, 500);
    }
});

export default authRoutes;
