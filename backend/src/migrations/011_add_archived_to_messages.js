"use strict";

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Add archived columns for both sender and receiver
    await queryInterface.addColumn("messages", "archivedBySender", {
      type: Sequelize.BOOLEAN,
      allowNull: false,
      defaultValue: false,
      after: "isRead",
    });

    await queryInterface.addColumn("messages", "archivedByReceiver", {
      type: Sequelize.BOOLEAN,
      allowNull: false,
      defaultValue: false,
      after: "archivedBySender",
    });

    // Add indexes for performance
    await queryInterface.addIndex("messages", ["archivedBySender"], {
      name: "messages_archived_by_sender_index",
    });

    await queryInterface.addIndex("messages", ["archivedByReceiver"], {
      name: "messages_archived_by_receiver_index",
    });
  },

  down: async (queryInterface, Sequelize) => {
    // Remove indexes first
    await queryInterface.removeIndex(
      "messages",
      "messages_archived_by_sender_index"
    );
    await queryInterface.removeIndex(
      "messages",
      "messages_archived_by_receiver_index"
    );

    // Remove columns
    await queryInterface.removeColumn("messages", "archivedBySender");
    await queryInterface.removeColumn("messages", "archivedByReceiver");
  },
};
