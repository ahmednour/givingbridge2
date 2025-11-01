/**
 * Response Formatter Middleware
 * Standardizes API response format across all endpoints
 */

const CURRENT_VERSION = "1.0.0";

/**
 * Standard API response format
 */
const formatResponse = (success, message, data = null, meta = {}) => {
  const response = {
    success,
    message,
    timestamp: new Date().toISOString(),
    version: CURRENT_VERSION
  };

  if (data !== null) {
    response.data = data;
  }

  if (Object.keys(meta).length > 0) {
    response.meta = meta;
  }

  return response;
};

/**
 * Success response formatter
 */
const formatSuccessResponse = (message, data = null, meta = {}) => {
  return formatResponse(true, message, data, meta);
};

/**
 * Error response formatter
 */
const formatErrorResponse = (message, errors = null, meta = {}) => {
  const response = formatResponse(false, message, null, meta);
  
  if (errors) {
    response.errors = errors;
  }

  // Add error ID for tracking
  response.errorId = `ERR_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

  return response;
};

/**
 * Pagination response formatter
 */
const formatPaginatedResponse = (message, items, pagination, meta = {}) => {
  return formatResponse(true, message, items, {
    pagination,
    ...meta
  });
};

/**
 * Response formatter middleware
 * Adds helper methods to res object
 */
const responseFormatter = (req, res, next) => {
  // Success response helper
  res.success = (message, data = null, statusCode = 200, meta = {}) => {
    const response = formatSuccessResponse(message, data, meta);
    return res.status(statusCode).json(response);
  };

  // Error response helper
  res.error = (message, statusCode = 500, errors = null, meta = {}) => {
    const response = formatErrorResponse(message, errors, meta);
    return res.status(statusCode).json(response);
  };

  // Paginated response helper
  res.paginated = (message, items, pagination, statusCode = 200, meta = {}) => {
    const response = formatPaginatedResponse(message, items, pagination, meta);
    return res.status(statusCode).json(response);
  };

  // Created response helper
  res.created = (message, data = null, meta = {}) => {
    const response = formatSuccessResponse(message, data, meta);
    return res.status(201).json(response);
  };

  // No content response helper
  res.noContent = () => {
    return res.status(204).send();
  };

  // Validation error helper
  res.validationError = (errors, message = 'Validation failed') => {
    const response = formatErrorResponse(message, errors, {
      errorType: 'VALIDATION_ERROR'
    });
    return res.status(400).json(response);
  };

  // Unauthorized error helper
  res.unauthorized = (message = 'Unauthorized access') => {
    const response = formatErrorResponse(message, null, {
      errorType: 'UNAUTHORIZED'
    });
    return res.status(401).json(response);
  };

  // Forbidden error helper
  res.forbidden = (message = 'Access forbidden') => {
    const response = formatErrorResponse(message, null, {
      errorType: 'FORBIDDEN'
    });
    return res.status(403).json(response);
  };

  // Not found error helper
  res.notFound = (message = 'Resource not found') => {
    const response = formatErrorResponse(message, null, {
      errorType: 'NOT_FOUND'
    });
    return res.status(404).json(response);
  };

  // Conflict error helper
  res.conflict = (message = 'Resource conflict') => {
    const response = formatErrorResponse(message, null, {
      errorType: 'CONFLICT'
    });
    return res.status(409).json(response);
  };

  // Rate limit error helper
  res.rateLimitExceeded = (message = 'Rate limit exceeded', retryAfter = 60) => {
    const response = formatErrorResponse(message, null, {
      errorType: 'RATE_LIMIT_EXCEEDED',
      retryAfter
    });
    
    // Add rate limit headers
    res.set({
      'Retry-After': retryAfter,
      'X-RateLimit-Exceeded': 'true'
    });
    
    return res.status(429).json(response);
  };

  // Server error helper
  res.serverError = (message = 'Internal server error', errorId = null) => {
    const response = formatErrorResponse(message, null, {
      errorType: 'INTERNAL_ERROR',
      ...(errorId && { errorId })
    });
    return res.status(500).json(response);
  };

  next();
};

/**
 * Response headers middleware
 * Adds standard headers to all responses
 */
const addResponseHeaders = (req, res, next) => {
  // Add standard API headers
  res.set({
    'X-Powered-By': 'GivingBridge API',
    'X-Response-Time': Date.now() - req.startTime,
    'Cache-Control': 'no-cache, no-store, must-revalidate',
    'Pragma': 'no-cache',
    'Expires': '0'
  });

  // Add CORS headers if not already set
  if (!res.get('Access-Control-Allow-Origin')) {
    res.set({
      'Access-Control-Allow-Origin': process.env.FRONTEND_URL || '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-API-Version',
      'Access-Control-Expose-Headers': 'X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset'
    });
  }

  next();
};

/**
 * Request timing middleware
 * Adds request start time for response time calculation
 */
const requestTiming = (req, res, next) => {
  req.startTime = Date.now();
  next();
};

module.exports = {
  responseFormatter,
  addResponseHeaders,
  requestTiming,
  formatResponse,
  formatSuccessResponse,
  formatErrorResponse,
  formatPaginatedResponse
};