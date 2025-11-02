/**
 * Migration: Add approval status to donations table
 * This enables admin approval workflow for donations
 */

module.exports = {
  async up(queryInterface, Sequelize) {
    // Add approvalStatus column
    await queryInterface.addColumn("donations", "approvalStatus", {
      type: Sequelize.ENUM("pending", "approved", "rejected"),
      allowNull: false,
      defaultValue: "pending",
      after: "status",
    });

    // Add approvedBy column to track which admin approved
    await queryInterface.addColumn("donations", "approvedBy", {
      type: Sequelize.INTEGER,
      allowNull: true,
      references: {
        model: "users",
        key: "id",
      },
      onUpdate: "CASCADE",
      onDelete: "SET NULL",
      after: "approvalStatus",
    });

    // Add approvedAt timestamp
    await queryInterface.addColumn("donations", "approvedAt", {
      type: Sequelize.DATE,
      allowNull: true,
      after: "approvedBy",
    });

    // Add rejectionReason for rejected donations
    await queryInterface.addColumn("donations", "rejectionReason", {
      type: Sequelize.TEXT,
      allowNull: true,
      after: "approvedAt",
    });

    // Add index for approval status for faster queries
    await queryInterface.addIndex("donations", ["approvalStatus"], {
      name: "idx_donations_approval_status",
    });

    // Update existing donations to be approved (backward compatibility)
    await queryInterface.sequelize.query(`
      UPDATE donations 
      SET approvalStatus = 'approved', 
          approvedAt = createdAt 
      WHERE approvalStatus = 'pending'
    `);
  },

  async down(queryInterface, Sequelize) {
    // Remove index
    await queryInterface.removeIndex("donations", "idx_donations_approval_status");

    // Remove columns in reverse order
    await queryInterface.removeColumn("donations", "rejectionReason");
    await queryInterface.removeColumn("donations", "approvedAt");
    await queryInterface.removeColumn("donations", "approvedBy");
    await queryInterface.removeColumn("donations", "approvalStatus");
  },
};
