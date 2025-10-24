const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/db");

const Notification = sequelize.define(
  "Notification",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: "users",
        key: "id",
      },
    },
    type: {
      type: DataTypes.ENUM(
        "donation_request",
        "donation_approved",
        "new_donation",
        "message",
        "reminder",
        "system",
        "celebration"
      ),
      allowNull: false,
    },
    title: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        notEmpty: true,
        len: [1, 255],
      },
    },
    message: {
      type: DataTypes.TEXT,
      allowNull: false,
      validate: {
        notEmpty: true,
        len: [1, 1000],
      },
    },
    isRead: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
    relatedId: {
      type: DataTypes.INTEGER,
      allowNull: true,
      comment: "ID of related donation, request, or message",
    },
    relatedType: {
      type: DataTypes.ENUM("donation", "request", "message", "other"),
      allowNull: true,
    },
    metadata: {
      type: DataTypes.JSON,
      allowNull: true,
      comment: "Additional data (icon, color, action URL, etc.)",
    },
  },
  {
    tableName: "notifications",
    timestamps: true,
    createdAt: "createdAt",
    updatedAt: "updatedAt",
    indexes: [
      {
        fields: ["userId"],
      },
      {
        fields: ["isRead"],
      },
      {
        fields: ["type"],
      },
      {
        fields: ["createdAt"],
      },
    ],
  }
);

module.exports = Notification;
