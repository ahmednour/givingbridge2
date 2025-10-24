const ActivityLog = require("../models/ActivityLog");

/**
 * Activity Logger Middleware
 * Provides functions to log user activities throughout the application
 */

class ActivityLogger {
  /**
   * Log an activity
   * @param {Object} params - Activity parameters
   * @param {number} params.userId - User ID
   * @param {string} params.userName - User name
   * @param {string} params.userRole - User role (donor/receiver/admin)
   * @param {string} params.action - Action name
   * @param {string} params.actionCategory - Category (auth/donation/request/etc)
   * @param {string} params.description - Human-readable description
   * @param {string} params.entityType - Optional entity type
   * @param {number} params.entityId - Optional entity ID
   * @param {Object} params.metadata - Optional additional data
   * @param {string} params.ipAddress - Optional IP address
   * @param {string} params.userAgent - Optional user agent
   */
  static async log({
    userId,
    userName,
    userRole,
    action,
    actionCategory,
    description,
    entityType = null,
    entityId = null,
    metadata = null,
    ipAddress = null,
    userAgent = null,
  }) {
    try {
      await ActivityLog.create({
        userId,
        userName,
        userRole,
        action,
        actionCategory,
        description,
        entityType,
        entityId,
        metadata,
        ipAddress,
        userAgent,
      });
    } catch (error) {
      // Log the error but don't throw - activity logging shouldn't break the main flow
      console.error("Activity logging failed:", error);
    }
  }

  /**
   * Extract IP address and User Agent from request
   * @param {Object} req - Express request object
   * @returns {Object} - {ipAddress, userAgent}
   */
  static extractRequestInfo(req) {
    const ipAddress =
      req.headers["x-forwarded-for"]?.split(",")[0] ||
      req.connection.remoteAddress ||
      req.socket.remoteAddress ||
      null;

    const userAgent = req.headers["user-agent"] || null;

    return { ipAddress, userAgent };
  }

  /**
   * Log authentication activities
   */
  static async logAuth(user, action, description, req = null) {
    const requestInfo = req ? this.extractRequestInfo(req) : {};

    await this.log({
      userId: user.id,
      userName: user.name,
      userRole: user.role,
      action,
      actionCategory: "auth",
      description,
      ...requestInfo,
    });
  }

  /**
   * Log donation activities
   */
  static async logDonation(
    user,
    action,
    donationId,
    description,
    metadata = null,
    req = null
  ) {
    const requestInfo = req ? this.extractRequestInfo(req) : {};

    await this.log({
      userId: user.id,
      userName: user.name,
      userRole: user.role,
      action,
      actionCategory: "donation",
      description,
      entityType: "donation",
      entityId: donationId,
      metadata,
      ...requestInfo,
    });
  }

  /**
   * Log request activities
   */
  static async logRequest(
    user,
    action,
    requestId,
    description,
    metadata = null,
    req = null
  ) {
    const requestInfo = req ? this.extractRequestInfo(req) : {};

    await this.log({
      userId: user.id,
      userName: user.name,
      userRole: user.role,
      action,
      actionCategory: "request",
      description,
      entityType: "request",
      entityId: requestId,
      metadata,
      ...requestInfo,
    });
  }

  /**
   * Log message activities
   */
  static async logMessage(
    user,
    action,
    messageId,
    description,
    metadata = null,
    req = null
  ) {
    const requestInfo = req ? this.extractRequestInfo(req) : {};

    await this.log({
      userId: user.id,
      userName: user.name,
      userRole: user.role,
      action,
      actionCategory: "message",
      description,
      entityType: "message",
      entityId: messageId,
      metadata,
      ...requestInfo,
    });
  }

  /**
   * Log user management activities
   */
  static async logUser(
    user,
    action,
    targetUserId,
    description,
    metadata = null,
    req = null
  ) {
    const requestInfo = req ? this.extractRequestInfo(req) : {};

    await this.log({
      userId: user.id,
      userName: user.name,
      userRole: user.role,
      action,
      actionCategory: "user",
      description,
      entityType: "user",
      entityId: targetUserId,
      metadata,
      ...requestInfo,
    });
  }

  /**
   * Log admin activities
   */
  static async logAdmin(
    user,
    action,
    description,
    metadata = null,
    req = null
  ) {
    const requestInfo = req ? this.extractRequestInfo(req) : {};

    await this.log({
      userId: user.id,
      userName: user.name,
      userRole: user.role,
      action,
      actionCategory: "admin",
      description,
      metadata,
      ...requestInfo,
    });
  }

  /**
   * Log report activities
   */
  static async logReport(
    user,
    action,
    reportId,
    description,
    metadata = null,
    req = null
  ) {
    const requestInfo = req ? this.extractRequestInfo(req) : {};

    await this.log({
      userId: user.id,
      userName: user.name,
      userRole: user.role,
      action,
      actionCategory: "report",
      description,
      entityType: "report",
      entityId: reportId,
      metadata,
      ...requestInfo,
    });
  }
}

module.exports = ActivityLogger;
