const { Op } = require("sequelize");
const Donation = require("../models/Donation");
const User = require("../models/User");
const notificationService = require("../services/notificationService");

class DonationController {
  /**
   * Get all donations with optional filters and pagination
   * @param {Object} filters - Filter options
   * @param {Object} pagination - Pagination options (page, limit)
   * @returns {Promise<Object>} Paginated list of donations with metadata
   */
  static async getAllDonations(filters = {}, pagination = {}, userRole = null) {
    const { category, location, available, startDate, endDate, approvalStatus } = filters;
    const { page = 1, limit = 20 } = pagination;

    const where = {};

    // Only show approved donations to non-admin users
    if (userRole !== "admin") {
      where.approvalStatus = "approved";
    } else if (approvalStatus) {
      // Admin can filter by approval status
      where.approvalStatus = approvalStatus;
    }

    // Basic filters
    if (category) where.category = category;
    if (location) where.location = { [Op.like]: `%${location}%` };
    if (available !== undefined) where.isAvailable = available === "true";

    // Date range filter
    if (startDate || endDate) {
      where.createdAt = {};
      if (startDate) {
        where.createdAt[Op.gte] = new Date(startDate);
      }
      if (endDate) {
        where.createdAt[Op.lte] = new Date(endDate);
      }
    }

    const offset = (page - 1) * limit;

    const { rows, count } = await Donation.findAndCountAll({
      where,
      order: [["createdAt", "DESC"]],
      limit: parseInt(limit),
      offset: parseInt(offset),
    });

    return {
      donations: rows,
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
   * Get donation by ID
   * @param {number} id - Donation ID
   * @param {string} userRole - User role (to check if admin)
   * @returns {Promise<Object|null>} Donation or null if not found
   */
  static async getDonationById(id, userRole = null) {
    const where = { id };
    
    // Only show approved donations to non-admin users
    if (userRole !== "admin") {
      where.approvalStatus = "approved";
    }
    
    return await Donation.findOne({ where });
  }

  /**
   * Get donation by ID with view count increment
   * @param {number} id - Donation ID
   * @param {string} userRole - User role (to check if admin)
   * @returns {Promise<Object|null>} Donation or null if not found
   */
  static async getDonationByIdWithViewCount(id, userRole = null) {
    const where = { id };
    
    // Only show approved donations to non-admin users
    if (userRole !== "admin") {
      where.approvalStatus = "approved";
    }
    
    const donation = await Donation.findOne({ where });
    if (donation) {
      // Increment view count
      await donation.increment("viewCount");
    }
    return donation;
  }

  /**
   * Get donations by donor ID
   * @param {number} donorId - Donor ID
   * @returns {Promise<Array>} List of donations by donor
   */
  static async getDonationsByDonor(donorId) {
    return await Donation.findAll({
      where: { donorId },
      order: [["createdAt", "DESC"]],
    });
  }

  /**
   * Create new donation
   * @param {Object} donationData - Donation data
   * @param {number} donorId - Donor ID
   * @returns {Promise<Object>} Created donation
   */
  static async createDonation(donationData, donorId) {
    const { title, description, category, condition, location, imageUrl } =
      donationData;

    // Validate donorId
    if (!donorId) {
      throw new Error("Donor ID is required");
    }

    // Get user info from database
    const user = await User.findByPk(donorId);
    if (!user) {
      throw new Error(`User not found with ID: ${donorId}. Please log in again.`);
    }

    // Create donation with pending approval status
    return await Donation.create({
      title,
      description,
      category,
      condition,
      location,
      donorId: user.id,
      donorName: user.name,
      imageUrl: imageUrl || null,
      approvalStatus: "pending", // Requires admin approval
      status: "available",
    });
  }

  /**
   * Update donation
   * @param {number} id - Donation ID
   * @param {Object} updateData - Update data
   * @param {number} userId - User ID (for ownership check)
   * @param {string} userRole - User role
   * @returns {Promise<Object>} Updated donation
   */
  static async updateDonation(id, updateData, userId, userRole) {
    const donation = await Donation.findByPk(id);
    if (!donation) {
      throw new Error("Donation not found");
    }

    // Check ownership (only donor can update their donation, or admin)
    if (donation.donorId !== userId && userRole !== "admin") {
      throw new Error("You can only update your own donations");
    }

    await donation.update(updateData);
    return donation;
  }

  /**
   * Delete donation
   * @param {number} id - Donation ID
   * @param {number} userId - User ID (for ownership check)
   * @param {string} userRole - User role
   * @returns {Promise<void>}
   */
  static async deleteDonation(id, userId, userRole) {
    const donation = await Donation.findByPk(id);
    if (!donation) {
      throw new Error("Donation not found");
    }

    // Check ownership (only donor can delete their donation, or admin)
    if (donation.donorId !== userId && userRole !== "admin") {
      throw new Error("You can only delete your own donations");
    }

    await donation.destroy();
  }

  /**
   * Send donation confirmation notification
   * @param {number} donationId - Donation ID
   * @param {number} donorId - Donor ID
   * @param {number} receiverId - Receiver ID
   * @returns {Promise<void>}
   */
  static async sendDonationConfirmation(donationId, donorId, receiverId) {
    const donation = await Donation.findByPk(donationId);
    const donor = await User.findByPk(donorId);
    const receiver = await User.findByPk(receiverId);

    if (donation && donor && receiver) {
      await notificationService.sendDonationConfirmation(
        donor,
        receiver,
        donation
      );
    }
  }

  /**
   * Get donation statistics (for admin dashboard)
   * @returns {Promise<Object>} Donation statistics
   */
  static async getDonationStats() {
    const total = await Donation.count();
    const available = await Donation.count({ where: { isAvailable: true } });
    const pending = await Donation.count({ where: { approvalStatus: "pending" } });
    const approved = await Donation.count({ where: { approvalStatus: "approved" } });
    const rejected = await Donation.count({ where: { approvalStatus: "rejected" } });

    const categories = {
      food: await Donation.count({ where: { category: "food" } }),
      clothes: await Donation.count({ where: { category: "clothes" } }),
      books: await Donation.count({ where: { category: "books" } }),
      electronics: await Donation.count({ where: { category: "electronics" } }),
      other: await Donation.count({ where: { category: "other" } }),
    };

    return {
      total,
      available,
      pending,
      approved,
      rejected,
      categories,
    };
  }

  /**
   * Approve donation (admin only)
   * @param {number} donationId - Donation ID
   * @param {number} adminId - Admin user ID
   * @returns {Promise<Object>} Updated donation
   */
  static async approveDonation(donationId, adminId) {
    const donation = await Donation.findByPk(donationId);
    
    if (!donation) {
      throw new Error("Donation not found");
    }

    if (donation.approvalStatus === "approved") {
      throw new Error("Donation is already approved");
    }

    await donation.update({
      approvalStatus: "approved",
      approvedBy: adminId,
      approvedAt: new Date(),
      rejectionReason: null, // Clear any previous rejection reason
    });

    // Notify donor about approval
    try {
      const donor = await User.findByPk(donation.donorId);
      if (donor) {
        await notificationService.sendDonationApprovalNotification(donor, donation, "approved");
      }
    } catch (error) {
      console.error("Failed to send approval notification:", error);
    }

    return donation;
  }

  /**
   * Reject donation (admin only)
   * @param {number} donationId - Donation ID
   * @param {number} adminId - Admin user ID
   * @param {string} reason - Rejection reason
   * @returns {Promise<Object>} Updated donation
   */
  static async rejectDonation(donationId, adminId, reason) {
    const donation = await Donation.findByPk(donationId);
    
    if (!donation) {
      throw new Error("Donation not found");
    }

    if (donation.approvalStatus === "rejected") {
      throw new Error("Donation is already rejected");
    }

    await donation.update({
      approvalStatus: "rejected",
      approvedBy: adminId,
      approvedAt: new Date(),
      rejectionReason: reason || "Does not meet platform guidelines",
      isAvailable: false, // Make unavailable when rejected
    });

    // Notify donor about rejection
    try {
      const donor = await User.findByPk(donation.donorId);
      if (donor) {
        await notificationService.sendDonationApprovalNotification(donor, donation, "rejected", reason);
      }
    } catch (error) {
      console.error("Failed to send rejection notification:", error);
    }

    return donation;
  }

  /**
   * Get pending donations (admin only)
   * @param {Object} pagination - Pagination options
   * @returns {Promise<Object>} Paginated list of pending donations
   */
  static async getPendingDonations(pagination = {}) {
    const { page = 1, limit = 20 } = pagination;
    const offset = (page - 1) * limit;

    const { rows, count } = await Donation.findAndCountAll({
      where: { approvalStatus: "pending" },
      order: [["createdAt", "ASC"]], // Oldest first for FIFO processing
      limit: parseInt(limit),
      offset: parseInt(offset),
      include: [
        {
          model: User,
          as: "donor",
          attributes: ["id", "name", "email", "role"],
        },
      ],
    });

    return {
      donations: rows,
      pagination: {
        total: count,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(count / limit),
        hasMore: offset + rows.length < count,
      },
    };
  }
}


module.exports = DonationController;
