const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/db");

const ActivityLog = sequelize.define(
  "ActivityLog",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: "users",
        key: "id",
      },
    },
    action: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        notEmpty: true,
        len: [1, 100],
      },
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    metadata: {
      type: DataTypes.JSON,
      allowNull: true,
    },
    ipAddress: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    userAgent: {
      type: DataTypes.STRING(500),
      allowNull: true,
    },
  },
  {
    tableName: "activity_logs",
    timestamps: true,
    createdAt: "createdAt",
    updatedAt: false,
    indexes: [
      {
        fields: ["userId"],
      },
      {
        fields: ["action"],
      },
      {
        name: "idx_activity_logs_user_date",
        fields: ["userId", "createdAt"],
      },
    ],
  }
);

// Define associations in a separate function to avoid circular dependencies
ActivityLog.associate = (models) => {
  ActivityLog.belongsTo(models.User, {
    foreignKey: "userId",
    as: "user",
  });
};

module.exports = ActivityLog;
