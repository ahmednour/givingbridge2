const express = require("express");
const router = express.Router();
const ShareController = require("../controllers/shareController");
const { authenticateToken } = require("../middleware/auth");
const { asyncHandler } = require("../middleware");

// All routes require authentication
router.use(authenticateToken);

// Create a new share
router.post(
  "/:donationId/shares",
  asyncHandler(async (req, res) => {
    const { donationId } = req.params;
    const { platform } = req.body;
    const userId = req.user.id;

    const shareData = { platform };

    const share = await ShareController.createShare(
      shareData,
      donationId,
      userId
    );

    res.status(201).json({
      success: true,
      message: "Share recorded successfully",
      data: share,
    });
  })
);

// Get shares for a specific donation
router.get(
  "/:donationId/shares",
  asyncHandler(async (req, res) => {
    const { donationId } = req.params;
    const { page, limit } = req.query;

    const pagination = {
      page: page || 1,
      limit: limit || 20,
    };

    const shares = await ShareController.getShares(donationId, pagination);

    res.json({
      success: true,
      message: "Shares retrieved successfully",
      data: shares,
    });
  })
);

// Get a specific share by ID
router.get(
  "/shares/:shareId",
  asyncHandler(async (req, res) => {
    const { shareId } = req.params;

    const share = await ShareController.getShareById(shareId);

    res.json({
      success: true,
      message: "Share retrieved successfully",
      data: share,
    });
  })
);

// Get all shares for the current user
router.get(
  "/my-shares",
  asyncHandler(async (req, res) => {
    const { page, limit } = req.query;
    const userId = req.user.id;

    const pagination = {
      page: page || 1,
      limit: limit || 20,
    };

    const shares = await ShareController.getUserShares(userId, pagination);

    res.json({
      success: true,
      message: "User shares retrieved successfully",
      data: shares,
    });
  })
);

// Get share statistics for a donation
router.get(
  "/:donationId/share-statistics",
  asyncHandler(async (req, res) => {
    const { donationId } = req.params;

    const statistics = await ShareController.getShareStatistics(donationId);

    res.json({
      success: true,
      message: "Share statistics retrieved successfully",
      data: statistics,
    });
  })
);

module.exports = router;
