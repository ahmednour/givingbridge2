const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/db");

/**
 * BlockedUser Model
 * Represents user blocking relationships for safety features
 */
const BlockedUser = sequelize.define(
  "BlockedUser",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
      allowNull: false,
    },
    blockerId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      comment: "User who blocked",
    },
    blockedId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      comment: "User who was blocked",
    },
    reason: {
      type: DataTypes.TEXT,
      allowNull: true,
      comment: "Optional reason for blocking",
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
    tableName: "blocked_users",
    timestamps: true,
    indexes: [
      {
        unique: true,
        fields: ["blockerId", "blockedId"],
        name: "unique_block_relationship",
      },
      {
        fields: ["blockerId"],
      },
      {
        fields: ["blockedId"],
      },
    ],
  }
);

module.exports = BlockedUser;
