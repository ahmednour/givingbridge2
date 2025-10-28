const Comment = require("../models/Comment");
const Donation = require("../models/Donation");
const User = require("../models/User");
const {
  NotFoundError,
  ValidationError,
  ForbiddenError,
} = require("../utils/errorHandler");

/**
 * Comment Controller
 * Handles comment functionality for donations
 */
class CommentController {
  /**
   * Create a new comment
   * @param {Object} commentData - Comment data
   * @param {number} donationId - Donation ID
   * @param {number} userId - User ID
   * @returns {Promise<Object>} Created comment
   */
  static async createComment(commentData, donationId, userId) {
    const { content, parentId } = commentData;

    // Validate input
    if (!content || content.trim().length === 0) {
      throw new ValidationError("Comment content is required");
    }

    // Get the donation
    const donation = await Donation.findByPk(donationId);
    if (!donation) {
      throw new NotFoundError("Donation not found");
    }

    // Validate parent comment if provided
    if (parentId) {
      const parentComment = await Comment.findByPk(parentId);
      if (!parentComment || parentComment.donationId !== donationId) {
        throw new ValidationError("Invalid parent comment");
      }
    }

    // Create the comment
    const comment = await Comment.create({
      donationId,
      userId,
      parentId: parentId || null,
      content,
    });

    // Increment comment count on donation
    await donation.increment("commentCount");

    // Include user information
    comment.user = await User.findByPk(userId, {
      attributes: ["id", "name", "email"],
    });

    return comment;
  }

  /**
   * Get comments for a specific donation
   * @param {number} donationId - Donation ID
   * @param {Object} pagination - Pagination options
   * @returns {Promise<Object>} Comments with metadata
   */
  static async getComments(donationId, pagination = {}) {
    const { page = 1, limit = 20 } = pagination;

    // Get the donation
    const donation = await Donation.findByPk(donationId);
    if (!donation) {
      throw new NotFoundError("Donation not found");
    }

    const offset = (page - 1) * limit;

    const { rows, count } = await Comment.findAndCountAll({
      where: {
        donationId,
        parentId: null, // Only top-level comments
      },
      include: [
        {
          model: User,
          as: "user",
          attributes: ["id", "name", "email"],
        },
        {
          model: Comment,
          as: "replies",
          include: [
            {
              model: User,
              as: "user",
              attributes: ["id", "name", "email"],
            },
          ],
          order: [["createdAt", "ASC"]],
        },
      ],
      order: [["createdAt", "DESC"]],
      limit: parseInt(limit),
      offset: parseInt(offset),
    });

    return {
      comments: rows,
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
   * Get comment by ID
   * @param {number} commentId - Comment ID
   * @returns {Promise<Object>} Comment
   */
  static async getCommentById(commentId) {
    const comment = await Comment.findByPk(commentId, {
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

    if (!comment) {
      throw new NotFoundError("Comment not found");
    }

    return comment;
  }

  /**
   * Update a comment
   * @param {number} commentId - Comment ID
   * @param {Object} updateData - Update data
   * @param {number} userId - User ID
   * @param {string} userRole - User role
   * @returns {Promise<Object>} Updated comment
   */
  static async updateComment(commentId, updateData, userId, userRole) {
    const { content } = updateData;

    const comment = await Comment.findByPk(commentId);
    if (!comment) {
      throw new NotFoundError("Comment not found");
    }

    // Check permissions - only creator or admin can update
    if (userRole !== "admin" && comment.userId !== userId) {
      throw new ForbiddenError("You can only update your own comments");
    }

    // Update the comment
    await comment.update({ content });

    return comment;
  }

  /**
   * Delete a comment
   * @param {number} commentId - Comment ID
   * @param {number} userId - User ID
   * @param {string} userRole - User role
   * @returns {Promise<void>}
   */
  static async deleteComment(commentId, userId, userRole) {
    const comment = await Comment.findByPk(commentId);
    if (!comment) {
      throw new NotFoundError("Comment not found");
    }

    // Check permissions - only creator or admin can delete
    if (userRole !== "admin" && comment.userId !== userId) {
      throw new ForbiddenError("You can only delete your own comments");
    }

    // Get the donation to decrement comment count
    const donation = await Donation.findByPk(comment.donationId);

    // Delete the comment
    await comment.destroy();

    // Decrement comment count on donation
    if (donation) {
      await donation.decrement("commentCount");
    }
  }

  /**
   * Get all comments for a user
   * @param {number} userId - User ID
   * @param {Object} pagination - Pagination options
   * @returns {Promise<Object>} User comments with metadata
   */
  static async getUserComments(userId, pagination = {}) {
    const { page = 1, limit = 20 } = pagination;

    const offset = (page - 1) * limit;

    const { rows, count } = await Comment.findAndCountAll({
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
      comments: rows,
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

module.exports = CommentController;
