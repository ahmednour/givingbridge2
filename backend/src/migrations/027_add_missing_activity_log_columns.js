module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Check if columns exist
    const activityLogTableInfo = await queryInterface.describeTable('activity_logs');
    
    if (!activityLogTableInfo.userName) {
      await queryInterface.addColumn('activity_logs', 'userName', {
        type: Sequelize.STRING,
        allowNull: true,
      });
    }
    
    if (!activityLogTableInfo.userRole) {
      await queryInterface.addColumn('activity_logs', 'userRole', {
        type: Sequelize.STRING,
        allowNull: true,
      });
    }

    if (!activityLogTableInfo.actionCategory) {
      await queryInterface.addColumn('activity_logs', 'actionCategory', {
        type: Sequelize.STRING,
        allowNull: true,
      });
    }

    if (!activityLogTableInfo.entityType) {
      await queryInterface.addColumn('activity_logs', 'entityType', {
        type: Sequelize.STRING,
        allowNull: true,
      });
    }

    if (!activityLogTableInfo.entityId) {
      await queryInterface.addColumn('activity_logs', 'entityId', {
        type: Sequelize.INTEGER,
        allowNull: true,
      });
    }

    // Update existing records to populate userName and userRole from user table
    await queryInterface.sequelize.query(`
      UPDATE activity_logs a
      JOIN users u ON a.user_id = u.id
      SET a.userName = u.name, a.userRole = u.role
      WHERE a.userName IS NULL OR a.userRole IS NULL
    `);
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn('activity_logs', 'userName');
    await queryInterface.removeColumn('activity_logs', 'userRole');
    await queryInterface.removeColumn('activity_logs', 'actionCategory');
    await queryInterface.removeColumn('activity_logs', 'entityType');
    await queryInterface.removeColumn('activity_logs', 'entityId');
  },
};