const NotificationPreference = require("../models/NotificationPreference");

/**
 * Get notification preferences for the authenticated user
 * @route GET /api/notification-preferences
 */
const getPreferences = async (req, res) => {
  try {
    const userId = req.user.id;

    let preferences = await NotificationPreference.findOne({
      where: { userId },
    });

    // Create default preferences if none exist
    if (!preferences) {
      preferences = await NotificationPreference.create({
        userId,
        emailEnabled: true,
        emailNewMessage: true,
        emailDonationRequest: true,
        emailRequestUpdate: true,
        emailDonationUpdate: true,
        pushEnabled: true,
        pushNewMessage: true,
        pushDonationRequest: true,
        pushRequestUpdate: true,
        pushDonationUpdate: true,
        inAppEnabled: true,
        inAppNewMessage: true,
        inAppDonationRequest: true,
        inAppRequestUpdate: true,
        inAppDonationUpdate: true,
        soundEnabled: true,
        vibrationEnabled: true,
      });
    }

    res.json({
      success: true,
      data: preferences,
    });
  } catch (error) {
    console.error("Error fetching notification preferences:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch notification preferences",
    });
  }
};

/**
 * Update notification preferences for the authenticated user
 * @route PUT /api/notification-preferences
 */
const updatePreferences = async (req, res) => {
  try {
    const userId = req.user.id;
    const updates = req.body;

    // Validate boolean fields
    const validFields = [
      "emailEnabled",
      "emailNewMessage",
      "emailDonationRequest",
      "emailRequestUpdate",
      "emailDonationUpdate",
      "pushEnabled",
      "pushNewMessage",
      "pushDonationRequest",
      "pushRequestUpdate",
      "pushDonationUpdate",
      "inAppEnabled",
      "inAppNewMessage",
      "inAppDonationRequest",
      "inAppRequestUpdate",
      "inAppDonationUpdate",
      "soundEnabled",
      "vibrationEnabled",
    ];

    const filteredUpdates = {};
    Object.keys(updates).forEach((key) => {
      if (validFields.includes(key) && typeof updates[key] === "boolean") {
        filteredUpdates[key] = updates[key];
      }
    });

    if (Object.keys(filteredUpdates).length === 0) {
      return res.status(400).json({
        success: false,
        message: "No valid fields to update",
      });
    }

    // Find or create preferences
    let [preferences, created] = await NotificationPreference.findOrCreate({
      where: { userId },
      defaults: {
        userId,
        emailEnabled: true,
        emailNewMessage: true,
        emailDonationRequest: true,
        emailRequestUpdate: true,
        emailDonationUpdate: true,
        pushEnabled: true,
        pushNewMessage: true,
        pushDonationRequest: true,
        pushRequestUpdate: true,
        pushDonationUpdate: true,
        inAppEnabled: true,
        inAppNewMessage: true,
        inAppDonationRequest: true,
        inAppRequestUpdate: true,
        inAppDonationUpdate: true,
        soundEnabled: true,
        vibrationEnabled: true,
      },
    });

    // Update preferences
    await preferences.update(filteredUpdates);

    res.json({
      success: true,
      data: preferences,
      message: "Notification preferences updated successfully",
    });
  } catch (error) {
    console.error("Error updating notification preferences:", error);
    res.status(500).json({
      success: false,
      message: "Failed to update notification preferences",
    });
  }
};

/**
 * Reset notification preferences to defaults
 * @route POST /api/notification-preferences/reset
 */
const resetPreferences = async (req, res) => {
  try {
    const userId = req.user.id;

    const defaults = {
      emailEnabled: true,
      emailNewMessage: true,
      emailDonationRequest: true,
      emailRequestUpdate: true,
      emailDonationUpdate: true,
      pushEnabled: true,
      pushNewMessage: true,
      pushDonationRequest: true,
      pushRequestUpdate: true,
      pushDonationUpdate: true,
      inAppEnabled: true,
      inAppNewMessage: true,
      inAppDonationRequest: true,
      inAppRequestUpdate: true,
      inAppDonationUpdate: true,
      soundEnabled: true,
      vibrationEnabled: true,
    };

    let [preferences] = await NotificationPreference.findOrCreate({
      where: { userId },
      defaults: { userId, ...defaults },
    });

    await preferences.update(defaults);

    res.json({
      success: true,
      data: preferences,
      message: "Notification preferences reset to defaults",
    });
  } catch (error) {
    console.error("Error resetting notification preferences:", error);
    res.status(500).json({
      success: false,
      message: "Failed to reset notification preferences",
    });
  }
};

module.exports = {
  getPreferences,
  updatePreferences,
  resetPreferences,
};
