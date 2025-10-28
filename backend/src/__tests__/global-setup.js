const { initializeTestDatabase } = require("../config/test-db");

module.exports = async () => {
  console.log("🚀 Setting up test environment...");
  
  try {
    // Initialize test database
    await initializeTestDatabase();
    console.log("✅ Test database initialized successfully");
  } catch (error) {
    console.error("❌ Failed to initialize test database:", error.message);
    // Don't throw error to allow tests to run with mocked data
    console.log("🟡 Tests will run without database connection");
  }
};