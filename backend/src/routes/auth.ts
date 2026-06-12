import { OpenAPIHono } from '@hono/zod-openapi';
import { z } from 'zod';
import { generateAndSendOtp, verifyOtp } from '../auth/otp.service.js';
import { signToken } from '../auth/jwt.js';
import { db } from '../db/index.js';
import { users } from '../db/schema.js';
import { eq } from 'drizzle-orm';

const authRoutes = new OpenAPIHono();

// Use phone as the field name
const reqOtpSchema = z.object({
    phone: z.string().min(10).max(20),
});

const verifyOtpSchema = z.object({
    phone: z.string().min(10).max(20),
    code: z.string().length(6),
});

authRoutes.post('/request-otp', async (c) => {
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

authRoutes.post('/verify-otp', async (c) => {
    const body = await c.req.json();
    const data = verifyOtpSchema.parse(body);
    
    const phone = data.phone;

    const ok = verifyOtp(phone, data.code);
    if (!ok) return c.json({ success: false, message: 'Invalid or expired OTP' }, 400);

    let user = await db.select().from(users).where(eq(users.phoneNumber, phone)).limit(1);
    if (!user.length) {
        const [newUser] = await db.insert(users).values({ phoneNumber: phone }).returning();
        user = [newUser];
    }

    const token = signToken(user[0].id);

    return c.json({ success: true, token, userPhone: phone });
});

// Test endpoint to verify Twilio configuration
authRoutes.get('/test-sms', async (c) => {
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
            body: '🧪 E-Shop Twilio Test: Your SMS configuration is working correctly!',
            from: testPhone,
            to: testPhone,
        });
        
        console.log('✅ Test SMS sent successfully!');
        return c.json({ 
            success: true, 
            message: 'Test SMS sent! Check your phone.',
            sentTo: testPhone 
        });
    } catch (error: any) {
        console.error('❌ Twilio Test Failed:', error.message);
        return c.json({ 
            success: false, 
            error: error.message,
            message: 'Twilio configuration error. Check your .env settings.',
            help: 'Make sure TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, and TWILIO_PHONE_NUMBER are correctly set'
        }, 500);
    }
});

export default authRoutes;
