const express = require("express");
const router = express.Router();
const NotificationController = require("../controllers/notificationController");
const { authenticateToken } = require("./auth");
const { asyncHandler } = require("../middleware");
const { generalLimiter } = require("../middleware/rateLimiting");

// Get all notifications for authenticated user
router.get(
  "/",
  authenticateToken,
  generalLimiter, // Apply general rate limiting
  asyncHandler(async (req, res) => {
    const { page, limit, unreadOnly } = req.query;

    const result = await NotificationController.getUserNotifications(
      req.user.userId,
      {
        page: page || 1,
        limit: limit || 20,
        unreadOnly: unreadOnly === "true",
      }
    );

    res.json({
      success: true,
      message: "Notifications retrieved successfully",
      ...result,
    });
  })
);

// Get unread notification count
router.get(
  "/unread-count",
  authenticateToken,
  generalLimiter, // Apply general rate limiting
  asyncHandler(async (req, res) => {
    const count = await NotificationController.getUnreadCount(req.user.userId);

    res.json({
      success: true,
      unreadCount: count,
    });
  })
);

// Mark notification as read
router.put(
  "/:id/read",
  authenticateToken,
  generalLimiter, // Apply general rate limiting
  asyncHandler(async (req, res) => {
    const notification = await NotificationController.markAsRead(
      req.params.id,
      req.user.userId
    );

    res.json({
      success: true,
      message: "Notification marked as read",
      notification,
    });
  })
);

// Mark all notifications as read
router.put(
  "/read-all",
  authenticateToken,
  generalLimiter, // Apply general rate limiting
  asyncHandler(async (req, res) => {
    await NotificationController.markAllAsRead(req.user.userId);

    res.json({
      success: true,
      message: "All notifications marked as read",
    });
  })
);

// Delete notification
router.delete(
  "/:id",
  authenticateToken,
  generalLimiter, // Apply general rate limiting
  asyncHandler(async (req, res) => {
    await NotificationController.deleteNotification(
      req.params.id,
      req.user.userId
    );

    res.json({
      success: true,
      message: "Notification deleted",
    });
  })
);

// Delete all notifications
router.delete(
  "/",
  authenticateToken,
  generalLimiter, // Apply general rate limiting
  asyncHandler(async (req, res) => {
    await NotificationController.deleteAllNotifications(req.user.userId);

    res.json({
      success: true,
      message: "All notifications deleted",
    });
  })
);

module.exports = router;
