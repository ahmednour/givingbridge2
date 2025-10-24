const { Op } = require("sequelize");
const Rating = require("../models/Rating");
const Request = require("../models/Request");
const User = require("../models/User");

class RatingController {
  /**
   * Create a new rating
   */
  static async createRating(data, userId) {
    const { requestId, rating, feedback } = data;

    // Verify request exists and is completed
    const request = await Request.findByPk(requestId);
    if (!request) {
      throw new Error("Request not found");
    }

    if (request.status !== "completed") {
      throw new Error("Can only rate completed requests");
    }

    // Determine who is rating (donor or receiver)
    let ratedBy;
    if (request.donorId === userId) {
      ratedBy = "donor";
    } else if (request.receiverId === userId) {
      ratedBy = "receiver";
    } else {
      throw new Error("You can only rate requests you are involved in");
    }

    // Check if rating already exists
    const existingRating = await Rating.findOne({
      where: { requestId, ratedBy },
    });

    if (existingRating) {
      throw new Error("You have already rated this request");
    }

    // Create rating
    return await Rating.create({
      requestId,
      donorId: request.donorId,
      receiverId: request.receiverId,
      ratedBy,
      rating,
      feedback: feedback || null,
    });
  }

  /**
   * Get rating by request ID
   */
  static async getRatingByRequest(requestId) {
    return await Rating.findOne({
      where: { requestId },
    });
  }

  /**
   * Get ratings for a donor (ratings received by donor)
   */
  static async getDonorRatings(donorId) {
    return await Rating.findAll({
      where: {
        donorId,
        ratedBy: "receiver", // Ratings given by receivers to this donor
      },
      order: [["createdAt", "DESC"]],
    });
  }

  /**
   * Get ratings for a receiver (ratings received by receiver)
   */
  static async getReceiverRatings(receiverId) {
    return await Rating.findAll({
      where: {
        receiverId,
        ratedBy: "donor", // Ratings given by donors to this receiver
      },
      order: [["createdAt", "DESC"]],
    });
  }

  /**
   * Get average rating for a donor
   */
  static async getDonorAverageRating(donorId) {
    const ratings = await this.getDonorRatings(donorId);

    if (ratings.length === 0) {
      return {
        average: 0,
        count: 0,
      };
    }

    const sum = ratings.reduce((acc, r) => acc + r.rating, 0);
    const average = sum / ratings.length;

    return {
      average: parseFloat(average.toFixed(1)),
      count: ratings.length,
    };
  }

  /**
   * Get average rating for a receiver
   */
  static async getReceiverAverageRating(receiverId) {
    const ratings = await this.getReceiverRatings(receiverId);

    if (ratings.length === 0) {
      return {
        average: 0,
        count: 0,
      };
    }

    const sum = ratings.reduce((acc, r) => acc + r.rating, 0);
    const average = sum / ratings.length;

    return {
      average: parseFloat(average.toFixed(1)),
      count: ratings.length,
    };
  }

  /**
   * Update a rating
   */
  static async updateRating(requestId, userId, data) {
    const { rating: newRating, feedback } = data;

    // Find the rating
    const rating = await Rating.findOne({
      where: { requestId },
    });

    if (!rating) {
      throw new Error("Rating not found");
    }

    // Verify ownership
    const request = await Request.findByPk(requestId);
    let canUpdate = false;

    if (rating.ratedBy === "donor" && request.donorId === userId) {
      canUpdate = true;
    } else if (rating.ratedBy === "receiver" && request.receiverId === userId) {
      canUpdate = true;
    }

    if (!canUpdate) {
      throw new Error("You can only update your own ratings");
    }

    await rating.update({
      rating: newRating,
      feedback: feedback || rating.feedback,
    });

    return rating;
  }

  /**
   * Delete a rating
   */
  static async deleteRating(requestId, userId) {
    const rating = await Rating.findOne({
      where: { requestId },
    });

    if (!rating) {
      throw new Error("Rating not found");
    }

    // Verify ownership
    const request = await Request.findByPk(requestId);
    let canDelete = false;

    if (rating.ratedBy === "donor" && request.donorId === userId) {
      canDelete = true;
    } else if (rating.ratedBy === "receiver" && request.receiverId === userId) {
      canDelete = true;
    }

    if (!canDelete) {
      throw new Error("You can only delete your own ratings");
    }

    await rating.destroy();
    return { success: true, message: "Rating deleted" };
  }
}

module.exports = RatingController;
