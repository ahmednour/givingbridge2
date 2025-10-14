const express = require("express");
const { body, validationResult } = require("express-validator");
const router = express.Router();
const AuthController = require("../controllers/authController");
const {
  USER_ROLES,
  VALIDATION_LIMITS,
  ERROR_MESSAGES,
  SUCCESS_MESSAGES,
  HTTP_STATUS,
} = require("../constants");

require("dotenv").config();

// Register route
router.post(
  "/register",
  [
    body("name")
      .trim()
      .isLength({ min: VALIDATION_LIMITS.NAME_MIN_LENGTH })
      .withMessage(
        `Name must be at least ${VALIDATION_LIMITS.NAME_MIN_LENGTH} characters`
      ),
    body("email")
      .isEmail()
      .normalizeEmail()
      .withMessage("Please provide a valid email"),
    body("password")
      .isLength({ min: VALIDATION_LIMITS.PASSWORD_MIN_LENGTH })
      .withMessage(
        `Password must be at least ${VALIDATION_LIMITS.PASSWORD_MIN_LENGTH} characters`
      ),
    body("role").isIn(Object.values(USER_ROLES)).withMessage("Invalid role"),
  ],
  async (req, res) => {
    try {
      // Check for validation errors
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(HTTP_STATUS.BAD_REQUEST).json({
          message: ERROR_MESSAGES.VALIDATION_FAILED,
          errors: errors.array(),
        });
      }

      const result = await AuthController.register(req.body);

      res.status(HTTP_STATUS.CREATED).json({
        message: SUCCESS_MESSAGES.USER_REGISTERED,
        user: result.user,
        token: result.token,
      });
    } catch (error) {
      console.error("Registration error:", error);
      res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
        message: "Registration failed",
        error: error.message,
      });
    }
  }
);

// Login route
router.post(
  "/login",
  [
    body("email")
      .isEmail()
      .normalizeEmail()
      .withMessage("Please provide a valid email"),
    body("password").notEmpty().withMessage("Password is required"),
  ],
  async (req, res) => {
    try {
      // Check for validation errors
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(HTTP_STATUS.BAD_REQUEST).json({
          message: ERROR_MESSAGES.VALIDATION_FAILED,
          errors: errors.array(),
        });
      }

      const { email, password } = req.body;
      const result = await AuthController.login(email, password);

      res.json({
        message: SUCCESS_MESSAGES.LOGIN_SUCCESS,
        user: result.user,
        token: result.token,
      });
    } catch (error) {
      console.error("Login error:", error);
      res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
        message: "Login failed",
        error: error.message,
      });
    }
  }
);

// Logout route (client-side token removal)
router.post("/logout", (req, res) => {
  res.json({
    message: SUCCESS_MESSAGES.LOGOUT_SUCCESS,
  });
});

// Middleware to verify JWT token
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1]; // Bearer TOKEN

  if (!token) {
    return res.status(HTTP_STATUS.UNAUTHORIZED).json({
      message: ERROR_MESSAGES.TOKEN_REQUIRED,
    });
  }

  AuthController.verifyToken(token)
    .then((user) => {
      req.user = user;
      next();
    })
    .catch((error) => {
      return res.status(HTTP_STATUS.FORBIDDEN).json({
        message: ERROR_MESSAGES.INVALID_TOKEN,
      });
    });
};

// Get current user profile
router.get("/me", authenticateToken, async (req, res) => {
  try {
    const user = await AuthController.getProfile(req.user.userId);

    res.json({
      user: user,
    });
  } catch (error) {
    console.error("Get user profile error:", error);
    res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      message: "Failed to get user profile",
      error: error.message,
    });
  }
});

// Export the router and middleware
module.exports = router;
module.exports.authenticateToken = authenticateToken;
