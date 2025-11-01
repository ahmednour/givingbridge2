module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Remove social proof fields that are not needed for MVP
    const tableInfo = await queryInterface.describeTable('donations');
    
    if (tableInfo.shareCount) {
      await queryInterface.removeColumn('donations', 'shareCount');
    }
    
    if (tableInfo.commentCount) {
      await queryInterface.removeColumn('donations', 'commentCount');
    }
    
    if (tableInfo.viewCount) {
      await queryInterface.removeColumn('donations', 'viewCount');
    }
  },

  down: async (queryInterface, Sequelize) => {
    // Add back the removed columns
    await queryInterface.addColumn('donations', 'shareCount', {
      type: Sequelize.INTEGER,
      allowNull: false,
      defaultValue: 0,
    });
    
    await queryInterface.addColumn('donations', 'commentCount', {
      type: Sequelize.INTEGER,
      allowNull: false,
      defaultValue: 0,
    });
    
    await queryInterface.addColumn('donations', 'viewCount', {
      type: Sequelize.INTEGER,
      allowNull: false,
      defaultValue: 0,
    });
  },
};