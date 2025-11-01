const sanitizeHtml = require('sanitize-html');
const validator = require('validator');
const { ValidationError } = require('../utils/errorHandler');

/**
 * Input Sanitization Middleware
 * Protects against XSS, SQL Injection, and other injection attacks
 */

/**
 * Sanitize HTML content
 */
const sanitizeHtmlContent = (html) => {
  return sanitizeHtml(html, {
    allowedTags: [], // No HTML tags allowed
    allowedAttributes: {},
    disallowedTagsMode: 'escape'
  });
};

/**
 * Sanitize search input to prevent SQL injection
 */
const sanitizeSearchInput = (input) => {
  if (typeof input !== 'string') return input;
  
  // Remove SQL injection patterns
  return input
    .replace(/[%_\\]/g, '\\$&') // Escape SQL wildcards
    .replace(/['";]/g, '') // Remove quotes and semicolons
    .substring(0, 100); // Limit length
};

/**
 * Sanitize all string inputs in request body
 */
const sanitizeBody = (req, res, next) => {
  if (!req.body || typeof req.body !== 'object') {
    return next();
  }

  try {
    const sanitized = {};
    
    for (const [key, value] of Object.entries(req.body)) {
      if (typeof value === 'string') {
        // Trim whitespace
        let sanitizedValue = value.trim();
        
        // Remove HTML tags
        sanitizedValue = sanitizeHtmlContent(sanitizedValue);
        
        // Escape special characters
        sanitizedValue = validator.escape(sanitizedValue);
        
        sanitized[key] = sanitizedValue;
      } else if (Array.isArray(value)) {
        // Sanitize array elements
        sanitized[key] = value.map(item => 
          typeof item === 'string' ? sanitizeHtmlContent(item.trim()) : item
        );
      } else {
        sanitized[key] = value;
      }
    }
    
    req.body = sanitized;
    next();
  } catch (error) {
    next(new ValidationError('Invalid input data'));
  }
};

/**
 * Sanitize query parameters
 */
const sanitizeQuery = (req, res, next) => {
  if (!req.query || typeof req.query !== 'object') {
    return next();
  }

  try {
    const sanitized = {};
    
    for (const [key, value] of Object.entries(req.query)) {
      if (typeof value === 'string') {
        // For search queries, use special sanitization
        if (key.includes('search') || key.includes('query')) {
          sanitized[key] = sanitizeSearchInput(value);
        } else {
          sanitized[key] = sanitizeHtmlContent(value.trim());
        }
      } else {
        sanitized[key] = value;
      }
    }
    
    req.query = sanitized;
    next();
  } catch (error) {
    next(new ValidationError('Invalid query parameters'));
  }
};

/**
 * Validate and sanitize email
 */
const sanitizeEmail = (email) => {
  if (!email || typeof email !== 'string') return email;
  
  const trimmed = email.trim().toLowerCase();
  
  if (!validator.isEmail(trimmed)) {
    throw new ValidationError('Invalid email format');
  }
  
  return validator.normalizeEmail(trimmed);
};

/**
 * Validate and sanitize URL
 */
const sanitizeUrl = (url) => {
  if (!url || typeof url !== 'string') return url;
  
  const trimmed = url.trim();
  
  if (!validator.isURL(trimmed, { require_protocol: true })) {
    throw new ValidationError('Invalid URL format');
  }
  
  return trimmed;
};

/**
 * Remove sensitive data from logs
 */
const sanitizeForLogging = (data) => {
  if (!data || typeof data !== 'object') return data;
  
  const sensitive = [
    'password',
    'token',
    'secret',
    'apiKey',
    'api_key',
    'accessToken',
    'refreshToken',
    'jwt',
    'authorization',
    'cookie',
    'ssn',
    'creditCard',
    'cvv'
  ];
  
  const sanitized = Array.isArray(data) ? [...data] : { ...data };
  
  const sanitizeObject = (obj) => {
    for (const key in obj) {
      if (sensitive.some(s => key.toLowerCase().includes(s))) {
        obj[key] = '[REDACTED]';
      } else if (typeof obj[key] === 'object' && obj[key] !== null) {
        sanitizeObject(obj[key]);
      }
    }
  };
  
  sanitizeObject(sanitized);
  return sanitized;
};

/**
 * Comprehensive input sanitization middleware
 */
const sanitizeInput = (req, res, next) => {
  // Sanitize body
  if (req.body) {
    sanitizeBody(req, res, () => {});
  }
  
  // Sanitize query
  if (req.query) {
    sanitizeQuery(req, res, () => {});
  }
  
  // Sanitize params
  if (req.params) {
    for (const key in req.params) {
      if (typeof req.params[key] === 'string') {
        req.params[key] = sanitizeHtmlContent(req.params[key].trim());
      }
    }
  }
  
  next();
};

module.exports = {
  sanitizeHtmlContent,
  sanitizeSearchInput,
  sanitizeBody,
  sanitizeQuery,
  sanitizeEmail,
  sanitizeUrl,
  sanitizeForLogging,
  sanitizeInput
};
