const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/db");

const NotificationPreference = sequelize.define(
  "NotificationPreference",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      unique: true,
      field: "user_id",
      references: {
        model: "users",
        key: "id",
      },
    },
    // Email Notifications
    emailEnabled: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
      field: "email_enabled",
    },
    emailNewMessage: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
      field: "email_new_message",
    },
    emailDonationRequest: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
      field: "email_donation_request",
    },
    emailRequestUpdate: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
      field: "email_request_update",
    },
    emailDonationUpdate: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
      field: "email_donation_update",
    },
    // Push Notifications
    pushEnabled: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
      field: "push_enabled",
    },
    pushNewMessage: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
      field: "push_new_message",
    },
    pushDonationRequest: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
      field: "push_donation_request",
    },
    pushRequestUpdate: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
      field: "push_request_update",
    },
    pushDonationUpdate: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
      field: "push_donation_update",
    },
    // In-App Notifications
    inAppEnabled: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
      field: "in_app_enabled",
    },
    inAppNewMessage: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
      field: "in_app_new_message",
    },
    inAppDonationRequest: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
      field: "in_app_donation_request",
    },
    inAppRequestUpdate: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
      field: "in_app_request_update",
    },
    inAppDonationUpdate: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
      field: "in_app_donation_update",
    },
    // Additional Settings
    soundEnabled: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
      field: "sound_enabled",
    },
    vibrationEnabled: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
      field: "vibration_enabled",
    },
  },
  {
    tableName: "notification_preferences",
    timestamps: true,
    createdAt: "created_at",
    updatedAt: "updated_at",
    indexes: [
      {
        unique: true,
        fields: ["user_id"],
      },
    ],
  }
);

// Association with User model
NotificationPreference.associate = (models) => {
  NotificationPreference.belongsTo(models.User, {
    foreignKey: "user_id",
    as: "user",
  });
};

module.exports = NotificationPreference;
