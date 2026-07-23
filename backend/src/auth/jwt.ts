import jwt from 'jsonwebtoken';
import type { SignOptions } from 'jsonwebtoken';
import { randomBytes } from 'crypto';
import { db } from '../db/index.js';
import { blacklistedTokens, refreshTokens } from '../db/schema.js';
import { eq, and, isNull } from 'drizzle-orm';

// =============================================================================
// JWT — Access Token (short-lived, 15 minutes)
// =============================================================================

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

/** Sign a short-lived access token (default: 15 minutes). */
export const signToken = (userId: number, expiresIn = '15m'): string => {
    return jwt.sign({ sub: String(userId) }, getJwtSecret(), { expiresIn } as SignOptions);
};

/** Verify an access token. Returns null on any failure. */
export const verifyToken = (token: string): { sub?: string; exp?: number } | null => {
    try {
        const decoded = jwt.verify(token, getJwtSecret()) as { sub?: string; exp?: number };
        return decoded;
    } catch (err) {
        return null;
    }
};

/** Returns true if the access token is JWT-expired (but otherwise structurally valid). */
export const isTokenExpired = (token: string): boolean => {
    try {
        jwt.verify(token, getJwtSecret());
        return false;
    } catch (err: any) {
        return err?.name === 'TokenExpiredError';
    }
};

// =============================================================================
// Access Token Blacklist (for explicit logout of a specific access token)
// =============================================================================

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

// =============================================================================
// Refresh Token (long-lived opaque token, stored in DB, 30 days)
// =============================================================================

const REFRESH_TOKEN_EXPIRY_DAYS = 30;

/**
 * Issue a new refresh token for a user.
 * One row is created in `refresh_tokens` per device/session.
 * Returns the raw token string to send to the client.
 */
export const issueRefreshToken = async (userId: number): Promise<string> => {
    const token = randomBytes(32).toString('hex'); // 64-char hex, 256-bit entropy
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + REFRESH_TOKEN_EXPIRY_DAYS);

    await db.insert(refreshTokens).values({ userId, token, expiresAt });
    return token;
};

/**
 * Validate a refresh token.
 * Returns the userId if the token is valid (exists, not revoked, not expired).
 * Returns null if invalid.
 */
export const validateRefreshToken = async (token: string): Promise<number | null> => {
    const [row] = await db
        .select()
        .from(refreshTokens)
        .where(
            and(
                eq(refreshTokens.token, token),
                isNull(refreshTokens.revokedAt),
            )
        )
        .limit(1);

    if (!row) return null;

    // Check expiry in application layer for clarity
    if (new Date() > row.expiresAt) {
        // Revoke it so future lookups are fast
        await db
            .update(refreshTokens)
            .set({ revokedAt: new Date() })
            .where(eq(refreshTokens.token, token));
        return null;
    }

    return row.userId;
};

/**
 * Rotate a refresh token: revoke the old one and issue a new one.
 * This prevents token replay — if a stolen token is used after rotation,
 * the server will reject it.
 * Returns the new refresh token string, or null if the old token is invalid.
 */
export const rotateRefreshToken = async (oldToken: string): Promise<{ userId: number; newRefreshToken: string } | null> => {
    const userId = await validateRefreshToken(oldToken);
    if (!userId) return null;

    // Revoke old token
    await db
        .update(refreshTokens)
        .set({ revokedAt: new Date() })
        .where(eq(refreshTokens.token, oldToken));

    // Issue new token
    const newRefreshToken = await issueRefreshToken(userId);
    return { userId, newRefreshToken };
};

/**
 * Revoke a refresh token explicitly (e.g., on logout).
 */
export const revokeRefreshToken = async (token: string): Promise<void> => {
    await db
        .update(refreshTokens)
        .set({ revokedAt: new Date() })
        .where(
            and(
                eq(refreshTokens.token, token),
                isNull(refreshTokens.revokedAt),
            )
        );
};
