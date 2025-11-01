module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Remove advanced fields that are not needed for MVP
    const tableInfo = await queryInterface.describeTable('users');
    
    // Remove FCM token field (Firebase notifications not needed)
    if (tableInfo.fcmToken) {
      await queryInterface.removeColumn('users', 'fcmToken');
    }
    
    // Remove verification fields (advanced verification not needed)
    if (tableInfo.isVerified) {
      await queryInterface.removeColumn('users', 'isVerified');
    }
    
    if (tableInfo.verificationLevel) {
      await queryInterface.removeColumn('users', 'verificationLevel');
    }
    
    if (tableInfo.lastVerificationAttempt) {
      await queryInterface.removeColumn('users', 'lastVerificationAttempt');
    }
  },

  down: async (queryInterface, Sequelize) => {
    // Add back the removed columns
    await queryInterface.addColumn('users', 'fcmToken', {
      type: Sequelize.STRING(500),
      allowNull: true,
    });
    
    await queryInterface.addColumn('users', 'isVerified', {
      type: Sequelize.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    });
    
    await queryInterface.addColumn('users', 'verificationLevel', {
      type: Sequelize.ENUM('unverified', 'basic', 'verified', 'premium'),
      allowNull: false,
      defaultValue: 'unverified',
    });
    
    await queryInterface.addColumn('users', 'lastVerificationAttempt', {
      type: Sequelize.DATE,
      allowNull: true,
    });
  },
};