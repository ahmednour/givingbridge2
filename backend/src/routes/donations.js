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

/**
 * @swagger
 * /api/donations:
 *   get:
 *     summary: Get all donations
 *     description: Retrieve a paginated list of donations with optional filtering
 *     tags: [Donations]
 *     security: []
 *     parameters:
 *       - $ref: '#/components/parameters/PageParam'
 *       - $ref: '#/components/parameters/LimitParam'
 *       - name: category
 *         in: query
 *         description: Filter by donation category
 *         required: false
 *         schema:
 *           type: string
 *           example: clothing
 *       - name: location
 *         in: query
 *         description: Filter by location
 *         required: false
 *         schema:
 *           type: string
 *           example: New York, NY
 *       - name: available
 *         in: query
 *         description: Filter by availability status
 *         required: false
 *         schema:
 *           type: boolean
 *           example: true
 *       - name: startDate
 *         in: query
 *         description: Filter donations created after this date
 *         required: false
 *         schema:
 *           type: string
 *           format: date
 *           example: 2024-01-01
 *       - name: endDate
 *         in: query
 *         description: Filter donations created before this date
 *         required: false
 *         schema:
 *           type: string
 *           format: date
 *           example: 2024-12-31
 *     responses:
 *       200:
 *         description: Donations retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Donations retrieved successfully
 *                 donations:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Donation'
 *                 pagination:
 *                   type: object
 *                   properties:
 *                     page:
 *                       type: integer
 *                       example: 1
 *                     limit:
 *                       type: integer
 *                       example: 20
 *                     total:
 *                       type: integer
 *                       example: 100
 *                     totalPages:
 *                       type: integer
 *                       example: 5
 *       429:
 *         $ref: '#/components/responses/RateLimitError'
 *       500:
 *         $ref: '#/components/responses/ServerError'
 */
router.get(
  "/",
  generalRateLimit, // Apply general rate limiting
  asyncHandler(async (req, res) => {
    const { category, location, available, startDate, endDate, page, limit } =
      req.query;

    const filters = {};
    if (category) filters.category = category;
    if (location) filters.location = location;
    if (available !== undefined) filters.available = available;
    if (startDate) filters.startDate = startDate;
    if (endDate) filters.endDate = endDate;

    const pagination = {
      page: page || 1,
      limit: limit || 20,
    };

    const result = await DonationController.getAllDonations(
      filters,
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

// Get social proof data for a donation with rate limiting
router.get(
  "/:id/social-proof",
  generalRateLimit, // Apply general rate limiting
  asyncHandler(async (req, res) => {
    const { id } = req.params;
    const socialProof = await DonationController.getSocialProof(id);

    res.json({
      message: "Social proof data retrieved successfully",
      data: socialProof,
    });
  })
);

// Create new donation (authenticated users only) with rate limiting
router.post(
  "/",
  authenticateToken,
  generalRateLimit, // Apply general rate limiting
  imageUpload.single("image"),
  imageUpload.optimizeUploadedImage, // Optimize uploaded image
  asyncHandler(async (req, res) => {
    // Log request details for debugging
    console.log("Create donation request:", {
      userId: req.user?.id,
      userEmail: req.user?.email,
      hasFile: !!req.file,
      body: req.body,
    });

    const donationData = { ...req.body };

    // Handle image upload with optimization info
    if (req.file) {
      donationData.imageUrl = `/uploads/images/${req.file.filename}`;
      donationData.thumbnailUrl = `/uploads/images/${req.file.thumbnailFilename}`;
      
      console.log(`📸 Image optimized: ${req.file.savings}% size reduction`);
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
