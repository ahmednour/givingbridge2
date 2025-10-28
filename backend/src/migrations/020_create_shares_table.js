module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable("shares", {
      id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
      },
      donationId: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: "donations",
          key: "id",
        },
        onDelete: "CASCADE",
      },
      userId: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: "users",
          key: "id",
        },
        onDelete: "CASCADE",
      },
      platform: {
        type: Sequelize.ENUM(
          "facebook",
          "twitter",
          "linkedin",
          "email",
          "other"
        ),
        allowNull: false,
      },
      createdAt: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal("CURRENT_TIMESTAMP"),
      },
    });

    // Add indexes
    await queryInterface.addIndex("shares", ["donationId"]);
    await queryInterface.addIndex("shares", ["userId"]);
    await queryInterface.addIndex("shares", ["platform"]);
    await queryInterface.addIndex("shares", ["createdAt"]);
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable("shares");
  },
};
