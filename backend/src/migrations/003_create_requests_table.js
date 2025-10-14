"use strict";

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable("requests", {
      id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false,
      },
      donationId: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: "donations",
          key: "id",
        },
        onUpdate: "CASCADE",
        onDelete: "CASCADE",
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
      receiverId: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: "users",
          key: "id",
        },
        onUpdate: "CASCADE",
        onDelete: "CASCADE",
      },
      receiverName: {
        type: Sequelize.STRING,
        allowNull: false,
      },
      receiverEmail: {
        type: Sequelize.STRING,
        allowNull: false,
      },
      receiverPhone: {
        type: Sequelize.STRING,
        allowNull: true,
      },
      message: {
        type: Sequelize.TEXT,
        allowNull: true,
        validate: {
          len: [0, 500],
        },
      },
      status: {
        type: Sequelize.ENUM(
          "pending",
          "approved",
          "declined",
          "completed",
          "cancelled"
        ),
        allowNull: false,
        defaultValue: "pending",
      },
      responseMessage: {
        type: Sequelize.TEXT,
        allowNull: true,
        validate: {
          len: [0, 500],
        },
      },
      respondedAt: {
        type: Sequelize.DATE,
        allowNull: true,
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
    await queryInterface.addIndex("requests", ["donationId"], {
      name: "requests_donation_id_index",
    });
    await queryInterface.addIndex("requests", ["donorId"], {
      name: "requests_donor_id_index",
    });
    await queryInterface.addIndex("requests", ["receiverId"], {
      name: "requests_receiver_id_index",
    });
    await queryInterface.addIndex("requests", ["status"], {
      name: "requests_status_index",
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable("requests");
  },
};
