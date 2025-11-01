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
      field: "user_id", // Map to snake_case database column
      references: {
        model: "users",
        key: "id",
      },
    },
    userName: {
      type: DataTypes.STRING,
      allowNull: true,
      field: "user_name", // Map to snake_case database column
    },
    userRole: {
      type: DataTypes.STRING,
      allowNull: true,
      field: "user_role", // Map to snake_case database column
    },
    actionCategory: {
      type: DataTypes.STRING,
      allowNull: true,
      field: "action_category", // Map to snake_case database column
    },
    entityType: {
      type: DataTypes.STRING,
      allowNull: true,
      field: "entity_type", // Map to snake_case database column
    },
    entityId: {
      type: DataTypes.INTEGER,
      allowNull: true,
      field: "entity_id", // Map to snake_case database column
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
      field: "ip_address", // Map to snake_case database column
    },
    userAgent: {
      type: DataTypes.STRING(500),
      allowNull: true,
      field: "user_agent", // Map to snake_case database column
    },
  },
  {
    tableName: "activity_logs",
    timestamps: true,
    createdAt: "created_at", // Map to snake_case database column
    updatedAt: false,
    indexes: [
      {
        fields: ["user_id"], // Use database column name
      },
      {
        fields: ["action"],
      },
      {
        name: "idx_activity_logs_user_date",
        fields: ["user_id", "created_at"], // Use database column names
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
