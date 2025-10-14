const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/db");

const Message = sequelize.define(
  "Message",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    senderId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: "users",
        key: "id",
      },
    },
    senderName: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    receiverId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: "users",
        key: "id",
      },
    },
    receiverName: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    donationId: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: "donations",
        key: "id",
      },
    },
    requestId: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: "requests",
        key: "id",
      },
    },
    content: {
      type: DataTypes.TEXT,
      allowNull: false,
      validate: {
        notEmpty: true,
        len: [1, 5000],
      },
    },
    isRead: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
  },
  {
    tableName: "messages",
    timestamps: true,
    createdAt: 'createdAt',
    updatedAt: 'updatedAt',
    indexes: [
      {
        fields: ["senderId"],
      },
      {
        fields: ["receiverId"],
      },
      {
        fields: ["donationId"],
      },
      {
        fields: ["requestId"],
      },
      {
        fields: ["isRead"],
      },
      {
        fields: ["createdAt"],
      },
    ],
  }
);

module.exports = Message;
