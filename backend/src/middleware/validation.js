const { ValidationError } = require("../utils/errorHandler");

/**
 * Request validation middleware
 * Provides common validation functions for API endpoints
 */

/**
 * Validate required fields in request body
 * @param {Array} requiredFields - Array of required field names
 * @returns {Function} Express middleware function
 */
const validateRequiredFields = (requiredFields) => {
  return (req, res, next) => {
    const missingFields = [];
    const emptyFields = [];

    for (const field of requiredFields) {
      if (!(field in req.body)) {
        missingFields.push(field);
      } else if (req.body[field] === null || req.body[field] === undefined || req.body[field] === '') {
        emptyFields.push(field);
      }
    }

    if (missingFields.length > 0 || emptyFields.length > 0) {
      const errors = [];
      
      if (missingFields.length > 0) {
        errors.push(`Missing required fields: ${missingFields.join(', ')}`);
      }
      
      if (emptyFields.length > 0) {
        errors.push(`Empty required fields: ${emptyFields.join(', ')}`);
      }

      throw new ValidationError("Validation failed", errors);
    }

    next();
  };
};

/**
 * Validate email format
 * @param {string} fieldName - Name of the email field (default: 'email')
 * @returns {Function} Express middleware function
 */
const validateEmail = (fieldName = 'email') => {
  return (req, res, next) => {
    const email = req.body[fieldName];
    
    if (email) {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(email)) {
        throw new ValidationError(`Invalid ${fieldName} format`);
      }
    }

    next();
  };
};

/**
 * Validate password strength
 * @param {string} fieldName - Name of the password field (default: 'password')
 * @returns {Function} Express middleware function
 */
const validatePassword = (fieldName = 'password') => {
  return (req, res, next) => {
    const password = req.body[fieldName];
    
    if (password) {
      const errors = [];
      
      if (password.length < 8) {
        errors.push("Password must be at least 8 characters long");
      }
      
      if (!/(?=.*[a-z])/.test(password)) {
        errors.push("Password must contain at least one lowercase letter");
      }
      
      if (!/(?=.*[A-Z])/.test(password)) {
        errors.push("Password must contain at least one uppercase letter");
      }
      
      if (!/(?=.*\d)/.test(password)) {
        errors.push("Password must contain at least one number");
      }

      if (errors.length > 0) {
        throw new ValidationError("Password validation failed", errors);
      }
    }

    next();
  };
};

/**
 * Validate phone number format
 * @param {string} fieldName - Name of the phone field (default: 'phone')
 * @returns {Function} Express middleware function
 */
const validatePhone = (fieldName = 'phone') => {
  return (req, res, next) => {
    const phone = req.body[fieldName];
    
    if (phone) {
      // Basic phone validation - adjust regex as needed for your requirements
      const phoneRegex = /^\+?[\d\s\-\(\)]{10,}$/;
      if (!phoneRegex.test(phone)) {
        throw new ValidationError(`Invalid ${fieldName} format`);
      }
    }

    next();
  };
};

/**
 * Validate numeric fields
 * @param {Array} numericFields - Array of field names that should be numeric
 * @returns {Function} Express middleware function
 */
const validateNumeric = (numericFields) => {
  return (req, res, next) => {
    const errors = [];

    for (const field of numericFields) {
      const value = req.body[field];
      if (value !== undefined && value !== null && value !== '') {
        const numValue = Number(value);
        if (isNaN(numValue)) {
          errors.push(`${field} must be a valid number`);
        } else {
          // Convert to number for further processing
          req.body[field] = numValue;
        }
      }
    }

    if (errors.length > 0) {
      throw new ValidationError("Numeric validation failed", errors);
    }

    next();
  };
};

/**
 * Validate enum values
 * @param {Object} enumFields - Object with field names as keys and allowed values as arrays
 * @returns {Function} Express middleware function
 */
const validateEnum = (enumFields) => {
  return (req, res, next) => {
    const errors = [];

    for (const [field, allowedValues] of Object.entries(enumFields)) {
      const value = req.body[field];
      if (value !== undefined && value !== null && value !== '') {
        if (!allowedValues.includes(value)) {
          errors.push(`${field} must be one of: ${allowedValues.join(', ')}`);
        }
      }
    }

    if (errors.length > 0) {
      throw new ValidationError("Enum validation failed", errors);
    }

    next();
  };
};

/**
 * Validate string length
 * @param {Object} lengthRules - Object with field names as keys and {min, max} as values
 * @returns {Function} Express middleware function
 */
const validateStringLength = (lengthRules) => {
  return (req, res, next) => {
    const errors = [];

    for (const [field, rules] of Object.entries(lengthRules)) {
      const value = req.body[field];
      if (value !== undefined && value !== null && typeof value === 'string') {
        if (rules.min && value.length < rules.min) {
          errors.push(`${field} must be at least ${rules.min} characters long`);
        }
        if (rules.max && value.length > rules.max) {
          errors.push(`${field} must be no more than ${rules.max} characters long`);
        }
      }
    }

    if (errors.length > 0) {
      throw new ValidationError("String length validation failed", errors);
    }

    next();
  };
};

/**
 * Validate pagination parameters
 * @returns {Function} Express middleware function
 */
const validatePagination = () => {
  return (req, res, next) => {
    const { page, limit } = req.query;
    
    if (page !== undefined) {
      const pageNum = parseInt(page, 10);
      if (isNaN(pageNum) || pageNum < 1) {
        throw new ValidationError("Page must be a positive integer");
      }
      req.query.page = pageNum;
    } else {
      req.query.page = 1;
    }

    if (limit !== undefined) {
      const limitNum = parseInt(limit, 10);
      if (isNaN(limitNum) || limitNum < 1 || limitNum > 100) {
        throw new ValidationError("Limit must be a positive integer between 1 and 100");
      }
      req.query.limit = limitNum;
    } else {
      req.query.limit = 10;
    }

    next();
  };
};

/**
 * Sanitize input by trimming whitespace and removing potentially harmful characters
 * @param {Array} fieldsToSanitize - Array of field names to sanitize
 * @returns {Function} Express middleware function
 */
const sanitizeInput = (fieldsToSanitize = []) => {
  return (req, res, next) => {
    // If no specific fields provided, sanitize all string fields
    const fields = fieldsToSanitize.length > 0 ? fieldsToSanitize : Object.keys(req.body);
    
    for (const field of fields) {
      const value = req.body[field];
      if (typeof value === 'string') {
        // Trim whitespace
        req.body[field] = value.trim();
        
        // Remove potentially harmful characters (basic XSS prevention)
        req.body[field] = req.body[field]
          .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
          .replace(/<[^>]*>/g, '');
      }
    }

    next();
  };
};

/**
 * Validate file upload
 * @param {Object} options - Upload validation options
 * @returns {Function} Express middleware function
 */
const validateFileUpload = (options = {}) => {
  const {
    required = false,
    maxSize = 10 * 1024 * 1024, // 10MB default
    allowedTypes = ['image/jpeg', 'image/png', 'image/gif'],
    fieldName = 'file'
  } = options;

  return (req, res, next) => {
    const file = req.file || req.files?.[fieldName];

    if (required && !file) {
      throw new ValidationError(`${fieldName} is required`);
    }

    if (file) {
      // Check file size
      if (file.size > maxSize) {
        throw new ValidationError(`File size must be less than ${Math.round(maxSize / 1024 / 1024)}MB`);
      }

      // Check file type
      if (!allowedTypes.includes(file.mimetype)) {
        throw new ValidationError(`File type must be one of: ${allowedTypes.join(', ')}`);
      }
    }

    next();
  };
};

module.exports = {
  validateRequiredFields,
  validateEmail,
  validatePassword,
  validatePhone,
  validateNumeric,
  validateEnum,
  validateStringLength,
  validatePagination,
  sanitizeInput,
  validateFileUpload
};