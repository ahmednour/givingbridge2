/**
 * HTTPS Redirect Middleware
 * Enforces HTTPS connections in production environment
 */

const logger = require("../utils/logger");

/**
 * Middleware to enforce HTTPS connections
 * @param {Object} options - Configuration options
 * @returns {Function} Express middleware function
 */
const enforceHTTPS = (options = {}) => {
  const {
    enabled = process.env.NODE_ENV === 'production',
    trustProxy = true,
    includeSubDomains = true,
    preload = true,
    maxAge = 31536000, // 1 year
    excludePaths = ['/health', '/.well-known/'],
    redirectCode = 301
  } = options;

  return (req, res, next) => {
    // Skip if HTTPS enforcement is disabled
    if (!enabled) {
      return next();
    }

    // Skip for excluded paths
    if (excludePaths.some(path => req.path.startsWith(path))) {
      return next();
    }

    // Determine if request is secure
    let isSecure = req.secure;
    
    if (trustProxy) {
      // Check various proxy headers
      const forwardedProto = req.headers['x-forwarded-proto'];
      const forwardedSsl = req.headers['x-forwarded-ssl'];
      const cloudFrontProto = req.headers['cloudfront-forwarded-proto'];
      
      if (forwardedProto === 'https' || 
          forwardedSsl === 'on' || 
          cloudFrontProto === 'https') {
        isSecure = true;
      }
    }

    // If not secure, redirect to HTTPS
    if (!isSecure) {
      const httpsUrl = `https://${req.get('host')}${req.originalUrl}`;
      
      logger.logSecurityEvent("HTTP to HTTPS redirect", "INFO", {
        originalUrl: req.originalUrl,
        redirectUrl: httpsUrl,
        ip: req.ip,
        userAgent: req.headers['user-agent']
      });

      return res.redirect(redirectCode, httpsUrl);
    }

    // Set HSTS header for secure connections
    const hstsValue = `max-age=${maxAge}${includeSubDomains ? '; includeSubDomains' : ''}${preload ? '; preload' : ''}`;
    res.setHeader('Strict-Transport-Security', hstsValue);

    next();
  };
};

/**
 * Middleware to set secure headers for HTTPS connections
 */
const setSecureHeaders = () => {
  return (req, res, next) => {
    // Only set secure headers for HTTPS connections
    if (req.secure || req.headers['x-forwarded-proto'] === 'https') {
      // Strict Transport Security
      res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains; preload');
      
      // Secure cookie settings
      if (res.cookie) {
        const originalCookie = res.cookie;
        res.cookie = function(name, value, options = {}) {
          options.secure = true;
          options.httpOnly = true;
          options.sameSite = 'strict';
          return originalCookie.call(this, name, value, options);
        };
      }
    }

    next();
  };
};

/**
 * Middleware to check SSL certificate validity (for monitoring)
 */
const checkSSLCertificate = () => {
  return (req, res, next) => {
    // This would typically be used with external monitoring
    // For now, just log SSL-related information
    if (req.secure || req.headers['x-forwarded-proto'] === 'https') {
      const sslInfo = {
        protocol: req.headers['x-forwarded-proto'] || 'https',
        cipher: req.connection?.getCipher?.() || 'unknown',
        authorized: req.connection?.authorized || 'unknown',
        peerCertificate: req.connection?.getPeerCertificate?.() || null
      };

      // Log SSL information for monitoring (only in debug mode)
      if (process.env.LOG_LEVEL === 'debug') {
        logger.debug("SSL connection info", {
          sslInfo,
          ip: req.ip,
          path: req.path
        });
      }
    }

    next();
  };
};

/**
 * Middleware to validate SSL configuration
 */
const validateSSLConfig = () => {
  return (req, res, next) => {
    // Check for mixed content issues
    if (req.secure || req.headers['x-forwarded-proto'] === 'https') {
      // Ensure all resources are loaded over HTTPS
      res.setHeader('Content-Security-Policy', 
        "default-src 'self' https:; " +
        "script-src 'self' https:; " +
        "style-src 'self' 'unsafe-inline' https:; " +
        "img-src 'self' data: https:; " +
        "connect-src 'self' wss: https:; " +
        "font-src 'self' https:; " +
        "object-src 'none'; " +
        "media-src 'self' https:; " +
        "frame-src 'none'; " +
        "upgrade-insecure-requests"
      );
    }

    next();
  };
};

/**
 * Complete HTTPS middleware stack
 */
const httpsMiddleware = (options = {}) => {
  return [
    enforceHTTPS(options),
    setSecureHeaders(),
    checkSSLCertificate(),
    validateSSLConfig()
  ];
};

module.exports = {
  enforceHTTPS,
  setSecureHeaders,
  checkSSLCertificate,
  validateSSLConfig,
  httpsMiddleware
};