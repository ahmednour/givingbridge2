const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/db");

const User = sequelize.define(
  "User",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        notEmpty: true,
        len: [2, 255],
      },
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
      validate: {
        isEmail: true,
      },
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        len: [6, 255],
      },
    },
    role: {
      type: DataTypes.ENUM("donor", "receiver", "admin"),
      allowNull: false,
      defaultValue: "donor",
    },
    phone: {
      type: DataTypes.STRING,
      allowNull: true,
      validate: {
        len: [0, 20],
      },
    },
    location: {
      type: DataTypes.STRING,
      allowNull: true,
      validate: {
        len: [0, 255],
      },
    },
    avatarUrl: {
      type: DataTypes.STRING,
      allowNull: true,
      validate: {
        len: [0, 500],
      },
    },
    fcmToken: {
      type: DataTypes.STRING(500),
      allowNull: true,
    },
    isEmailVerified: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
    emailVerificationToken: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    emailVerificationExpiry: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    passwordResetToken: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    passwordResetExpiry: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    // Verification fields
    isVerified: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
    verificationLevel: {
      type: DataTypes.ENUM("unverified", "basic", "verified", "premium"),
      allowNull: false,
      defaultValue: "unverified",
    },
    lastVerificationAttempt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
  },
  {
    tableName: "users",
    timestamps: true,
    createdAt: "createdAt",
    updatedAt: "updatedAt",
    indexes: [
      {
        unique: true,
        fields: ["email"],
      },
    ],
  }
);

// Define associations in a separate function to avoid circular dependencies
User.associate = (models) => {
  User.hasMany(models.Donation, { foreignKey: "donorId", as: "donations" });
  User.hasMany(models.Request, {
    foreignKey: "receiverId",
    as: "receivedRequests",
  });
  User.hasMany(models.Request, {
    foreignKey: "donorId",
    as: "donatedRequests",
  });
  User.hasMany(models.UserVerificationDocument, {
    foreignKey: "userId",
    as: "verificationDocuments",
  });
  User.hasMany(models.UserVerificationDocument, {
    foreignKey: "verifiedBy",
    as: "verifiedDocuments",
  });
  User.hasMany(models.RequestVerificationDocument, {
    foreignKey: "verifiedBy",
    as: "verifiedRequestDocuments",
  });
  
  // Additional associations
  User.hasMany(models.Message, { foreignKey: "senderId", as: "sentMessages" });
  User.hasMany(models.Message, { foreignKey: "receiverId", as: "receivedMessages" });
  User.hasMany(models.Notification, { foreignKey: "userId", as: "notifications" });
  User.hasMany(models.Rating, { foreignKey: "raterId", as: "givenRatings" });
  User.hasMany(models.Rating, { foreignKey: "ratedUserId", as: "receivedRatings" });
  User.hasMany(models.ActivityLog, { foreignKey: "userId", as: "activities" });
  User.hasOne(models.NotificationPreference, { foreignKey: "userId", as: "notificationPreferences" });
  User.hasMany(models.Comment, { foreignKey: "userId", as: "comments" });
  User.hasMany(models.Share, { foreignKey: "userId", as: "shares" });
  User.hasMany(models.RequestUpdate, { foreignKey: "userId", as: "requestUpdates" });
};

module.exports = User;
