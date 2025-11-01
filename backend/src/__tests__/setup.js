// Load test configuration
require("./test-config");

const { testSequelize } = require("../config/test-db");
const TestMigrationRunner = require("./test-migration-runner");
const TestDataSeeder = require("./test-data-seeder");

let migrationRunner;
let dataSeeder;
let isDatabaseConnected = false;

// Setup test database
beforeAll(async () => {
  try {
    // Test connection first
    await testSequelize.authenticate();
    console.log("✅ Test database connection established");
    isDatabaseConnected = true;

    // Initialize migration runner and run migrations
    migrationRunner = new TestMigrationRunner();
    await migrationRunner.syncModels();
    console.log("✅ Test database models synced");

    // Initialize data seeder
    dataSeeder = new TestDataSeeder();
  } catch (error) {
    console.error("❌ Test database setup failed:", error.message);
    console.log("🟡 Tests will run without database connection");
    isDatabaseConnected = false;
    // Don't throw error to allow tests to run with mocked data
  }
});

// Cleanup after each test
afterEach(async () => {
  if (!isDatabaseConnected) return;

  try {
    // Clean up test data if seeder was used
    if (dataSeeder) {
      await dataSeeder.cleanupTestData();
    }

    // Clear all tables in correct order to avoid foreign key constraints
    await testSequelize.query("SET FOREIGN_KEY_CHECKS = 0");
    
    const tableNames = [
      "messages",
      "requests",
      "donations",
      "users",
      "test_migrations"
    ];

    for (const tableName of tableNames) {
      await testSequelize.query(`TRUNCATE TABLE IF EXISTS \`${tableName}\``);
    }
    
    await testSequelize.query("SET FOREIGN_KEY_CHECKS = 1");
  } catch (error) {
    console.warn("⚠️ Failed to cleanup test database:", error.message);
  }
});

// Close database connection after all tests
afterAll(async () => {
  if (!isDatabaseConnected) return;

  try {
    await testSequelize.close();
    console.log("✅ Test database connection closed");
  } catch (error) {
    console.warn("⚠️ Failed to close test database connection:", error.message);
  }
});

// Export utilities for use in tests
global.testUtils = {
  isConnected: () => isDatabaseConnected,
  getSeeder: () => dataSeeder,
  getMigrationRunner: () => migrationRunner,
  getSequelize: () => testSequelize,
};
