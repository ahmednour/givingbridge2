module.exports = {
  up: async (queryInterface, Sequelize) => {
    try {
      await queryInterface.addColumn("users", "isVerified", {
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
      await queryInterface.addColumn("users", "verificationLevel", {
        type: Sequelize.ENUM("unverified", "basic", "verified", "premium"),
        allowNull: false,
        defaultValue: "unverified",
      });
    } catch (error) {
      // If column already exists, continue silently
      if (error.message && !error.message.includes("Duplicate column name")) {
        throw error;
      }
    }

    try {
      await queryInterface.addColumn("users", "lastVerificationAttempt", {
        type: Sequelize.DATE,
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
      await queryInterface.removeColumn("users", "isVerified");
    } catch (error) {
      // If column doesn't exist, continue silently
      if (error.message && !error.message.includes("Unknown column")) {
        throw error;
      }
    }

    try {
      await queryInterface.removeColumn("users", "verificationLevel");
    } catch (error) {
      // If column doesn't exist, continue silently
      if (error.message && !error.message.includes("Unknown column")) {
        throw error;
      }
    }

    try {
      await queryInterface.removeColumn("users", "lastVerificationAttempt");
    } catch (error) {
      // If column doesn't exist, continue silently
      if (error.message && !error.message.includes("Unknown column")) {
        throw error;
      }
    }
  },
};
