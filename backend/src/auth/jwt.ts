import jwt from 'jsonwebtoken';
import type { SignOptions } from 'jsonwebtoken';
import { db } from '../db/index.js';
import { blacklistedTokens } from '../db/schema.js';
import { eq } from 'drizzle-orm';

// Assert that JWT_SECRET is a valid string at runtime
const getJwtSecret = (): string => {
  const secret = process.env.JWT_SECRET;
  if (!secret || secret.length < 16) {
    throw new Error(
      'JWT_SECRET environment variable is required (minimum 16 characters). ' +
      'Please set it in your .env file. Generate with: openssl rand -base64 32'
    );
  }
  return secret;
};

export const signToken = (userId: number, expiresIn = '1h'): string => {
    return jwt.sign({ sub: String(userId) }, getJwtSecret(), { expiresIn } as SignOptions);
};

export const verifyToken = (token: string) => {
    try {
        const decoded = jwt.verify(token, getJwtSecret()) as { sub?: string };
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
