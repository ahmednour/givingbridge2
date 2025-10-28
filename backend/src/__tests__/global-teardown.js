const { testSequelize } = require("../config/test-db");

module.exports = async () => {
  console.log("🧹 Cleaning up test environment...");
  
  try {
    // Close test database connection
    if (testSequelize) {
      await testSequelize.close();
      console.log("✅ Test database connection closed");
    }
  } catch (error) {
    console.warn("⚠️ Failed to close test database connection:", error.message);
  }
};