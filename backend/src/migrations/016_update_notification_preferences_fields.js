module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Rename user_id to userId
    await queryInterface.renameColumn(
      "notification_preferences",
      "user_id",
      "userId"
    );

    // Rename columns to match the new naming convention
    await queryInterface.renameColumn(
      "notification_preferences",
      "email_notifications",
      "emailEnabled"
    );
    await queryInterface.renameColumn(
      "notification_preferences",
      "push_notifications",
      "pushEnabled"
    );
    await queryInterface.renameColumn(
      "notification_preferences",
      "sms_notifications",
      "smsEnabled"
    );
    await queryInterface.renameColumn(
      "notification_preferences",
      "in_app_notifications",
      "inAppEnabled"
    );
    await queryInterface.renameColumn(
      "notification_preferences",
      "donation_requests",
      "emailDonationRequest"
    );
    await queryInterface.renameColumn(
      "notification_preferences",
      "donation_approvals",
      "emailRequestUpdate"
    );
    await queryInterface.renameColumn(
      "notification_preferences",
      "new_donations",
      "emailDonationUpdate"
    );
    await queryInterface.renameColumn(
      "notification_preferences",
      "messages",
      "emailNewMessage"
    );
    await queryInterface.renameColumn(
      "notification_preferences",
      "reminders",
      "remindersEnabled"
    );
    await queryInterface.renameColumn(
      "notification_preferences",
      "system_updates",
      "systemUpdatesEnabled"
    );
    await queryInterface.renameColumn(
      "notification_preferences",
      "weekly_summary",
      "weeklySummaryEnabled"
    );
    await queryInterface.renameColumn(
      "notification_preferences",
      "daily_digest",
      "dailyDigestEnabled"
    );

    // Add missing columns
    await queryInterface.addColumn(
      "notification_preferences",
      "emailDonationRequest",
      {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
      }
    );

    await queryInterface.addColumn(
      "notification_preferences",
      "emailRequestUpdate",
      {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
      }
    );

    await queryInterface.addColumn(
      "notification_preferences",
      "emailDonationUpdate",
      {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
      }
    );

    await queryInterface.addColumn(
      "notification_preferences",
      "emailNewMessage",
      {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
      }
    );

    await queryInterface.addColumn(
      "notification_preferences",
      "pushNewMessage",
      {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
      }
    );

    await queryInterface.addColumn(
      "notification_preferences",
      "pushDonationRequest",
      {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
      }
    );

    await queryInterface.addColumn(
      "notification_preferences",
      "pushRequestUpdate",
      {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
      }
    );

    await queryInterface.addColumn(
      "notification_preferences",
      "pushDonationUpdate",
      {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
      }
    );

    await queryInterface.addColumn(
      "notification_preferences",
      "inAppNewMessage",
      {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
      }
    );

    await queryInterface.addColumn(
      "notification_preferences",
      "inAppDonationRequest",
      {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
      }
    );

    await queryInterface.addColumn(
      "notification_preferences",
      "inAppRequestUpdate",
      {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
      }
    );

    await queryInterface.addColumn(
      "notification_preferences",
      "inAppDonationUpdate",
      {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
      }
    );

    await queryInterface.addColumn("notification_preferences", "soundEnabled", {
      type: Sequelize.BOOLEAN,
      allowNull: false,
      defaultValue: true,
    });

    await queryInterface.addColumn(
      "notification_preferences",
      "vibrationEnabled",
      {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
      }
    );
  },

  down: async (queryInterface, Sequelize) => {
    // Remove added columns
    await queryInterface.removeColumn(
      "notification_preferences",
      "emailDonationRequest"
    );
    await queryInterface.removeColumn(
      "notification_preferences",
      "emailRequestUpdate"
    );
    await queryInterface.removeColumn(
      "notification_preferences",
      "emailDonationUpdate"
    );
    await queryInterface.removeColumn(
      "notification_preferences",
      "emailNewMessage"
    );
    await queryInterface.removeColumn(
      "notification_preferences",
      "pushNewMessage"
    );
    await queryInterface.removeColumn(
      "notification_preferences",
      "pushDonationRequest"
    );
    await queryInterface.removeColumn(
      "notification_preferences",
      "pushRequestUpdate"
    );
    await queryInterface.removeColumn(
      "notification_preferences",
      "pushDonationUpdate"
    );
    await queryInterface.removeColumn(
      "notification_preferences",
      "inAppNewMessage"
    );
    await queryInterface.removeColumn(
      "notification_preferences",
      "inAppDonationRequest"
    );
    await queryInterface.removeColumn(
      "notification_preferences",
      "inAppRequestUpdate"
    );
    await queryInterface.removeColumn(
      "notification_preferences",
      "inAppDonationUpdate"
    );
    await queryInterface.removeColumn(
      "notification_preferences",
      "soundEnabled"
    );
    await queryInterface.removeColumn(
      "notification_preferences",
      "vibrationEnabled"
    );

    // Rename columns back to original names
    await queryInterface.renameColumn(
      "notification_preferences",
      "userId",
      "user_id"
    );
    await queryInterface.renameColumn(
      "notification_preferences",
      "emailEnabled",
      "email_notifications"
    );
    await queryInterface.renameColumn(
      "notification_preferences",
      "pushEnabled",
      "push_notifications"
    );
    await queryInterface.renameColumn(
      "notification_preferences",
      "smsEnabled",
      "sms_notifications"
    );
    await queryInterface.renameColumn(
      "notification_preferences",
      "inAppEnabled",
      "in_app_notifications"
    );
    await queryInterface.renameColumn(
      "notification_preferences",
      "remindersEnabled",
      "reminders"
    );
    await queryInterface.renameColumn(
      "notification_preferences",
      "systemUpdatesEnabled",
      "system_updates"
    );
    await queryInterface.renameColumn(
      "notification_preferences",
      "weeklySummaryEnabled",
      "weekly_summary"
    );
    await queryInterface.renameColumn(
      "notification_preferences",
      "dailyDigestEnabled",
      "daily_digest"
    );
  },
};
