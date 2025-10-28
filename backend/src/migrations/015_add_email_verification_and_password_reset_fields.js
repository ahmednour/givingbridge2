module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn("users", "isEmailVerified", {
      type: Sequelize.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    });

    await queryInterface.addColumn("users", "emailVerificationToken", {
      type: Sequelize.STRING,
      allowNull: true,
    });

    await queryInterface.addColumn("users", "emailVerificationExpiry", {
      type: Sequelize.DATE,
      allowNull: true,
    });

    await queryInterface.addColumn("users", "passwordResetToken", {
      type: Sequelize.STRING,
      allowNull: true,
    });

    await queryInterface.addColumn("users", "passwordResetExpiry", {
      type: Sequelize.DATE,
      allowNull: true,
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn("users", "isEmailVerified");
    await queryInterface.removeColumn("users", "emailVerificationToken");
    await queryInterface.removeColumn("users", "emailVerificationExpiry");
    await queryInterface.removeColumn("users", "passwordResetToken");
    await queryInterface.removeColumn("users", "passwordResetExpiry");
  },
};
