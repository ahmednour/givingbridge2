module.exports = {
  up: async (queryInterface, Sequelize) => {
    try {
      await queryInterface.addColumn("donations", "shareCount", {
        type: Sequelize.INTEGER,
        allowNull: false,
        defaultValue: 0,
      });
    } catch (error) {
      // If column already exists, continue silently
      if (error.message && !error.message.includes("Duplicate column name")) {
        throw error;
      }
    }

    try {
      await queryInterface.addColumn("donations", "commentCount", {
        type: Sequelize.INTEGER,
        allowNull: false,
        defaultValue: 0,
      });
    } catch (error) {
      // If column already exists, continue silently
      if (error.message && !error.message.includes("Duplicate column name")) {
        throw error;
      }
    }

    try {
      await queryInterface.addColumn("donations", "viewCount", {
        type: Sequelize.INTEGER,
        allowNull: false,
        defaultValue: 0,
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
      await queryInterface.removeColumn("donations", "shareCount");
    } catch (error) {
      // If column doesn't exist, continue silently
      if (error.message && !error.message.includes("Unknown column")) {
        throw error;
      }
    }

    try {
      await queryInterface.removeColumn("donations", "commentCount");
    } catch (error) {
      // If column doesn't exist, continue silently
      if (error.message && !error.message.includes("Unknown column")) {
        throw error;
      }
    }

    try {
      await queryInterface.removeColumn("donations", "viewCount");
    } catch (error) {
      // If column doesn't exist, continue silently
      if (error.message && !error.message.includes("Unknown column")) {
        throw error;
      }
    }
  },
};
