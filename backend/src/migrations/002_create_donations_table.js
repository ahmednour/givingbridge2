"use strict";

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable("donations", {
      id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false,
      },
      title: {
        type: Sequelize.STRING,
        allowNull: false,
        validate: {
          notEmpty: true,
          len: [3, 255],
        },
      },
      description: {
        type: Sequelize.TEXT,
        allowNull: false,
        validate: {
          notEmpty: true,
          len: [10, 5000],
        },
      },
      category: {
        type: Sequelize.ENUM(
          "food",
          "clothes",
          "books",
          "electronics",
          "other"
        ),
        allowNull: false,
      },
      condition: {
        type: Sequelize.ENUM("new", "like-new", "good", "fair"),
        allowNull: false,
        defaultValue: "good",
      },
      location: {
        type: Sequelize.STRING,
        allowNull: false,
        validate: {
          notEmpty: true,
          len: [2, 255],
        },
      },
      donorId: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: "users",
          key: "id",
        },
        onUpdate: "CASCADE",
        onDelete: "CASCADE",
      },
      donorName: {
        type: Sequelize.STRING,
        allowNull: false,
      },
      imageUrl: {
        type: Sequelize.STRING,
        allowNull: true,
        validate: {
          len: [0, 500],
        },
      },
      isAvailable: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
      },
      status: {
        type: Sequelize.ENUM("available", "pending", "completed", "cancelled"),
        allowNull: false,
        defaultValue: "available",
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
    await queryInterface.addIndex("donations", ["donorId"], {
      name: "donations_donor_id_index",
    });
    await queryInterface.addIndex("donations", ["category"], {
      name: "donations_category_index",
    });
    await queryInterface.addIndex("donations", ["isAvailable"], {
      name: "donations_is_available_index",
    });
    await queryInterface.addIndex("donations", ["status"], {
      name: "donations_status_index",
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable("donations");
  },
};
