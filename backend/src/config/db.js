const { Sequelize } = require("sequelize");
require("dotenv").config();

const sequelize = new Sequelize({
  dialect: "mysql",
  host: process.env.DB_HOST || "db",
  port: parseInt(process.env.DB_PORT) || 3306,
  database: process.env.DB_NAME || "givingbridge",
  username: process.env.DB_USER || "root",
  password: process.env.DB_PASSWORD || "root",
  logging: process.env.NODE_ENV === "development" ? console.log : false,
  pool: {
    max: 10,
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
    max: 5,
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

// Test the connection with retry logic
async function testConnection(maxRetries = 5, retryDelay = 5000) {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      await sequelize.authenticate();
      console.log("✅ Database connection has been established successfully.");
      return true;
    } catch (error) {
      console.error(
        `❌ Database connection attempt ${attempt} failed:`,
        error.message
      );
      if (attempt < maxRetries) {
        console.log(`⏳ Retrying in ${retryDelay / 1000} seconds...`);
        await new Promise((resolve) => setTimeout(resolve, retryDelay));
      } else {
        console.error(
          "❌ Unable to connect to the database after all retries:",
          error
        );
        return false;
      }
    }
  }
}

module.exports = { sequelize, testConnection };
