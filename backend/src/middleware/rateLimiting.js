const rateLimit = require("express-rate-limit");
const { sendErrorResponse } = require("../utils/errorHandler");
const { HTTP_STATUS } = require("../constants");
const logger = require("../utils/logger");

/**
 * Enhanced rate limiting middleware with structured logging
 */

/**
 * Create a rate limiter with custom configuration
 * @param {Object} options - Rate limiting options
 * @returns {Function} Express middleware function
 */
const createRateLimiter = (options = {}) => {
  const {
    windowMs = 15 * 60 * 1000, // 15 minutes
    max = 100, // limit each IP to 100 requests per windowMs
    message = "Too many requests from this IP, please try again later",
    standardHeaders = true,
    legacyHeaders = false,
    skipSuccessfulRequests = false,
    skipFailedRequests = false,
    keyGenerator = (req) => req.ip,
    skip = () => false,
    onLimitReached = null,
    ...otherOptions
  } = options;

  return rateLimit({
    windowMs,
    max,
    standardHeaders,
    legacyHeaders,
    skipSuccessfulRequests,
    skipFailedRequests,
    keyGenerator,
    skip,
    message: {
      success: false,
      message,
      errorType: "RATE_LIMIT_EXCEEDED",
      retryAfter: Math.ceil(windowMs / 1000),
      timestamp: new Date().toISOString()
    },
    handler: (req, res) => {
      // Log rate limit exceeded
      logger.warn("Rate limit exceeded", {
        req,
        ip: req.ip,
        userAgent: req.get('User-Agent'),
        limit: max,
        windowMs,
        path: req.path
      });

      // Call custom onLimitReached handler if provided
      if (onLimitReached) {
        onLimitReached(req, res);
      }

      // Send structured error response
      sendErrorResponse(
        res,
        message,
        HTTP_STATUS.TOO_MANY_REQUESTS,
        null,
        {
          rateLimitExceeded: true,
          retryAfter: Math.ceil(windowMs / 1000)
        }
      );
    },
    ...otherOptions
  });
};

/**
 * General API rate limiter
 * DISABLED FOR GRADUATION PROJECT DEMO
 */
const generalRateLimit = createRateLimiter({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000,
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 999999, // Effectively disabled
  message: "Too many requests from this IP, please try again later"
});

/**
 * Strict rate limiter for authentication endpoints
 * DISABLED FOR GRADUATION PROJECT DEMO
 */
const authRateLimit = createRateLimiter({
  windowMs: parseInt(process.env.LOGIN_RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000,
  max: parseInt(process.env.LOGIN_RATE_LIMIT_MAX_ATTEMPTS) || 999999, // Effectively disabled
  message: "Too many authentication attempts, please try again later",
  skipSuccessfulRequests: true, // Don't count successful logins
  onLimitReached: (req, res) => {
    // Log potential brute force attack
    logger.logSecurityEvent("Potential brute force attack", "HIGH", {
      req,
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      endpoint: req.path
    });
  }
});

/**
 * Lenient rate limiter for file uploads
 * DISABLED FOR GRADUATION PROJECT DEMO
 */
const uploadRateLimit = createRateLimiter({
  windowMs: 60 * 1000, // 1 minute
  max: 999999, // Effectively disabled
  message: "Too many file uploads, please wait before uploading again"
});

/**
 * Strict rate limiter for password reset requests
 * DISABLED FOR GRADUATION PROJECT DEMO
 */
const passwordResetRateLimit = createRateLimiter({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 999999, // Effectively disabled
  message: "Too many password reset requests, please try again later",
  keyGenerator: (req) => {
    // Rate limit by email if provided, otherwise by IP
    return req.body.email || req.ip;
  }
});

/**
 * Rate limiter for email verification requests
 * DISABLED FOR GRADUATION PROJECT DEMO
 */
const emailVerificationLimiter = createRateLimiter({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 999999, // Effectively disabled
  message: "Too many email verification requests, please try again later",
  keyGenerator: (req) => {
    // Rate limit by email if provided, otherwise by IP
    return req.body.email || req.ip;
  }
});

/**
 * Rate limiter for search endpoints
 * DISABLED FOR GRADUATION PROJECT DEMO
 */
const searchRateLimit = createRateLimiter({
  windowMs: 60 * 1000, // 1 minute
  max: 999999, // Effectively disabled
  message: "Too many search requests, please slow down"
});

/**
 * Rate limiter for API endpoints that create resources
 * DISABLED FOR GRADUATION PROJECT DEMO
 */
const createResourceRateLimit = createRateLimiter({
  windowMs: 60 * 1000, // 1 minute
  max: 999999, // Effectively disabled
  message: "Too many resource creation requests, please slow down"
});

/**
 * Dynamic rate limiter based on user role
 * @param {Object} limits - Rate limits by role
 * @returns {Function} Express middleware function
 */
const createRoleBasedRateLimit = (limits = {}) => {
  const defaultLimits = {
    admin: { windowMs: 15 * 60 * 1000, max: 1000 },
    donor: { windowMs: 15 * 60 * 1000, max: 200 },
    receiver: { windowMs: 15 * 60 * 1000, max: 200 },
    guest: { windowMs: 15 * 60 * 1000, max: 50 }
  };

  const roleLimits = { ...defaultLimits, ...limits };

  return (req, res, next) => {
    const userRole = req.user?.role || 'guest';
    const limit = roleLimits[userRole] || roleLimits.guest;

    const rateLimiter = createRateLimiter({
      ...limit,
      keyGenerator: (req) => {
        // Use user ID if authenticated, otherwise IP
        return req.user?.id ? `user_${req.user.id}` : `ip_${req.ip}`;
      },
      message: `Rate limit exceeded for ${userRole} role`
    });

    rateLimiter(req, res, next);
  };
};

/**
 * Middleware to add rate limit headers to responses
 */
const addRateLimitHeaders = () => {
  return (req, res, next) => {
    // Add custom rate limit information
    res.setHeader('X-RateLimit-Policy', 'GivingBridge API Rate Limiting');
    
    // Add documentation link
    res.setHeader('X-RateLimit-Docs', 'https://api.givingbridge.com/docs/rate-limits');
    
    next();
  };
};

module.exports = {
  createRateLimiter,
  generalRateLimit,
  authRateLimit,
  uploadRateLimit,
  passwordResetRateLimit,
  emailVerificationLimiter,
  searchRateLimit,
  createResourceRateLimit,
  createRoleBasedRateLimit,
  addRateLimitHeaders
};