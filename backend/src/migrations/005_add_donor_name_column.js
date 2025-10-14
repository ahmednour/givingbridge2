"use strict";

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Check if the column already exists
    const tableDescription = await queryInterface.describeTable("donations");

    if (!tableDescription.donorName) {
      await queryInterface.addColumn("donations", "donorName", {
        type: Sequelize.STRING,
        allowNull: false,
        defaultValue: "Unknown Donor", // Temporary default for existing records
      });

      console.log("✅ Added donorName column to donations table");
    } else {
      console.log("ℹ️ donorName column already exists in donations table");
    }
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn("donations", "donorName");
    console.log("✅ Removed donorName column from donations table");
  },
};
