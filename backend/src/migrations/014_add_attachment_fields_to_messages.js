module.exports = {
  up: async (queryInterface, Sequelize) => {
    try {
      await queryInterface.addColumn("messages", "messageType", {
        type: Sequelize.STRING(20),
        allowNull: true,
        defaultValue: "text",
      });
    } catch (error) {
      // If column already exists, continue silently
      if (error.message && !error.message.includes("Duplicate column name")) {
        throw error;
      }
    }

    try {
      await queryInterface.addColumn("messages", "attachmentUrl", {
        type: Sequelize.STRING(500),
        allowNull: true,
      });
    } catch (error) {
      // If column already exists, continue silently
      if (error.message && !error.message.includes("Duplicate column name")) {
        throw error;
      }
    }

    try {
      await queryInterface.addColumn("messages", "attachmentName", {
        type: Sequelize.STRING(255),
        allowNull: true,
      });
    } catch (error) {
      // If column already exists, continue silently
      if (error.message && !error.message.includes("Duplicate column name")) {
        throw error;
      }
    }

    try {
      await queryInterface.addColumn("messages", "attachmentSize", {
        type: Sequelize.INTEGER,
        allowNull: true,
      });
    } catch (error) {
      // If column already exists, continue silently
      if (error.message && !error.message.includes("Duplicate column name")) {
        throw error;
      }
    }
  },

  down: async (queryInterface, Sequelize) => {
    try {
      await queryInterface.removeColumn("messages", "messageType");
    } catch (error) {
      // If column doesn't exist, continue silently
      if (error.message && !error.message.includes("Unknown column")) {
        throw error;
      }
    }

    try {
      await queryInterface.removeColumn("messages", "attachmentUrl");
    } catch (error) {
      // If column doesn't exist, continue silently
      if (error.message && !error.message.includes("Unknown column")) {
        throw error;
      }
    }

    try {
      await queryInterface.removeColumn("messages", "attachmentName");
    } catch (error) {
      // If column doesn't exist, continue silently
      if (error.message && !error.message.includes("Unknown column")) {
        throw error;
      }
    }

    try {
      await queryInterface.removeColumn("messages", "attachmentSize");
    } catch (error) {
      // If column doesn't exist, continue silently
      if (error.message && !error.message.includes("Unknown column")) {
        throw error;
      }
    }
  },
};
