const { Op } = require("sequelize");
const Request = require("../models/Request");
const Donation = require("../models/Donation");
const User = require("../models/User");
const {
  NotFoundError,
  ConflictError,
  ValidationError,
} = require("../utils/errorHandler");

class RequestController {
  /**
   * Get all requests with optional filters and pagination
   * @param {Object} filters - Filter options
   * @param {Object} user - Current user
   * @param {Object} pagination - Pagination options
   * @returns {Promise<Object>} Paginated requests with metadata
   */
  static async getAllRequests(filters = {}, user, pagination = {}) {
    const { donationId, status } = filters;
    const { page = 1, limit = 20 } = pagination;
    const where = {};

    if (donationId) where.donationId = donationId;
    if (status) where.status = status;

    // Filter based on user role
    if (user.role === "donor") {
      where.donorId = user.id;
    } else if (user.role === "receiver") {
      where.receiverId = user.id;
    }
    // Admin can see all requests (no additional filter)

    const offset = (page - 1) * limit;

    const { rows, count } = await Request.findAndCountAll({
      where,
      order: [["createdAt", "DESC"]],
      limit: parseInt(limit),
      offset: parseInt(offset),
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
        {
          model: User,
          as: "receiver",
          attributes: ["id", "name", "email", "phone", "location"],
        },
      ],
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
   * Get request by ID
   * @param {number} id - Request ID
   * @param {Object} user - Current user
   * @returns {Promise<Object|null>} Request or null if not found
   */
  static async getRequestById(id, user) {
    const request = await Request.findByPk(id, {
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
        {
          model: User,
          as: "receiver",
          attributes: ["id", "name", "email", "phone", "location"],
        },
      ],
    });

    if (!request) {
      throw new NotFoundError("Request not found");
    }

    // Check access permissions
    if (
      user.role !== "admin" &&
      request.donorId !== user.id &&
      request.receiverId !== user.id
    ) {
      throw new ValidationError("Access denied");
    }

    return request;
  }

  /**
   * Get requests for a specific user (as receiver)
   * @param {number} userId - User ID
   * @returns {Promise<Array>} List of user's requests
   */
  static async getRequestsByReceiver(userId) {
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
   * Get incoming requests for a donor
   * @param {number} donorId - Donor ID
   * @returns {Promise<Array>} List of incoming requests
   */
  static async getIncomingRequestsByDonor(donorId) {
    return await Request.findAll({
      where: { donorId },
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
   * Create new request
   * @param {Object} requestData - Request data
   * @param {number} receiverId - Receiver ID
   * @returns {Promise<Object>} Created request
   */
  static async createRequest(requestData, receiverId) {
    const { donationId, message } = requestData;

    // Get receiver info
    const receiver = await User.findByPk(receiverId);
    if (!receiver) {
      throw new NotFoundError("Receiver not found");
    }

    // Only receivers can make requests
    if (receiver.role !== "receiver") {
      throw new ValidationError("Only receivers can request donations");
    }

    // Check if donation exists and is available
    const donation = await Donation.findByPk(donationId);
    if (!donation) {
      throw new NotFoundError("Donation not found");
    }

    if (!donation.isAvailable) {
      throw new ConflictError("This donation is no longer available");
    }

    // Prevent requesting own donations (if user has both roles)
    if (donation.donorId === receiver.id) {
      throw new ConflictError("You cannot request your own donation");
    }

    // Check if user has already requested this donation
    const existingRequest = await Request.findOne({
      where: {
        receiverId: receiver.id,
        donationId: parseInt(donationId),
        status: {
          [Op.notIn]: ["cancelled", "declined"],
        },
      },
    });

    if (existingRequest) {
      throw new ConflictError("You have already requested this donation");
    }

    // Get donor information
    const donor = await User.findByPk(donation.donorId);
    if (!donor) {
      throw new NotFoundError("Donor not found");
    }

    return await Request.create({
      donationId: parseInt(donationId),
      donorId: donor.id,
      donorName: donor.name,
      receiverId: receiver.id,
      receiverName: receiver.name,
      receiverEmail: receiver.email,
      receiverPhone: receiver.phone || null,
      message: message || null,
      status: "pending",
    });
  }

  /**
   * Update request status
   * @param {number} id - Request ID
   * @param {Object} updateData - Update data
   * @param {Object} user - Current user
   * @returns {Promise<Object>} Updated request
   */
  static async updateRequestStatus(id, updateData, user) {
    const { status, responseMessage } = updateData;
    const request = await Request.findByPk(id);

    if (!request) {
      throw new NotFoundError("Request not found");
    }

    // Check permissions
    if (user.role === "admin") {
      // Admin can update any request
    } else if (status === "approved" || status === "declined") {
      // Only donor can approve/decline
      if (request.donorId !== user.id) {
        throw new ValidationError(
          "Only the donor can approve or decline this request"
        );
      }
    } else if (status === "completed") {
      // Both donor and receiver can mark as completed
      if (request.donorId !== user.id && request.receiverId !== user.id) {
        throw new ValidationError("Access denied");
      }
    } else if (status === "cancelled") {
      // Only receiver can cancel their own request
      if (request.receiverId !== user.id) {
        throw new ValidationError("Only the receiver can cancel this request");
      }
    }

    // Validate status transitions
    if (request.status === "completed" || request.status === "cancelled") {
      throw new ValidationError(
        "Cannot update a completed or cancelled request"
      );
    }

    if (request.status === "declined" && status !== "cancelled") {
      throw new ValidationError("Cannot update a declined request");
    }

    // Update request
    await request.update({
      status,
      responseMessage: responseMessage || null,
      respondedAt: new Date(),
    });

    // Update donation availability
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

  /**
   * Delete request
   * @param {number} id - Request ID
   * @param {Object} user - Current user
   * @returns {Promise<void>}
   */
  static async deleteRequest(id, user) {
    const request = await Request.findByPk(id);

    if (!request) {
      throw new NotFoundError("Request not found");
    }

    // Check permissions
    if (user.role !== "admin" && request.receiverId !== user.id) {
      throw new ValidationError("Access denied");
    }

    // Cannot delete approved or completed requests
    if (request.status === "approved" || request.status === "completed") {
      throw new ValidationError("Cannot delete approved or completed requests");
    }

    await request.destroy();
  }

  /**
   * Get request statistics (for admin dashboard)
   * @returns {Promise<Object>} Request statistics
   */
  static async getRequestStats() {
    const total = await Request.count();
    const pending = await Request.count({ where: { status: "pending" } });
    const approved = await Request.count({ where: { status: "approved" } });
    const declined = await Request.count({ where: { status: "declined" } });
    const completed = await Request.count({ where: { status: "completed" } });
    const cancelled = await Request.count({ where: { status: "cancelled" } });

    return {
      total,
      pending,
      approved,
      declined,
      completed,
      cancelled,
    };
  }
}

module.exports = RequestController;
