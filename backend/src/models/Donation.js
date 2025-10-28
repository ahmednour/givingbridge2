const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/db");

const Donation = sequelize.define(
  "Donation",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    title: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        notEmpty: true,
        len: [3, 255],
      },
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: false,
      validate: {
        notEmpty: true,
        len: [10, 5000],
      },
    },
    category: {
      type: DataTypes.ENUM("food", "clothes", "books", "electronics", "other"),
      allowNull: false,
    },
    condition: {
      type: DataTypes.ENUM("new", "like-new", "good", "fair"),
      allowNull: false,
      defaultValue: "good",
    },
    location: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        notEmpty: true,
        len: [2, 255],
      },
    },
    donorId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: "users",
        key: "id",
      },
    },
    donorName: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    imageUrl: {
      type: DataTypes.STRING,
      allowNull: true,
      validate: {
        len: [0, 500],
      },
    },
    isAvailable: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
    },
    status: {
      type: DataTypes.ENUM("available", "pending", "completed", "cancelled"),
      allowNull: false,
      defaultValue: "available",
    },
    // Social proof fields
    shareCount: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
    },
    commentCount: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
    },
    viewCount: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
    },
  },
  {
    tableName: "donations",
    timestamps: true,
    createdAt: "createdAt",
    updatedAt: "updatedAt",
    indexes: [
      {
        fields: ["donorId"],
      },
      {
        fields: ["category"],
      },
      {
        fields: ["isAvailable"],
      },
      {
        fields: ["status"],
      },
    ],
  }
);

// Define associations in a separate function to avoid circular dependencies
Donation.associate = (models) => {
  Donation.belongsTo(models.User, { foreignKey: "donorId", as: "donor" });
  Donation.hasMany(models.Request, {
    foreignKey: "donationId",
    as: "requests",
  });
  Donation.hasMany(models.Comment, {
    foreignKey: "donationId",
    as: "comments",
  });
  Donation.hasMany(models.Share, {
    foreignKey: "donationId",
    as: "shares",
  });
};

module.exports = Donation;
