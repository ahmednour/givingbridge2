const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/db");

const Request = sequelize.define(
  "Request",
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
      allowNull: true,
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
    receiverEmail: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    receiverPhone: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    message: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    status: {
      type: DataTypes.ENUM(
        "pending",
        "approved",
        "declined",
        "completed",
        "cancelled"
      ),
      allowNull: false,
      defaultValue: "pending",
    },
    respondedAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
  },
  {
    tableName: "requests",
    timestamps: true,
    createdAt: "createdAt",
    updatedAt: "updatedAt",
    indexes: [
      {
        fields: ["donationId"],
      },
      {
        fields: ["donorId"],
      },
      {
        fields: ["receiverId"],
      },
      {
        fields: ["status"],
      },
    ],
    hooks: {
      beforeUpdate: (request, options) => {
        // Set respondedAt when status changes from pending
        if (
          request.changed("status") &&
          request._previousDataValues.status === "pending" &&
          request.status !== "pending"
        ) {
          request.respondedAt = new Date();
        }
      },
    },
  }
);

// Define associations in a separate function to avoid circular dependencies
Request.associate = (models) => {
  Request.belongsTo(models.User, { foreignKey: "receiverId", as: "receiver" });
  Request.belongsTo(models.User, { foreignKey: "donorId", as: "requestDonor" });
  Request.belongsTo(models.Donation, {
    foreignKey: "donationId",
    as: "donation",
  });
};

module.exports = Request;
