const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/db");

const RequestUpdate = sequelize.define(
  "RequestUpdate",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    requestId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: "requests",
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
    title: {
      type: DataTypes.STRING(255),
      allowNull: false,
      validate: {
        notEmpty: true,
        len: [1, 255],
      },
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    imageUrl: {
      type: DataTypes.STRING(500),
      allowNull: true,
      validate: {
        len: [0, 500],
      },
    },
    isPublic: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
    },
  },
  {
    tableName: "request_updates",
    timestamps: true,
    createdAt: "createdAt",
    updatedAt: "updatedAt",
    indexes: [
      {
        fields: ["requestId"],
      },
      {
        fields: ["userId"],
      },
      {
        fields: ["createdAt"],
      },
      {
        fields: ["isPublic"],
      },
    ],
  }
);

// Define associations in a separate function to avoid circular dependencies
RequestUpdate.associate = (models) => {
  RequestUpdate.belongsTo(models.Request, {
    foreignKey: "requestId",
    as: "request",
  });
  RequestUpdate.belongsTo(models.User, {
    foreignKey: "userId",
    as: "user",
  });
};

module.exports = RequestUpdate;
