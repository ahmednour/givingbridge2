const ActivityLog = require("../models/ActivityLog");
const { Op } = require("sequelize");

class ActivityController {
  /**
   * Get activity logs with filtering and pagination
   * Admins can see all logs, users can see only their own
   */
  static async getLogs(req, res) {
    try {
      const {
        page = 1,
        limit = 20,
        userId,
        actionCategory,
        action,
        startDate,
        endDate,
        search,
      } = req.query;

      const offset = (page - 1) * limit;
      const where = {};

      // Authorization: Users can only see their own logs, admins can see all
      if (req.user.role !== "admin") {
        where.userId = req.user.id;
      } else if (userId) {
        // Admin filtering by specific user
        where.userId = userId;
      }

      // Filter by action category
      if (actionCategory) {
        where.actionCategory = actionCategory;
      }

      // Filter by specific action
      if (action) {
        where.action = action;
      }

      // Filter by date range
      if (startDate || endDate) {
        where.createdAt = {};
        if (startDate) {
          where.createdAt[Op.gte] = new Date(startDate);
        }
        if (endDate) {
          where.createdAt[Op.lte] = new Date(endDate);
        }
      }

      // Search in description
      if (search) {
        where.description = {
          [Op.like]: `%${search}%`,
        };
      }

      const { count, rows: logs } = await ActivityLog.findAndCountAll({
        where,
        limit: parseInt(limit),
        offset: parseInt(offset),
        order: [["createdAt", "DESC"]],
        attributes: [
          "id",
          "userId",
          "userName",
          "userRole",
          "action",
          "actionCategory",
          "description",
          "entityType",
          "entityId",
          "metadata",
          "createdAt",
        ],
      });

      const totalPages = Math.ceil(count / limit);

      res.json({
        success: true,
        logs,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          totalPages,
          hasMore: page < totalPages,
        },
      });
    } catch (error) {
      console.error("Get activity logs error:", error);
      res.status(500).json({
        success: false,
        message: "Failed to fetch activity logs",
        error: error.message,
      });
    }
  }

  /**
   * Get activity statistics
   * Admin only - provides analytics about platform activity
   */
  static async getStatistics(req, res) {
    try {
      // Only admins can access statistics
      if (req.user.role !== "admin") {
        return res.status(403).json({
          success: false,
          message: "Access denied. Admin role required.",
        });
      }

      const { startDate, endDate } = req.query;
      const where = {};

      // Filter by date range if provided
      if (startDate || endDate) {
        where.createdAt = {};
        if (startDate) {
          where.createdAt[Op.gte] = new Date(startDate);
        }
        if (endDate) {
          where.createdAt[Op.lte] = new Date(endDate);
        }
      }

      // Get total count
      const totalLogs = await ActivityLog.count({ where });

      // Count by category
      const categoryStats = await ActivityLog.findAll({
        where,
        attributes: [
          "actionCategory",
          [
            ActivityLog.sequelize.fn("COUNT", ActivityLog.sequelize.col("id")),
            "count",
          ],
        ],
        group: ["actionCategory"],
        raw: true,
      });

      // Count by user role
      const roleStats = await ActivityLog.findAll({
        where,
        attributes: [
          "userRole",
          [
            ActivityLog.sequelize.fn("COUNT", ActivityLog.sequelize.col("id")),
            "count",
          ],
        ],
        group: ["userRole"],
        raw: true,
      });

      // Top 10 most active users
      const topUsers = await ActivityLog.findAll({
        where,
        attributes: [
          "userId",
          "userName",
          [
            ActivityLog.sequelize.fn("COUNT", ActivityLog.sequelize.col("id")),
            "activityCount",
          ],
        ],
        group: ["userId", "userName"],
        order: [[ActivityLog.sequelize.literal("activityCount"), "DESC"]],
        limit: 10,
        raw: true,
      });

      // Recent activity timeline (last 7 days)
      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

      const timeline = await ActivityLog.findAll({
        where: {
          ...where,
          createdAt: {
            [Op.gte]: sevenDaysAgo,
          },
        },
        attributes: [
          [
            ActivityLog.sequelize.fn(
              "DATE",
              ActivityLog.sequelize.col("created_at")
            ),
            "date",
          ],
          [
            ActivityLog.sequelize.fn("COUNT", ActivityLog.sequelize.col("id")),
            "count",
          ],
        ],
        group: [
          ActivityLog.sequelize.fn(
            "DATE",
            ActivityLog.sequelize.col("created_at")
          ),
        ],
        order: [[ActivityLog.sequelize.literal("date"), "ASC"]],
        raw: true,
      });

      res.json({
        success: true,
        statistics: {
          totalLogs,
          byCategory: categoryStats,
          byRole: roleStats,
          topUsers,
          timeline,
        },
      });
    } catch (error) {
      console.error("Get activity statistics error:", error);
      res.status(500).json({
        success: false,
        message: "Failed to fetch activity statistics",
        error: error.message,
      });
    }
  }

  /**
   * Get a single activity log by ID
   * Users can only see their own logs, admins can see all
   */
  static async getLogById(req, res) {
    try {
      const { id } = req.params;

      const log = await ActivityLog.findByPk(id);

      if (!log) {
        return res.status(404).json({
          success: false,
          message: "Activity log not found",
        });
      }

      // Authorization check
      if (req.user.role !== "admin" && log.userId !== req.user.id) {
        return res.status(403).json({
          success: false,
          message: "Access denied",
        });
      }

      res.json({
        success: true,
        log,
      });
    } catch (error) {
      console.error("Get activity log by ID error:", error);
      res.status(500).json({
        success: false,
        message: "Failed to fetch activity log",
        error: error.message,
      });
    }
  }

  /**
   * Export activity logs as CSV
   * Admin only for all logs, users can export their own
   */
  static async exportLogs(req, res) {
    try {
      const { userId, actionCategory, startDate, endDate } = req.query;
      const where = {};

      // Authorization: Users can only export their own logs
      if (req.user.role !== "admin") {
        where.userId = req.user.id;
      } else if (userId) {
        where.userId = userId;
      }

      // Apply filters
      if (actionCategory) {
        where.actionCategory = actionCategory;
      }

      if (startDate || endDate) {
        where.createdAt = {};
        if (startDate) {
          where.createdAt[Op.gte] = new Date(startDate);
        }
        if (endDate) {
          where.createdAt[Op.lte] = new Date(endDate);
        }
      }

      const logs = await ActivityLog.findAll({
        where,
        order: [["createdAt", "DESC"]],
        limit: 10000, // Limit to prevent memory issues
      });

      // Generate CSV
      const csvHeader = [
        "ID",
        "User ID",
        "User Name",
        "User Role",
        "Action",
        "Category",
        "Description",
        "Entity Type",
        "Entity ID",
        "Date/Time",
      ].join(",");

      const csvRows = logs.map((log) => {
        return [
          log.id,
          log.userId,
          `"${log.userName}"`,
          log.userRole,
          log.action,
          log.actionCategory,
          `"${log.description.replace(/"/g, '""')}"`, // Escape quotes
          log.entityType || "",
          log.entityId || "",
          log.createdAt.toISOString(),
        ].join(",");
      });

      const csv = [csvHeader, ...csvRows].join("\n");

      // Set headers for file download
      res.setHeader("Content-Type", "text/csv");
      res.setHeader(
        "Content-Disposition",
        `attachment; filename="activity_logs_${Date.now()}.csv"`
      );
      res.send(csv);
    } catch (error) {
      console.error("Export activity logs error:", error);
      res.status(500).json({
        success: false,
        message: "Failed to export activity logs",
        error: error.message,
      });
    }
  }
}

module.exports = ActivityController;
