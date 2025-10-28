module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable("request_verification_documents", {
      id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
      },
      requestId: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: "requests",
          key: "id",
        },
        onDelete: "CASCADE",
      },
      documentType: {
        type: Sequelize.ENUM("proof_of_need", "receipt", "photo", "other"),
        allowNull: false,
      },
      documentUrl: {
        type: Sequelize.STRING(500),
        allowNull: false,
      },
      documentName: {
        type: Sequelize.STRING(255),
        allowNull: false,
      },
      documentSize: {
        type: Sequelize.INTEGER,
        allowNull: true,
      },
      isVerified: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false,
      },
      verifiedBy: {
        type: Sequelize.INTEGER,
        allowNull: true,
        references: {
          model: "users",
          key: "id",
        },
      },
      verifiedAt: {
        type: Sequelize.DATE,
        allowNull: true,
      },
      rejectionReason: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      createdAt: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal("CURRENT_TIMESTAMP"),
      },
      updatedAt: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal("CURRENT_TIMESTAMP"),
      },
    });

    // Add indexes
    await queryInterface.addIndex("request_verification_documents", [
      "requestId",
    ]);
    await queryInterface.addIndex("request_verification_documents", [
      "documentType",
    ]);
    await queryInterface.addIndex("request_verification_documents", [
      "isVerified",
    ]);
    await queryInterface.addIndex("request_verification_documents", [
      "verifiedBy",
    ]);
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable("request_verification_documents");
  },
};
