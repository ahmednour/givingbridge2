const Share = require("../models/Share");
const Donation = require("../models/Donation");
const User = require("../models/User");
const { NotFoundError, ValidationError } = require("../utils/errorHandler");

/**
 * Share Controller
 * Handles sharing functionality for donations
 */
class ShareController {
  /**
   * Create a new share
   * @param {Object} shareData - Share data
   * @param {number} donationId - Donation ID
   * @param {number} userId - User ID
   * @returns {Promise<Object>} Created share
   */
  static async createShare(shareData, donationId, userId) {
    const { platform } = shareData;

    // Validate input
    if (!platform) {
      throw new ValidationError("Share platform is required");
    }

    // Get the donation
    const donation = await Donation.findByPk(donationId);
    if (!donation) {
      throw new NotFoundError("Donation not found");
    }

    // Check if user already shared this donation on this platform
    const existingShare = await Share.findOne({
      where: {
        donationId,
        userId,
        platform,
      },
    });

    if (existingShare) {
      // If already shared, just return the existing share
      return existingShare;
    }

    // Create the share
    const share = await Share.create({
      donationId,
      userId,
      platform,
    });

    // Increment share count on donation
    await donation.increment("shareCount");

    // Include user and donation information
    share.user = await User.findByPk(userId, {
      attributes: ["id", "name", "email"],
    });

    share.donation = donation;

    return share;
  }

  /**
   * Get shares for a specific donation
   * @param {number} donationId - Donation ID
   * @param {Object} pagination - Pagination options
   * @returns {Promise<Object>} Shares with metadata
   */
  static async getShares(donationId, pagination = {}) {
    const { page = 1, limit = 20 } = pagination;

    // Get the donation
    const donation = await Donation.findByPk(donationId);
    if (!donation) {
      throw new NotFoundError("Donation not found");
    }

    const offset = (page - 1) * limit;

    const { rows, count } = await Share.findAndCountAll({
      where: { donationId },
      include: [
        {
          model: User,
          as: "user",
          attributes: ["id", "name", "email"],
        },
      ],
      order: [["createdAt", "DESC"]],
      limit: parseInt(limit),
      offset: parseInt(offset),
    });

    return {
      shares: rows,
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
   * Get share by ID
   * @param {number} shareId - Share ID
   * @returns {Promise<Object>} Share
   */
  static async getShareById(shareId) {
    const share = await Share.findByPk(shareId, {
      include: [
        {
          model: User,
          as: "user",
          attributes: ["id", "name", "email"],
        },
        {
          model: Donation,
          as: "donation",
          attributes: ["id", "title"],
        },
      ],
    });

    if (!share) {
      throw new NotFoundError("Share not found");
    }

    return share;
  }

  /**
   * Get all shares for a user
   * @param {number} userId - User ID
   * @param {Object} pagination - Pagination options
   * @returns {Promise<Object>} User shares with metadata
   */
  static async getUserShares(userId, pagination = {}) {
    const { page = 1, limit = 20 } = pagination;

    const offset = (page - 1) * limit;

    const { rows, count } = await Share.findAndCountAll({
      where: { userId },
      include: [
        {
          model: User,
          as: "user",
          attributes: ["id", "name", "email"],
        },
        {
          model: Donation,
          as: "donation",
          attributes: ["id", "title"],
        },
      ],
      order: [["createdAt", "DESC"]],
      limit: parseInt(limit),
      offset: parseInt(offset),
    });

    return {
      shares: rows,
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
   * Get share statistics for a donation
   * @param {number} donationId - Donation ID
   * @returns {Promise<Object>} Share statistics
   */
  static async getShareStatistics(donationId) {
    // Get the donation
    const donation = await Donation.findByPk(donationId);
    if (!donation) {
      throw new NotFoundError("Donation not found");
    }

    // Get share counts by platform
    const platformShares = await Share.findAll({
      where: { donationId },
      attributes: [
        "platform",
        [Share.sequelize.fn("COUNT", Share.sequelize.col("id")), "count"],
      ],
      group: ["platform"],
      raw: true,
    });

    // Convert to object
    const platformStats = {};
    platformShares.forEach((share) => {
      platformStats[share.platform] = parseInt(share.count);
    });

    return {
      totalShares: donation.shareCount,
      platformStats,
    };
  }
}

module.exports = ShareController;
