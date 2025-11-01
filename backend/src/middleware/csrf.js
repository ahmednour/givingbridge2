const crypto = require('crypto');
const { sendErrorResponse } = require('../utils/errorHandler');
const { HTTP_STATUS } = require('../constants');

/**
 * Modern CSRF Protection Middleware
 * Uses double-submit cookie pattern
 */

// Store for CSRF tokens (in production, use Redis)
const tokenStore = new Map();

// Token expiry time (1 hour)
const TOKEN_EXPIRY = 60 * 60 * 1000;

/**
 * Generate CSRF token
 */
const generateToken = () => {
  return crypto.randomBytes(32).toString('hex');
};

/**
 * Create CSRF protection middleware
 * Can be used globally or on specific routes
 */
const csrfProtection = (req, res, next) => {
  // Skip for GET, HEAD, OPTIONS (safe methods)
  if (['GET', 'HEAD', 'OPTIONS'].includes(req.method)) {
    return next();
  }

  // Skip for specific routes (including auth endpoints)
  // Note: paths here don't include /api prefix as it's stripped by Express
  const skipRoutes = [
    '/webhooks',
    '/health',
    '/version',
    '/csrf-token',
    '/auth/login',
    '/auth/register',
    '/auth/forgot-password',
    '/auth/reset-password',
    '/auth/verify-email',
    '/auth/resend-verification'
  ];
  
  // Debug logging
  console.log(`CSRF Check: ${req.method} ${req.path}`);
  
  if (skipRoutes.some(route => req.path === route || req.path.startsWith(route + '/'))) {
    console.log(`CSRF Skipped for: ${req.path}`);
    return next();
  }

  // Get token from header
  const token = req.headers['x-csrf-token'] || req.body._csrf;

  if (!token) {
    return sendErrorResponse(
      res,
      'CSRF token is required',
      HTTP_STATUS.FORBIDDEN,
      null,
      { csrfError: true }
    );
  }

  // Verify token
  const storedToken = tokenStore.get(token);
  
  if (!storedToken) {
    return sendErrorResponse(
      res,
      'Invalid CSRF token',
      HTTP_STATUS.FORBIDDEN,
      null,
      { csrfError: true }
    );
  }

  // Check if token expired
  if (Date.now() > storedToken.expiry) {
    tokenStore.delete(token);
    return sendErrorResponse(
      res,
      'CSRF token expired. Please refresh the page.',
      HTTP_STATUS.FORBIDDEN,
      null,
      { csrfError: true, expired: true }
    );
  }

  // Token is valid
  next();
};

/**
 * CSRF error handler
 */
const csrfErrorHandler = (err, req, res, next) => {
  if (err.code === 'EBADCSRFTOKEN' || err.csrfError) {
    return sendErrorResponse(
      res,
      'Invalid CSRF token. Please refresh the page and try again.',
      HTTP_STATUS.FORBIDDEN,
      null,
      { csrfError: true }
    );
  }
  next(err);
};

/**
 * Get CSRF token endpoint
 */
const getCsrfToken = (req, res) => {
  const token = generateToken();
  const expiry = Date.now() + TOKEN_EXPIRY;
  
  // Store token
  tokenStore.set(token, { expiry });
  
  // Clean up expired tokens periodically
  if (tokenStore.size > 10000) {
    cleanupExpiredTokens();
  }
  
  res.json({
    success: true,
    csrfToken: token,
    expiresIn: TOKEN_EXPIRY / 1000, // seconds
    timestamp: new Date().toISOString()
  });
};

/**
 * Clean up expired tokens
 */
const cleanupExpiredTokens = () => {
  const now = Date.now();
  for (const [token, data] of tokenStore.entries()) {
    if (now > data.expiry) {
      tokenStore.delete(token);
    }
  }
};

// Cleanup expired tokens every 10 minutes
setInterval(cleanupExpiredTokens, 10 * 60 * 1000);

module.exports = {
  csrfProtection,
  csrfErrorHandler,
  getCsrfToken
};
