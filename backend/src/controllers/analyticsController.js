const { Op, fn, col, literal } = require("sequelize");
const { sequelize } = require("../config/db");
const User = require("../models/User");
const Donation = require("../models/Donation");
const Request = require("../models/Request");
const Rating = require("../models/Rating");

class AnalyticsController {
  /**
   * Get overview statistics for admin dashboard
   */
  static async getOverview() {
    const [
      totalUsers,
      totalDonations,
      totalRequests,
      completedRequests,
      donorCount,
      receiverCount,
      adminCount,
    ] = await Promise.all([
      User.count(),
      Donation.count(),
      Request.count(),
      Request.count({ where: { status: "completed" } }),
      User.count({ where: { role: "donor" } }),
      User.count({ where: { role: "receiver" } }),
      User.count({ where: { role: "admin" } }),
    ]);

    return {
      users: {
        total: totalUsers,
        donors: donorCount,
        receivers: receiverCount,
        admins: adminCount,
      },
      donations: {
        total: totalDonations,
        available: await Donation.count({ where: { isAvailable: true } }),
        completed: await Donation.count({ where: { status: "completed" } }),
      },
      requests: {
        total: totalRequests,
        pending: await Request.count({ where: { status: "pending" } }),
        approved: await Request.count({ where: { status: "approved" } }),
        completed: completedRequests,
        declined: await Request.count({ where: { status: "declined" } }),
      },
    };
  }

  /**
   * Get donation trends over time (last 30 days)
   */
  static async getDonationTrends(days = 30) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const donations = await Donation.findAll({
      attributes: [
        [fn("DATE", col("createdAt")), "date"],
        [fn("COUNT", col("id")), "count"],
      ],
      where: {
        createdAt: {
          [Op.gte]: startDate,
        },
      },
      group: [fn("DATE", col("createdAt"))],
      order: [[fn("DATE", col("createdAt")), "ASC"]],
      raw: true,
    });

    return donations;
  }

  /**
   * Get user growth trends (last 30 days)
   */
  static async getUserGrowth(days = 30) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const users = await User.findAll({
      attributes: [
        [fn("DATE", col("createdAt")), "date"],
        [fn("COUNT", col("id")), "count"],
        "role",
      ],
      where: {
        createdAt: {
          [Op.gte]: startDate,
        },
      },
      group: [fn("DATE", col("createdAt")), "role"],
      order: [[fn("DATE", col("createdAt")), "ASC"]],
      raw: true,
    });

    return users;
  }

  /**
   * Get donation category distribution
   */
  static async getCategoryDistribution() {
    const distribution = await Donation.findAll({
      attributes: ["category", [fn("COUNT", col("id")), "count"]],
      group: ["category"],
      raw: true,
    });

    return distribution;
  }

  /**
   * Get request status distribution
   */
  static async getStatusDistribution() {
    const distribution = await Request.findAll({
      attributes: ["status", [fn("COUNT", col("id")), "count"]],
      group: ["status"],
      raw: true,
    });

    return distribution;
  }

  /**
   * Get top donors (by donation count)
   */
  static async getTopDonors(limit = 10) {
    const topDonors = await Donation.findAll({
      attributes: [
        "donorId",
        "donorName",
        [fn("COUNT", col("id")), "donationCount"],
      ],
      group: ["donorId", "donorName"],
      order: [[fn("COUNT", col("id")), "DESC"]],
      limit,
      raw: true,
    });

    // Get average ratings for each donor
    const donorsWithRatings = await Promise.all(
      topDonors.map(async (donor) => {
        const ratings = await Rating.findAll({
          where: {
            donorId: donor.donorId,
            ratedBy: "receiver",
          },
          attributes: [[fn("AVG", col("rating")), "avgRating"]],
          raw: true,
        });

        return {
          ...donor,
          averageRating: ratings[0]?.avgRating
            ? parseFloat(ratings[0].avgRating).toFixed(1)
            : 0,
        };
      })
    );

    return donorsWithRatings;
  }

  /**
   * Get recent activity (donations, requests, ratings)
   */
  static async getRecentActivity(limit = 20) {
    const [recentDonations, recentRequests, recentRatings] = await Promise.all([
      Donation.findAll({
        order: [["createdAt", "DESC"]],
        limit: Math.floor(limit / 3),
        attributes: ["id", "title", "donorName", "category", "createdAt"],
        raw: true,
      }),
      Request.findAll({
        order: [["createdAt", "DESC"]],
        limit: Math.floor(limit / 3),
        attributes: ["id", "receiverName", "status", "createdAt"],
        raw: true,
      }),
      Rating.findAll({
        order: [["createdAt", "DESC"]],
        limit: Math.floor(limit / 3),
        attributes: ["id", "rating", "ratedBy", "createdAt"],
        raw: true,
      }),
    ]);

    // Combine and format
    const activity = [
      ...recentDonations.map((d) => ({
        type: "donation",
        id: d.id,
        title: d.title,
        user: d.donorName,
        category: d.category,
        timestamp: d.createdAt,
      })),
      ...recentRequests.map((r) => ({
        type: "request",
        id: r.id,
        user: r.receiverName,
        status: r.status,
        timestamp: r.createdAt,
      })),
      ...recentRatings.map((r) => ({
        type: "rating",
        id: r.id,
        rating: r.rating,
        ratedBy: r.ratedBy,
        timestamp: r.createdAt,
      })),
    ];

    // Sort by timestamp
    activity.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));

    return activity.slice(0, limit);
  }

  /**
   * Get platform statistics summary
   */
  static async getPlatformStats() {
    const overview = await this.getOverview();
    const categoryDist = await this.getCategoryDistribution();
    const statusDist = await this.getStatusDistribution();
    const topDonors = await this.getTopDonors(5);

    // Calculate success rate
    const successRate =
      overview.requests.total > 0
        ? (
            (overview.requests.completed / overview.requests.total) *
            100
          ).toFixed(1)
        : 0;

    return {
      overview,
      metrics: {
        successRate: parseFloat(successRate),
        totalDonationsValue: overview.donations.total,
        activeUsers: overview.users.donors + overview.users.receivers,
      },
      distributions: {
        categories: categoryDist,
        statuses: statusDist,
      },
      topDonors,
    };
  }
}

module.exports = AnalyticsController;
