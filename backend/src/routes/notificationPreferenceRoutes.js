const express = require("express");
const router = express.Router();
const notificationPreferenceController = require("../controllers/notificationPreferenceController");
const { authenticateToken } = require("./auth");

/**
 * @route   GET /api/notification-preferences
 * @desc    Get notification preferences for authenticated user
 * @access  Private
 */
router.get(
  "/",
  authenticateToken,
  notificationPreferenceController.getPreferences
);

/**
 * @route   PUT /api/notification-preferences
 * @desc    Update notification preferences
 * @access  Private
 */
router.put(
  "/",
  authenticateToken,
  notificationPreferenceController.updatePreferences
);

/**
 * @route   POST /api/notification-preferences/reset
 * @desc    Reset notification preferences to defaults
 * @access  Private
 */
router.post(
  "/reset",
  authenticateToken,
  notificationPreferenceController.resetPreferences
);

module.exports = router;
