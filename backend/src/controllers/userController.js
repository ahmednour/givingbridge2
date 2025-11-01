const { Op } = require("sequelize");
const bcrypt = require("bcryptjs");
const fs = require("fs");
const path = require("path");
const User = require("../models/User");
const Donation = require("../models/Donation");
const Request = require("../models/Request");
// BlockedUser and UserReport models removed for MVP simplification
const {
  NotFoundError,
  ConflictError,
  ValidationError,
} = require("../utils/errorHandler");

class UserController {
  /**
   * Get all users (admin only)
   * @param {Object} filters - Filter options
   * @returns {Promise<Array>} List of users
   */
  static async getAllUsers(filters = {}) {
    const { role, search, page = 1, limit = 10 } = filters;
    const where = {};
    const offset = (page - 1) * limit;

    if (role) where.role = role;
    if (search) {
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
   * Get user by ID
   * @param {number} id - User ID
   * @param {Object} user - Current user
   * @returns {Promise<Object|null>} User or null if not found
   */
  static async getUserById(id, user) {
    const targetUser = await User.findByPk(id, {
      attributes: { exclude: ["password"] },
    });

    if (!targetUser) {
      throw new NotFoundError("User not found");
    }

    // Check access permissions
    if (user.role !== "admin" && targetUser.id !== user.id) {
      throw new ValidationError("Access denied");
    }

    return targetUser;
  }

  /**
   * Update user profile
   * @param {number} id - User ID
   * @param {Object} updateData - Update data
   * @param {Object} user - Current user
   * @returns {Promise<Object>} Updated user
   */
  static async updateUser(id, updateData, user) {
    const targetUser = await User.findByPk(id);

    if (!targetUser) {
      throw new NotFoundError("User not found");
    }

    // Check permissions
    if (user.role !== "admin" && targetUser.id !== user.id) {
      throw new ValidationError("Access denied");
    }

    // Non-admin users cannot change their role
    if (
      user.role !== "admin" &&
      updateData.role &&
      updateData.role !== targetUser.role
    ) {
      throw new ValidationError("You cannot change your role");
    }

    // Check if email is being changed and if it's already taken
    if (updateData.email && updateData.email !== targetUser.email) {
      const existingUser = await User.findOne({
        where: { email: updateData.email },
      });
      if (existingUser) {
        throw new ConflictError("Email already exists");
      }
    }

    // Hash password if provided
    if (updateData.password) {
      updateData.password = await bcrypt.hash(updateData.password, 12);
    }

    await targetUser.update(updateData);

    // Return user without password
    const updatedUser = await User.findByPk(id, {
      attributes: { exclude: ["password"] },
    });

    return updatedUser;
  }

  /**
   * Delete user (admin only)
   * @param {number} id - User ID
   * @param {Object} user - Current user
   * @returns {Promise<void>}
   */
  static async deleteUser(id, user) {
    const targetUser = await User.findByPk(id);

    if (!targetUser) {
      throw new NotFoundError("User not found");
    }

    // Prevent self-deletion
    if (targetUser.id === user.id) {
      throw new ValidationError("You cannot delete your own account");
    }

    // Check if user has active donations or requests
    const activeDonations = await Donation.count({
      where: {
        donorId: id,
        status: { [Op.notIn]: ["completed", "cancelled"] },
      },
    });

    const activeRequests = await Request.count({
      where: {
        [Op.or]: [{ donorId: id }, { receiverId: id }],
        status: { [Op.notIn]: ["completed", "cancelled", "declined"] },
      },
    });

    if (activeDonations > 0 || activeRequests > 0) {
      throw new ConflictError(
        "Cannot delete user with active donations or requests. Please complete or cancel them first."
      );
    }

    await targetUser.destroy();
  }

  /**
   * Get user's donations
   * @param {number} userId - User ID
   * @param {Object} user - Current user
   * @returns {Promise<Array>} User's donations
   */
  static async getUserDonations(userId, user) {
    // Check access permissions
    if (user.role !== "admin" && userId !== user.id) {
      throw new ValidationError("Access denied");
    }

    return await Donation.findAll({
      where: { donorId: userId },
      order: [["createdAt", "DESC"]],
    });
  }

  /**
   * Get user's requests (as receiver)
   * @param {number} userId - User ID
   * @param {Object} user - Current user
   * @returns {Promise<Array>} User's requests
   */
  static async getUserRequests(userId, user) {
    // Check access permissions
    if (user.role !== "admin" && userId !== user.id) {
      throw new ValidationError("Access denied");
    }

    return await Request.findAll({
      where: { receiverId: userId },
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
          as: "donor",
          attributes: ["id", "name", "email", "phone", "location"],
        },
      ],
    });
  }

  /**
   * Get user's incoming requests (as donor)
   * @param {number} userId - User ID
   * @param {Object} user - Current user
   * @returns {Promise<Array>} User's incoming requests
   */
  static async getUserIncomingRequests(userId, user) {
    // Check access permissions
    if (user.role !== "admin" && userId !== user.id) {
      throw new ValidationError("Access denied");
    }

    return await Request.findAll({
      where: { donorId: userId },
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
          attributes: ["id", "name", "email", "phone", "location"],
        },
      ],
    });
  }

  /**
   * Get user statistics
   * @param {number} userId - User ID
   * @param {Object} user - Current user
   * @returns {Promise<Object>} User statistics
   */
  static async getUserStats(userId, user) {
    // Check access permissions
    if (user.role !== "admin" && userId !== user.id) {
      throw new ValidationError("Access denied");
    }

    const donationsCount = await Donation.count({ where: { donorId: userId } });
    const requestsCount = await Request.count({
      where: { receiverId: userId },
    });
    const incomingRequestsCount = await Request.count({
      where: { donorId: userId },
    });

    const completedDonations = await Donation.count({
      where: { donorId: userId, status: "completed" },
    });

    const completedRequests = await Request.count({
      where: { receiverId: userId, status: "completed" },
    });

    return {
      donations: {
        total: donationsCount,
        completed: completedDonations,
      },
      requests: {
        total: requestsCount,
        completed: completedRequests,
      },
      incomingRequests: {
        total: incomingRequestsCount,
      },
    };
  }

  /**
   * Get user dashboard data
   * @param {number} userId - User ID
   * @param {Object} user - Current user
   * @returns {Promise<Object>} Dashboard data
   */
  static async getUserDashboard(userId, user) {
    // Check access permissions
    if (user.role !== "admin" && userId !== user.id) {
      throw new ValidationError("Access denied");
    }

    const targetUser = await User.findByPk(userId, {
      attributes: { exclude: ["password"] },
    });

    if (!targetUser) {
      throw new NotFoundError("User not found");
    }

    const stats = await this.getUserStats(userId, user);

    // Get recent activity
    const recentDonations = await Donation.findAll({
      where: { donorId: userId },
      order: [["createdAt", "DESC"]],
      limit: 5,
    });

    const recentRequests = await Request.findAll({
      where: { receiverId: userId },
      order: [["createdAt", "DESC"]],
      limit: 5,
      include: [
        {
          model: Donation,
          as: "donation",
          attributes: ["id", "title", "category"],
        },
      ],
    });

    return {
      user: targetUser,
      stats,
      recentActivity: {
        donations: recentDonations,
        requests: recentRequests,
      },
    };
  }

  /**
   * Search users
   * @param {Object} searchParams - Search parameters
   * @returns {Promise<Array>} Search results
   */
  static async searchUsers(searchParams) {
    const { query, role, limit = 10 } = searchParams;
    const where = {};

    if (role) where.role = role;
    if (query) {
      where[Op.or] = [
        { name: { [Op.like]: `%${query}%` } },
        { email: { [Op.like]: `%${query}%` } },
        { location: { [Op.like]: `%${query}%` } },
      ];
    }

    return await User.findAll({
      where,
      attributes: { exclude: ["password"] },
      order: [["name", "ASC"]],
      limit: parseInt(limit),
    });
  }

  // User blocking, reporting, and verification features removed for MVP simplification

  /**
   * Upload user avatar
   * @param {Object} user - Current user
   * @param {Object} file - Uploaded file
   * @returns {Promise<Object>} Updated user with avatar URL
   */
  static async uploadAvatar(user, file) {
    if (!file) {
      throw new ValidationError("No file uploaded");
    }

    const targetUser = await User.findByPk(user.id);

    if (!targetUser) {
      throw new NotFoundError("User not found");
    }

    // Delete old avatar if exists
    if (targetUser.avatarUrl) {
      const oldAvatarPath = path.join(
        __dirname,
        "../../",
        targetUser.avatarUrl
      );
      if (fs.existsSync(oldAvatarPath)) {
        try {
          fs.unlinkSync(oldAvatarPath);
        } catch (err) {
          console.error("Error deleting old avatar:", err);
        }
      }
    }

    // Update user with new avatar URL
    const avatarUrl = `/uploads/avatars/${file.filename}`;
    await targetUser.update({ avatarUrl });

    // Return updated user without password
    const updatedUser = await User.findByPk(user.id, {
      attributes: { exclude: ["password"] },
    });

    return {
      success: true,
      message: "Avatar uploaded successfully",
      user: updatedUser,
      avatarUrl,
    };
  }

  /**
   * Delete user avatar
   * @param {Object} user - Current user
   * @returns {Promise<Object>} Updated user
   */
  static async deleteAvatar(user) {
    const targetUser = await User.findByPk(user.id);

    if (!targetUser) {
      throw new NotFoundError("User not found");
    }

    if (!targetUser.avatarUrl) {
      throw new ValidationError("No avatar to delete");
    }

    // Delete avatar file
    const avatarPath = path.join(__dirname, "../../", targetUser.avatarUrl);
    if (fs.existsSync(avatarPath)) {
      try {
        fs.unlinkSync(avatarPath);
      } catch (err) {
        console.error("Error deleting avatar:", err);
      }
    }

    // Update user to remove avatar URL
    await targetUser.update({ avatarUrl: null });

    // Return updated user without password
    const updatedUser = await User.findByPk(user.id, {
      attributes: { exclude: ["password"] },
    });

    return {
      success: true,
      message: "Avatar deleted successfully",
      user: updatedUser,
    };
  }

  // FCM token functionality removed for MVP
}

module.exports = UserController;
