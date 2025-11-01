module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Remove advanced message features that are not needed for MVP
    const tableInfo = await queryInterface.describeTable('messages');
    
    // Remove archived fields (advanced message management not needed)
    if (tableInfo.archivedBySender) {
      await queryInterface.removeColumn('messages', 'archivedBySender');
    }
    
    if (tableInfo.archivedByReceiver) {
      await queryInterface.removeColumn('messages', 'archivedByReceiver');
    }
    
    // Remove attachment size field (keep basic attachment support)
    if (tableInfo.attachmentSize) {
      await queryInterface.removeColumn('messages', 'attachmentSize');
    }
  },

  down: async (queryInterface, Sequelize) => {
    // Add back the removed columns
    await queryInterface.addColumn('messages', 'archivedBySender', {
      type: Sequelize.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    });
    
    await queryInterface.addColumn('messages', 'archivedByReceiver', {
      type: Sequelize.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    });
    
    await queryInterface.addColumn('messages', 'attachmentSize', {
      type: Sequelize.INTEGER,
      allowNull: true,
    });
  },
};