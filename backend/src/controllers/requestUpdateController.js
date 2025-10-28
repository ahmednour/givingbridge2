const RequestUpdate = require("../models/RequestUpdate");
const Request = require("../models/Request");
const User = require("../models/User");
const {
  NotFoundError,
  ValidationError,
  ForbiddenError,
} = require("../utils/errorHandler");
const notificationService = require("../services/notificationService");

/**
 * Request Update Controller
 * Handles request milestones/updates functionality
 */
class RequestUpdateController {
  /**
   * Create a new request update
   * @param {Object} updateData - Update data
   * @param {number} requestId - Request ID
   * @param {number} userId - User ID
   * @param {string} userRole - User role
   * @returns {Promise<Object>} Created request update
   */
  static async createRequestUpdate(updateData, requestId, userId, userRole) {
    const { title, description, imageUrl, isPublic } = updateData;

    // Validate input
    if (!title || title.trim().length === 0) {
      throw new ValidationError("Title is required");
    }

    // Get the request
    const request = await Request.findByPk(requestId, {
      include: [
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
    });

    if (!request) {
      throw new NotFoundError("Request not found");
    }

    // Check permissions - only receiver can create updates for their requests
    // or admin can create updates for any request
    if (userRole !== "admin" && request.receiverId !== userId) {
      throw new ForbiddenError(
        "You can only create updates for your own requests"
      );
    }

    // Check if request is approved or completed
    if (request.status !== "approved" && request.status !== "completed") {
      throw new ValidationError(
        "Updates can only be added to approved or completed requests"
      );
    }

    // Create the update
    const requestUpdate = await RequestUpdate.create({
      requestId,
      userId,
      title,
      description: description || null,
      imageUrl: imageUrl || null,
      isPublic: isPublic !== undefined ? isPublic : true,
    });

    // Send notification to donor
    if (request.requestDonor) {
      await notificationService.sendRequestUpdate(
        request.requestDonor,
        request.receiver,
        request,
        requestUpdate
      );
    }

    return requestUpdate;
  }

  /**
   * Get request updates for a specific request
   * @param {number} requestId - Request ID
   * @param {Object} user - Current user
   * @param {Object} pagination - Pagination options
   * @returns {Promise<Object>} Request updates with metadata
   */
  static async getRequestUpdates(requestId, user, pagination = {}) {
    const { page = 1, limit = 20 } = pagination;

    // Get the request
    const request = await Request.findByPk(requestId);
    if (!request) {
      throw new NotFoundError("Request not found");
    }

    // Check permissions - donor, receiver, or admin can view updates
    if (
      user.role !== "admin" &&
      request.donorId !== user.id &&
      request.receiverId !== user.id
    ) {
      throw new ForbiddenError("Access denied");
    }

    const offset = (page - 1) * limit;

    const { rows, count } = await RequestUpdate.findAndCountAll({
      where: { requestId },
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
      updates: rows,
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
   * Get request update by ID
   * @param {number} updateId - Update ID
   * @param {Object} user - Current user
   * @returns {Promise<Object>} Request update
   */
  static async getRequestUpdateById(updateId, user) {
    const requestUpdate = await RequestUpdate.findByPk(updateId, {
      include: [
        {
          model: User,
          as: "user",
          attributes: ["id", "name", "email"],
        },
        {
          model: Request,
          as: "request",
          include: [
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
        },
      ],
    });

    if (!requestUpdate) {
      throw new NotFoundError("Request update not found");
    }

    // Check permissions - donor, receiver, or admin can view update
    if (
      user.role !== "admin" &&
      requestUpdate.request.donorId !== user.id &&
      requestUpdate.request.receiverId !== user.id
    ) {
      throw new ForbiddenError("Access denied");
    }

    // If update is not public, only creator, donor, receiver, or admin can view
    if (
      !requestUpdate.isPublic &&
      user.role !== "admin" &&
      requestUpdate.userId !== user.id &&
      requestUpdate.request.donorId !== user.id &&
      requestUpdate.request.receiverId !== user.id
    ) {
      throw new ForbiddenError("Access denied");
    }

    return requestUpdate;
  }

  /**
   * Update a request update
   * @param {number} updateId - Update ID
   * @param {Object} updateData - Update data
   * @param {number} userId - User ID
   * @param {string} userRole - User role
   * @returns {Promise<Object>} Updated request update
   */
  static async updateRequestUpdate(updateId, updateData, userId, userRole) {
    const requestUpdate = await RequestUpdate.findByPk(updateId, {
      include: [
        {
          model: Request,
          as: "request",
        },
      ],
    });

    if (!requestUpdate) {
      throw new NotFoundError("Request update not found");
    }

    // Check permissions - only creator or admin can update
    if (userRole !== "admin" && requestUpdate.userId !== userId) {
      throw new ForbiddenError("You can only update your own updates");
    }

    // Update the request update
    await requestUpdate.update(updateData);

    return requestUpdate;
  }

  /**
   * Delete a request update
   * @param {number} updateId - Update ID
   * @param {number} userId - User ID
   * @param {string} userRole - User role
   * @returns {Promise<void>}
   */
  static async deleteRequestUpdate(updateId, userId, userRole) {
    const requestUpdate = await RequestUpdate.findByPk(updateId);

    if (!requestUpdate) {
      throw new NotFoundError("Request update not found");
    }

    // Check permissions - only creator or admin can delete
    if (userRole !== "admin" && requestUpdate.userId !== userId) {
      throw new ForbiddenError("You can only delete your own updates");
    }

    await requestUpdate.destroy();
  }

  /**
   * Get all updates for a user (as receiver or donor)
   * @param {number} userId - User ID
   * @param {string} userType - User type ('donor' or 'receiver')
   * @param {Object} pagination - Pagination options
   * @returns {Promise<Object>} User updates with metadata
   */
  static async getUserUpdates(userId, userType, pagination = {}) {
    const { page = 1, limit = 20 } = pagination;

    let whereClause = {};
    if (userType === "receiver") {
      // Get updates created by this receiver
      whereClause.userId = userId;
    } else if (userType === "donor") {
      // Get updates for requests where this user is the donor
      const requests = await Request.findAll({
        where: { donorId: userId },
        attributes: ["id"],
      });
      const requestIds = requests.map((request) => request.id);
      whereClause.requestId = { [Sequelize.Op.in]: requestIds };
    } else {
      throw new ValidationError("Invalid user type");
    }

    const offset = (page - 1) * limit;

    const { rows, count } = await RequestUpdate.findAndCountAll({
      where: whereClause,
      include: [
        {
          model: User,
          as: "user",
          attributes: ["id", "name", "email"],
        },
        {
          model: Request,
          as: "request",
          include: [
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
        },
      ],
      order: [["createdAt", "DESC"]],
      limit: parseInt(limit),
      offset: parseInt(offset),
    });

    return {
      updates: rows,
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

module.exports = RequestUpdateController;
