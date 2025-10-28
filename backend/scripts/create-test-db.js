#!/usr/bin/env node

const { createTestDatabase } = require("../src/config/test-db");

async function main() {
  console.log("🚀 Creating test database...");
  
  try {
    const success = await createTestDatabase();
    if (success) {
      console.log("✅ Test database created successfully");
      process.exit(0);
    } else {
      console.error("❌ Failed to create test database");
      process.exit(1);
    }
  } catch (error) {
    console.error("❌ Error creating test database:", error.message);
    process.exit(1);
  }
}

main();