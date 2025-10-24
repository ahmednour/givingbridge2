const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/db");

const Rating = sequelize.define(
  "Rating",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    requestId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      unique: true, // One rating per request
      references: {
        model: "requests",
        key: "id",
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
    receiverId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: "users",
        key: "id",
      },
    },
    ratedBy: {
      type: DataTypes.ENUM("donor", "receiver"),
      allowNull: false,
      comment: "Who created this rating",
    },
    rating: {
      type: DataTypes.INTEGER,
      allowNull: false,
      validate: {
        min: 1,
        max: 5,
      },
    },
    feedback: {
      type: DataTypes.TEXT,
      allowNull: true,
      validate: {
        len: [0, 1000],
      },
    },
  },
  {
    tableName: "ratings",
    timestamps: true,
    createdAt: "createdAt",
    updatedAt: "updatedAt",
    indexes: [
      {
        fields: ["requestId"],
        unique: true,
      },
      {
        fields: ["donorId"],
      },
      {
        fields: ["receiverId"],
      },
      {
        fields: ["ratedBy"],
      },
    ],
  }
);

module.exports = Rating;
