module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Remove verification fields that are not needed for MVP
    const tableInfo = await queryInterface.describeTable('requests');
    
    if (tableInfo.isVerified) {
      await queryInterface.removeColumn('requests', 'isVerified');
    }
    
    if (tableInfo.verificationNotes) {
      await queryInterface.removeColumn('requests', 'verificationNotes');
    }
  },

  down: async (queryInterface, Sequelize) => {
    // Add back the removed columns
    await queryInterface.addColumn('requests', 'isVerified', {
      type: Sequelize.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    });
    
    await queryInterface.addColumn('requests', 'verificationNotes', {
      type: Sequelize.TEXT,
      allowNull: true,
    });
  },
};