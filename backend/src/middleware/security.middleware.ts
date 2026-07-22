import { Context } from 'hono';
import type { Next } from 'hono';

// =============================================================================
// Security Headers Middleware
// =============================================================================
// Adds essential security headers to all responses
// Based on OWASP recommendations and Helmet.js

export interface SecurityHeadersConfig {
  /**
   * Content Security Policy
   * Controls which resources can be loaded
   */
  contentSecurityPolicy?: string;

  /**
   * X-Content-Type-Options
   * Prevents MIME type sniffing
   */
  xContentTypeOptions?: boolean;

  /**
   * X-Frame-Options
   * Prevents clickjacking by controlling iframe embedding
   */
  xFrameOptions?: 'DENY' | 'SAMEORIGIN';

  /**
   * X-XSS-Protection
   * Enables XSS protection in browsers
   */
  xssProtection?: string;

  /**
   * Strict-Transport-Security
   * Enforces HTTPS connections
   */
  strictTransportSecurity?: string;

  /**
   * Referrer-Policy
   * Controls how much referrer information is sent
   */
  referrerPolicy?: 'no-referrer' | 'no-referrer-when-downgrade' | 'same-origin' | 'origin' | 'strict-origin' | 'origin-when-cross-origin' | 'strict-origin-when-cross-origin' | 'unsafe-url';

  /**
   * Permissions-Policy
   * Controls which browser features can be used
   */
  permissionsPolicy?: Record<string, string[]>;

  /**
   * Cross-Origin-Opener-Policy
   * Isolates your application from other origins
   */
  crossOriginOpenerPolicy?: 'unsafe-none' | 'same-origin-allow-popups' | 'same-origin';

  /**
   * Cross-Origin-Resource-Policy
   * Prevents certain types of cross-origin requests
   */
  crossOriginResourcePolicy?: 'same-site' | 'same-origin' | 'cross-origin';
}

// Default security headers configuration
const defaultConfig: Required<SecurityHeadersConfig> = {
  contentSecurityPolicy:
    "default-src 'self'; " +
    "script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdn.jsdelivr.net https://unpkg.com; " +
    "style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net https://unpkg.com https://fonts.googleapis.com; " +
    "img-src 'self' data: https://cdn.jsdelivr.net https://unpkg.com; " +
    "font-src 'self' data: https://fonts.gstatic.com https://cdn.jsdelivr.net; " +
    "connect-src 'self' https://cdn.jsdelivr.net https://unpkg.com; " +
    "frame-src 'self'; object-src 'none'; base-uri 'self'; form-action 'self';",
  xContentTypeOptions: true,
  xFrameOptions: 'DENY',
  xssProtection: '1; mode=block',
  strictTransportSecurity: 'max-age=63072000; includeSubDomains; preload',
  referrerPolicy: 'strict-origin-when-cross-origin',
  permissionsPolicy: {
    geolocation: [],
    microphone: [],
    camera: [],
    payment: [],
    usb: [],
  },
  crossOriginOpenerPolicy: 'same-origin',
  crossOriginResourcePolicy: 'cross-origin',
};

export const securityHeaders = (config?: SecurityHeadersConfig) => {
  const mergedConfig = { ...defaultConfig, ...config };

  return async (c: Context, next: Next) => {
    // Content-Security-Policy
    if (mergedConfig.contentSecurityPolicy) {
      c.header('Content-Security-Policy', mergedConfig.contentSecurityPolicy);
    }

    // X-Content-Type-Options
    if (mergedConfig.xContentTypeOptions) {
      c.header('X-Content-Type-Options', 'nosniff');
    }

    // X-Frame-Options
    if (mergedConfig.xFrameOptions) {
      c.header('X-Frame-Options', mergedConfig.xFrameOptions);
    }

    // X-XSS-Protection
    if (mergedConfig.xssProtection) {
      c.header('X-XSS-Protection', mergedConfig.xssProtection);
    }

    // Strict-Transport-Security (only in production)
    if (mergedConfig.strictTransportSecurity && process.env.NODE_ENV === 'production') {
      c.header('Strict-Transport-Security', mergedConfig.strictTransportSecurity);
    }

    // Referrer-Policy
    if (mergedConfig.referrerPolicy) {
      c.header('Referrer-Policy', mergedConfig.referrerPolicy);
    }

    // Permissions-Policy
    if (mergedConfig.permissionsPolicy) {
      const directives = Object.entries(mergedConfig.permissionsPolicy)
        .map(([feature, allowedOrigins]) => {
          if (allowedOrigins.length === 0) {
            return `${feature}=()`;
          }
          return `${feature}=(${allowedOrigins.join(', ')})`;
        })
        .join(', ');
      c.header('Permissions-Policy', directives);
    }

    // Cross-Origin-Opener-Policy
    if (mergedConfig.crossOriginOpenerPolicy) {
      c.header('Cross-Origin-Opener-Policy', mergedConfig.crossOriginOpenerPolicy);
    }

    // Cross-Origin-Resource-Policy
    if (mergedConfig.crossOriginResourcePolicy) {
      c.header('Cross-Origin-Resource-Policy', mergedConfig.crossOriginResourcePolicy);
    }

    // Additional security headers
    c.header('X-DNS-Prefetch-Control', 'off');

    await next();
  };
};

// Pre-configured security headers for API applications (including Swagger UI & Scalar documentation)
export const apiSecurityHeaders = securityHeaders({
  contentSecurityPolicy:
    "default-src 'self'; " +
    "script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdn.jsdelivr.net https://unpkg.com; " +
    "style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net https://unpkg.com https://fonts.googleapis.com; " +
    "img-src 'self' data: https://cdn.jsdelivr.net https://unpkg.com https://validator.swagger.io; " +
    "font-src 'self' data: https://fonts.gstatic.com https://cdn.jsdelivr.net; " +
    "connect-src 'self' https://cdn.jsdelivr.net https://unpkg.com; " +
    "frame-ancestors 'none'; " +
    "form-action 'self';",
  xContentTypeOptions: true,
  xFrameOptions: 'DENY',
  xssProtection: '1; mode=block',
  referrerPolicy: 'strict-origin-when-cross-origin',
  permissionsPolicy: {
    geolocation: [],
    microphone: [],
    camera: [],
    payment: [],
    usb: [],
  },
  crossOriginOpenerPolicy: 'same-origin',
  crossOriginResourcePolicy: 'cross-origin',
});
