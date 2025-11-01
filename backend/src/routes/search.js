const express = require("express");
const router = express.Router();
const SearchController = require("../controllers/searchController");
const { authenticateToken } = require("./auth");
const {
  generalRateLimit,
} = require("../middleware/rateLimiting");

/**
 * Search donations
 * @route GET /api/search/donations
 */
router.get("/donations", generalRateLimit, async (req, res) => {
  try {
    const {
      query,
      category,
      location,
      condition,
      status,
      available,
      startDate,
      endDate,
      minDate,
      maxDate,
      sortBy,
      sortOrder,
      page,
      limit,
    } = req.query;

    const filters = {};
    if (query) filters.query = query;
    if (category) filters.category = category;
    if (location) filters.location = location;
    if (condition) filters.condition = condition;
    if (status) filters.status = status;
    if (available !== undefined) filters.available = available;
    if (startDate) filters.startDate = startDate;
    if (endDate) filters.endDate = endDate;
    if (minDate) filters.minDate = minDate;
    if (maxDate) filters.maxDate = maxDate;
    if (sortBy) filters.sortBy = sortBy;
    if (sortOrder) filters.sortOrder = sortOrder;

    const pagination = {
      page: page || 1,
      limit: limit || 20,
    };

    // Get user ID if authenticated (optional for donations search)
    let userId = null;
    if (req.headers.authorization) {
      try {
        const jwt = require('jsonwebtoken');
        const token = req.headers.authorization.split(' ')[1];
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        userId = decoded.userId;
      } catch (error) {
        // Token invalid or expired, continue without user ID
      }
    }

    const result = await SearchController.searchDonations(filters, pagination, userId);

    res.json({
      message: "Donations search completed successfully",
      donations: result.donations,
      pagination: result.pagination,
    });
  } catch (error) {
    console.error("Search donations error:", error);
    res.status(500).json({
      message: "Failed to search donations",
      error: error.message,
    });
  }
});

/**
 * Search requests
 * @route GET /api/search/requests
 */
router.get("/requests", authenticateToken, generalRateLimit, async (req, res) => {
  try {
    const {
      query,
      status,
      category,
      location,
      startDate,
      endDate,
      minDate,
      maxDate,
      sortBy,
      sortOrder,
      page,
      limit,
    } = req.query;

    const user = await require("../models/User").findByPk(req.user.userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    const filters = {};
    if (query) filters.query = query;
    if (status) filters.status = status;
    if (category) filters.category = category;
    if (location) filters.location = location;
    if (startDate) filters.startDate = startDate;
    if (endDate) filters.endDate = endDate;
    if (minDate) filters.minDate = minDate;
    if (maxDate) filters.maxDate = maxDate;
    if (sortBy) filters.sortBy = sortBy;
    if (sortOrder) filters.sortOrder = sortOrder;

    const pagination = {
      page: page || 1,
      limit: limit || 20,
    };

    const result = await SearchController.searchRequests(
      filters,
      user,
      pagination
    );

    res.json({
      message: "Requests search completed successfully",
      requests: result.requests,
      pagination: result.pagination,
    });
  } catch (error) {
    console.error("Search requests error:", error);
    res.status(500).json({
      message: "Failed to search requests",
      error: error.message,
    });
  }
});

/**
 * Get donation filter options
 * @route GET /api/search/donations/filters
 */
router.get("/donations/filters", generalRateLimit, async (req, res) => {
  try {
    const filterOptions = await SearchController.getDonationFilterOptions();

    res.json({
      message: "Donation filter options retrieved successfully",
      filters: filterOptions,
    });
  } catch (error) {
    console.error("Get donation filter options error:", error);
    res.status(500).json({
      message: "Failed to retrieve donation filter options",
      error: error.message,
    });
  }
});

/**
 * Get request filter options
 * @route GET /api/search/requests/filters
 */
router.get(
  "/requests/filters",
  authenticateToken,
  generalRateLimit,
  async (req, res) => {
    try {
      const filterOptions = await SearchController.getRequestFilterOptions();

      res.json({
        message: "Request filter options retrieved successfully",
        filters: filterOptions,
      });
    } catch (error) {
      console.error("Get request filter options error:", error);
      res.status(500).json({
        message: "Failed to retrieve request filter options",
        error: error.message,
      });
    }
  }
);

/**
 * Get search suggestions
 * @route GET /api/search/suggestions
 */
router.get("/suggestions", generalRateLimit, async (req, res) => {
  try {
    const { q: partialTerm, type = 'all', limit = 10 } = req.query;

    if (!partialTerm || partialTerm.length < 2) {
      return res.json({
        message: "Search suggestions retrieved successfully",
        suggestions: []
      });
    }

    const result = await SearchController.getSearchSuggestions(
      partialTerm,
      type,
      parseInt(limit)
    );

    res.json({
      message: "Search suggestions retrieved successfully",
      ...result
    });
  } catch (error) {
    console.error("Get search suggestions error:", error);
    res.status(500).json({
      message: "Failed to retrieve search suggestions",
      error: error.message,
    });
  }
});

/**
 * Get user's search history
 * @route GET /api/search/history
 */
router.get("/history", authenticateToken, generalRateLimit, async (req, res) => {
  try {
    const { limit = 20 } = req.query;
    const userId = req.user.userId;

    const result = await SearchController.getUserSearchHistory(
      userId,
      parseInt(limit)
    );

    res.json({
      message: "Search history retrieved successfully",
      ...result
    });
  } catch (error) {
    console.error("Get search history error:", error);
    res.status(500).json({
      message: "Failed to retrieve search history",
      error: error.message,
    });
  }
});

/**
 * Clear user's search history
 * @route DELETE /api/search/history
 */
router.delete("/history", authenticateToken, generalRateLimit, async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await SearchController.clearUserSearchHistory(userId);

    if (result.success) {
      res.json({
        message: "Search history cleared successfully"
      });
    } else {
      res.status(500).json({
        message: "Failed to clear search history"
      });
    }
  } catch (error) {
    console.error("Clear search history error:", error);
    res.status(500).json({
      message: "Failed to clear search history",
      error: error.message,
    });
  }
});

/**
 * Get popular search terms
 * @route GET /api/search/popular
 */
router.get("/popular", generalRateLimit, async (req, res) => {
  try {
    const { limit = 10, days = 30 } = req.query;

    const result = await SearchController.getPopularSearchTerms(
      parseInt(limit),
      parseInt(days)
    );

    res.json({
      message: "Popular search terms retrieved successfully",
      ...result
    });
  } catch (error) {
    console.error("Get popular search terms error:", error);
    res.status(500).json({
      message: "Failed to retrieve popular search terms",
      error: error.message,
    });
  }
});

/**
 * Get search analytics (admin only)
 * @route GET /api/search/analytics
 */
router.get("/analytics", authenticateToken, generalRateLimit, async (req, res) => {
  try {
    const user = await require("../models/User").findByPk(req.user.userId);
    if (!user || user.role !== 'admin') {
      return res.status(403).json({ 
        message: "Access denied. Admin privileges required." 
      });
    }

    const { days = 30 } = req.query;

    const analytics = await SearchController.getSearchAnalytics(parseInt(days));

    res.json({
      message: "Search analytics retrieved successfully",
      analytics
    });
  } catch (error) {
    console.error("Get search analytics error:", error);
    res.status(500).json({
      message: "Failed to retrieve search analytics",
      error: error.message,
    });
  }
});

module.exports = router;
