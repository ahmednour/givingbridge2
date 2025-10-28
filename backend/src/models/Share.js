const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/db");

const Share = sequelize.define(
  "Share",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    donationId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: "donations",
        key: "id",
      },
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: "users",
        key: "id",
      },
    },
    platform: {
      type: DataTypes.ENUM("facebook", "twitter", "linkedin", "email", "other"),
      allowNull: false,
    },
  },
  {
    tableName: "shares",
    timestamps: true,
    createdAt: "createdAt",
    updatedAt: false,
    indexes: [
      {
        fields: ["donationId"],
      },
      {
        fields: ["userId"],
      },
      {
        fields: ["platform"],
      },
      {
        fields: ["createdAt"],
      },
    ],
  }
);

// Define associations in a separate function to avoid circular dependencies
Share.associate = (models) => {
  Share.belongsTo(models.Donation, {
    foreignKey: "donationId",
    as: "donation",
  });
  Share.belongsTo(models.User, {
    foreignKey: "userId",
    as: "user",
  });
};

module.exports = Share;
