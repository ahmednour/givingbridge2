module.exports = {
  up: async (queryInterface, Sequelize) => {
    try {
      await queryInterface.addColumn("requests", "isVerified", {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false,
      });
    } catch (error) {
      // If column already exists, continue silently
      if (error.message && !error.message.includes("Duplicate column name")) {
        throw error;
      }
    }

    try {
      await queryInterface.addColumn("requests", "verificationNotes", {
        type: Sequelize.TEXT,
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
      await queryInterface.removeColumn("requests", "isVerified");
    } catch (error) {
      // If column doesn't exist, continue silently
      if (error.message && !error.message.includes("Unknown column")) {
        throw error;
      }
    }

    try {
      await queryInterface.removeColumn("requests", "verificationNotes");
    } catch (error) {
      // If column doesn't exist, continue silently
      if (error.message && !error.message.includes("Unknown column")) {
        throw error;
      }
    }
  },
};
