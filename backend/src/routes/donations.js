const express = require("express");
const router = express.Router();
const DonationController = require("../controllers/donationController");
const {
  requireAdmin,
  asyncHandler,
} = require("../middleware");
const { authenticateToken } = require("../middleware/auth");
const {
  generalRateLimit,
} = require("../middleware/rateLimiting");
const imageUpload = require("../middleware/imageUpload");

/**
 * @swagger
 * components:
 *   schemas:
 *     DonationRequest:
 *       type: object
 *       required:
 *         - title
 *         - description
 *         - category
 *         - location
 *       properties:
 *         title:
 *           type: string
 *           description: Donation title
 *           example: Winter Clothes for Homeless
 *         description:
 *           type: string
 *           description: Detailed donation description
 *           example: Warm winter clothes including jackets, sweaters, and blankets
 *         category:
 *           type: string
 *           description: Donation category
 *           example: clothing
 *         location:
 *           type: string
 *           description: Donation pickup location
 *           example: New York, NY
 *         condition:
 *           type: string
 *           enum: [new, like_new, good, fair]
 *           description: Item condition
 *           example: good
 *         quantity:
 *           type: integer
 *           description: Number of items
 *           example: 5
 *         expiryDate:
 *           type: string
 *           format: date
 *           description: Donation expiry date (for perishables)
 *           example: 2024-12-31
 */

// Get all donations with basic pagination (simplified for MVP)
router.get(
  "/",
  generalRateLimit,
  asyncHandler(async (req, res) => {
    const { page, limit } = req.query;

    const pagination = {
      page: page || 1,
      limit: limit || 20,
    };

    const result = await DonationController.getAllDonations(
      {},  // No filters for MVP
      pagination
    );

    res.json({
      message: "Donations retrieved successfully",
      donations: result.donations,
      pagination: result.pagination,
    });
  })
);

// Get donation by ID (public endpoint with view count) with rate limiting
router.get(
  "/:id",
  generalRateLimit, // Apply general rate limiting
  asyncHandler(async (req, res) => {
    const { id } = req.params;
    const donation = await DonationController.getDonationByIdWithViewCount(id);

    if (!donation) {
      return res.status(404).json({ message: "Donation not found" });
    }

    res.json({
      message: "Donation retrieved successfully",
      donation,
    });
  })
);

// Social proof features removed for MVP

// Create new donation (simplified for MVP)
router.post(
  "/",
  authenticateToken,
  generalRateLimit,
  imageUpload.single("image"),
  asyncHandler(async (req, res) => {
    const donationData = { ...req.body };

    // Handle basic image upload without optimization
    if (req.file) {
      donationData.imageUrl = `/uploads/images/${req.file.filename}`;
    }

    const donation = await DonationController.createDonation(
      donationData,
      req.user.id
    );

    res.status(201).json({
      message: "Donation created successfully",
      donation,
    });
  })
);

// Update donation (donor or admin only) with rate limiting
router.put(
  "/:id",
  authenticateToken,
  generalRateLimit, // Apply general rate limiting
  imageUpload.single("image"),
  asyncHandler(async (req, res) => {
    const { id } = req.params;
    const updateData = { ...req.body };

    // Handle image upload
    if (req.file) {
      updateData.imageUrl = `/uploads/images/${req.file.filename}`;
    }

    try {
      const donation = await DonationController.updateDonation(
        id,
        updateData,
        req.user.id,
        req.user.role
      );

      res.json({
        message: "Donation updated successfully",
        donation,
      });
    } catch (error) {
      res.status(403).json({ message: error.message });
    }
  })
);

// Delete donation (donor or admin only) with rate limiting
router.delete(
  "/:id",
  authenticateToken,
  generalRateLimit, // Apply general rate limiting
  asyncHandler(async (req, res) => {
    const { id } = req.params;

    try {
      await DonationController.deleteDonation(id, req.user.id, req.user.role);

      res.json({ message: "Donation deleted successfully" });
    } catch (error) {
      res.status(403).json({ message: error.message });
    }
  })
);

// Get user's donations (authenticated users only) with rate limiting
router.get(
  "/user/my-donations",
  authenticateToken,
  generalRateLimit, // Apply general rate limiting
  asyncHandler(async (req, res) => {
    const donations = await DonationController.getDonationsByDonor(req.user.id);

    res.json({
      message: "Your donations retrieved successfully",
      donations,
      total: donations.length,
    });
  })
);

// Get donation statistics (admin only) with rate limiting
router.get(
  "/stats",
  authenticateToken,
  requireAdmin,
  generalRateLimit, // Apply heavy operation rate limiting
  asyncHandler(async (req, res) => {
    const stats = await DonationController.getDonationStats();

    res.json({
      message: "Donation statistics retrieved successfully",
      stats,
    });
  })
);

module.exports = router;
