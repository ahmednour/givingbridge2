const { Op, Sequelize } = require("sequelize");
const { sequelize } = require("../config/db");
const Donation = require("../models/Donation");
const Request = require("../models/Request");
const User = require("../models/User");

/**
 * Advanced Search Service
 * Provides full-text search capabilities with ranking and advanced filtering
 */
class SearchService {
  /**
   * Initialize full-text search indexes
   * Creates MySQL full-text indexes for better search performance
   */
  static async initializeSearchIndexes() {
    try {
      // SECURITY: Using safe table names (no user input)
      // These are hardcoded table names from our schema
      const tables = [
        { name: 'donations', columns: ['title', 'description'] },
        { name: 'users', columns: ['name', 'location'] },
        { name: 'requests', columns: ['message'] }
      ];

      for (const table of tables) {
        try {
          // SECURITY: Table and column names are hardcoded, not from user input
          // Using backticks to properly escape identifiers
          const columnList = table.columns.map(col => `\`${col}\``).join(', ');
          await sequelize.query(
            `ALTER TABLE \`${table.name}\` ADD FULLTEXT(${columnList}) WITH PARSER ngram`,
            { type: Sequelize.QueryTypes.RAW }
          );
          console.log(`✅ Full-text index created for ${table.name}`);
        } catch (error) {
          // Index might already exist, which is fine
          if (error.message.includes('Duplicate key name')) {
            console.log(`ℹ️  Full-text index already exists for ${table.name}`);
          } else {
            console.warn(`⚠️  Failed to create index for ${table.name}:`, error.message);
          }
        }
      }

      console.log("✅ Full-text search indexes initialization completed");
    } catch (error) {
      console.error("❌ Error initializing search indexes:", error);
    }
  }

  /**
   * Perform full-text search on donations with ranking
   * @param {string} searchTerm - Search query
   * @param {Object} filters - Additional filters
   * @param {Object} pagination - Pagination options
   * @returns {Promise<Object>} Ranked search results
   */
  static async searchDonationsFullText(searchTerm, filters = {}, pagination = {}) {
    const { page = 1, limit = 20 } = pagination;
    const offset = (page - 1) * limit;

    let whereClause = {};
    let orderClause = [["createdAt", "DESC"]];

    // Apply additional filters
    if (filters.category) whereClause.category = filters.category;
    if (filters.condition) whereClause.condition = filters.condition;
    if (filters.location) whereClause.location = { [Op.like]: `%${filters.location}%` };
    if (filters.isAvailable !== undefined) whereClause.isAvailable = filters.isAvailable;
    if (filters.status) whereClause.status = filters.status;

    // Date range filters
    if (filters.startDate || filters.endDate) {
      const dateFilter = {};
      if (filters.startDate) dateFilter[Op.gte] = new Date(filters.startDate);
      if (filters.endDate) dateFilter[Op.lte] = new Date(filters.endDate);
      whereClause.createdAt = dateFilter;
    }

    let results;

    if (searchTerm && searchTerm.trim()) {
      // Use full-text search with ranking
      const searchQuery = searchTerm.trim().replace(/['"]/g, '');
      
      // Build the full-text search query
      const fullTextQuery = `
        SELECT d.*, 
               MATCH(d.title, d.description) AGAINST(:searchTerm IN NATURAL LANGUAGE MODE) as relevance_score,
               u.name as donorName,
               u.location as donorLocation
        FROM donations d
        LEFT JOIN users u ON d.donorId = u.id
        WHERE MATCH(d.title, d.description) AGAINST(:searchTerm IN NATURAL LANGUAGE MODE)
        ${Object.keys(whereClause).length > 0 ? 'AND' : ''}
        ${this.buildWhereClauseForRawQuery(whereClause)}
        ORDER BY relevance_score DESC, d.createdAt DESC
        LIMIT :limit OFFSET :offset
      `;

      const countQuery = `
        SELECT COUNT(*) as total
        FROM donations d
        WHERE MATCH(d.title, d.description) AGAINST(:searchTerm IN NATURAL LANGUAGE MODE)
        ${Object.keys(whereClause).length > 0 ? 'AND' : ''}
        ${this.buildWhereClauseForRawQuery(whereClause)}
      `;

      const [searchResults, countResults] = await Promise.all([
        sequelize.query(fullTextQuery, {
          replacements: { searchTerm: searchQuery, limit: parseInt(limit), offset: parseInt(offset) },
          type: Sequelize.QueryTypes.SELECT
        }),
        sequelize.query(countQuery, {
          replacements: { searchTerm: searchQuery },
          type: Sequelize.QueryTypes.SELECT
        })
      ]);

      results = {
        rows: searchResults,
        count: countResults[0].total
      };
    } else {
      // Fallback to regular search without full-text
      const { rows, count } = await Donation.findAndCountAll({
        where: whereClause,
        include: [
          {
            model: User,
            as: "donor",
            attributes: ["id", "name", "location"]
          }
        ],
        order: orderClause,
        limit: parseInt(limit),
        offset: parseInt(offset)
      });

      results = { rows, count };
    }

    return {
      donations: results.rows,
      pagination: {
        total: results.count,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(results.count / limit),
        hasMore: offset + results.rows.length < results.count,
      },
      searchTerm: searchTerm || null,
      hasFullTextSearch: !!(searchTerm && searchTerm.trim())
    };
  }

  /**
   * Perform full-text search on users
   * @param {string} searchTerm - Search query
   * @param {Object} filters - Additional filters
   * @param {Object} pagination - Pagination options
   * @returns {Promise<Object>} Ranked search results
   */
  static async searchUsersFullText(searchTerm, filters = {}, pagination = {}) {
    const { page = 1, limit = 20 } = pagination;
    const offset = (page - 1) * limit;

    let whereClause = {};
    let orderClause = [["createdAt", "DESC"]];

    // Apply additional filters
    if (filters.role) whereClause.role = filters.role;
    if (filters.isVerified !== undefined) whereClause.isVerified = filters.isVerified;
    if (filters.verificationLevel) whereClause.verificationLevel = filters.verificationLevel;

    let results;

    if (searchTerm && searchTerm.trim()) {
      // Use full-text search with ranking
      const searchQuery = searchTerm.trim().replace(/['"]/g, '');
      
      const fullTextQuery = `
        SELECT u.*, 
               MATCH(u.name, u.location) AGAINST(:searchTerm IN NATURAL LANGUAGE MODE) as relevance_score
        FROM users u
        WHERE MATCH(u.name, u.location) AGAINST(:searchTerm IN NATURAL LANGUAGE MODE)
        ${Object.keys(whereClause).length > 0 ? 'AND' : ''}
        ${this.buildWhereClauseForRawQuery(whereClause)}
        ORDER BY relevance_score DESC, u.createdAt DESC
        LIMIT :limit OFFSET :offset
      `;

      const countQuery = `
        SELECT COUNT(*) as total
        FROM users u
        WHERE MATCH(u.name, u.location) AGAINST(:searchTerm IN NATURAL LANGUAGE MODE)
        ${Object.keys(whereClause).length > 0 ? 'AND' : ''}
        ${this.buildWhereClauseForRawQuery(whereClause)}
      `;

      const [searchResults, countResults] = await Promise.all([
        sequelize.query(fullTextQuery, {
          replacements: { searchTerm: searchQuery, limit: parseInt(limit), offset: parseInt(offset) },
          type: Sequelize.QueryTypes.SELECT
        }),
        sequelize.query(countQuery, {
          replacements: { searchTerm: searchQuery },
          type: Sequelize.QueryTypes.SELECT
        })
      ]);

      results = {
        rows: searchResults,
        count: countResults[0].total
      };
    } else {
      // Fallback to regular search
      const { rows, count } = await User.findAndCountAll({
        where: whereClause,
        attributes: { exclude: ['password', 'passwordResetToken', 'emailVerificationToken'] },
        order: orderClause,
        limit: parseInt(limit),
        offset: parseInt(offset)
      });

      results = { rows, count };
    }

    return {
      users: results.rows,
      pagination: {
        total: results.count,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(results.count / limit),
        hasMore: offset + results.rows.length < results.count,
      },
      searchTerm: searchTerm || null,
      hasFullTextSearch: !!(searchTerm && searchTerm.trim())
    };
  }

  /**
   * Get search suggestions based on partial input
   * @param {string} partialTerm - Partial search term
   * @param {string} type - Type of suggestions ('donations', 'users', 'all')
   * @param {number} limit - Maximum number of suggestions
   * @returns {Promise<Object>} Search suggestions
   */
  static async getSearchSuggestions(partialTerm, type = 'all', limit = 10) {
    if (!partialTerm || partialTerm.length < 2) {
      return { suggestions: [] };
    }

    const suggestions = [];
    const searchTerm = partialTerm.trim().toLowerCase();

    try {
      if (type === 'donations' || type === 'all') {
        // Get donation title suggestions
        const donationTitles = await Donation.findAll({
          attributes: ['title'],
          where: {
            title: { [Op.like]: `%${searchTerm}%` },
            isAvailable: true
          },
          limit: Math.ceil(limit / 2),
          order: [['viewCount', 'DESC'], ['createdAt', 'DESC']]
        });

        suggestions.push(...donationTitles.map(d => ({
          text: d.title,
          type: 'donation_title',
          category: 'donations'
        })));
      }

      if (type === 'users' || type === 'all') {
        // Get user name suggestions
        const userNames = await User.findAll({
          attributes: ['name', 'location'],
          where: {
            [Op.or]: [
              { name: { [Op.like]: `%${searchTerm}%` } },
              { location: { [Op.like]: `%${searchTerm}%` } }
            ]
          },
          limit: Math.ceil(limit / 2),
          order: [['createdAt', 'DESC']]
        });

        suggestions.push(...userNames.map(u => ({
          text: u.name,
          type: 'user_name',
          category: 'users',
          location: u.location
        })));
      }

      // Remove duplicates and limit results
      const uniqueSuggestions = suggestions
        .filter((item, index, self) => 
          index === self.findIndex(t => t.text.toLowerCase() === item.text.toLowerCase())
        )
        .slice(0, limit);

      return { suggestions: uniqueSuggestions };
    } catch (error) {
      console.error('Error getting search suggestions:', error);
      return { suggestions: [] };
    }
  }

  /**
   * Log search query for analytics
   * @param {number} userId - User ID (optional)
   * @param {string} searchTerm - Search term
   * @param {string} searchType - Type of search
   * @param {number} resultsCount - Number of results returned
   * @returns {Promise<void>}
   */
  static async logSearchQuery(userId, searchTerm, searchType, resultsCount) {
    try {
      // Create search_logs table if it doesn't exist
      await sequelize.query(`
        CREATE TABLE IF NOT EXISTS search_logs (
          id INT PRIMARY KEY AUTO_INCREMENT,
          user_id INT NULL,
          search_term VARCHAR(255) NOT NULL,
          search_type VARCHAR(50) NOT NULL,
          results_count INT DEFAULT 0,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          INDEX idx_user_id (user_id),
          INDEX idx_search_term (search_term),
          INDEX idx_created_at (created_at)
        )
      `);

      // Insert search log
      await sequelize.query(`
        INSERT INTO search_logs (user_id, search_term, search_type, results_count)
        VALUES (:userId, :searchTerm, :searchType, :resultsCount)
      `, {
        replacements: {
          userId: userId || null,
          searchTerm: searchTerm.substring(0, 255), // Limit length
          searchType,
          resultsCount
        }
      });
    } catch (error) {
      console.error('Error logging search query:', error);
      // Don't throw error as this is not critical functionality
    }
  }

  /**
   * Get popular search terms
   * @param {number} limit - Number of terms to return
   * @param {number} days - Number of days to look back
   * @returns {Promise<Array>} Popular search terms
   */
  static async getPopularSearchTerms(limit = 10, days = 30) {
    try {
      const query = `
        SELECT search_term, COUNT(*) as search_count
        FROM search_logs
        WHERE created_at >= DATE_SUB(NOW(), INTERVAL :days DAY)
        AND search_term != ''
        GROUP BY search_term
        ORDER BY search_count DESC
        LIMIT :limit
      `;

      const results = await sequelize.query(query, {
        replacements: { limit: parseInt(limit), days: parseInt(days) },
        type: Sequelize.QueryTypes.SELECT
      });

      return results;
    } catch (error) {
      console.error('Error getting popular search terms:', error);
      return [];
    }
  }

  /**
   * Get user's search history
   * @param {number} userId - User ID
   * @param {number} limit - Number of terms to return
   * @returns {Promise<Array>} User's recent search terms
   */
  static async getUserSearchHistory(userId, limit = 20) {
    try {
      const query = `
        SELECT DISTINCT search_term, MAX(created_at) as last_searched
        FROM search_logs
        WHERE user_id = :userId
        AND search_term != ''
        GROUP BY search_term
        ORDER BY last_searched DESC
        LIMIT :limit
      `;

      const results = await sequelize.query(query, {
        replacements: { userId: parseInt(userId), limit: parseInt(limit) },
        type: Sequelize.QueryTypes.SELECT
      });

      return results.map(result => ({
        term: result.search_term,
        lastSearched: result.last_searched
      }));
    } catch (error) {
      console.error('Error getting user search history:', error);
      return [];
    }
  }

  /**
   * Clear user's search history
   * @param {number} userId - User ID
   * @returns {Promise<boolean>} Success status
   */
  static async clearUserSearchHistory(userId) {
    try {
      await sequelize.query(`
        DELETE FROM search_logs
        WHERE user_id = :userId
      `, {
        replacements: { userId: parseInt(userId) }
      });

      return true;
    } catch (error) {
      console.error('Error clearing user search history:', error);
      return false;
    }
  }

  /**
   * Get search analytics for admin dashboard
   * @param {number} days - Number of days to analyze
   * @returns {Promise<Object>} Search analytics data
   */
  static async getSearchAnalytics(days = 30) {
    try {
      const [totalSearches, uniqueUsers, topTerms, searchTrends] = await Promise.all([
        // Total searches
        sequelize.query(`
          SELECT COUNT(*) as total_searches
          FROM search_logs
          WHERE created_at >= DATE_SUB(NOW(), INTERVAL :days DAY)
        `, {
          replacements: { days: parseInt(days) },
          type: Sequelize.QueryTypes.SELECT
        }),

        // Unique users who searched
        sequelize.query(`
          SELECT COUNT(DISTINCT user_id) as unique_users
          FROM search_logs
          WHERE created_at >= DATE_SUB(NOW(), INTERVAL :days DAY)
          AND user_id IS NOT NULL
        `, {
          replacements: { days: parseInt(days) },
          type: Sequelize.QueryTypes.SELECT
        }),

        // Top search terms
        sequelize.query(`
          SELECT search_term, COUNT(*) as search_count
          FROM search_logs
          WHERE created_at >= DATE_SUB(NOW(), INTERVAL :days DAY)
          AND search_term != ''
          GROUP BY search_term
          ORDER BY search_count DESC
          LIMIT 10
        `, {
          replacements: { days: parseInt(days) },
          type: Sequelize.QueryTypes.SELECT
        }),

        // Search trends by day
        sequelize.query(`
          SELECT 
            DATE(created_at) as search_date,
            COUNT(*) as search_count,
            COUNT(DISTINCT user_id) as unique_users
          FROM search_logs
          WHERE created_at >= DATE_SUB(NOW(), INTERVAL :days DAY)
          GROUP BY DATE(created_at)
          ORDER BY search_date DESC
        `, {
          replacements: { days: parseInt(days) },
          type: Sequelize.QueryTypes.SELECT
        })
      ]);

      return {
        totalSearches: totalSearches[0].total_searches,
        uniqueUsers: uniqueUsers[0].unique_users,
        topTerms: topTerms,
        searchTrends: searchTrends,
        averageSearchesPerUser: uniqueUsers[0].unique_users > 0 
          ? (totalSearches[0].total_searches / uniqueUsers[0].unique_users).toFixed(2)
          : 0
      };
    } catch (error) {
      console.error('Error getting search analytics:', error);
      return {
        totalSearches: 0,
        uniqueUsers: 0,
        topTerms: [],
        searchTrends: [],
        averageSearchesPerUser: 0
      };
    }
  }

  /**
   * Build WHERE clause for raw SQL queries
   * @param {Object} whereClause - Sequelize where clause object
   * @returns {string} SQL WHERE clause string
   */
  static buildWhereClauseForRawQuery(whereClause) {
    const conditions = [];
    
    Object.keys(whereClause).forEach(key => {
      const value = whereClause[key];
      
      if (typeof value === 'string') {
        conditions.push(`d.${key} = '${value.replace(/'/g, "''")}'`);
      } else if (typeof value === 'number' || typeof value === 'boolean') {
        conditions.push(`d.${key} = ${value}`);
      } else if (value && typeof value === 'object') {
        // Handle operators like Op.like, Op.gte, etc.
        if (value[Op.like]) {
          const likeValue = value[Op.like].replace(/'/g, "''");
          conditions.push(`d.${key} LIKE '${likeValue}'`);
        }
        if (value[Op.gte]) {
          conditions.push(`d.${key} >= '${value[Op.gte].toISOString()}'`);
        }
        if (value[Op.lte]) {
          conditions.push(`d.${key} <= '${value[Op.lte].toISOString()}'`);
        }
      }
    });

    return conditions.join(' AND ');
  }
}

module.exports = SearchService;