const { Op } = require("sequelize");
const Notification = require("../models/Notification");

class NotificationController {
  /**
   * Get all notifications for a user with pagination
   */
  static async getUserNotifications(userId, options = {}) {
    const { page = 1, limit = 20, unreadOnly = false } = options;

    const where = { userId };
    if (unreadOnly) {
      where.isRead = false;
    }

    const offset = (page - 1) * limit;

    const { rows, count } = await Notification.findAndCountAll({
      where,
      order: [["createdAt", "DESC"]],
      limit: parseInt(limit),
      offset: parseInt(offset),
    });

    return {
      notifications: rows,
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
   * Get unread notification count for a user
   */
  static async getUnreadCount(userId) {
    return await Notification.count({
      where: {
        userId,
        isRead: false,
      },
    });
  }

  /**
   * Create a new notification
   */
  static async createNotification(data) {
    const { userId, type, title, message, relatedId, relatedType, metadata } =
      data;

    return await Notification.create({
      userId,
      type,
      title,
      message,
      relatedId,
      relatedType,
      metadata,
      isRead: false,
    });
  }

  /**
   * Mark notification as read
   */
  static async markAsRead(notificationId, userId) {
    const notification = await Notification.findByPk(notificationId);

    if (!notification) {
      throw new Error("Notification not found");
    }

    if (notification.userId !== userId) {
      throw new Error("Unauthorized to mark this notification as read");
    }

    await notification.update({ isRead: true });
    return notification;
  }

  /**
   * Mark all notifications as read for a user
   */
  static async markAllAsRead(userId) {
    await Notification.update(
      { isRead: true },
      { where: { userId, isRead: false } }
    );

    return { success: true, message: "All notifications marked as read" };
  }

  /**
   * Delete a notification
   */
  static async deleteNotification(notificationId, userId) {
    const notification = await Notification.findByPk(notificationId);

    if (!notification) {
      throw new Error("Notification not found");
    }

    if (notification.userId !== userId) {
      throw new Error("Unauthorized to delete this notification");
    }

    await notification.destroy();
    return { success: true, message: "Notification deleted" };
  }

  /**
   * Delete all notifications for a user
   */
  static async deleteAllNotifications(userId) {
    await Notification.destroy({
      where: { userId },
    });

    return { success: true, message: "All notifications deleted" };
  }

  /**
   * Create notification for donation request
   */
  static async notifyDonationRequest(
    donorId,
    receiverName,
    donationTitle,
    requestId
  ) {
    return await this.createNotification({
      userId: donorId,
      type: "donation_request",
      title: "New Donation Request",
      message: `${receiverName} requested your donation: ${donationTitle}`,
      relatedId: requestId,
      relatedType: "request",
    });
  }

  /**
   * Create notification for donation approval
   */
  static async notifyDonationApproval(
    receiverId,
    donorName,
    donationTitle,
    requestId
  ) {
    return await this.createNotification({
      userId: receiverId,
      type: "donation_approved",
      title: "Donation Approved!",
      message: `${donorName} approved your request for: ${donationTitle}`,
      relatedId: requestId,
      relatedType: "request",
    });
  }

  /**
   * Create notification for new donation
   */
  static async notifyNewDonation(userIds, donationTitle, donationId) {
    const notifications = userIds.map((userId) => ({
      userId,
      type: "new_donation",
      title: "New Donation Available",
      message: `${donationTitle} is now available`,
      relatedId: donationId,
      relatedType: "donation",
    }));

    return await Notification.bulkCreate(notifications);
  }

  /**
   * Create notification for new message
   */
  static async notifyNewMessage(userId, senderName, messageId) {
    return await this.createNotification({
      userId,
      type: "message",
      title: "New Message",
      message: `You have a new message from ${senderName}`,
      relatedId: messageId,
      relatedType: "message",
    });
  }
}

module.exports = NotificationController;
