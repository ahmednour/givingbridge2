const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/db");

/**
 * UserReport Model
 * Represents user reports for moderation and safety
 */
const UserReport = sequelize.define(
  "UserReport",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
      allowNull: false,
    },
    reporterId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      comment: "User who submitted the report",
    },
    reportedId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      comment: "User who was reported",
    },
    reason: {
      type: DataTypes.ENUM(
        "spam",
        "harassment",
        "inappropriate_content",
        "scam",
        "fake_profile",
        "other"
      ),
      allowNull: false,
      comment: "Category of the report",
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: false,
      comment: "Detailed description of the issue",
    },
    status: {
      type: DataTypes.ENUM("pending", "reviewed", "resolved", "dismissed"),
      allowNull: false,
      defaultValue: "pending",
      comment: "Status of the report",
    },
    reviewedBy: {
      type: DataTypes.INTEGER,
      allowNull: true,
      comment: "Admin who reviewed the report",
    },
    reviewNotes: {
      type: DataTypes.TEXT,
      allowNull: true,
      comment: "Admin notes on the report",
    },
    reviewedAt: {
      type: DataTypes.DATE,
      allowNull: true,
      comment: "When the report was reviewed",
    },
    createdAt: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },
    updatedAt: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    tableName: "user_reports",
    timestamps: true,
    indexes: [
      {
        fields: ["reporterId"],
      },
      {
        fields: ["reportedId"],
      },
      {
        fields: ["status"],
      },
      {
        fields: ["createdAt"],
      },
    ],
  }
);

module.exports = UserReport;
