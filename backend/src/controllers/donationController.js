const { Op } = require("sequelize");
const Donation = require("../models/Donation");
const User = require("../models/User");

class DonationController {
  /**
   * Get all donations with optional filters
   * @param {Object} filters - Filter options
   * @returns {Promise<Array>} List of donations
   */
  static async getAllDonations(filters = {}) {
    const { category, location, available } = filters;

    const where = {};
    if (category) where.category = category;
    if (location) where.location = { [Op.like]: `%${location}%` };
    if (available !== undefined) where.isAvailable = available === "true";

    return await Donation.findAll({
      where,
      order: [["createdAt", "DESC"]],
    });
  }

  /**
   * Get donation by ID
   * @param {number} id - Donation ID
   * @returns {Promise<Object|null>} Donation or null if not found
   */
  static async getDonationById(id) {
    return await Donation.findByPk(id);
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

    // Get user info from database
    const user = await User.findByPk(donorId);
    if (!user) {
      throw new Error("User not found");
    }

    return await Donation.create({
      title,
      description,
      category,
      condition,
      location,
      donorId: user.id,
      donorName: user.name,
      imageUrl: imageUrl || null,
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
   * Get donation statistics (for admin dashboard)
   * @returns {Promise<Object>} Donation statistics
   */
  static async getDonationStats() {
    const total = await Donation.count();
    const available = await Donation.count({ where: { isAvailable: true } });

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
      categories,
    };
  }
}

module.exports = DonationController;
