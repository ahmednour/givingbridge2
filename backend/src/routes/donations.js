const express = require("express");
const { body, validationResult } = require("express-validator");
const router = express.Router();
const Donation = require("../models/Donation");

// Import authentication middleware from auth routes
const { authenticateToken } = require("./auth");

// Get all donations with optional filters
router.get("/", async (req, res) => {
  try {
    const { category, location, available } = req.query;

    const filters = {};
    if (category) filters.category = category;
    if (location) filters.location = location;
    if (available !== undefined) filters.isAvailable = available === "true";

    const donations = Donation.findAll(filters);

    res.json({
      message: "Donations retrieved successfully",
      donations,
      total: donations.length,
    });
  } catch (error) {
    console.error("Get donations error:", error);
    res.status(500).json({
      message: "Failed to retrieve donations",
      error: error.message,
    });
  }
});

// Get donation by ID
router.get("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const donation = Donation.findById(id);

    if (!donation) {
      return res.status(404).json({
        message: "Donation not found",
      });
    }

    res.json({
      message: "Donation retrieved successfully",
      donation,
    });
  } catch (error) {
    console.error("Get donation error:", error);
    res.status(500).json({
      message: "Failed to retrieve donation",
      error: error.message,
    });
  }
});

// Get donations by donor (requires authentication)
router.get("/donor/my-donations", authenticateToken, async (req, res) => {
  try {
    const donations = Donation.findByDonorId(req.user.userId);

    res.json({
      message: "Your donations retrieved successfully",
      donations,
      total: donations.length,
    });
  } catch (error) {
    console.error("Get my donations error:", error);
    res.status(500).json({
      message: "Failed to retrieve your donations",
      error: error.message,
    });
  }
});

// Create new donation (requires authentication)
router.post(
  "/",
  [
    authenticateToken,
    body("title")
      .trim()
      .isLength({ min: 3 })
      .withMessage("Title must be at least 3 characters"),
    body("description")
      .trim()
      .isLength({ min: 10 })
      .withMessage("Description must be at least 10 characters"),
    body("category")
      .isIn(["food", "clothes", "books", "electronics", "other"])
      .withMessage("Invalid category"),
    body("condition")
      .isIn(["new", "like-new", "good", "fair"])
      .withMessage("Invalid condition"),
    body("location")
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

      const { title, description, category, condition, location, imageUrl } =
        req.body;

      // Get user info from token
      const { users } = require("./auth");
      const user = users.find((u) => u.id === req.user.userId);

      if (!user) {
        return res.status(404).json({
          message: "User not found",
        });
      }

      const donation = Donation.create({
        title,
        description,
        category,
        condition,
        location,
        donorId: user.id,
        donorName: user.name,
        imageUrl: imageUrl || null,
      });

      res.status(201).json({
        message: "Donation created successfully",
        donation,
      });
    } catch (error) {
      console.error("Create donation error:", error);
      res.status(500).json({
        message: "Failed to create donation",
        error: error.message,
      });
    }
  }
);

// Update donation (requires authentication and ownership)
router.put(
  "/:id",
  [
    authenticateToken,
    body("title")
      .optional()
      .trim()
      .isLength({ min: 3 })
      .withMessage("Title must be at least 3 characters"),
    body("description")
      .optional()
      .trim()
      .isLength({ min: 10 })
      .withMessage("Description must be at least 10 characters"),
    body("category")
      .optional()
      .isIn(["food", "clothes", "books", "electronics", "other"])
      .withMessage("Invalid category"),
    body("condition")
      .optional()
      .isIn(["new", "like-new", "good", "fair"])
      .withMessage("Invalid condition"),
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

      const { id } = req.params;
      const donation = Donation.findById(id);

      if (!donation) {
        return res.status(404).json({
          message: "Donation not found",
        });
      }

      // Check ownership (only donor can update their donation, or admin)
      const { users } = require("./auth");
      const user = users.find((u) => u.id === req.user.userId);

      if (donation.donorId !== req.user.userId && user.role !== "admin") {
        return res.status(403).json({
          message: "You can only update your own donations",
        });
      }

      const updatedDonation = Donation.update(id, req.body);

      res.json({
        message: "Donation updated successfully",
        donation: updatedDonation,
      });
    } catch (error) {
      console.error("Update donation error:", error);
      res.status(500).json({
        message: "Failed to update donation",
        error: error.message,
      });
    }
  }
);

// Delete donation (requires authentication and ownership)
router.delete("/:id", authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const donation = Donation.findById(id);

    if (!donation) {
      return res.status(404).json({
        message: "Donation not found",
      });
    }

    // Check ownership (only donor can delete their donation, or admin)
    const { users } = require("./auth");
    const user = users.find((u) => u.id === req.user.userId);

    if (donation.donorId !== req.user.userId && user.role !== "admin") {
      return res.status(403).json({
        message: "You can only delete your own donations",
      });
    }

    const deleted = Donation.delete(id);

    if (deleted) {
      res.json({
        message: "Donation deleted successfully",
      });
    } else {
      res.status(500).json({
        message: "Failed to delete donation",
      });
    }
  } catch (error) {
    console.error("Delete donation error:", error);
    res.status(500).json({
      message: "Failed to delete donation",
      error: error.message,
    });
  }
});

// Get donation statistics (for admin dashboard)
router.get("/admin/stats", authenticateToken, async (req, res) => {
  try {
    // Check if user is admin
    const { users } = require("./auth");
    const user = users.find((u) => u.id === req.user.userId);

    if (user.role !== "admin") {
      return res.status(403).json({
        message: "Admin access required",
      });
    }

    const stats = Donation.getStats();

    res.json({
      message: "Donation statistics retrieved successfully",
      stats,
    });
  } catch (error) {
    console.error("Get donation stats error:", error);
    res.status(500).json({
      message: "Failed to retrieve donation statistics",
      error: error.message,
    });
  }
});

module.exports = router;
