const { Sequelize } = require("sequelize");
require("dotenv").config();

// Test database configuration with separate settings
const testSequelize = new Sequelize({
  dialect: "mysql",
  host: process.env.TEST_DB_HOST || process.env.DB_HOST || "localhost",
  port: parseInt(process.env.TEST_DB_PORT || process.env.DB_PORT) || 3306,
  database: process.env.TEST_DB_NAME || "givingbridge_test",
  username: process.env.TEST_DB_USER || process.env.DB_USER || "root",
  password: process.env.TEST_DB_PASSWORD || process.env.DB_PASSWORD || "root",
  logging: process.env.NODE_ENV === "test" ? false : console.log,
  pool: {
    max: 5,
    min: 0,
    acquire: 30000,
    idle: 10000,
  },
  define: {
    timestamps: true,
    createdAt: "createdAt",
    updatedAt: "updatedAt",
  },
  dialectOptions: {
    charset: "utf8mb4",
  },
  retry: {
    max: 3,
    match: [
      /ETIMEDOUT/,
      /EHOSTUNREACH/,
      /ECONNRESET/,
      /ECONNREFUSED/,
      /ETIMEDOUT/,
      /ESOCKETTIMEDOUT/,
      /EPIPE/,
    ],
  },
});

// Test database connection with retry logic
async function testDatabaseConnection(maxRetries = 3, retryDelay = 2000) {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      await testSequelize.authenticate();
      console.log("✅ Test database connection established successfully.");
      return true;
    } catch (error) {
      console.error(
        `❌ Test database connection attempt ${attempt} failed:`,
        error.message
      );
      if (attempt < maxRetries) {
        console.log(`⏳ Retrying in ${retryDelay / 1000} seconds...`);
        await new Promise((resolve) => setTimeout(resolve, retryDelay));
      } else {
        console.error(
          "❌ Unable to connect to test database after all retries:",
          error
        );
        return false;
      }
    }
  }
}

// Create test database if it doesn't exist
async function createTestDatabase() {
  const adminSequelize = new Sequelize({
    dialect: "mysql",
    host: process.env.TEST_DB_HOST || process.env.DB_HOST || "localhost",
    port: parseInt(process.env.TEST_DB_PORT || process.env.DB_PORT) || 3306,
    username: process.env.TEST_DB_USER || process.env.DB_USER || "root",
    password: process.env.TEST_DB_PASSWORD || process.env.DB_PASSWORD || "root",
    logging: false,
  });

  try {
    await adminSequelize.authenticate();
    const testDbName = process.env.TEST_DB_NAME || "givingbridge_test";
    
    // Create test database if it doesn't exist
    await adminSequelize.query(
      `CREATE DATABASE IF NOT EXISTS \`${testDbName}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`
    );
    
    console.log(`✅ Test database '${testDbName}' created or already exists.`);
    await adminSequelize.close();
    return true;
  } catch (error) {
    console.error("❌ Failed to create test database:", error.message);
    await adminSequelize.close();
    return false;
  }
}

// Initialize test database
async function initializeTestDatabase() {
  try {
    // First create the database if it doesn't exist
    await createTestDatabase();
    
    // Then connect to it
    const connected = await testDatabaseConnection();
    if (!connected) {
      throw new Error("Failed to connect to test database");
    }
    
    return testSequelize;
  } catch (error) {
    console.error("❌ Test database initialization failed:", error.message);
    throw error;
  }
}

module.exports = { 
  testSequelize, 
  testDatabaseConnection, 
  createTestDatabase,
  initializeTestDatabase 
};