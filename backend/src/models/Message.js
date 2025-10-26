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
    messageType: {
      type: DataTypes.ENUM("text", "image", "file"),
      allowNull: false,
      defaultValue: "text",
    },
    isRead: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
    attachmentUrl: {
      type: DataTypes.STRING(500),
      allowNull: true,
      validate: {
        len: [0, 500],
      },
    },
    attachmentName: {
      type: DataTypes.STRING,
      allowNull: true,
      validate: {
        len: [0, 255],
      },
    },
    attachmentType: {
      type: DataTypes.STRING,
      allowNull: true,
      validate: {
        len: [0, 50],
      },
    },
  },
  {
    tableName: "messages",
    timestamps: true,
    createdAt: "createdAt",
    updatedAt: "updatedAt",
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

// Define associations in a separate function to avoid circular dependencies
Message.associate = (models) => {
  Message.belongsTo(models.User, { foreignKey: "senderId", as: "sender" });
  Message.belongsTo(models.User, { foreignKey: "receiverId", as: "receiver" });
  Message.belongsTo(models.Donation, {
    foreignKey: "donationId",
    as: "donation",
  });
  Message.belongsTo(models.Request, { foreignKey: "requestId", as: "request" });
};

module.exports = Message;
