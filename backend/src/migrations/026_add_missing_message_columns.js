module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Check if senderName column exists
    const messageTableInfo = await queryInterface.describeTable('messages');
    
    if (!messageTableInfo.senderName) {
      await queryInterface.addColumn('messages', 'senderName', {
        type: Sequelize.STRING,
        allowNull: true, // Allow null initially for existing records
      });
    }
    
    if (!messageTableInfo.receiverName) {
      await queryInterface.addColumn('messages', 'receiverName', {
        type: Sequelize.STRING,
        allowNull: true, // Allow null initially for existing records
      });
    }

    // Update existing records to populate the new columns from user table
    await queryInterface.sequelize.query(`
      UPDATE messages m
      JOIN users u ON m.senderId = u.id
      SET m.senderName = u.name
      WHERE m.senderName IS NULL
    `);

    await queryInterface.sequelize.query(`
      UPDATE messages m
      JOIN users u ON m.receiverId = u.id
      SET m.receiverName = u.name
      WHERE m.receiverName IS NULL
    `);

    // Now make the columns NOT NULL
    await queryInterface.changeColumn('messages', 'senderName', {
      type: Sequelize.STRING,
      allowNull: false,
    });

    await queryInterface.changeColumn('messages', 'receiverName', {
      type: Sequelize.STRING,
      allowNull: false,
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn('messages', 'senderName');
    await queryInterface.removeColumn('messages', 'receiverName');
  },
};