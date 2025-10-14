"use strict";

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable("users", {
      id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false,
      },
      name: {
        type: Sequelize.STRING,
        allowNull: false,
        validate: {
          notEmpty: true,
          len: [2, 255],
        },
      },
      email: {
        type: Sequelize.STRING,
        allowNull: false,
        unique: true,
        validate: {
          isEmail: true,
        },
      },
      password: {
        type: Sequelize.STRING,
        allowNull: false,
        validate: {
          len: [6, 255],
        },
      },
      role: {
        type: Sequelize.ENUM("donor", "receiver", "admin"),
        allowNull: false,
        defaultValue: "donor",
      },
      phone: {
        type: Sequelize.STRING,
        allowNull: true,
        validate: {
          len: [0, 20],
        },
      },
      location: {
        type: Sequelize.STRING,
        allowNull: true,
        validate: {
          len: [0, 255],
        },
      },
      avatarUrl: {
        type: Sequelize.STRING,
        allowNull: true,
        validate: {
          len: [0, 500],
        },
      },
      createdAt: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW,
      },
      updatedAt: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW,
      },
    });

    // Add indexes
    await queryInterface.addIndex("users", ["email"], {
      unique: true,
      name: "users_email_unique",
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable("users");
  },
};
