"use strict";

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable("messages", {
      id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false,
      },
      senderId: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: "users",
          key: "id",
        },
        onUpdate: "CASCADE",
        onDelete: "CASCADE",
      },
      senderName: {
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
      donationId: {
        type: Sequelize.INTEGER,
        allowNull: true,
        references: {
          model: "donations",
          key: "id",
        },
        onUpdate: "CASCADE",
        onDelete: "SET NULL",
      },
      requestId: {
        type: Sequelize.INTEGER,
        allowNull: true,
        references: {
          model: "requests",
          key: "id",
        },
        onUpdate: "CASCADE",
        onDelete: "SET NULL",
      },
      content: {
        type: Sequelize.TEXT,
        allowNull: false,
        validate: {
          notEmpty: true,
          len: [1, 2000],
        },
      },
      isRead: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false,
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
    await queryInterface.addIndex("messages", ["senderId"], {
      name: "messages_sender_id_index",
    });
    await queryInterface.addIndex("messages", ["receiverId"], {
      name: "messages_receiver_id_index",
    });
    await queryInterface.addIndex("messages", ["donationId"], {
      name: "messages_donation_id_index",
    });
    await queryInterface.addIndex("messages", ["requestId"], {
      name: "messages_request_id_index",
    });
    await queryInterface.addIndex("messages", ["isRead"], {
      name: "messages_is_read_index",
    });
    await queryInterface.addIndex("messages", ["createdAt"], {
      name: "messages_created_at_index",
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable("messages");
  },
};
