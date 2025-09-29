const express = require("express");
const { body, validationResult } = require("express-validator");
const { authenticateToken } = require("./auth");
const User = require("../models/User");
const router = express.Router();

// Get all users (admin only)
router.get("/", authenticateToken, async (req, res) => {
  try {
    // Check if user is admin
    if (req.user.role !== "admin") {
      return res.status(403).json({
        message: "Access denied. Admin role required.",
      });
    }

    // Get all users from database (excluding passwords)
    const users = await User.findAll({
      attributes: { exclude: ['password'] }
    });

    res.json({
      users: users,
      total: users.length,
    });
  } catch (error) {
    console.error("Get users error:", error);
    res.status(500).json({
      message: "Failed to fetch users",
      error: error.message,
    });
  }
});

// Get user by ID
router.get("/:id", authenticateToken, async (req, res) => {
  try {
    const userId = parseInt(req.params.id);

    // Users can only access their own profile unless they're admin
    if (req.user.userId !== userId && req.user.role !== "admin") {
      return res.status(403).json({
        message: "Access denied",
      });
    }

    const user = await User.findByPk(userId, {
      attributes: { exclude: ['password'] }
    });

    if (!user) {
      return res.status(404).json({
        message: "User not found",
      });
    }

    res.json({
      user: user,
    });
  } catch (error) {
    console.error("Get user error:", error);
    res.status(500).json({
      message: "Failed to fetch user",
      error: error.message,
    });
  }
});

// Update user profile
router.put(
  "/:id",
  [
    authenticateToken,
    body("name")
      .optional()
      .trim()
      .isLength({ min: 2 })
      .withMessage("Name must be at least 2 characters"),
    body("email")
      .optional()
      .isEmail()
      .normalizeEmail()
      .withMessage("Please provide a valid email"),
    body("phone")
      .optional()
      .isMobilePhone()
      .withMessage("Please provide a valid phone number"),
    body("location")
      .optional()
      .trim()
      .isLength({ min: 2 })
      .withMessage("Location must be at least 2 characters"),
  ],
  async (req, res) => {
    try {
      // Check for validation errors
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          message: "Validation failed",
          errors: errors.array(),
        });
      }

      const userId = parseInt(req.params.id);

      // Users can only update their own profile unless they're admin
      if (req.user.userId !== userId && req.user.role !== "admin") {
        return res.status(403).json({
          message: "Access denied",
        });
      }

      const user = await User.findByPk(userId);
      if (!user) {
        return res.status(404).json({
          message: "User not found",
        });
      }

      const { name, email, phone, location, avatarUrl } = req.body;

      // Check if email is already taken by another user
      if (email && email !== user.email) {
        const existingUser = await User.findOne({
          where: { email },
          attributes: ['id']
        });
        if (existingUser && existingUser.id !== userId) {
          return res.status(400).json({
            message: "Email is already taken",
          });
        }
      }

      // Update user fields
      const updateData = {};
      if (name !== undefined) updateData.name = name;
      if (email !== undefined) updateData.email = email;
      if (phone !== undefined) updateData.phone = phone;
      if (location !== undefined) updateData.location = location;
      if (avatarUrl !== undefined) updateData.avatarUrl = avatarUrl;

      await user.update(updateData);

      // Return updated user without password
      const updatedUser = await User.findByPk(userId, {
        attributes: { exclude: ['password'] }
      });

      res.json({
        message: "User updated successfully",
        user: updatedUser,
      });
    } catch (error) {
      console.error("Update user error:", error);
      res.status(500).json({
        message: "Failed to update user",
        error: error.message,
      });
    }
  }
);

// Delete user (admin only)
router.delete("/:id", authenticateToken, async (req, res) => {
  try {
    // Check if user is admin
    if (req.user.role !== "admin") {
      return res.status(403).json({
        message: "Access denied. Admin role required.",
      });
    }

    const userId = parseInt(req.params.id);
    const user = await User.findByPk(userId);

    if (!user) {
      return res.status(404).json({
        message: "User not found",
      });
    }

    // Don't allow admin to delete themselves
    if (req.user.userId === userId) {
      return res.status(400).json({
        message: "Cannot delete your own account",
      });
    }

    await user.destroy();

    res.json({
      message: "User deleted successfully",
    });
  } catch (error) {
    console.error("Delete user error:", error);
    res.status(500).json({
      message: "Failed to delete user",
      error: error.message,
    });
  }
});

// Get user's requests
router.get("/:id/requests", authenticateToken, (req, res) => {
  try {
    const userId = parseInt(req.params.id);

    // Users can only access their own requests unless they're admin
    if (req.user.userId !== userId && req.user.role !== "admin") {
      return res.status(403).json({
        message: "Access denied",
      });
    }

    // Import requests from requests route (this is a circular dependency issue)
    // For now, return empty array - this should be handled properly with a shared data store
    const userRequests = [];

    res.json({
      requests: userRequests,
      total: userRequests.length,
    });
  } catch (error) {
    console.error("Get user requests error:", error);
    res.status(500).json({
      message: "Failed to fetch user requests",
      error: error.message,
    });
  }
});

module.exports = router;
