"use strict";

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable("activity_logs", {
      id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false,
      },
      userId: {
        type: Sequelize.INTEGER,
        allowNull: false,
        field: "user_id",
        references: {
          model: "users",
          key: "id",
        },
        onUpdate: "CASCADE",
        onDelete: "CASCADE",
      },
      userName: {
        type: Sequelize.STRING(255),
        allowNull: false,
        field: "user_name",
      },
      userRole: {
        type: Sequelize.ENUM("donor", "receiver", "admin"),
        allowNull: false,
        field: "user_role",
      },
      action: {
        type: Sequelize.STRING(100),
        allowNull: false,
        comment:
          "Type of action performed (e.g., create_donation, update_profile)",
      },
      actionCategory: {
        type: Sequelize.ENUM(
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
        comment: "Category of the action for filtering",
      },
      description: {
        type: Sequelize.TEXT,
        allowNull: false,
        comment: "Human-readable description of the action",
      },
      entityType: {
        type: Sequelize.STRING(50),
        allowNull: true,
        field: "entity_type",
        comment: "Type of entity affected (e.g., donation, user, message)",
      },
      entityId: {
        type: Sequelize.INTEGER,
        allowNull: true,
        field: "entity_id",
        comment: "ID of the affected entity",
      },
      metadata: {
        type: Sequelize.JSON,
        allowNull: true,
        comment: "Additional data about the action (JSON format)",
      },
      ipAddress: {
        type: Sequelize.STRING(45),
        allowNull: true,
        field: "ip_address",
        comment: "IP address of the user (IPv4 or IPv6)",
      },
      userAgent: {
        type: Sequelize.TEXT,
        allowNull: true,
        field: "user_agent",
        comment: "Browser/client user agent string",
      },
      createdAt: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal("CURRENT_TIMESTAMP"),
        field: "created_at",
      },
    });

    // Add indexes for better query performance
    await queryInterface.addIndex("activity_logs", ["user_id"], {
      name: "idx_activity_logs_user_id",
    });

    await queryInterface.addIndex("activity_logs", ["action_category"], {
      name: "idx_activity_logs_action_category",
    });

    await queryInterface.addIndex("activity_logs", ["created_at"], {
      name: "idx_activity_logs_created_at",
    });

    await queryInterface.addIndex(
      "activity_logs",
      ["entity_type", "entity_id"],
      {
        name: "idx_activity_logs_entity",
      }
    );

    // Compound index for common query patterns
    await queryInterface.addIndex("activity_logs", ["user_id", "created_at"], {
      name: "idx_activity_logs_user_date",
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable("activity_logs");
  },
};
