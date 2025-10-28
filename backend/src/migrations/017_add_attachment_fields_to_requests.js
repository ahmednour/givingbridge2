module.exports = {
  up: async (queryInterface, Sequelize) => {
    try {
      await queryInterface.addColumn("requests", "attachmentUrl", {
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
      await queryInterface.addColumn("requests", "attachmentName", {
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
      await queryInterface.addColumn("requests", "attachmentSize", {
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
      await queryInterface.removeColumn("requests", "attachmentUrl");
    } catch (error) {
      // If column doesn't exist, continue silently
      if (error.message && !error.message.includes("Unknown column")) {
        throw error;
      }
    }

    try {
      await queryInterface.removeColumn("requests", "attachmentName");
    } catch (error) {
      // If column doesn't exist, continue silently
      if (error.message && !error.message.includes("Unknown column")) {
        throw error;
      }
    }

    try {
      await queryInterface.removeColumn("requests", "attachmentSize");
    } catch (error) {
      // If column doesn't exist, continue silently
      if (error.message && !error.message.includes("Unknown column")) {
        throw error;
      }
    }
  },
};
