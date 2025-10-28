const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/User");
const config = require("../config");
const { Op } = require("sequelize");
const {
  AuthenticationError,
  ConflictError,
  NotFoundError,
} = require("../utils/errorHandler");
const { JWT_SETTINGS } = require("../constants");
const notificationService = require("../services/notificationService");
const crypto = require("crypto");

// JWT Secret - must be provided via environment variable
const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) {
  throw new Error("JWT_SECRET environment variable is required");
}

class AuthController {
  /**
   * Register a new user
   * @param {Object} userData - User registration data
   * @returns {Promise<Object>} Registration result with user and token
   */
  static async register(userData) {
    const { name, email, password, role, phone, location } = userData;

    // Check if user already exists
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      throw new ConflictError("User with this email already exists");
    }

    // Hash password
    const saltRounds = config.bcryptRounds;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Generate email verification token
    const emailVerificationToken = crypto.randomBytes(32).toString("hex");
    const emailVerificationExpiry = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours

    // Create new user
    const newUser = await User.create({
      name,
      email,
      password: hashedPassword,
      role: role || "donor",
      phone: phone || null,
      location: location || null,
      avatarUrl: null,
      emailVerificationToken,
      emailVerificationExpiry,
      isEmailVerified: false,
    });

    // Send email verification notification
    await notificationService.sendEmailVerification(
      newUser,
      emailVerificationToken
    );

    // Generate JWT token
    const token = jwt.sign(
      {
        userId: newUser.id,
        email: newUser.email,
        role: newUser.role,
      },
      JWT_SECRET,
      { expiresIn: JWT_SETTINGS.EXPIRES_IN }
    );

    // Remove password and verification fields from response
    const {
      password: _,
      emailVerificationToken: __,
      emailVerificationExpiry: ___,
      ...userResponse
    } = newUser.toJSON();

    return {
      user: userResponse,
      token,
      message:
        "Registration successful. Please check your email to verify your account.",
    };
  }

  /**
   * Login user with email and password
   * @param {string} email - User email
   * @param {string} password - User password
   * @returns {Promise<Object>} Login result with user and token
   */
  static async login(email, password) {
    try {
      // Find user by email
      const user = await User.findOne({ where: { email } });
      if (!user) {
        throw new AuthenticationError("Invalid email or password");
      }

      // Check password
      const isPasswordValid = await bcrypt.compare(password, user.password);
      if (!isPasswordValid) {
        throw new AuthenticationError("Invalid email or password");
      }

      // Generate JWT token
      const token = jwt.sign(
        {
          userId: user.id,
          email: user.email,
          role: user.role,
        },
        JWT_SECRET,
        { expiresIn: JWT_SETTINGS.EXPIRES_IN }
      );

      // Remove password from response
      const { password: _, ...userResponse } = user.toJSON();

      return {
        user: userResponse,
        token,
      };
    } catch (error) {
      // Handle database connection errors specifically
      if (
        error.name === "SequelizeConnectionRefusedError" ||
        error.name === "SequelizeDatabaseError"
      ) {
        throw new Error(
          "Service temporarily unavailable. Please try again later."
        );
      }
      throw error;
    }
  }

  /**
   * Get user profile by ID
   * @param {number} userId - User ID
   * @returns {Promise<Object>} User profile without password
   */
  static async getProfile(userId) {
    const user = await User.findByPk(userId);
    if (!user) {
      throw new NotFoundError("User not found");
    }

    const { password: _, ...userResponse } = user.toJSON();
    return userResponse;
  }

  /**
   * Verify JWT token
   * @param {string} token - JWT token
   * @returns {Promise<Object>} Decoded token payload
   */
  static async verifyToken(token) {
    return new Promise((resolve, reject) => {
      jwt.verify(token, JWT_SECRET, (err, decoded) => {
        if (err) {
          reject(new AuthenticationError("Invalid or expired token"));
        } else {
          resolve(decoded);
        }
      });
    });
  }

  /**
   * Update user's FCM token for push notifications
   * @param {number} userId - User ID
   * @param {string} fcmToken - Firebase Cloud Messaging token
   * @returns {Promise<Object>} Update result
   */
  static async updateFCMToken(userId, fcmToken) {
    const user = await User.findByPk(userId);
    if (!user) {
      throw new NotFoundError("User not found");
    }

    await user.update({ fcmToken });

    console.log(`✅ Updated FCM token for user ${userId}`);

    return {
      success: true,
      message: "FCM token updated successfully",
    };
  }

  /**
   * Verify user's email address
   * @param {string} email - User email
   * @param {string} token - Email verification token
   * @returns {Promise<Object>} Verification result
   */
  static async verifyEmail(email, token) {
    const user = await User.findOne({
      where: {
        email,
        emailVerificationToken: token,
        emailVerificationExpiry: {
          [Op.gt]: new Date(),
        },
      },
    });

    if (!user) {
      throw new NotFoundError("Invalid or expired verification token");
    }

    await user.update({
      isEmailVerified: true,
      emailVerificationToken: null,
      emailVerificationExpiry: null,
    });

    return {
      success: true,
      message: "Email verified successfully",
    };
  }

  /**
   * Resend email verification
   * @param {string} email - User email
   * @returns {Promise<Object>} Resend result
   */
  static async resendVerificationEmail(email) {
    const user = await User.findOne({ where: { email } });

    if (!user) {
      throw new NotFoundError("User not found");
    }

    if (user.isEmailVerified) {
      throw new ConflictError("Email is already verified");
    }

    // Generate new email verification token
    const emailVerificationToken = crypto.randomBytes(32).toString("hex");
    const emailVerificationExpiry = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours

    await user.update({
      emailVerificationToken,
      emailVerificationExpiry,
    });

    // Send email verification notification
    await notificationService.sendEmailVerification(
      user,
      emailVerificationToken
    );

    return {
      success: true,
      message: "Verification email sent successfully",
    };
  }

  /**
   * Request password reset
   * @param {string} email - User email
   * @returns {Promise<Object>} Reset request result
   */
  static async requestPasswordReset(email) {
    const user = await User.findOne({ where: { email } });

    if (!user) {
      throw new NotFoundError("User not found");
    }

    // Generate password reset token
    const passwordResetToken = crypto.randomBytes(32).toString("hex");
    const passwordResetExpiry = new Date(Date.now() + 60 * 60 * 1000); // 1 hour

    await user.update({
      passwordResetToken,
      passwordResetExpiry,
    });

    // Send password reset notification
    await notificationService.sendPasswordReset(user, passwordResetToken);

    return {
      success: true,
      message: "Password reset email sent successfully",
    };
  }

  /**
   * Reset user password
   * @param {string} email - User email
   * @param {string} token - Password reset token
   * @param {string} newPassword - New password
   * @returns {Promise<Object>} Reset result
   */
  static async resetPassword(email, token, newPassword) {
    const user = await User.findOne({
      where: {
        email,
        passwordResetToken: token,
        passwordResetExpiry: {
          [Op.gt]: new Date(),
        },
      },
    });

    if (!user) {
      throw new NotFoundError("Invalid or expired reset token");
    }

    // Hash new password
    const saltRounds = config.bcryptRounds;
    const hashedPassword = await bcrypt.hash(newPassword, saltRounds);

    await user.update({
      password: hashedPassword,
      passwordResetToken: null,
      passwordResetExpiry: null,
    });

    return {
      success: true,
      message: "Password reset successfully",
    };
  }
}

module.exports = AuthController;
