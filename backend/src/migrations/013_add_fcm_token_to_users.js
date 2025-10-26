module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Check if the column already exists
    const tableInfo = await queryInterface.describeTable("users");
    if (!tableInfo.fcmToken) {
      await queryInterface.addColumn("users", "fcmToken", {
        type: Sequelize.STRING(500),
        allowNull: true,
      });
      console.log("✅ Added fcmToken column to users table");
    } else {
      console.log("🟡 fcmToken column already exists in users table");
    }
  },

  down: async (queryInterface, Sequelize) => {
    // Check if the column exists before removing it
    const tableInfo = await queryInterface.describeTable("users");
    if (tableInfo.fcmToken) {
      await queryInterface.removeColumn("users", "fcmToken");
      console.log("✅ Removed fcmToken column from users table");
    } else {
      console.log("🟡 fcmToken column does not exist in users table");
    }
  },
};
