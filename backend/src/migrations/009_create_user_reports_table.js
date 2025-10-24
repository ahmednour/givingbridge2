/**
 * Migration: Create user_reports table
 * This table stores user reports for moderation and safety
 */

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable("user_reports", {
      id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false,
      },
      reporterId: {
        type: Sequelize.INTEGER,
        allowNull: false,
        comment: "User who submitted the report",
        references: {
          model: "users",
          key: "id",
        },
        onUpdate: "CASCADE",
        onDelete: "CASCADE",
      },
      reportedId: {
        type: Sequelize.INTEGER,
        allowNull: false,
        comment: "User who was reported",
        references: {
          model: "users",
          key: "id",
        },
        onUpdate: "CASCADE",
        onDelete: "CASCADE",
      },
      reason: {
        type: Sequelize.ENUM(
          "spam",
          "harassment",
          "inappropriate_content",
          "scam",
          "fake_profile",
          "other"
        ),
        allowNull: false,
        comment: "Category of the report",
      },
      description: {
        type: Sequelize.TEXT,
        allowNull: false,
        comment: "Detailed description of the issue",
      },
      status: {
        type: Sequelize.ENUM("pending", "reviewed", "resolved", "dismissed"),
        allowNull: false,
        defaultValue: "pending",
        comment: "Status of the report",
      },
      reviewedBy: {
        type: Sequelize.INTEGER,
        allowNull: true,
        comment: "Admin who reviewed the report",
        references: {
          model: "users",
          key: "id",
        },
        onUpdate: "CASCADE",
        onDelete: "SET NULL",
      },
      reviewNotes: {
        type: Sequelize.TEXT,
        allowNull: true,
        comment: "Admin notes on the report",
      },
      reviewedAt: {
        type: Sequelize.DATE,
        allowNull: true,
        comment: "When the report was reviewed",
      },
      createdAt: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal("CURRENT_TIMESTAMP"),
      },
      updatedAt: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal(
          "CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP"
        ),
      },
    });

    // Add indexes for faster queries
    await queryInterface.addIndex("user_reports", ["reporterId"]);
    await queryInterface.addIndex("user_reports", ["reportedId"]);
    await queryInterface.addIndex("user_reports", ["status"]);
    await queryInterface.addIndex("user_reports", ["createdAt"]);
  },

  down: async (queryInterface) => {
    await queryInterface.dropTable("user_reports");
  },
};
