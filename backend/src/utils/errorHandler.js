const { HTTP_STATUS, ERROR_MESSAGES } = require("../constants");
const logger = require("./logger");

/**
 * Custom error classes for better error handling
 */
class AppError extends Error {
  constructor(
    message,
    statusCode = HTTP_STATUS.INTERNAL_SERVER_ERROR,
    isOperational = true
  ) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = isOperational;
    this.timestamp = new Date().toISOString();

    Error.captureStackTrace(this, this.constructor);
  }
}

class ValidationError extends AppError {
  constructor(message, errors = []) {
    super(message, HTTP_STATUS.BAD_REQUEST);
    this.errors = errors;
  }
}

class AuthenticationError extends AppError {
  constructor(message = ERROR_MESSAGES.INVALID_CREDENTIALS) {
    super(message, HTTP_STATUS.UNAUTHORIZED);
  }
}

class AuthorizationError extends AppError {
  constructor(message = ERROR_MESSAGES.ACCESS_DENIED) {
    super(message, HTTP_STATUS.FORBIDDEN);
  }
}

class NotFoundError extends AppError {
  constructor(message = ERROR_MESSAGES.USER_NOT_FOUND) {
    super(message, HTTP_STATUS.NOT_FOUND);
  }
}

class ConflictError extends AppError {
  constructor(message) {
    super(message, HTTP_STATUS.BAD_REQUEST);
  }
}

/**
 * Centralized error handling middleware
 */
const errorHandler = (err, req, res, next) => {
  let error = { ...err };
  error.message = err.message;

  // Generate unique error ID for tracking
  const errorId = `ERR_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

  // Log error with structured logging
  logger.error("Request error occurred", {
    req,
    error: err,
    errorId,
    statusCode: err.statusCode || 500,
    userAgent: req.get('User-Agent'),
    ip: req.ip || req.connection.remoteAddress
  });

  // Mongoose bad ObjectId
  if (err.name === "CastError") {
    const message = "Resource not found";
    error = new NotFoundError(message);
  }

  // Mongoose duplicate key
  if (err.code === 11000) {
    const message = "Duplicate field value entered";
    error = new ConflictError(message);
  }

  // Mongoose validation error
  if (err.name === "ValidationError") {
    const message = Object.values(err.errors)
      .map((val) => val.message)
      .join(", ");
    error = new ValidationError(message);
  }

  // Sequelize validation error
  if (err.name === "SequelizeValidationError") {
    const message = err.errors.map((e) => e.message).join(", ");
    error = new ValidationError(message);
  }

  // Sequelize unique constraint error
  if (err.name === "SequelizeUniqueConstraintError") {
    const message = "Duplicate field value entered";
    error = new ConflictError(message);
  }

  // Sequelize foreign key constraint error
  if (err.name === "SequelizeForeignKeyConstraintError") {
    const message = "Referenced resource not found";
    error = new NotFoundError(message);
  }

  // JWT errors
  if (err.name === "JsonWebTokenError") {
    const message = "Invalid token";
    error = new AuthenticationError(message);
  }

  if (err.name === "TokenExpiredError") {
    const message = "Token expired";
    error = new AuthenticationError(message);
  }

  // Prepare error response
  const errorResponse = {
    success: false,
    message: error.message || ERROR_MESSAGES.SERVER_ERROR,
    errorId,
    timestamp: error.timestamp || new Date().toISOString(),
    ...(error.errors && { errors: error.errors })
  };

  // Add stack trace in development
  if (process.env.NODE_ENV === "development") {
    errorResponse.stack = err.stack;
    errorResponse.details = {
      originalError: err.name,
      statusCode: error.statusCode || HTTP_STATUS.INTERNAL_SERVER_ERROR
    };
  }

  // Add helpful hints for common errors
  if (error.statusCode === HTTP_STATUS.UNAUTHORIZED) {
    errorResponse.hint = "Please check your authentication credentials";
  } else if (error.statusCode === HTTP_STATUS.FORBIDDEN) {
    errorResponse.hint = "You don't have permission to access this resource";
  } else if (error.statusCode === HTTP_STATUS.NOT_FOUND) {
    errorResponse.hint = "The requested resource was not found";
  } else if (error.statusCode === HTTP_STATUS.BAD_REQUEST) {
    errorResponse.hint = "Please check your request data and try again";
  }

  res.status(error.statusCode || HTTP_STATUS.INTERNAL_SERVER_ERROR).json(errorResponse);
};

/**
 * Handle 404 errors
 */
const notFound = (req, res, next) => {
  // Log 404 attempts for security monitoring
  logger.warn("404 Not Found", {
    req,
    route: req.originalUrl,
    method: req.method,
    userAgent: req.get('User-Agent'),
    ip: req.ip || req.connection.remoteAddress
  });

  const error = new NotFoundError(`Route ${req.originalUrl} not found`);
  next(error);
};

/**
 * Async error wrapper
 */
const asyncHandler = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

/**
 * Error response helper
 */
const sendErrorResponse = (
  res,
  message,
  statusCode = HTTP_STATUS.INTERNAL_SERVER_ERROR,
  errors = null,
  meta = {}
) => {
  const errorId = `ERR_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  
  // Log the error
  logger.error("Manual error response", {
    message,
    statusCode,
    errors,
    errorId,
    ...meta
  });

  const errorResponse = {
    success: false,
    message,
    errorId,
    timestamp: new Date().toISOString(),
    ...(errors && { errors })
  };

  res.status(statusCode).json(errorResponse);
};

/**
 * Success response helper
 */
const sendSuccessResponse = (
  res,
  message,
  data = null,
  statusCode = HTTP_STATUS.OK,
  meta = {}
) => {
  // Log successful operations for audit trail
  if (statusCode === HTTP_STATUS.CREATED || meta.logSuccess) {
    logger.info("Successful operation", {
      message,
      statusCode,
      dataType: data ? typeof data : null,
      ...meta
    });
  }

  const response = {
    success: true,
    message,
    timestamp: new Date().toISOString(),
    ...(data && { data })
  };

  res.status(statusCode).json(response);
};

module.exports = {
  AppError,
  ValidationError,
  AuthenticationError,
  AuthorizationError,
  NotFoundError,
  ConflictError,
  errorHandler,
  notFound,
  asyncHandler,
  sendErrorResponse,
  sendSuccessResponse,
};
