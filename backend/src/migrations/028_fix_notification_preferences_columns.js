module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Check current table structure
    const tableInfo = await queryInterface.describeTable('notification_preferences');
    
    // Add email_notifications column if it doesn't exist (needed for migration 016)
    if (!tableInfo.email_notifications) {
      await queryInterface.addColumn('notification_preferences', 'email_notifications', {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
      });
    }

    // Add other missing columns that migration 016 expects
    const expectedColumns = [
      'push_notifications',
      'sms_notifications', 
      'in_app_notifications',
      'donation_requests',
      'donation_approvals',
      'new_donations',
      'messages',
      'reminders',
      'system_updates',
      'weekly_summary',
      'daily_digest'
    ];

    for (const column of expectedColumns) {
      if (!tableInfo[column]) {
        await queryInterface.addColumn('notification_preferences', column, {
          type: Sequelize.BOOLEAN,
          allowNull: false,
          defaultValue: true,
        });
      }
    }
  },

  down: async (queryInterface, Sequelize) => {
    // Remove the columns we added
    const columnsToRemove = [
      'email_notifications',
      'push_notifications',
      'sms_notifications',
      'in_app_notifications', 
      'donation_requests',
      'donation_approvals',
      'new_donations',
      'messages',
      'reminders',
      'system_updates',
      'weekly_summary',
      'daily_digest'
    ];

    for (const column of columnsToRemove) {
      try {
        await queryInterface.removeColumn('notification_preferences', column);
      } catch (error) {
        // Column might not exist, continue
        console.log(`Column ${column} doesn't exist, skipping removal`);
      }
    }
  },
};