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
});

// Test the connection
async function testConnection() {
  try {
    await sequelize.authenticate();
    console.log("✅ Database connection has been established successfully.");
  } catch (error) {
    console.error("❌ Unable to connect to the database:", error);
  }
}

module.exports = { sequelize, testConnection };
