// Load test configuration
require("./test-config");

const { sequelize } = require("../config/db");

// Setup test database
beforeAll(async () => {
  try {
    // Test connection first
    await sequelize.authenticate();
    console.log("✅ Test database connection established");

    // Sync database
    await sequelize.sync({ force: true });
    console.log("✅ Test database synced");
  } catch (error) {
    console.error("❌ Test database setup failed:", error.message);
    console.log("🟡 Tests will be skipped due to database connection issues");
    // Don't throw error to allow tests to run with mocked data
  }
});

// Cleanup after each test
afterEach(async () => {
  try {
    // Clear all tables
    await sequelize.truncate({ cascade: true });
  } catch (error) {
    console.warn("⚠️ Failed to truncate test database:", error.message);
  }
});

// Close database connection after all tests
afterAll(async () => {
  try {
    await sequelize.close();
    console.log("✅ Test database connection closed");
  } catch (error) {
    console.warn("⚠️ Failed to close test database connection:", error.message);
  }
});
