const User = require("../models/User");

/**
 * Middleware to load user from database and attach to request
 * This eliminates the repeated user loading logic across routes
 */
const loadUser = async (req, res, next) => {
  try {
    const user = await User.findByPk(req.user.userId);

    if (!user) {
      return res.status(404).json({
        message: "User not found",
      });
    }

    // Attach user to request for use in route handlers
    req.loadedUser = user;
    next();
  } catch (error) {
    console.error("Load user middleware error:", error);
    res.status(500).json({
      message: "Failed to load user",
      error: error.message,
    });
  }
};

/**
 * Middleware to check if user has admin role
 * Must be used after authenticateToken middleware
 */
const requireAdmin = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({
      message: "Authentication required",
    });
  }

  if (req.user.role !== "admin") {
    return res.status(403).json({
      message: "Admin access required",
    });
  }

  next();
};

/**
 * Middleware to check if user has specific role
 * @param {string|Array<string>} roles - Required role(s)
 */
const requireRole = (roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        message: "Authentication required",
      });
    }

    const userRole = req.user.role;
    const allowedRoles = Array.isArray(roles) ? roles : [roles];

    if (!allowedRoles.includes(userRole)) {
      return res.status(403).json({
        message: `Access denied. Required role: ${allowedRoles.join(" or ")}`,
      });
    }

    next();
  };
};

/**
 * Middleware to check ownership of a resource
 * @param {Function} getResourceOwnerId - Function to get owner ID from request
 */
const requireOwnership = (getResourceOwnerId) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        message: "Authentication required",
      });
    }

    // Admin can access any resource
    if (req.user.role === "admin") {
      return next();
    }

    const resourceOwnerId = getResourceOwnerId(req);

    if (resourceOwnerId !== req.user.userId) {
      return res.status(403).json({
        message: "Access denied. You can only access your own resources.",
      });
    }

    next();
  };
};

/**
 * Middleware to validate request body against schema
 * @param {Object} schema - Validation schema
 */
const validateSchema = (schema) => {
  return (req, res, next) => {
    const { error } = schema.validate(req.body);

    if (error) {
      return res.status(400).json({
        message: "Validation failed",
        errors: error.details.map((detail) => ({
          field: detail.path.join("."),
          message: detail.message,
        })),
      });
    }

    next();
  };
};

/**
 * Middleware to handle async errors
 * Wraps async route handlers to catch errors automatically
 */
const asyncHandler = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

/**
 * Middleware to add pagination to requests
 * Adds limit, offset, and pagination info to request
 */
const paginate = (defaultLimit = 20, maxLimit = 100) => {
  return (req, res, next) => {
    const page = parseInt(req.query.page) || 1;
    const limit = Math.min(parseInt(req.query.limit) || defaultLimit, maxLimit);
    const offset = (page - 1) * limit;

    req.pagination = {
      page,
      limit,
      offset,
    };

    next();
  };
};

/**
 * Middleware to add sorting to requests
 * Adds sort order to request
 */
const sort = (defaultSort = "createdAt", allowedFields = []) => {
  return (req, res, next) => {
    const sortBy = req.query.sortBy || defaultSort;
    const sortOrder = req.query.sortOrder === "desc" ? "DESC" : "ASC";

    // Validate sort field if allowedFields is provided
    if (allowedFields.length > 0 && !allowedFields.includes(sortBy)) {
      return res.status(400).json({
        message: `Invalid sort field. Allowed fields: ${allowedFields.join(
          ", "
        )}`,
      });
    }

    req.sorting = {
      field: sortBy,
      order: sortOrder,
    };

    next();
  };
};

module.exports = {
  loadUser,
  requireAdmin,
  requireRole,
  requireOwnership,
  validateSchema,
  asyncHandler,
  paginate,
  sort,
};
