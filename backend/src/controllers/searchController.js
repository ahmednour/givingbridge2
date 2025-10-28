const { Op } = require("sequelize");
const Donation = require("../models/Donation");
const Request = require("../models/Request");
const User = require("../models/User");
const SearchService = require("../services/searchService");

/**
 * Search Controller
 * Handles search and filtering operations across donations and requests
 */
class SearchController {
  /**
   * Search donations with advanced filters and full-text search
   * @param {Object} filters - Search filters
   * @param {Object} pagination - Pagination options
   * @param {number} userId - User ID for logging (optional)
   * @returns {Promise<Object>} Search results with pagination
   */
  static async searchDonations(filters = {}, pagination = {}, userId = null) {
    const {
      query,
      category,
      location,
      condition,
      startDate,
      endDate,
      minDate,
      maxDate,
      sortBy = "createdAt",
      sortOrder = "DESC",
      useFullText = true,
      ...otherFilters
    } = filters;

    const { page = 1, limit = 20 } = pagination;

    let result;

    // Use full-text search if query is provided and enabled
    if (query && useFullText) {
      const searchFilters = {
        category,
        location,
        condition,
        startDate: startDate || minDate,
        endDate: endDate || maxDate,
        isAvailable: true, // Only show available donations by default
        ...otherFilters
      };

      result = await SearchService.searchDonationsFullText(query, searchFilters, pagination);
      
      // Log search query for analytics
      await SearchService.logSearchQuery(userId, query, 'donations', result.donations.length);
    } else {
      // Fallback to original search method
      const where = {};

      // Text search across title and description
      if (query) {
        where[Op.or] = [
          { title: { [Op.like]: `%${query}%` } },
          { description: { [Op.like]: `%${query}%` } },
        ];
      }

      // Exact match filters
      if (category) where.category = category;
      if (condition) where.condition = condition;

      // Location search (partial match)
      if (location) where.location = { [Op.like]: `%${location}%` };

      // Date range filters
      const dateFilters = {};
      if (startDate || endDate) {
        dateFilters[Op.gte] = startDate
          ? new Date(startDate)
          : new Date("1970-01-01");
        dateFilters[Op.lte] = endDate ? new Date(endDate) : new Date();
        where.createdAt = dateFilters;
      } else if (minDate || maxDate) {
        // Alternative date range format
        dateFilters[Op.gte] = minDate
          ? new Date(minDate)
          : new Date("1970-01-01");
        dateFilters[Op.lte] = maxDate ? new Date(maxDate) : new Date();
        where.createdAt = dateFilters;
      }

      // Apply other filters
      Object.keys(otherFilters).forEach((key) => {
        if (otherFilters[key] !== undefined && otherFilters[key] !== null) {
          where[key] = otherFilters[key];
        }
      });

      const offset = (page - 1) * limit;

      const { rows, count } = await Donation.findAndCountAll({
        where,
        include: [
          {
            model: User,
            as: "donor",
            attributes: ["id", "name", "location"]
          }
        ],
        order: [[sortBy, sortOrder.toUpperCase()]],
        limit: parseInt(limit),
        offset: parseInt(offset),
      });

      result = {
        donations: rows,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          totalPages: Math.ceil(count / limit),
          hasMore: offset + rows.length < count,
        },
        searchTerm: query || null,
        hasFullTextSearch: false
      };

      // Log search query for analytics
      if (query) {
        await SearchService.logSearchQuery(userId, query, 'donations', rows.length);
      }
    }

    return result;
  }

  /**
   * Search requests with advanced filters
   * @param {Object} filters - Search filters
   * @param {Object} user - Current user
   * @param {Object} pagination - Pagination options
   * @returns {Promise<Object>} Search results with pagination
   */
  static async searchRequests(filters = {}, user, pagination = {}) {
    const {
      query,
      status,
      category,
      location,
      startDate,
      endDate,
      minDate,
      maxDate,
      sortBy = "createdAt",
      sortOrder = "DESC",
      ...otherFilters
    } = filters;

    const { page = 1, limit = 20 } = pagination;

    // Build where clause for requests
    const where = {};

    // User role-based filtering
    if (user.role === "donor") {
      where.donorId = user.id;
    } else if (user.role === "receiver") {
      where.receiverId = user.id;
    }
    // Admin can see all requests

    // Status filter
    if (status) where.status = status;

    // Date range filters
    const dateFilters = {};
    if (startDate || endDate) {
      dateFilters[Op.gte] = startDate
        ? new Date(startDate)
        : new Date("1970-01-01");
      dateFilters[Op.lte] = endDate ? new Date(endDate) : new Date();
      where.createdAt = dateFilters;
    } else if (minDate || maxDate) {
      // Alternative date range format
      dateFilters[Op.gte] = minDate
        ? new Date(minDate)
        : new Date("1970-01-01");
      dateFilters[Op.lte] = maxDate ? new Date(maxDate) : new Date();
      where.createdAt = dateFilters;
    }

    // Apply other filters
    Object.keys(otherFilters).forEach((key) => {
      if (otherFilters[key] !== undefined && otherFilters[key] !== null) {
        where[key] = otherFilters[key];
      }
    });

    // Build include clause for related models
    const include = [
      {
        model: Donation,
        as: "donation",
        attributes: [
          "id",
          "title",
          "description",
          "category",
          "condition",
          "location",
        ],
        where: {},
        required: false,
      },
      {
        model: User,
        as: "donor",
        attributes: ["id", "name", "email", "phone", "location"],
      },
      {
        model: User,
        as: "receiver",
        attributes: ["id", "name", "email", "phone", "location"],
      },
    ];

    // Add donation-related filters
    if (query) {
      include[0].where[Op.or] = [
        { title: { [Op.like]: `%${query}%` } },
        { description: { [Op.like]: `%${query}%` } },
      ];
    }

    if (category) {
      include[0].where.category = category;
    }

    if (location) {
      include[0].where.location = { [Op.like]: `%${location}%` };
    }

    const offset = (page - 1) * limit;

    const { rows, count } = await Request.findAndCountAll({
      where,
      include,
      order: [[sortBy, sortOrder.toUpperCase()]],
      limit: parseInt(limit),
      offset: parseInt(offset),
    });

    return {
      requests: rows,
      pagination: {
        total: count,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(count / limit),
        hasMore: offset + rows.length < count,
      },
    };
  }

  /**
   * Get filter options for donations
   * @returns {Promise<Object>} Available filter options
   */
  static async getDonationFilterOptions() {
    // Get unique categories
    const categories = await Donation.aggregate("category", "DISTINCT", {
      plain: false,
    });

    // Get unique conditions
    const conditions = await Donation.aggregate("condition", "DISTINCT", {
      plain: false,
    });

    // Get unique locations (limit to top 50 for performance)
    const locations = await Donation.aggregate("location", "DISTINCT", {
      plain: false,
      limit: 50,
    });

    return {
      categories: categories.map((item) => item.DISTINCT).filter(Boolean),
      conditions: conditions.map((item) => item.DISTINCT).filter(Boolean),
      locations: locations.map((item) => item.DISTINCT).filter(Boolean),
    };
  }

  /**
   * Get filter options for requests
   * @returns {Promise<Object>} Available filter options
   */
  static async getRequestFilterOptions() {
    // Get unique statuses
    const statuses = await Request.aggregate("status", "DISTINCT", {
      plain: false,
    });

    return {
      statuses: statuses.map((item) => item.DISTINCT).filter(Boolean),
    };
  }

  /**
   * Get search suggestions based on partial input
   * @param {string} partialTerm - Partial search term
   * @param {string} type - Type of suggestions
   * @param {number} limit - Maximum suggestions
   * @returns {Promise<Object>} Search suggestions
   */
  static async getSearchSuggestions(partialTerm, type = 'all', limit = 10) {
    return await SearchService.getSearchSuggestions(partialTerm, type, limit);
  }

  /**
   * Get user's search history
   * @param {number} userId - User ID
   * @param {number} limit - Maximum history items
   * @returns {Promise<Object>} User's search history
   */
  static async getUserSearchHistory(userId, limit = 20) {
    const history = await SearchService.getUserSearchHistory(userId, limit);
    return { history };
  }

  /**
   * Clear user's search history
   * @param {number} userId - User ID
   * @returns {Promise<Object>} Success status
   */
  static async clearUserSearchHistory(userId) {
    const success = await SearchService.clearUserSearchHistory(userId);
    return { success };
  }

  /**
   * Get popular search terms
   * @param {number} limit - Maximum terms to return
   * @param {number} days - Days to look back
   * @returns {Promise<Object>} Popular search terms
   */
  static async getPopularSearchTerms(limit = 10, days = 30) {
    const terms = await SearchService.getPopularSearchTerms(limit, days);
    return { popularTerms: terms };
  }

  /**
   * Get search analytics for admin dashboard
   * @param {number} days - Days to analyze
   * @returns {Promise<Object>} Search analytics
   */
  static async getSearchAnalytics(days = 30) {
    return await SearchService.getSearchAnalytics(days);
  }
}

module.exports = SearchController;
