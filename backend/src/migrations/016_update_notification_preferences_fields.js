module.exports = {
  up: async (queryInterface, Sequelize) => {
    // This migration is no longer needed as migration 012 already creates
    // the notification_preferences table with the correct structure.
    // This is a no-op migration to maintain migration numbering.
    console.log('Migration 016: Skipping - table already has correct structure from migration 012');
  },

  down: async (queryInterface, Sequelize) => {
    // No-op - nothing to rollback
    console.log('Migration 016 rollback: Skipping - no changes were made');
  },
};
