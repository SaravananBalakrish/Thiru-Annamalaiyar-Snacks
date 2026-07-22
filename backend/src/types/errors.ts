// =============================================================================
// Standard Error Types
// =============================================================================
// Defines consistent error response format across the API

/**
 * Standard API error response format
 */
export interface ApiErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
    details?: Record<string, any>;
  };
  timestamp: string;
  requestId?: string;
}

/**
 * Error codes for different types of errors
 */
export const ErrorCodes = {
  // Authentication errors
  UNAUTHORIZED: 'UNAUTHORIZED',
  INVALID_TOKEN: 'INVALID_TOKEN',
  TOKEN_EXPIRED: 'TOKEN_EXPIRED',
  TOKEN_BLACKLISTED: 'TOKEN_BLACKLISTED',
  INVALID_CREDENTIALS: 'INVALID_CREDENTIALS',
  
  // Validation errors
  VALIDATION_ERROR: 'VALIDATION_ERROR',
  INVALID_INPUT: 'INVALID_INPUT',
  
  // Rate limiting
  RATE_LIMIT_EXCEEDED: 'RATE_LIMIT_EXCEEDED',
  
  // Resource errors
  NOT_FOUND: 'NOT_FOUND',
  RESOURCE_EXISTS: 'RESOURCE_EXISTS',
  
  // Permission errors
  FORBIDDEN: 'FORBIDDEN',
  INSUFFICIENT_PERMISSIONS: 'INSUFFICIENT_PERMISSIONS',
  
  // Business logic errors
  OTP_INVALID: 'OTP_INVALID',
  OTP_EXPIRED: 'OTP_EXPIRED',
  CART_EMPTY: 'CART_EMPTY',
  PAYMENT_FAILED: 'PAYMENT_FAILED',
  
  // Server errors
  INTERNAL_SERVER_ERROR: 'INTERNAL_SERVER_ERROR',
  SERVICE_UNAVAILABLE: 'SERVICE_UNAVAILABLE',
} as const;

export type ErrorCode = keyof typeof ErrorCodes;

/**
 * Custom API error class for consistent error handling
 */
export class ApiError extends Error {
  public readonly statusCode: number;
  public readonly code: ErrorCode;
  public readonly details?: Record<string, any>;
  public readonly timestamp: string;

  constructor(
    code: ErrorCode,
    message: string,
    statusCode: number,
    details?: Record<string, any>
  ) {
    super(message);
    this.name = 'ApiError';
    this.code = code;
    this.statusCode = statusCode;
    this.details = details;
    this.timestamp = new Date().toISOString();
  }

  toJSON(requestId?: string): ApiErrorResponse {
    return {
      success: false,
      error: {
        code: this.code,
        message: this.message,
        details: this.details,
      },
      timestamp: this.timestamp,
      requestId,
    };
  }
}

/**
 * Helper function to create validation error
 */
export const createValidationError = (message: string, details?: Record<string, any>) => {
  return new ApiError(
    ErrorCodes.VALIDATION_ERROR,
    message,
    400,
    details
  );
};

/**
 * Helper function to create not found error
 */
export const createNotFoundError = (resource: string, identifier?: string | number) => {
  const message = identifier 
    ? `${resource} not found with id: ${identifier}`
    : `${resource} not found`;
  return new ApiError(
    ErrorCodes.NOT_FOUND,
    message,
    404,
    { resource, identifier }
  );
};

/**
 * Helper function to create unauthorized error
 */
export const createUnauthorizedError = (message = 'Unauthorized') => {
  return new ApiError(
    ErrorCodes.UNAUTHORIZED,
    message,
    401
  );
};

/**
 * Helper function to create forbidden error
 */
export const createForbiddenError = (message = 'Forbidden') => {
  return new ApiError(
    ErrorCodes.FORBIDDEN,
    message,
    403
  );
};

/**
 * Helper function to create rate limit error
 */
export const createRateLimitError = (retryAfter?: number) => {
  return new ApiError(
    ErrorCodes.RATE_LIMIT_EXCEEDED,
    'Too many requests, please try again later',
    429,
    retryAfter ? { retryAfter } : undefined
  );
};
