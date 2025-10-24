const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/db");

const ActivityLog = sequelize.define(
  "ActivityLog",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
      allowNull: false,
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: "user_id",
    },
    userName: {
      type: DataTypes.STRING(255),
      allowNull: false,
      field: "user_name",
    },
    userRole: {
      type: DataTypes.ENUM("donor", "receiver", "admin"),
      allowNull: false,
      field: "user_role",
    },
    action: {
      type: DataTypes.STRING(100),
      allowNull: false,
    },
    actionCategory: {
      type: DataTypes.ENUM(
        "auth",
        "donation",
        "request",
        "message",
        "user",
        "admin",
        "notification",
        "report"
      ),
      allowNull: false,
      field: "action_category",
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    entityType: {
      type: DataTypes.STRING(50),
      allowNull: true,
      field: "entity_type",
    },
    entityId: {
      type: DataTypes.INTEGER,
      allowNull: true,
      field: "entity_id",
    },
    metadata: {
      type: DataTypes.JSON,
      allowNull: true,
    },
    ipAddress: {
      type: DataTypes.STRING(45),
      allowNull: true,
      field: "ip_address",
    },
    userAgent: {
      type: DataTypes.TEXT,
      allowNull: true,
      field: "user_agent",
    },
    createdAt: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW,
      field: "created_at",
    },
  },
  {
    tableName: "activity_logs",
    timestamps: false, // We only need createdAt, managed manually
    indexes: [
      {
        name: "idx_activity_logs_user_id",
        fields: ["user_id"],
      },
      {
        name: "idx_activity_logs_action_category",
        fields: ["action_category"],
      },
      {
        name: "idx_activity_logs_created_at",
        fields: ["created_at"],
      },
      {
        name: "idx_activity_logs_entity",
        fields: ["entity_type", "entity_id"],
      },
      {
        name: "idx_activity_logs_user_date",
        fields: ["user_id", "created_at"],
      },
    ],
  }
);

// Define associations
ActivityLog.associate = (models) => {
  ActivityLog.belongsTo(models.User, {
    foreignKey: "userId",
    as: "user",
  });
};

module.exports = ActivityLog;
