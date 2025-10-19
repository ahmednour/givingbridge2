const express = require("express");
const { body, validationResult } = require("express-validator");
const router = express.Router();
const DonationController = require("../controllers/donationController");
const User = require("../models/User");
const { loadUser, requireAdmin, asyncHandler } = require("../middleware");

// Import authentication middleware from auth routes
const { authenticateToken } = require("./auth");

// Get all donations with optional filters and pagination
router.get("/", async (req, res) => {
  try {
    const { category, location, available, page, limit } = req.query;
    const result = await DonationController.getAllDonations(
      {
        category,
        location,
        available,
      },
      {
        page: page || 1,
        limit: limit || 20,
      }
    );

    res.json({
      message: "Donations retrieved successfully",
      donations: result.donations,
      pagination: result.pagination,
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
    const donation = await DonationController.getDonationById(id);

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
router.get(
  "/donor/my-donations",
  authenticateToken,
  asyncHandler(async (req, res) => {
    const donations = await DonationController.getDonationsByDonor(
      req.user.userId
    );

    res.json({
      message: "Your donations retrieved successfully",
      donations,
      total: donations.length,
    });
  })
);

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

      const donation = await DonationController.createDonation(
        req.body,
        req.user.userId
      );

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
      const user = await User.findByPk(req.user.userId);

      const donation = await DonationController.updateDonation(
        id,
        req.body,
        req.user.userId,
        user.role
      );

      res.json({
        message: "Donation updated successfully",
        donation,
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
    const user = await User.findByPk(req.user.userId);

    await DonationController.deleteDonation(id, req.user.userId, user.role);

    res.json({
      message: "Donation deleted successfully",
    });
  } catch (error) {
    console.error("Delete donation error:", error);
    res.status(500).json({
      message: "Failed to delete donation",
      error: error.message,
    });
  }
});

// Get donation statistics (for admin dashboard)
router.get(
  "/admin/stats",
  authenticateToken,
  requireAdmin,
  asyncHandler(async (req, res) => {
    const stats = await DonationController.getDonationStats();

    res.json({
      message: "Donation statistics retrieved successfully",
      stats,
    });
  })
);

module.exports = router;
