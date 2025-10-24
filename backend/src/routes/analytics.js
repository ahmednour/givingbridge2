const express = require("express");
const router = express.Router();
const AnalyticsController = require("../controllers/analyticsController");
const { authenticateToken } = require("./auth");
const { requireAdmin, asyncHandler } = require("../middleware");

// All analytics routes require admin authentication
router.use(authenticateToken);
router.use(requireAdmin);

// Get overview statistics
router.get(
  "/overview",
  asyncHandler(async (req, res) => {
    const overview = await AnalyticsController.getOverview();

    res.json({
      success: true,
      message: "Overview statistics retrieved successfully",
      data: overview,
    });
  })
);

// Get donation trends
router.get(
  "/donations/trends",
  asyncHandler(async (req, res) => {
    const { days } = req.query;
    const trends = await AnalyticsController.getDonationTrends(days || 30);

    res.json({
      success: true,
      message: "Donation trends retrieved successfully",
      data: trends,
    });
  })
);

// Get user growth
router.get(
  "/users/growth",
  asyncHandler(async (req, res) => {
    const { days } = req.query;
    const growth = await AnalyticsController.getUserGrowth(days || 30);

    res.json({
      success: true,
      message: "User growth data retrieved successfully",
      data: growth,
    });
  })
);

// Get category distribution
router.get(
  "/donations/category-distribution",
  asyncHandler(async (req, res) => {
    const distribution = await AnalyticsController.getCategoryDistribution();

    res.json({
      success: true,
      message: "Category distribution retrieved successfully",
      data: distribution,
    });
  })
);

// Get status distribution
router.get(
  "/requests/status-distribution",
  asyncHandler(async (req, res) => {
    const distribution = await AnalyticsController.getStatusDistribution();

    res.json({
      success: true,
      message: "Status distribution retrieved successfully",
      data: distribution,
    });
  })
);

// Get top donors
router.get(
  "/donors/top",
  asyncHandler(async (req, res) => {
    const { limit } = req.query;
    const topDonors = await AnalyticsController.getTopDonors(limit || 10);

    res.json({
      success: true,
      message: "Top donors retrieved successfully",
      data: topDonors,
    });
  })
);

// Get recent activity
router.get(
  "/activity/recent",
  asyncHandler(async (req, res) => {
    const { limit } = req.query;
    const activity = await AnalyticsController.getRecentActivity(limit || 20);

    res.json({
      success: true,
      message: "Recent activity retrieved successfully",
      data: activity,
    });
  })
);

// Get platform statistics (comprehensive)
router.get(
  "/platform/stats",
  asyncHandler(async (req, res) => {
    const stats = await AnalyticsController.getPlatformStats();

    res.json({
      success: true,
      message: "Platform statistics retrieved successfully",
      data: stats,
    });
  })
);

module.exports = router;
