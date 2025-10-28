const express = require("express");
const router = express.Router();
const AnalyticsController = require("../controllers/analyticsController");
const ReportingService = require("../services/reportingService");
const { authenticateToken } = require("./auth");
const { requireAdmin, asyncHandler } = require("../middleware");
const { heavyOperationLimiter } = require("../middleware/rateLimiting");

// All analytics routes require admin authentication
router.use(authenticateToken);
router.use(requireAdmin);

// Get overview statistics
router.get(
  "/overview",
  heavyOperationLimiter, // Apply heavy operation rate limiting
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
  heavyOperationLimiter, // Apply heavy operation rate limiting
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
  heavyOperationLimiter, // Apply heavy operation rate limiting
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
  heavyOperationLimiter, // Apply heavy operation rate limiting
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
  heavyOperationLimiter, // Apply heavy operation rate limiting
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
  heavyOperationLimiter, // Apply heavy operation rate limiting
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

// Get top receivers
router.get(
  "/receivers/top",
  heavyOperationLimiter, // Apply heavy operation rate limiting
  asyncHandler(async (req, res) => {
    const { limit } = req.query;
    const topReceivers = await AnalyticsController.getTopReceivers(limit || 10);

    res.json({
      success: true,
      message: "Top receivers retrieved successfully",
      data: topReceivers,
    });
  })
);

// Get geographic distribution
router.get(
  "/donations/geographic-distribution",
  heavyOperationLimiter, // Apply heavy operation rate limiting
  asyncHandler(async (req, res) => {
    const distribution = await AnalyticsController.getGeographicDistribution();

    res.json({
      success: true,
      message: "Geographic distribution retrieved successfully",
      data: distribution,
    });
  })
);

// Get request success rate
router.get(
  "/requests/success-rate",
  heavyOperationLimiter, // Apply heavy operation rate limiting
  asyncHandler(async (req, res) => {
    const successRate = await AnalyticsController.getRequestSuccessRate();

    res.json({
      success: true,
      message: "Request success rate retrieved successfully",
      data: successRate,
    });
  })
);

// Get donation statistics over time
router.get(
  "/donations/statistics-over-time",
  heavyOperationLimiter, // Apply heavy operation rate limiting
  asyncHandler(async (req, res) => {
    const { days } = req.query;
    const statistics = await AnalyticsController.getDonationStatisticsOverTime(
      days || 30
    );

    res.json({
      success: true,
      message: "Donation statistics over time retrieved successfully",
      data: statistics,
    });
  })
);

// Get recent activity
router.get(
  "/activity/recent",
  heavyOperationLimiter, // Apply heavy operation rate limiting
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
  heavyOperationLimiter, // Apply heavy operation rate limiting
  asyncHandler(async (req, res) => {
    const stats = await AnalyticsController.getPlatformStats();

    res.json({
      success: true,
      message: "Platform statistics retrieved successfully",
      data: stats,
    });
  })
);

// Generate comprehensive analytics report
router.get(
  "/reports/generate",
  heavyOperationLimiter,
  asyncHandler(async (req, res) => {
    const { 
      startDate, 
      endDate, 
      format = 'json', 
      reportType = 'comprehensive',
      topLimit = 10,
      activityLimit = 50
    } = req.query;

    // Validate dates
    const start = startDate ? new Date(startDate) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    const end = endDate ? new Date(endDate) : new Date();

    if (isNaN(start.getTime()) || isNaN(end.getTime())) {
      return res.status(400).json({
        success: false,
        message: "Invalid date format. Use YYYY-MM-DD format."
      });
    }

    if (start >= end) {
      return res.status(400).json({
        success: false,
        message: "Start date must be before end date."
      });
    }

    const options = {
      topLimit: parseInt(topLimit),
      activityLimit: parseInt(activityLimit)
    };

    const report = await ReportingService.generateReport(start, end, format, reportType, options);

    // Set appropriate headers based on format
    if (format.toLowerCase() === 'pdf') {
      res.setHeader('Content-Type', report.contentType);
      res.setHeader('Content-Disposition', `attachment; filename="${report.filename}"`);
      res.send(report.data);
    } else if (format.toLowerCase() === 'csv') {
      res.setHeader('Content-Type', report.contentType);
      res.setHeader('Content-Disposition', `attachment; filename="${report.filename}"`);
      res.send(report.data);
    } else {
      res.json({
        success: true,
        message: "Analytics report generated successfully",
        data: report.data,
        metadata: {
          format,
          reportType,
          filename: report.filename
        }
      });
    }
  })
);

// Get advanced analytics data (for dashboard)
router.get(
  "/advanced",
  heavyOperationLimiter,
  asyncHandler(async (req, res) => {
    const { 
      startDate, 
      endDate,
      topLimit = 10,
      activityLimit = 20
    } = req.query;

    // Default to last 30 days if no dates provided
    const start = startDate ? new Date(startDate) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    const end = endDate ? new Date(endDate) : new Date();

    if (isNaN(start.getTime()) || isNaN(end.getTime())) {
      return res.status(400).json({
        success: false,
        message: "Invalid date format. Use YYYY-MM-DD format."
      });
    }

    const options = {
      topLimit: parseInt(topLimit),
      activityLimit: parseInt(activityLimit)
    };

    const analyticsData = await ReportingService.generateAnalyticsData(start, end, options);

    res.json({
      success: true,
      message: "Advanced analytics data retrieved successfully",
      data: analyticsData
    });
  })
);

// Get real-time metrics (for live dashboard updates)
router.get(
  "/realtime",
  heavyOperationLimiter,
  asyncHandler(async (req, res) => {
    // Get metrics for the last 24 hours
    const end = new Date();
    const start = new Date(end.getTime() - 24 * 60 * 60 * 1000);

    const realtimeData = {
      timestamp: new Date().toISOString(),
      last24Hours: await ReportingService.generateAnalyticsData(start, end, { 
        topLimit: 5, 
        activityLimit: 10 
      }),
      currentStats: await AnalyticsController.getOverview()
    };

    res.json({
      success: true,
      message: "Real-time analytics data retrieved successfully",
      data: realtimeData
    });
  })
);

// Get geographic analytics
router.get(
  "/geographic",
  heavyOperationLimiter,
  asyncHandler(async (req, res) => {
    const { 
      startDate, 
      endDate
    } = req.query;

    // Default to last 30 days if no dates provided
    const start = startDate ? new Date(startDate) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    const end = endDate ? new Date(endDate) : new Date();

    if (isNaN(start.getTime()) || isNaN(end.getTime())) {
      return res.status(400).json({
        success: false,
        message: "Invalid date format. Use YYYY-MM-DD format."
      });
    }

    const geographicData = await ReportingService.getGeographicAnalytics(start, end);

    res.json({
      success: true,
      message: "Geographic analytics data retrieved successfully",
      data: {
        period: {
          startDate: start.toISOString().split('T')[0],
          endDate: end.toISOString().split('T')[0]
        },
        locations: geographicData
      }
    });
  })
);

module.exports = router;
