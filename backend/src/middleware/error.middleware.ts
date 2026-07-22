import { Context } from 'hono';
import type { Next } from 'hono';
import { ApiError } from '../types/errors.js';

// =============================================================================
// Global Error Handler Middleware
// =============================================================================
// Catches all errors and returns consistent error responses

export const errorHandler = async (err: Error, c: Context, next: Next) => {
  // If it's an ApiError, use its structured response
  if (err instanceof ApiError) {
    const requestId = c.get('requestId') || 'unknown';
    return c.json(err.toJSON(requestId), err.statusCode as any);
  }

  // Handle Zod validation errors (Zod v4)
  if (err.name === 'ZodError') {
    const requestId = c.get('requestId') || 'unknown';
    // Zod v4: Get issues from the error
    const issues = (err as any).issues || [];
    return c.json({
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Validation failed',
        details: issues,
      },
      timestamp: new Date().toISOString(),
      requestId,
    }, 400);
  }

  // Handle JWT errors
  if (err.name === 'JsonWebTokenError') {
    const requestId = c.get('requestId') || 'unknown';
    return c.json({
      success: false,
      error: {
        code: 'INVALID_TOKEN',
        message: 'Invalid or malformed token',
        details: { error: err.message },
      },
      timestamp: new Date().toISOString(),
      requestId,
    }, 401);
  }

  if (err.name === 'TokenExpiredError') {
    const requestId = c.get('requestId') || 'unknown';
    return c.json({
      success: false,
      error: {
        code: 'TOKEN_EXPIRED',
        message: 'Token has expired',
        details: { error: err.message },
      },
      timestamp: new Date().toISOString(),
      requestId,
    }, 401);
  }

  // Handle generic errors
  const requestId = c.get('requestId') || 'unknown';
  const statusCode = err.name === 'NotFoundError' ? 404 : 500;
  
  return c.json({
    success: false,
    error: {
      code: statusCode === 404 ? 'NOT_FOUND' : 'INTERNAL_SERVER_ERROR',
      message: statusCode === 404 ? 'Resource not found' : 'Internal server error',
      details: process.env.NODE_ENV === 'development' 
        ? { error: err.message, stack: err.stack }
        : undefined,
    },
    timestamp: new Date().toISOString(),
    requestId,
  }, statusCode as any);
};

// =============================================================================
// Error wrapper for async routes
// =============================================================================
// Wraps async route handlers to catch and forward errors to the error handler
export const asyncHandler = (fn: (c: Context) => Promise<any>) => {
  return async (c: Context) => {
    try {
      return await fn(c);
    } catch (err) {
      if (err instanceof ApiError) {
        throw err;
      }
      throw err;
    }
  };
};
