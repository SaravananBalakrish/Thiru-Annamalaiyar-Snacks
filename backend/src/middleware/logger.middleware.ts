import { Context } from 'hono';
import type { Next } from 'hono';
import { nanoid } from 'nanoid';

// =============================================================================
// Request ID Middleware
// =============================================================================
// Generates a unique request ID for each incoming request
// and adds it to the response headers for tracing

export const requestIdMiddleware = async (c: Context, next: Next) => {
  const requestId = nanoid(12);
  
  // Store request ID in context for use in other middleware/handlers
  c.set('requestId', requestId);
  
  // Store start time for duration calculation
  c.set('requestStartTime', Date.now());
  
  // Add request ID to response headers
  await next();
  
  c.header('X-Request-ID', requestId);
};

// =============================================================================
// Request Logging Middleware
// =============================================================================
// Logs details about each request including method, path, status, and duration

export const loggingMiddleware = async (c: Context, next: Next) => {
  const start = Date.now();
  const requestId = c.get('requestId') || nanoid(12);
  
  // Extract request info
  const method = c.req.method;
  const path = c.req.path;
  const ip = c.req.header('x-forwarded-for') || c.req.header('cf-connecting-ip') || 'unknown';
  const userAgent = c.req.header('user-agent') || 'unknown';
  
  // Log request start
  console.log(`[${new Date().toISOString()}] [${requestId}] ${method} ${path} - started from ${ip}`);
  
  try {
    await next();
  } catch (error) {
    // Log errors with request ID
    const duration = Date.now() - start;
    console.error(`[${new Date().toISOString()}] [${requestId}] ${method} ${path} ${500} ${duration}ms - ERROR:`, error);
    throw error;
  } finally {
    const duration = Date.now() - start;
    const status = c.res.status;
    
    // Log request completion
    console.log(`[${new Date().toISOString()}] [${requestId}] ${method} ${path} ${status} ${duration}ms - completed`);
  }
};

// =============================================================================
// Combined Middleware
// =============================================================================
// Combines request ID generation and logging into a single middleware

export const requestLogger = async (c: Context, next: Next) => {
  const requestId = nanoid(12);
  const start = Date.now();
  
  c.set('requestId', requestId);
  c.set('requestStartTime', start);
  
  const method = c.req.method;
  const path = c.req.path;
  const ip = c.req.header('x-forwarded-for') || c.req.header('cf-connecting-ip') || 'unknown';
  
  console.log(`[${new Date().toISOString()}] [${requestId}] ${method} ${path} - started from ${ip}`);
  
  try {
    await next();
  } catch (error) {
    const duration = Date.now() - start;
    console.error(`[${new Date().toISOString()}] [${requestId}] ${method} ${path} 500 ${duration}ms - ERROR:`, error);
    throw error;
  } finally {
    const duration = Date.now() - start;
    const status = c.res.status;
    console.log(`[${new Date().toISOString()}] [${requestId}] ${method} ${path} ${status} ${duration}ms - completed`);
    c.header('X-Request-ID', requestId);
  }
};
