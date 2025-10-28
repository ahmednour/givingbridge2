/**
 * Production Security Configuration
 * Comprehensive security hardening for the GivingBridge platform
 */

const helmet = require("helmet");
const rateLimit = require("express-rate-limit");
const { ValidationError } = require("../utils/errorHandler");
const logger = require("../utils/logger");

/**
 * Security configuration class
 */
class SecurityConfig {
  constructor() {
    this.isProduction = process.env.NODE_ENV === "production";
    this.isDevelopment = process.env.NODE_ENV === "development";
  }

  /**
   * Get Helmet security configuration
   */
  getHelmetConfig() {
    const baseConfig = {
      // Content Security Policy
      contentSecurityPolicy: {
        directives: {
          defaultSrc: ["'self'"],
          styleSrc: [
            "'self'",
            "'unsafe-inline'", // Required for some CSS frameworks
            "https://fonts.googleapis.com",
            "https://cdnjs.cloudflare.com"
          ],
          scriptSrc: [
            "'self'",
            "https://www.google-analytics.com",
            "https://www.googletagmanager.com"
          ],
          imgSrc: [
            "'self'",
            "data:",
            "https:",
            "blob:",
            "https://www.google-analytics.com"
          ],
          connectSrc: [
            "'self'",
            "https://api.givingbridge.com",
            "wss://api.givingbridge.com",
            "https://www.google-analytics.com"
          ],
          fontSrc: [
            "'self'",
            "https://fonts.gstatic.com",
            "https://cdnjs.cloudflare.com"
          ],
          objectSrc: ["'none'"],
          mediaSrc: ["'self'"],
          frameSrc: ["'none'"],
          baseUri: ["'self'"],
          formAction: ["'self'"]
        }
      },

      // HTTP Strict Transport Security
      hsts: {
        maxAge: 31536000, // 1 year
        includeSubDomains: true,
        preload: true
      },

      // X-Content-Type-Options
      noSniff: true,

      // X-Frame-Options
      frameguard: { action: "deny" },

      // X-XSS-Protection
      xssFilter: true,

      // Referrer Policy
      referrerPolicy: { policy: "strict-origin-when-cross-origin" },

      // Cross-Origin Embedder Policy
      crossOriginEmbedderPolicy: false,

      // Cross-Origin Opener Policy
      crossOriginOpenerPolicy: { policy: "same-origin" },

      // Cross-Origin Resource Policy
      crossOriginResourcePolicy: { policy: "cross-origin" },

      // Permissions Policy
      permissionsPolicy: {
        camera: [],
        microphone: [],
        geolocation: ["self"],
        notifications: ["self"],
        payment: ["self"]
      }
    };

    // Development overrides
    if (this.isDevelopment) {
      baseConfig.contentSecurityPolicy = false; // Disable CSP in development
      baseConfig.hsts = false; // Disable HSTS in development
    }

    return baseConfig;
  }

  /**
   * Get CORS configuration
   */
  getCorsConfig() {
    const allowedOrigins = this.isProduction
      ? [
          "https://givingbridge.com",
          "https://www.givingbridge.com",
          "https://app.givingbridge.com"
        ]
      : [
          "http://localhost:3000",
          "http://localhost:8080",
          "http://127.0.0.1:3000",
          "http://127.0.0.1:8080"
        ];

    return {
      origin: (origin, callback) => {
        // Allow requests with no origin (mobile apps, Postman, etc.)
        if (!origin) return callback(null, true);

        if (allowedOrigins.includes(origin)) {
          callback(null, true);
        } else {
          logger.logSecurityEvent("CORS violation", "MEDIUM", {
            origin,
            allowedOrigins,
            timestamp: new Date().toISOString()
          });
          callback(new Error("Not allowed by CORS"));
        }
      },
      credentials: true,
      methods: ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
      allowedHeaders: [
        "Origin",
        "X-Requested-With",
        "Content-Type",
        "Accept",
        "Authorization",
        "X-API-Key"
      ],
      exposedHeaders: [
        "X-RateLimit-Limit",
        "X-RateLimit-Remaining",
        "X-RateLimit-Reset"
      ],
      maxAge: 86400 // 24 hours
    };
  }

  /**
   * Enhanced input validation middleware
   */
  getInputValidationMiddleware() {
    return (req, res, next) => {
      try {
        // Validate request size
        const maxBodySize = 10 * 1024 * 1024; // 10MB
        if (req.headers['content-length'] && parseInt(req.headers['content-length']) > maxBodySize) {
          throw new ValidationError("Request body too large");
        }

        // Validate Content-Type for POST/PUT requests
        if (['POST', 'PUT', 'PATCH'].includes(req.method)) {
          const contentType = req.headers['content-type'];
          if (!contentType) {
            throw new ValidationError("Content-Type header is required");
          }

          const allowedTypes = [
            'application/json',
            'multipart/form-data',
            'application/x-www-form-urlencoded'
          ];

          if (!allowedTypes.some(type => contentType.includes(type))) {
            throw new ValidationError("Invalid Content-Type");
          }
        }

        // Validate User-Agent (basic bot detection)
        const userAgent = req.headers['user-agent'];
        if (!userAgent || userAgent.length < 10) {
          logger.logSecurityEvent("Suspicious User-Agent", "LOW", {
            userAgent,
            ip: req.ip,
            path: req.path
          });
        }

        // Check for suspicious patterns in URL
        const suspiciousPatterns = [
          /\.\./,           // Directory traversal
          /<script/i,       // XSS attempts
          /union.*select/i, // SQL injection
          /exec\(/i,        // Code injection
          /eval\(/i         // Code injection
        ];

        const fullUrl = req.originalUrl || req.url;
        for (const pattern of suspiciousPatterns) {
          if (pattern.test(fullUrl)) {
            logger.logSecurityEvent("Suspicious URL pattern", "HIGH", {
              url: fullUrl,
              ip: req.ip,
              pattern: pattern.toString()
            });
            throw new ValidationError("Invalid request");
          }
        }

        next();
      } catch (error) {
        next(error);
      }
    };
  }

  /**
   * File upload security middleware
   */
  getFileUploadSecurityMiddleware() {
    return (req, res, next) => {
      if (!req.file && !req.files) {
        return next();
      }

      const files = req.files ? Object.values(req.files).flat() : [req.file];

      for (const file of files) {
        // Validate file size
        const maxSize = 10 * 1024 * 1024; // 10MB
        if (file.size > maxSize) {
          throw new ValidationError(`File ${file.originalname} exceeds maximum size of 10MB`);
        }

        // Validate file type
        const allowedMimeTypes = [
          'image/jpeg',
          'image/png',
          'image/gif',
          'image/webp',
          'application/pdf',
          'text/plain',
          'text/csv'
        ];

        if (!allowedMimeTypes.includes(file.mimetype)) {
          throw new ValidationError(`File type ${file.mimetype} is not allowed`);
        }

        // Validate file extension
        const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.pdf', '.txt', '.csv'];
        const fileExtension = file.originalname.toLowerCase().substring(file.originalname.lastIndexOf('.'));
        
        if (!allowedExtensions.includes(fileExtension)) {
          throw new ValidationError(`File extension ${fileExtension} is not allowed`);
        }

        // Check for suspicious file names
        const suspiciousPatterns = [
          /\.\./,           // Directory traversal
          /[<>:"|?*]/,      // Invalid characters
          /^(con|prn|aux|nul|com[1-9]|lpt[1-9])$/i, // Windows reserved names
          /\.php$/i,        // Executable files
          /\.exe$/i,
          /\.bat$/i,
          /\.cmd$/i,
          /\.scr$/i,
          /\.js$/i
        ];

        for (const pattern of suspiciousPatterns) {
          if (pattern.test(file.originalname)) {
            logger.logSecurityEvent("Suspicious file upload", "HIGH", {
              filename: file.originalname,
              mimetype: file.mimetype,
              size: file.size,
              ip: req.ip
            });
            throw new ValidationError("Invalid file name");
          }
        }

        // Sanitize file name
        file.originalname = file.originalname
          .replace(/[^a-zA-Z0-9.-]/g, '_')
          .substring(0, 100); // Limit filename length
      }

      next();
    };
  }

  /**
   * API key validation middleware
   */
  getApiKeyValidationMiddleware() {
    return (req, res, next) => {
      // Skip API key validation for public endpoints
      const publicEndpoints = [
        '/api/auth/login',
        '/api/auth/register',
        '/api/auth/forgot-password',
        '/health',
        '/'
      ];

      if (publicEndpoints.includes(req.path)) {
        return next();
      }

      const apiKey = req.headers['x-api-key'];
      const authHeader = req.headers.authorization;

      // Require either API key or JWT token
      if (!apiKey && !authHeader) {
        throw new ValidationError("API key or authorization token required");
      }

      // Validate API key format if provided
      if (apiKey) {
        const apiKeyPattern = /^[a-zA-Z0-9]{32,64}$/;
        if (!apiKeyPattern.test(apiKey)) {
          logger.logSecurityEvent("Invalid API key format", "MEDIUM", {
            apiKey: apiKey.substring(0, 8) + '...',
            ip: req.ip,
            path: req.path
          });
          throw new ValidationError("Invalid API key format");
        }
      }

      next();
    };
  }

  /**
   * Request logging middleware for security monitoring
   */
  getSecurityLoggingMiddleware() {
    return (req, res, next) => {
      // Log sensitive operations
      const sensitiveEndpoints = [
        '/api/auth/login',
        '/api/auth/register',
        '/api/auth/forgot-password',
        '/api/auth/reset-password',
        '/api/users/change-password',
        '/api/verification'
      ];

      if (sensitiveEndpoints.some(endpoint => req.path.startsWith(endpoint))) {
        logger.logSecurityEvent("Sensitive endpoint access", "INFO", {
          method: req.method,
          path: req.path,
          ip: req.ip,
          userAgent: req.headers['user-agent'],
          timestamp: new Date().toISOString()
        });
      }

      // Log failed authentication attempts
      const originalSend = res.send;
      res.send = function(data) {
        if (res.statusCode === 401 || res.statusCode === 403) {
          logger.logSecurityEvent("Authentication failure", "MEDIUM", {
            method: req.method,
            path: req.path,
            ip: req.ip,
            statusCode: res.statusCode,
            userAgent: req.headers['user-agent']
          });
        }
        originalSend.call(this, data);
      };

      next();
    };
  }

  /**
   * Production security headers middleware
   */
  getSecurityHeadersMiddleware() {
    return (req, res, next) => {
      // Remove server information
      res.removeHeader('X-Powered-By');
      
      // Add custom security headers
      res.setHeader('X-API-Version', '1.0');
      res.setHeader('X-Security-Policy', 'GivingBridge Security Policy v1.0');
      
      if (this.isProduction) {
        // Production-only headers
        res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains; preload');
        res.setHeader('X-Content-Type-Options', 'nosniff');
        res.setHeader('X-Frame-Options', 'DENY');
        res.setHeader('X-XSS-Protection', '1; mode=block');
        res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
      }

      next();
    };
  }

  /**
   * Get complete security middleware stack
   */
  getSecurityMiddleware() {
    return [
      this.getSecurityHeadersMiddleware(),
      helmet(this.getHelmetConfig()),
      this.getInputValidationMiddleware(),
      this.getSecurityLoggingMiddleware(),
      this.getApiKeyValidationMiddleware()
    ];
  }
}

// Export singleton instance
const securityConfig = new SecurityConfig();

module.exports = {
  SecurityConfig,
  securityConfig,
  getHelmetConfig: () => securityConfig.getHelmetConfig(),
  getCorsConfig: () => securityConfig.getCorsConfig(),
  getInputValidationMiddleware: () => securityConfig.getInputValidationMiddleware(),
  getFileUploadSecurityMiddleware: () => securityConfig.getFileUploadSecurityMiddleware(),
  getApiKeyValidationMiddleware: () => securityConfig.getApiKeyValidationMiddleware(),
  getSecurityLoggingMiddleware: () => securityConfig.getSecurityLoggingMiddleware(),
  getSecurityHeadersMiddleware: () => securityConfig.getSecurityHeadersMiddleware(),
  getSecurityMiddleware: () => securityConfig.getSecurityMiddleware()
};