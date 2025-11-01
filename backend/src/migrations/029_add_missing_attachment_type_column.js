module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Check if attachmentType column exists
    const messageTableInfo = await queryInterface.describeTable('messages');
    
    if (!messageTableInfo.attachmentType) {
      await queryInterface.addColumn('messages', 'attachmentType', {
        type: Sequelize.STRING,
        allowNull: true,
        validate: {
          len: [0, 50],
        },
      });
    }
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn('messages', 'attachmentType');
  },
};