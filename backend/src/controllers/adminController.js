const User = require("../models/User");
const Request = require("../models/Request");
const Donation = require("../models/Donation");
const {
  ValidationError,
} = require("../utils/errorHandler");

class AdminController {
  /**
   * Get admin dashboard statistics
   * @returns {Promise<Object>} Dashboard statistics
   */
  static async getDashboardStats() {
    const totalUsers = await User.count();
    const totalDonations = await Donation.count();
    const totalRequests = await Request.count();
    const pendingRequests = await Request.count({ where: { status: "pending" } });
    const completedRequests = await Request.count({ where: { status: "completed" } });

    // Get user counts by role
    const donors = await User.count({ where: { role: "donor" } });
    const receivers = await User.count({ where: { role: "receiver" } });
    const admins = await User.count({ where: { role: "admin" } });

    // Get donation stats
    const availableDonations = await Donation.count({ where: { isAvailable: true } });
    const completedDonations = await Donation.count({ where: { status: "completed" } });

    return {
      totalUsers,
      totalDonations,
      totalRequests,
      pendingRequests,
      completedRequests,
      usersByRole: {
        donors,
        receivers,
        admins,
      },
      donationStats: {
        available: availableDonations,
        completed: completedDonations,
      },
    };
  }

  /**
   * Get all users with basic info (admin only)
   * @param {Object} filters - Filter options
   * @returns {Promise<Object>} Users list with pagination
   */
  static async getAllUsers(filters = {}) {
    const { role, search, page = 1, limit = 20 } = filters;
    const where = {};
    const offset = (page - 1) * limit;

    if (role && role !== 'all') where.role = role;
    if (search) {
      const { Op } = require("sequelize");
      where[Op.or] = [
        { name: { [Op.like]: `%${search}%` } },
        { email: { [Op.like]: `%${search}%` } },
        { location: { [Op.like]: `%${search}%` } },
      ];
    }

    const { count, rows } = await User.findAndCountAll({
      where,
      attributes: { exclude: ["password"] },
      order: [["createdAt", "DESC"]],
      limit: parseInt(limit),
      offset,
    });

    return {
      users: rows,
      pagination: {
        total: count,
        page: parseInt(page),
        limit: parseInt(limit),
        pages: Math.ceil(count / limit),
      },
    };
  }

  /**
   * Get all requests (admin only)
   * @param {Object} filters - Filter options
   * @returns {Promise<Object>} Requests list with pagination
   */
  static async getAllRequests(filters = {}) {
    const { status, page = 1, limit = 20 } = filters;
    const where = {};
    const offset = (page - 1) * limit;

    if (status && status !== 'all') where.status = status;

    const { count, rows } = await Request.findAndCountAll({
      where,
      include: [
        {
          model: Donation,
          as: "donation",
          attributes: ["id", "title", "description", "category"],
        },
        {
          model: User,
          as: "requestDonor",
          attributes: ["id", "name", "email"],
        },
        {
          model: User,
          as: "receiver",
          attributes: ["id", "name", "email"],
        },
      ],
      order: [["createdAt", "DESC"]],
      limit: parseInt(limit),
      offset,
    });

    return {
      requests: rows,
      pagination: {
        total: count,
        page: parseInt(page),
        limit: parseInt(limit),
        pages: Math.ceil(count / limit),
      },
    };
  }

  /**
   * Delete user (admin only)
   * @param {number} userId - User ID to delete
   * @param {Object} currentUser - Current admin user
   * @returns {Promise<void>}
   */
  static async deleteUser(userId, currentUser) {
    const targetUser = await User.findByPk(userId);

    if (!targetUser) {
      throw new ValidationError("User not found");
    }

    // Prevent self-deletion
    if (targetUser.id === currentUser.id) {
      throw new ValidationError("You cannot delete your own account");
    }

    // Check if user has active donations or requests
    const { Op } = require("sequelize");
    const activeDonations = await Donation.count({
      where: {
        donorId: userId,
        status: { [Op.notIn]: ["completed", "cancelled"] },
      },
    });

    const activeRequests = await Request.count({
      where: {
        [Op.or]: [{ donorId: userId }, { receiverId: userId }],
        status: { [Op.notIn]: ["completed", "cancelled", "declined"] },
      },
    });

    if (activeDonations > 0 || activeRequests > 0) {
      throw new ValidationError(
        "Cannot delete user with active donations or requests. Please complete or cancel them first."
      );
    }

    await targetUser.destroy();
  }

  /**
   * Update request status (admin only)
   * @param {number} requestId - Request ID
   * @param {string} status - New status
   * @param {Object} currentUser - Current admin user
   * @returns {Promise<Object>} Updated request
   */
  static async updateRequestStatus(requestId, status, currentUser) {
    const request = await Request.findByPk(requestId);

    if (!request) {
      throw new ValidationError("Request not found");
    }

    // Validate status
    const validStatuses = ["pending", "approved", "declined", "completed", "cancelled"];
    if (!validStatuses.includes(status)) {
      throw new ValidationError("Invalid status");
    }

    // Update request
    await request.update({
      status,
      respondedAt: new Date(),
    });

    // Update donation availability if needed
    const donation = await Donation.findByPk(request.donationId);
    if (donation) {
      if (status === "approved") {
        await donation.update({ isAvailable: false, status: "pending" });
      } else if (status === "declined" || status === "cancelled") {
        await donation.update({ isAvailable: true, status: "available" });
      } else if (status === "completed") {
        await donation.update({ status: "completed" });
      }
    }

    return request;
  }
}

module.exports = AdminController;