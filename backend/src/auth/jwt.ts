import jwt from 'jsonwebtoken';
import { db } from '../db/index.js';
import { blacklistedTokens } from '../db/schema.js';
import { eq } from 'drizzle-orm';

const JWT_SECRET = process.env.JWT_SECRET ?? 'please-change-me';

export const signToken = (userId: number, expiresIn = '1h') => {
    return jwt.sign({ sub: String(userId) }, JWT_SECRET, { expiresIn } as any);
};

export const verifyToken = (token: string) => {
    try {
        const decoded = jwt.verify(token, JWT_SECRET) as { sub?: string };
        return decoded;
    } catch (err) {
        return null;
    }
};

export const isTokenBlacklisted = async (token: string): Promise<boolean> => {
    const result = await db
        .select()
        .from(blacklistedTokens)
        .where(eq(blacklistedTokens.token, token))
        .limit(1);
    return result.length > 0;
};

export const blacklistToken = async (token: string): Promise<void> => {
    await db.insert(blacklistedTokens).values({ token });
};
