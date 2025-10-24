const express = require("express");
const { body, validationResult } = require("express-validator");
const { authenticateToken } = require("./auth");
const User = require("../models/User");
const UserController = require("../controllers/userController");
const upload = require("../middleware/upload");
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
      attributes: { exclude: ["password"] },
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

// Search users for starting conversations
router.get("/search/conversation", authenticateToken, async (req, res) => {
  try {
    const { query, limit = 10 } = req.query;

    // Search for users to start conversations with
    const users = await UserController.searchUsers({
      query,
      limit: parseInt(limit),
    });

    // Filter out current user and blocked users
    const filteredUsers = users.filter((user) => user.id !== req.user.userId);

    res.json({
      users: filteredUsers,
      total: filteredUsers.length,
    });
  } catch (error) {
    console.error("Search users error:", error);
    res.status(500).json({
      message: "Failed to search users",
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
      attributes: { exclude: ["password"] },
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
          attributes: ["id"],
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
        attributes: { exclude: ["password"] },
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

// ============ Safety Features Routes ============

// Block a user
router.post(
  "/:id/block",
  [
    authenticateToken,
    body("reason")
      .optional()
      .trim()
      .isLength({ max: 500 })
      .withMessage("Reason must be at most 500 characters"),
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          message: "Validation failed",
          errors: errors.array(),
        });
      }

      const userId = parseInt(req.params.id);
      const { reason } = req.body;

      const result = await UserController.blockUser(userId, req.user, reason);

      res.json(result);
    } catch (error) {
      console.error("Block user error:", error);
      const status = error.statusCode || 500;
      res.status(status).json({
        message: error.message || "Failed to block user",
      });
    }
  }
);

// Unblock a user
router.delete("/:id/block", authenticateToken, async (req, res) => {
  try {
    const userId = parseInt(req.params.id);
    const result = await UserController.unblockUser(userId, req.user);
    res.json(result);
  } catch (error) {
    console.error("Unblock user error:", error);
    const status = error.statusCode || 500;
    res.status(status).json({
      message: error.message || "Failed to unblock user",
    });
  }
});

// Get blocked users list
router.get("/blocked/list", authenticateToken, async (req, res) => {
  try {
    const blockedUsers = await UserController.getBlockedUsers(req.user);
    res.json({
      blockedUsers,
      total: blockedUsers.length,
    });
  } catch (error) {
    console.error("Get blocked users error:", error);
    res.status(500).json({
      message: "Failed to fetch blocked users",
      error: error.message,
    });
  }
});

// Check if user is blocked
router.get("/:id/blocked", authenticateToken, async (req, res) => {
  try {
    const userId = parseInt(req.params.id);
    const isBlocked = await UserController.isUserBlocked(userId, req.user);
    res.json({ isBlocked });
  } catch (error) {
    console.error("Check blocked status error:", error);
    res.status(500).json({
      message: "Failed to check blocked status",
      error: error.message,
    });
  }
});

// Report a user
router.post(
  "/:id/report",
  [
    authenticateToken,
    body("reason")
      .notEmpty()
      .withMessage("Reason is required")
      .isIn([
        "spam",
        "harassment",
        "inappropriate_content",
        "scam",
        "fake_profile",
        "other",
      ])
      .withMessage("Invalid report reason"),
    body("description")
      .notEmpty()
      .withMessage("Description is required")
      .trim()
      .isLength({ min: 10, max: 1000 })
      .withMessage("Description must be between 10 and 1000 characters"),
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          message: "Validation failed",
          errors: errors.array(),
        });
      }

      const userId = parseInt(req.params.id);
      const { reason, description } = req.body;

      const result = await UserController.reportUser(userId, req.user, {
        reason,
        description,
      });

      res.json(result);
    } catch (error) {
      console.error("Report user error:", error);
      const status = error.statusCode || 500;
      res.status(status).json({
        message: error.message || "Failed to report user",
      });
    }
  }
);

// Get user's submitted reports
router.get("/reports/my", authenticateToken, async (req, res) => {
  try {
    const reports = await UserController.getUserReports(req.user);
    res.json({
      reports,
      total: reports.length,
    });
  } catch (error) {
    console.error("Get user reports error:", error);
    res.status(500).json({
      message: "Failed to fetch reports",
      error: error.message,
    });
  }
});

// Get all reports (admin only)
router.get("/reports/all", authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== "admin") {
      return res.status(403).json({
        message: "Access denied. Admin role required.",
      });
    }

    const { status, page, limit } = req.query;
    const result = await UserController.getAllReports({ status, page, limit });
    res.json(result);
  } catch (error) {
    console.error("Get all reports error:", error);
    res.status(500).json({
      message: "Failed to fetch reports",
      error: error.message,
    });
  }
});

// Update report status (admin only)
router.patch(
  "/reports/:reportId",
  [
    authenticateToken,
    body("status")
      .optional()
      .isIn(["pending", "reviewed", "resolved", "dismissed"])
      .withMessage("Invalid status"),
    body("reviewNotes")
      .optional()
      .trim()
      .isLength({ max: 1000 })
      .withMessage("Review notes must be at most 1000 characters"),
  ],
  async (req, res) => {
    try {
      if (req.user.role !== "admin") {
        return res.status(403).json({
          message: "Access denied. Admin role required.",
        });
      }

      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          message: "Validation failed",
          errors: errors.array(),
        });
      }

      const reportId = parseInt(req.params.reportId);
      const { status, reviewNotes } = req.body;

      const result = await UserController.updateReportStatus(
        reportId,
        { status, reviewNotes },
        req.user
      );

      res.json(result);
    } catch (error) {
      console.error("Update report error:", error);
      const status = error.statusCode || 500;
      res.status(status).json({
        message: error.message || "Failed to update report",
      });
    }
  }
);

// Upload user avatar
router.post(
  "/avatar",
  authenticateToken,
  upload.single("avatar"),
  async (req, res) => {
    try {
      const result = await UserController.uploadAvatar(req.user, req.file);
      res.status(200).json(result);
    } catch (error) {
      console.error("Upload avatar error:", error);
      const status = error.statusCode || 500;
      res.status(status).json({
        message: error.message || "Failed to upload avatar",
      });
    }
  }
);

// Delete user avatar
router.delete("/avatar", authenticateToken, async (req, res) => {
  try {
    const result = await UserController.deleteAvatar(req.user);
    res.json(result);
  } catch (error) {
    console.error("Delete avatar error:", error);
    const status = error.statusCode || 500;
    res.status(status).json({
      message: error.message || "Failed to delete avatar",
    });
  }
});

module.exports = router;
