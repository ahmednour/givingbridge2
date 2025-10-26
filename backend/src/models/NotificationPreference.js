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
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: "users",
        key: "id",
      },
    },
    email_notifications: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
    },
    push_notifications: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
    },
    sms_notifications: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
    in_app_notifications: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
    },
    donation_requests: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
    },
    donation_approvals: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
    },
    new_donations: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
    },
    messages: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
    },
    reminders: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
    },
    system_updates: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
    },
    weekly_summary: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
    daily_digest: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
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

// Define associations in a separate function to avoid circular dependencies
NotificationPreference.associate = (models) => {
  NotificationPreference.belongsTo(models.User, {
    foreignKey: "user_id",
    as: "user",
  });
};

module.exports = NotificationPreference;
