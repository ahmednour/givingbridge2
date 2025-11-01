const jwt = require("jsonwebtoken");
const { asyncHandler, sendErrorResponse } = require("../utils/errorHandler");
const { ERROR_MESSAGES, HTTP_STATUS } = require("../constants");
const AuthController = require("../controllers/authController");
const logger = require("../utils/logger");

// Middleware to verify JWT token
const authenticateToken = asyncHandler(async (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1]; // Bearer TOKEN

  if (!token) {
    logger.logSecurityEvent("missing_auth_token", "MEDIUM", { req });
    return sendErrorResponse(res, ERROR_MESSAGES.TOKEN_REQUIRED, HTTP_STATUS.UNAUTHORIZED);
  }

  try {
    const decoded = await AuthController.verifyToken(token);
    // Map userId from token to id for consistency
    req.user = {
      id: decoded.userId,
      userId: decoded.userId,
      email: decoded.email,
      role: decoded.role,
    };
    next();
  } catch (error) {
    logger.logSecurityEvent("invalid_auth_token", "MEDIUM", { 
      req, 
      error: error.message,
      token: token.substring(0, 10) + "..." 
    });
    
    return sendErrorResponse(res, ERROR_MESSAGES.INVALID_TOKEN, HTTP_STATUS.FORBIDDEN);
  }
});

module.exports = {
  authenticateToken
};