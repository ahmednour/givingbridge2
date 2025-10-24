module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn("users", "fcmToken", {
      type: Sequelize.STRING(500),
      allowNull: true,
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn("users", "fcmToken");
  },
};
