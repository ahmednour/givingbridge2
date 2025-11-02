const { Op } = require("sequelize");
const Donation = require("../models/Donation");
const Request = require("../models/Request");
const User = require("../models/User");
// Receipt service removed for MVP simplification
const { NotFoundError, ValidationError } = require("../utils/errorHandler");

/**
 * Donation History Controller
 * Handles donation history and receipt generation
 */
class DonationHistoryController {
  /**
   * Get user's donation history
   * @param {number} userId - User ID
   * @param {string} userType - User type (donor/receiver)
   * @param {Object} filters - Filter options
   * @param {Object} pagination - Pagination options
   * @returns {Promise<Object>} Donation history with metadata
   */
  static async getDonationHistory(
    userId,
    userType,
    filters = {},
    pagination = {}
  ) {
    const { status, category, startDate, endDate, search } = filters;
    const { page = 1, limit = 20 } = pagination;

    let donations, requests, count;

    if (userType === "donor") {
      // Get donations made by the user
      const donationWhere = { donorId: userId };

      // Apply filters
      if (status) donationWhere.status = status;
      if (category) donationWhere.category = category;

      if (startDate || endDate) {
        donationWhere.createdAt = {};
        if (startDate) {
          donationWhere.createdAt[Op.gte] = new Date(startDate);
        }
        if (endDate) {
          donationWhere.createdAt[Op.lte] = new Date(endDate);
        }
      }

      if (search) {
        donationWhere[Op.or] = [
          { title: { [Op.like]: `%${search}%` } },
          { description: { [Op.like]: `%${search}%` } },
        ];
      }

      const donationResult = await Donation.findAndCountAll({
        where: donationWhere,
        order: [["createdAt", "DESC"]],
        limit: parseInt(limit),
        offset: (parseInt(page) - 1) * parseInt(limit),
        include: [
          {
            model: User,
            as: "donor",
            attributes: ["id", "name", "email", "location"],
          },
        ],
      });

      donations = donationResult.rows;
      count = donationResult.count;
    } else if (userType === "receiver") {
      // Get requests made by the user
      const requestWhere = { receiverId: userId };

      // Apply filters
      if (status) requestWhere.status = status;

      if (startDate || endDate) {
        requestWhere.createdAt = {};
        if (startDate) {
          requestWhere.createdAt[Op.gte] = new Date(startDate);
        }
        if (endDate) {
          requestWhere.createdAt[Op.lte] = new Date(endDate);
        }
      }

      const requestResult = await Request.findAndCountAll({
        where: requestWhere,
        order: [["createdAt", "DESC"]],
        limit: parseInt(limit),
        offset: (parseInt(page) - 1) * parseInt(limit),
        include: [
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
          },
          {
            model: User,
            as: "receiver",
            attributes: ["id", "name", "email", "location"],
          },
          {
            model: User,
            as: "requestDonor",
            attributes: ["id", "name", "email", "location"],
          },
        ],
      });

      requests = requestResult.rows;
      count = requestResult.count;
    } else {
      throw new ValidationError("Invalid user type");
    }

    return {
      transactions: userType === "donor" ? donations : requests,
      type: userType === "donor" ? "donations" : "requests",
      pagination: {
        total: count,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(count / parseInt(limit)),
        hasMore:
          (parseInt(page) - 1) * parseInt(limit) +
            (userType === "donor" ? donations.length : requests.length) <
          count,
      },
    };
  }

  /**
   * Get combined transaction history (donations and requests)
   * @param {number} userId - User ID
   * @param {Object} filters - Filter options
   * @param {Object} pagination - Pagination options
   * @returns {Promise<Object>} Combined transaction history
   */
  static async getCombinedTransactionHistory(
    userId,
    filters = {},
    pagination = {}
  ) {
    const { status, category, startDate, endDate, search } = filters;
    const { page = 1, limit = 20 } = pagination;

    // Get user's donations
    const donationWhere = { donorId: userId };

    if (status) donationWhere.status = status;
    if (category) donationWhere.category = category;

    if (startDate || endDate) {
      donationWhere.createdAt = {};
      if (startDate) {
        donationWhere.createdAt[Op.gte] = new Date(startDate);
      }
      if (endDate) {
        donationWhere.createdAt[Op.lte] = new Date(endDate);
      }
    }

    if (search) {
      donationWhere[Op.or] = [
        { title: { [Op.like]: `%${search}%` } },
        { description: { [Op.like]: `%${search}%` } },
      ];
    }

    const donations = await Donation.findAll({
      where: donationWhere,
      order: [["createdAt", "DESC"]],
      include: [
        {
          model: User,
          as: "donor",
          attributes: ["id", "name", "email", "location"],
        },
      ],
    });

    // Get user's requests
    const requestWhere = { receiverId: userId };

    if (status) requestWhere.status = status;

    if (startDate || endDate) {
      requestWhere.createdAt = {};
      if (startDate) {
        requestWhere.createdAt[Op.gte] = new Date(startDate);
      }
      if (endDate) {
        requestWhere.createdAt[Op.lte] = new Date(endDate);
      }
    }

    const requests = await Request.findAll({
      where: requestWhere,
      order: [["createdAt", "DESC"]],
      include: [
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
        },
        {
          model: User,
          as: "receiver",
          attributes: ["id", "name", "email", "location"],
        },
        {
          model: User,
          as: "requestDonor",
          attributes: ["id", "name", "email", "location"],
        },
      ],
    });

    // Combine and sort transactions
    const allTransactions = [
      ...donations.map((donation) => ({
        ...donation.toJSON(),
        type: "donation",
      })),
      ...requests.map((request) => ({ ...request.toJSON(), type: "request" })),
    ].sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

    // Apply pagination
    const offset = (parseInt(page) - 1) * parseInt(limit);
    const paginatedTransactions = allTransactions.slice(
      offset,
      offset + parseInt(limit)
    );
    const total = allTransactions.length;

    return {
      transactions: paginatedTransactions,
      pagination: {
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(total / parseInt(limit)),
        hasMore: offset + paginatedTransactions.length < total,
      },
    };
  }

  /**
   * Generate donation receipt
   * @param {number} donationId - Donation ID
   * @param {number} userId - User ID
   * @param {string} userType - User type (donor/receiver)
   * @returns {Promise<Object>} Receipt information
   */
  static async generateDonationReceipt(donationId, userId, userType) {
    // Get donation
    const donation = await Donation.findByPk(donationId, {
      include: [
        {
          model: User,
          as: "donor",
          attributes: ["id", "name", "email", "location"],
        },
      ],
    });

    if (!donation) {
      throw new NotFoundError("Donation not found");
    }

    // Verify user has access to this donation
    if (userType === "donor" && donation.donorId !== userId) {
      throw new ValidationError("Access denied");
    }

    // Get related request (if any)
    const request = await Request.findOne({
      where: { donationId: donationId },
      include: [
        {
          model: User,
          as: "receiver",
          attributes: ["id", "name", "email", "location"],
        },
      ],
    });

    // Get donor and receiver
    const donor = donation.donor;
    const receiver = request ? request.receiver : null;

    // Receipt generation removed for MVP simplification
    return {
      success: true,
      message: "Transaction completed successfully",
      donation,
      request,
      donor,
      receiver,
    };
  }

  /**
   * Generate transaction history report
   * @param {number} userId - User ID
   * @param {string} format - Export format (pdf, csv)
   * @param {Object} filters - Filter options
   * @returns {Promise<Object>} Report information
   */
  static async generateTransactionHistoryReport(
    userId,
    format = "pdf",
    filters = {}
  ) {
    // Get user
    const user = await User.findByPk(userId);
    if (!user) {
      throw new NotFoundError("User not found");
    }

    // Get combined transaction history
    const history = await this.getCombinedTransactionHistory(userId, filters);

    // Report generation removed for MVP simplification
    return {
      success: true,
      message: "Transaction history retrieved successfully",
      history,
    };
  }

  /**
   * Get receipt by ID - Removed for MVP simplification
   * @param {string} receiptId - Receipt ID
   * @returns {Promise<Buffer>} Receipt file buffer
   */
  static async getReceipt(receiptId) {
    throw new NotFoundError("Receipt generation feature is not available in this version");
  }
}

module.exports = DonationHistoryController;
