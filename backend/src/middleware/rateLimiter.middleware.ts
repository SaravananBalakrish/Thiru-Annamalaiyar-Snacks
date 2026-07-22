import { Context } from 'hono';
import type { Next } from 'hono';

// =============================================================================
// Rate Limiting Middleware
// =============================================================================
// Simple in-memory rate limiter for API endpoints
// For production, consider using Redis-based rate limiting

interface RateLimitEntry {
  count: number;
  resetTime: number;
}

// Store rate limit state by IP address
const rateLimitStore = new Map<string, RateLimitEntry>();

// Default rate limit configuration
const DEFAULT_WINDOW_MS = 15 * 60 * 1000; // 15 minutes
const DEFAULT_MAX_REQUESTS = 100; // 100 requests per window

// Rate limit configuration by endpoint (path prefix -> limits)
const endpointLimits: Record<string, { windowMs: number; maxRequests: number }> = {
  '/v1/auth/request-otp': { windowMs: 60 * 1000, maxRequests: 5 }, // 5 OTP requests per minute
  '/v1/auth/verify-otp': { windowMs: 60 * 1000, maxRequests: 5 }, // 5 OTP verifications per minute
  '/v1/auth': { windowMs: 60 * 1000, maxRequests: 10 }, // 10 auth requests per minute
};

// Cleanup expired entries periodically
setInterval(() => {
  const now = Date.now();
  for (const [key, entry] of rateLimitStore.entries()) {
    if (now >= entry.resetTime) {
      rateLimitStore.delete(key);
    }
  }
}, 60 * 1000); // Run cleanup every minute

export interface RateLimitConfig {
  windowMs?: number;
  maxRequests?: number;
  message?: string;
  skip?: (c: Context) => boolean;
}

export const rateLimiter = (config?: RateLimitConfig) => {
  const windowMs = config?.windowMs || DEFAULT_WINDOW_MS;
  const maxRequests = config?.maxRequests || DEFAULT_MAX_REQUESTS;
  const message = config?.message || 'Too many requests, please try again later.';

  return async (c: Context, next: Next) => {
    // Check if we should skip rate limiting for this request
    if (config?.skip?.(c)) {
      return await next();
    }

    // Get client IP from headers (check for forwarded IP first)
    const ip = (
      c.req.header('x-forwarded-for')?.split(',')[0]?.trim() ||
      c.req.header('cf-connecting-ip') ||
      c.req.header('x-real-ip') ||
      'unknown'
    );

    // Get endpoint-specific limits
    const path = c.req.path;
    let effectiveWindowMs = windowMs;
    let effectiveMaxRequests = maxRequests;

    for (const [prefix, limits] of Object.entries(endpointLimits)) {
      if (path.startsWith(prefix)) {
        effectiveWindowMs = limits.windowMs;
        effectiveMaxRequests = limits.maxRequests;
        break;
      }
    }

    const key = `${ip}:${effectiveWindowMs}`;
    const now = Date.now();

    // Get or create rate limit entry
    let entry = rateLimitStore.get(key);
    if (!entry || now >= entry.resetTime) {
      entry = { count: 0, resetTime: now + effectiveWindowMs };
      rateLimitStore.set(key, entry);
    }

    // Increment request count
    entry.count++;

    // Check if limit exceeded
    if (entry.count > effectiveMaxRequests) {
      const retryAfter = Math.ceil((entry.resetTime - now) / 1000);
      
      c.header('X-RateLimit-Limit', String(effectiveMaxRequests));
      c.header('X-RateLimit-Remaining', '0');
      c.header('X-RateLimit-Reset', String(Math.ceil(entry.resetTime / 1000)));
      c.header('Retry-After', String(retryAfter));

      return c.json({
        success: false,
        error: 'RATE_LIMIT_EXCEEDED',
        message,
        retryAfter,
      }, 429);
    }

    // Add rate limit headers to response
    c.header('X-RateLimit-Limit', String(effectiveMaxRequests));
    c.header('X-RateLimit-Remaining', String(effectiveMaxRequests - entry.count));
    c.header('X-RateLimit-Reset', String(Math.ceil(entry.resetTime / 1000)));

    return await next();
  };
};

// Pre-configured rate limiters for different scenarios
export const apiRateLimiter = rateLimiter({
  windowMs: DEFAULT_WINDOW_MS,
  maxRequests: DEFAULT_MAX_REQUESTS,
  message: 'API rate limit exceeded. Please try again in a few minutes.',
});

export const strictRateLimiter = rateLimiter({
  windowMs: 60 * 1000, // 1 minute
  maxRequests: 10,
  message: 'Rate limit exceeded. Please wait before making more requests.',
});

export const authRateLimiter = rateLimiter({
  windowMs: 60 * 1000, // 1 minute
  maxRequests: 5,
  message: 'Too many authentication attempts. Please wait before trying again.',
});
