/**
 * Migration: Create blocked_users table
 * This table stores user blocking relationships for safety features
 */

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable("blocked_users", {
      id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false,
      },
      blockerId: {
        type: Sequelize.INTEGER,
        allowNull: false,
        comment: "User who blocked",
        references: {
          model: "users",
          key: "id",
        },
        onUpdate: "CASCADE",
        onDelete: "CASCADE",
      },
      blockedId: {
        type: Sequelize.INTEGER,
        allowNull: false,
        comment: "User who was blocked",
        references: {
          model: "users",
          key: "id",
        },
        onUpdate: "CASCADE",
        onDelete: "CASCADE",
      },
      reason: {
        type: Sequelize.TEXT,
        allowNull: true,
        comment: "Optional reason for blocking",
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

    // Add unique constraint to prevent duplicate blocks
    await queryInterface.addIndex("blocked_users", ["blockerId", "blockedId"], {
      unique: true,
      name: "unique_block_relationship",
    });

    // Add index for faster queries
    await queryInterface.addIndex("blocked_users", ["blockerId"]);
    await queryInterface.addIndex("blocked_users", ["blockedId"]);
  },

  down: async (queryInterface) => {
    await queryInterface.dropTable("blocked_users");
  },
};
