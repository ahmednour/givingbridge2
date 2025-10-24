"use strict";

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn("Users", "fcmToken", {
      type: Sequelize.STRING(255),
      allowNull: true,
      comment: "Firebase Cloud Messaging token for push notifications",
    });

    console.log("✅ Added fcmToken column to Users table");
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn("Users", "fcmToken");
    console.log("✅ Removed fcmToken column from Users table");
  },
};
