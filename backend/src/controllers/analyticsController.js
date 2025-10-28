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
            ratedUserId: donor.donorId,
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
   * Get top receivers (by request count)
   */
  static async getTopReceivers(limit = 10) {
    const topReceivers = await Request.findAll({
      attributes: [
        "receiverId",
        "receiverName",
        [fn("COUNT", col("id")), "requestCount"],
      ],
      group: ["receiverId", "receiverName"],
      order: [[fn("COUNT", col("id")), "DESC"]],
      limit,
      raw: true,
    });

    // Get average ratings for each receiver
    const receiversWithRatings = await Promise.all(
      topReceivers.map(async (receiver) => {
        const ratings = await Rating.findAll({
          where: {
            ratedUserId: receiver.receiverId,
          },
          attributes: [[fn("AVG", col("rating")), "avgRating"]],
          raw: true,
        });

        return {
          ...receiver,
          averageRating: ratings[0]?.avgRating
            ? parseFloat(ratings[0].avgRating).toFixed(1)
            : 0,
        };
      })
    );

    return receiversWithRatings;
  }

  /**
   * Get geographic distribution of donations
   */
  static async getGeographicDistribution() {
    const distribution = await Donation.findAll({
      attributes: ["location", [fn("COUNT", col("id")), "count"]],
      group: ["location"],
      order: [[fn("COUNT", col("id")), "DESC"]],
      raw: true,
    });

    return distribution;
  }

  /**
   * Get request success rate statistics
   */
  static async getRequestSuccessRate() {
    const totalRequests = await Request.count();
    const approvedRequests = await Request.count({
      where: { status: "approved" },
    });
    const completedRequests = await Request.count({
      where: { status: "completed" },
    });
    const declinedRequests = await Request.count({
      where: { status: "declined" },
    });
    const cancelledRequests = await Request.count({
      where: { status: "cancelled" },
    });
    const pendingRequests = await Request.count({
      where: { status: "pending" },
    });

    const successRate =
      totalRequests > 0
        ? ((completedRequests / totalRequests) * 100).toFixed(2)
        : 0;

    const approvalRate =
      totalRequests > 0
        ? (
            ((approvedRequests + completedRequests) / totalRequests) *
            100
          ).toFixed(2)
        : 0;

    return {
      total: totalRequests,
      approved: approvedRequests,
      completed: completedRequests,
      declined: declinedRequests,
      cancelled: cancelledRequests,
      pending: pendingRequests,
      successRate: parseFloat(successRate),
      approvalRate: parseFloat(approvalRate),
    };
  }

  /**
   * Get comprehensive donation statistics over time
   */
  static async getDonationStatisticsOverTime(days = 30) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    // Get donations grouped by date
    const donationsOverTime = await Donation.findAll({
      attributes: [
        [fn("DATE", col("createdAt")), "date"],
        [fn("COUNT", col("id")), "totalDonations"],
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

    // Get completed donations grouped by date
    const completedDonationsOverTime = await Donation.findAll({
      attributes: [
        [fn("DATE", col("updatedAt")), "date"],
        [fn("COUNT", col("id")), "completedDonations"],
      ],
      where: {
        status: "completed",
        updatedAt: {
          [Op.gte]: startDate,
        },
      },
      group: [fn("DATE", col("updatedAt"))],
      order: [[fn("DATE", col("updatedAt")), "ASC"]],
      raw: true,
    });

    // Merge the data
    const mergedData = donationsOverTime.map((donation) => {
      const completed = completedDonationsOverTime.find(
        (c) => c.date === donation.date
      );
      return {
        date: donation.date,
        totalDonations: donation.totalDonations,
        completedDonations: completed ? completed.completedDonations : 0,
      };
    });

    return mergedData;
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
    const geographicDist = await this.getGeographicDistribution();
    const requestSuccessRate = await this.getRequestSuccessRate();
    const donationTrends = await this.getDonationStatisticsOverTime(30);

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
        geographic: geographicDist,
      },
      topDonors,
      requestSuccessRate,
      donationTrends,
    };
  }
}

module.exports = AnalyticsController;
