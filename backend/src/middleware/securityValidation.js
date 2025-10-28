/**
 * Enhanced Security Validation Middleware
 * Comprehensive input validation and sanitization for production security
 */

const { ValidationError } = require("../utils/errorHandler");
const logger = require("../utils/logger");
const validator = require("express-validator");

/**
 * SQL Injection detection patterns
 */
const SQL_INJECTION_PATTERNS = [
  /(\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|EXEC|EXECUTE)\b)/i,
  /(UNION\s+SELECT)/i,
  /(\bOR\b\s+\d+\s*=\s*\d+)/i,
  /(\bAND\b\s+\d+\s*=\s*\d+)/i,
  /(--|\#|\/\*|\*\/)/,
  /(\bxp_cmdshell\b)/i,
  /(\bsp_executesql\b)/i
];

/**
 * XSS detection patterns
 */
const XSS_PATTERNS = [
  /<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi,
  /<iframe\b[^<]*(?:(?!<\/iframe>)<[^<]*)*<\/iframe>/gi,
  /<object\b[^<]*(?:(?!<\/object>)<[^<]*)*<\/object>/gi,
  /<embed\b[^<]*(?:(?!<\/embed>)<[^<]*)*<\/embed>/gi,
  /javascript:/gi,
  /vbscript:/gi,
  /onload\s*=/gi,
  /onerror\s*=/gi,
  /onclick\s*=/gi,
  /onmouseover\s*=/gi
];

/**
 * Path traversal detection patterns
 */
const PATH_TRAVERSAL_PATTERNS = [
  /\.\.\//g,
  /\.\.\\g,
  /%2e%2e%2f/gi,
  /%2e%2e%5c/gi,
  /\.\.%2f/gi,
  /\.\.%5c/gi
];

/**
 * Command injection detection patterns
 */
const COMMAND_INJECTION_PATTERNS = [
  /[;&|`$(){}[\]]/,
  /\b(cat|ls|dir|type|copy|move|del|rm|mkdir|rmdir|cd|pwd)\b/i,
  /\b(wget|curl|nc|netcat|telnet|ssh|ftp)\b/i,
  /\b(eval|exec|system|shell_exec|passthru)\b/i
];

/**
 * Detect and log security threats in input
 */
const detectSecurityThreats = (input, fieldName, req) => {
  const threats = [];
  
  if (typeof input !== 'string') {
    return threats;
  }

  // Check for SQL injection
  for (const pattern of SQL_INJECTION_PATTERNS) {
    if (pattern.test(input)) {
      threats.push({
        type: 'SQL_INJECTION',
        pattern: pattern.toString(),
        field: fieldName,
        value: input.substring(0, 100) // Log first 100 chars only
      });
    }
  }

  // Check for XSS
  for (const pattern of XSS_PATTERNS) {
    if (pattern.test(input)) {
      threats.push({
        type: 'XSS',
        pattern: pattern.toString(),
        field: fieldName,
        value: input.substring(0, 100)
      });
    }
  }

  // Check for path traversal
  for (const pattern of PATH_TRAVERSAL_PATTERNS) {
    if (pattern.test(input)) {
      threats.push({
        type: 'PATH_TRAVERSAL',
        pattern: pattern.toString(),
        field: fieldName,
        value: input.substring(0, 100)
      });
    }
  }

  // Check for command injection
  for (const pattern of COMMAND_INJECTION_PATTERNS) {
    if (pattern.test(input)) {
      threats.push({
        type: 'COMMAND_INJECTION',
        pattern: pattern.toString(),
        field: fieldName,
        value: input.substring(0, 100)
      });
    }
  }

  // Log threats
  if (threats.length > 0) {
    logger.logSecurityEvent("Security threat detected in input", "HIGH", {
      threats,
      ip: req.ip,
      userAgent: req.headers['user-agent'],
      path: req.path,
      method: req.method,
      userId: req.user?.id
    });
  }

  return threats;
};

/**
 * Sanitize input to remove potentially harmful content
 */
const sanitizeInput = (input) => {
  if (typeof input !== 'string') {
    return input;
  }

  let sanitized = input;

  // Remove script tags and their content
  sanitized = sanitized.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '');
  
  // Remove iframe tags and their content
  sanitized = sanitized.replace(/<iframe\b[^<]*(?:(?!<\/iframe>)<[^<]*)*<\/iframe>/gi, '');
  
  // Remove object and embed tags
  sanitized = sanitized.replace(/<(object|embed)\b[^<]*(?:(?!<\/\1>)<[^<]*)*<\/\1>/gi, '');
  
  // Remove javascript: and vbscript: protocols
  sanitized = sanitized.replace(/(javascript|vbscript):/gi, '');
  
  // Remove event handlers
  sanitized = sanitized.replace(/on\w+\s*=/gi, '');
  
  // Remove potentially dangerous HTML attributes
  sanitized = sanitized.replace(/(style|class|id)\s*=\s*["'][^"']*["']/gi, '');
  
  // Encode HTML entities
  sanitized = sanitized
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;')
    .replace(/\//g, '&#x2F;');

  // Remove null bytes
  sanitized = sanitized.replace(/\0/g, '');

  // Trim whitespace
  sanitized = sanitized.trim();

  return sanitized;
};

/**
 * Comprehensive input validation middleware
 */
const validateAndSanitizeInput = (options = {}) => {
  const {
    sanitize = true,
    detectThreats = true,
    blockThreats = true,
    maxLength = 10000,
    allowedFields = null
  } = options;

  return (req, res, next) => {
    try {
      const allThreats = [];

      // Validate and sanitize request body
      if (req.body && typeof req.body === 'object') {
        for (const [key, value] of Object.entries(req.body)) {
          // Check if field is allowed
          if (allowedFields && !allowedFields.includes(key)) {
            delete req.body[key];
            continue;
          }

          if (typeof value === 'string') {
            // Check length
            if (value.length > maxLength) {
              throw new ValidationError(`Field ${key} exceeds maximum length of ${maxLength} characters`);
            }

            // Detect threats
            if (detectThreats) {
              const threats = detectSecurityThreats(value, key, req);
              allThreats.push(...threats);
            }

            // Sanitize input
            if (sanitize) {
              req.body[key] = sanitizeInput(value);
            }
          } else if (Array.isArray(value)) {
            // Handle arrays
            req.body[key] = value.map(item => {
              if (typeof item === 'string') {
                if (item.length > maxLength) {
                  throw new ValidationError(`Array item in ${key} exceeds maximum length`);
                }
                
                if (detectThreats) {
                  const threats = detectSecurityThreats(item, `${key}[]`, req);
                  allThreats.push(...threats);
                }
                
                return sanitize ? sanitizeInput(item) : item;
              }
              return item;
            });
          }
        }
      }

      // Validate and sanitize query parameters
      if (req.query && typeof req.query === 'object') {
        for (const [key, value] of Object.entries(req.query)) {
          if (typeof value === 'string') {
            if (value.length > 1000) { // Shorter limit for query params
              throw new ValidationError(`Query parameter ${key} exceeds maximum length`);
            }

            if (detectThreats) {
              const threats = detectSecurityThreats(value, `query.${key}`, req);
              allThreats.push(...threats);
            }

            if (sanitize) {
              req.query[key] = sanitizeInput(value);
            }
          }
        }
      }

      // Block request if threats detected and blocking is enabled
      if (blockThreats && allThreats.length > 0) {
        const threatTypes = [...new Set(allThreats.map(t => t.type))];
        throw new ValidationError(`Security threat detected: ${threatTypes.join(', ')}`);
      }

      next();
    } catch (error) {
      next(error);
    }
  };
};

/**
 * Validate specific data types with enhanced security
 */
const validateDataTypes = {
  /**
   * Validate email with additional security checks
   */
  email: (fieldName = 'email') => {
    return [
      validator.body(fieldName)
        .isEmail()
        .withMessage('Invalid email format')
        .normalizeEmail()
        .isLength({ max: 254 })
        .withMessage('Email too long')
        .custom((value) => {
          // Check for suspicious patterns in email
          const suspiciousPatterns = [
            /[<>]/,           // HTML tags
            /javascript:/i,   // JavaScript protocol
            /\0/,            // Null bytes
            /@.*@/           // Multiple @ symbols
          ];

          for (const pattern of suspiciousPatterns) {
            if (pattern.test(value)) {
              throw new Error('Invalid email format');
            }
          }
          return true;
        })
    ];
  },

  /**
   * Validate password with security requirements
   */
  password: (fieldName = 'password') => {
    return [
      validator.body(fieldName)
        .isLength({ min: 8, max: 128 })
        .withMessage('Password must be between 8 and 128 characters')
        .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
        .withMessage('Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character')
        .custom((value) => {
          // Check for common weak passwords
          const weakPasswords = [
            'password', 'password123', '123456', 'qwerty', 'admin', 'letmein'
          ];
          
          if (weakPasswords.includes(value.toLowerCase())) {
            throw new Error('Password is too common');
          }
          
          // Check for repeated characters
          if (/(.)\1{3,}/.test(value)) {
            throw new Error('Password cannot contain more than 3 consecutive identical characters');
          }
          
          return true;
        })
    ];
  },

  /**
   * Validate phone number
   */
  phone: (fieldName = 'phone') => {
    return [
      validator.body(fieldName)
        .optional()
        .matches(/^\+?[\d\s\-\(\)]{10,20}$/)
        .withMessage('Invalid phone number format')
        .custom((value) => {
          if (value) {
            // Remove formatting and check length
            const digitsOnly = value.replace(/\D/g, '');
            if (digitsOnly.length < 10 || digitsOnly.length > 15) {
              throw new Error('Phone number must contain 10-15 digits');
            }
          }
          return true;
        })
    ];
  },

  /**
   * Validate URL with security checks
   */
  url: (fieldName = 'url') => {
    return [
      validator.body(fieldName)
        .optional()
        .isURL({
          protocols: ['http', 'https'],
          require_protocol: true,
          require_host: true,
          require_valid_protocol: true,
          allow_underscores: false,
          host_whitelist: false,
          host_blacklist: ['localhost', '127.0.0.1', '0.0.0.0']
        })
        .withMessage('Invalid URL format')
        .isLength({ max: 2048 })
        .withMessage('URL too long')
    ];
  },

  /**
   * Validate text with length and content restrictions
   */
  text: (fieldName, options = {}) => {
    const { min = 1, max = 1000, allowHTML = false } = options;
    
    return [
      validator.body(fieldName)
        .isLength({ min, max })
        .withMessage(`${fieldName} must be between ${min} and ${max} characters`)
        .custom((value) => {
          if (!allowHTML) {
            // Check for HTML tags
            if (/<[^>]*>/.test(value)) {
              throw new Error(`${fieldName} cannot contain HTML tags`);
            }
          }
          
          // Check for null bytes
          if (value.includes('\0')) {
            throw new Error(`${fieldName} contains invalid characters`);
          }
          
          return true;
        })
    ];
  }
};

/**
 * Handle validation errors
 */
const handleValidationErrors = (req, res, next) => {
  const errors = validator.validationResult(req);
  
  if (!errors.isEmpty()) {
    const errorMessages = errors.array().map(error => ({
      field: error.param,
      message: error.msg,
      value: error.value
    }));

    logger.warn("Validation errors", {
      errors: errorMessages,
      ip: req.ip,
      path: req.path,
      method: req.method
    });

    throw new ValidationError("Validation failed", errorMessages);
  }
  
  next();
};

module.exports = {
  validateAndSanitizeInput,
  validateDataTypes,
  handleValidationErrors,
  detectSecurityThreats,
  sanitizeInput
};