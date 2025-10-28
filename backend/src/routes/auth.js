const express = require("express");
const { body, validationResult } = require("express-validator");
const router = express.Router();
const AuthController = require("../controllers/authController");
const { authRateLimit, passwordResetRateLimit, emailVerificationLimiter } = require("../middleware/rateLimiting");
const {
  validateRequiredFields,
  validateEmail,
  validatePassword,
  validateEnum,
  sanitizeInput
} = require("../middleware/validation");
const {
  asyncHandler,
  sendSuccessResponse,
  sendErrorResponse
} = require("../utils/errorHandler");
const logger = require("../utils/logger");
const {
  USER_ROLES,
  ERROR_MESSAGES,
  SUCCESS_MESSAGES,
  HTTP_STATUS,
  VALIDATION_LIMITS,
} = require("../constants");

require("dotenv").config();

/**
 * @swagger
 * components:
 *   schemas:
 *     LoginRequest:
 *       type: object
 *       required:
 *         - email
 *         - password
 *       properties:
 *         email:
 *           type: string
 *           format: email
 *           description: User email address
 *           example: john.doe@example.com
 *         password:
 *           type: string
 *           format: password
 *           description: User password
 *           example: mySecurePassword123
 *     RegisterRequest:
 *       type: object
 *       required:
 *         - name
 *         - email
 *         - password
 *       properties:
 *         name:
 *           type: string
 *           description: Full name of the user
 *           example: John Doe
 *         email:
 *           type: string
 *           format: email
 *           description: User email address
 *           example: john.doe@example.com
 *         password:
 *           type: string
 *           format: password
 *           minLength: 6
 *           description: User password (minimum 6 characters)
 *           example: mySecurePassword123
 *         role:
 *           type: string
 *           enum: [donor, receiver, admin]
 *           description: User role in the platform
 *           example: donor
 *         phone:
 *           type: string
 *           description: User phone number
 *           example: "+1234567890"
 *         location:
 *           type: string
 *           description: User location
 *           example: "New York, NY"
 *     AuthResponse:
 *       type: object
 *       properties:
 *         message:
 *           type: string
 *           example: Login successful
 *         user:
 *           $ref: '#/components/schemas/User'
 *         token:
 *           type: string
 *           description: JWT authentication token
 *           example: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
 *     FCMTokenRequest:
 *       type: object
 *       required:
 *         - fcmToken
 *       properties:
 *         fcmToken:
 *           type: string
 *           description: Firebase Cloud Messaging token
 *           example: dGhpc0lzQUZha2VGQ01Ub2tlbg==
 */

/**
 * @swagger
 * /api/auth/register:
 *   post:
 *     summary: Register a new user
 *     description: Create a new user account with email verification
 *     tags: [Authentication]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/RegisterRequest'
 *     responses:
 *       201:
 *         description: User registered successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/AuthResponse'
 *       400:
 *         $ref: '#/components/responses/ValidationError'
 *       409:
 *         description: User already exists
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       429:
 *         $ref: '#/components/responses/RateLimitError'
 *       500:
 *         $ref: '#/components/responses/ServerError'
 */
router.post(
  "/register",
  authRateLimit,
  sanitizeInput(['name', 'email', 'phone', 'location']),
  validateRequiredFields(['name', 'email', 'password']),
  validateEmail('email'),
  validatePassword('password'),
  validateEnum({ role: Object.values(USER_ROLES) }),
  asyncHandler(async (req, res) => {
    logger.logAuthEvent("registration_attempt", null, { 
      email: req.body.email,
      role: req.body.role 
    });

    const result = await AuthController.register(req.body);

    logger.logAuthEvent("registration_success", result.user.id, { 
      email: result.user.email,
      role: result.user.role 
    });

    sendSuccessResponse(
      res,
      result.message || SUCCESS_MESSAGES.USER_REGISTERED,
      { user: result.user, token: result.token },
      HTTP_STATUS.CREATED,
      { logSuccess: true }
    );
  })
);

/**
 * @swagger
 * /api/auth/login:
 *   post:
 *     summary: User login
 *     description: Authenticate user with email and password
 *     tags: [Authentication]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/LoginRequest'
 *     responses:
 *       200:
 *         description: Login successful
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/AuthResponse'
 *       400:
 *         $ref: '#/components/responses/ValidationError'
 *       401:
 *         description: Invalid credentials
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       429:
 *         $ref: '#/components/responses/RateLimitError'
 *       500:
 *         $ref: '#/components/responses/ServerError'
 */
router.post(
  "/login",
  authRateLimit,
  sanitizeInput(['email']),
  validateRequiredFields(['email', 'password']),
  validateEmail('email'),
  asyncHandler(async (req, res) => {
    const { email, password } = req.body;
    
    logger.logAuthEvent("login_attempt", null, { email });

    const result = await AuthController.login(email, password);

    logger.logAuthEvent("login_success", result.user.id, { 
      email: result.user.email,
      role: result.user.role 
    });

    sendSuccessResponse(
      res,
      SUCCESS_MESSAGES.LOGIN_SUCCESS,
      { user: result.user, token: result.token }
    );
  })
);

// Logout route (client-side token removal)
router.post("/logout", (req, res) => {
  logger.logAuthEvent("logout", req.user?.userId || null);
  
  sendSuccessResponse(res, SUCCESS_MESSAGES.LOGOUT_SUCCESS);
});

// Middleware to verify JWT token
const authenticateToken = asyncHandler(async (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1]; // Bearer TOKEN

  if (!token) {
    logger.logSecurityEvent("missing_auth_token", "MEDIUM", { req });
    return sendErrorResponse(res, ERROR_MESSAGES.TOKEN_REQUIRED, HTTP_STATUS.UNAUTHORIZED);
  }

  try {
    const user = await AuthController.verifyToken(token);
    req.user = user;
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

/**
 * @swagger
 * /api/auth/me:
 *   get:
 *     summary: Get current user profile
 *     description: Retrieve the authenticated user's profile information
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Profile retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Profile retrieved successfully
 *                 user:
 *                   $ref: '#/components/schemas/User'
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *       500:
 *         $ref: '#/components/responses/ServerError'
 */
router.get("/me", authenticateToken, asyncHandler(async (req, res) => {
  const user = await AuthController.getProfile(req.user.userId);
  
  sendSuccessResponse(res, "Profile retrieved successfully", { user });
}));

// Update FCM token for push notifications
router.post(
  "/fcm-token",
  authenticateToken,
  [
    body("fcmToken")
      .notEmpty()
      .withMessage("FCM token is required")
      .isString()
      .withMessage("FCM token must be a string"),
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

      const { fcmToken } = req.body;
      const result = await AuthController.updateFCMToken(
        req.user.userId,
        fcmToken
      );

      res.json({
        message: "FCM token updated successfully",
        ...result,
      });
    } catch (error) {
      console.error("Update FCM token error:", error);
      res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
        message: "Failed to update FCM token",
        error: error.message,
      });
    }
  }
);

// Verify email with rate limiting
router.post(
  "/verify-email",
  emailVerificationLimiter, // Apply email verification rate limiting
  [
    body("email")
      .isEmail()
      .normalizeEmail()
      .withMessage("Please provide a valid email"),
    body("token").notEmpty().withMessage("Verification token is required"),
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

      const { email, token } = req.body;
      const result = await AuthController.verifyEmail(email, token);

      res.json({
        message: "Email verified successfully",
        ...result,
      });
    } catch (error) {
      console.error("Email verification error:", error);

      if (error.name === "NotFoundError") {
        return res.status(HTTP_STATUS.NOT_FOUND).json({
          message: error.message,
        });
      }

      if (error.name === "ConflictError") {
        return res.status(HTTP_STATUS.CONFLICT).json({
          message: error.message,
        });
      }

      res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
        message: "Email verification failed",
        error: error.message,
      });
    }
  }
);

// Resend verification email with rate limiting
router.post(
  "/resend-verification",
  emailVerificationLimiter, // Apply email verification rate limiting
  [
    body("email")
      .isEmail()
      .normalizeEmail()
      .withMessage("Please provide a valid email"),
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

      const { email } = req.body;
      const result = await AuthController.resendVerificationEmail(email);

      res.json({
        message: "Verification email sent successfully",
        ...result,
      });
    } catch (error) {
      console.error("Resend verification email error:", error);

      if (error.name === "NotFoundError") {
        return res.status(HTTP_STATUS.NOT_FOUND).json({
          message: error.message,
        });
      }

      if (error.name === "ConflictError") {
        return res.status(HTTP_STATUS.CONFLICT).json({
          message: error.message,
        });
      }

      res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
        message: "Failed to resend verification email",
        error: error.message,
      });
    }
  }
);

// Request password reset with rate limiting
router.post(
  "/forgot-password",
  passwordResetLimiter, // Apply password reset rate limiting
  [
    body("email")
      .isEmail()
      .normalizeEmail()
      .withMessage("Please provide a valid email"),
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

      const { email } = req.body;
      const result = await AuthController.requestPasswordReset(email);

      res.json({
        message: "Password reset email sent successfully",
        ...result,
      });
    } catch (error) {
      console.error("Password reset request error:", error);

      if (error.name === "NotFoundError") {
        return res.status(HTTP_STATUS.NOT_FOUND).json({
          message: error.message,
        });
      }

      res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
        message: "Failed to process password reset request",
        error: error.message,
      });
    }
  }
);

// Reset password with rate limiting
router.post(
  "/reset-password",
  passwordResetLimiter, // Apply password reset rate limiting
  [
    body("email")
      .isEmail()
      .normalizeEmail()
      .withMessage("Please provide a valid email"),
    body("token").notEmpty().withMessage("Reset token is required"),
    body("newPassword")
      .isLength({ min: VALIDATION_LIMITS.PASSWORD_MIN_LENGTH })
      .withMessage(
        `Password must be at least ${VALIDATION_LIMITS.PASSWORD_MIN_LENGTH} characters`
      ),
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

      const { email, token, newPassword } = req.body;
      const result = await AuthController.resetPassword(
        email,
        token,
        newPassword
      );

      res.json({
        message: "Password reset successfully",
        ...result,
      });
    } catch (error) {
      console.error("Password reset error:", error);

      if (error.name === "NotFoundError") {
        return res.status(HTTP_STATUS.NOT_FOUND).json({
          message: error.message,
        });
      }

      res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
        message: "Failed to reset password",
        error: error.message,
      });
    }
  }
);

// Export the router and middleware
module.exports = router;
module.exports.authenticateToken = authenticateToken;
