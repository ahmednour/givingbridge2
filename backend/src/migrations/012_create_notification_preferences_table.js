"use strict";

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable("notification_preferences", {
      id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false,
      },
      userId: {
        type: Sequelize.INTEGER,
        allowNull: false,
        unique: true,
        field: "user_id",
        references: {
          model: "users",
          key: "id",
        },
        onUpdate: "CASCADE",
        onDelete: "CASCADE",
      },
      // Email Notifications
      emailEnabled: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
        field: "email_enabled",
      },
      emailNewMessage: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
        field: "email_new_message",
      },
      emailDonationRequest: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
        field: "email_donation_request",
      },
      emailRequestUpdate: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
        field: "email_request_update",
      },
      emailDonationUpdate: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
        field: "email_donation_update",
      },
      // Push Notifications
      pushEnabled: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
        field: "push_enabled",
      },
      pushNewMessage: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
        field: "push_new_message",
      },
      pushDonationRequest: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
        field: "push_donation_request",
      },
      pushRequestUpdate: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
        field: "push_request_update",
      },
      pushDonationUpdate: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
        field: "push_donation_update",
      },
      // In-App Notifications
      inAppEnabled: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
        field: "in_app_enabled",
      },
      inAppNewMessage: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
        field: "in_app_new_message",
      },
      inAppDonationRequest: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
        field: "in_app_donation_request",
      },
      inAppRequestUpdate: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
        field: "in_app_request_update",
      },
      inAppDonationUpdate: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
        field: "in_app_donation_update",
      },
      // Additional Settings
      soundEnabled: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
        field: "sound_enabled",
      },
      vibrationEnabled: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
        field: "vibration_enabled",
      },
      createdAt: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW,
        field: "created_at",
      },
      updatedAt: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW,
        field: "updated_at",
      },
    });

    // Add indexes
    await queryInterface.addIndex("notification_preferences", ["user_id"], {
      unique: true,
      name: "notification_preferences_user_id_unique",
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable("notification_preferences");
  },
};
