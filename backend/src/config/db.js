// Database config
// Fix backend/src/config/db.js
const { Sequelize } = require("sequelize");

const sequelize = new Sequelize({
  dialect: "mysql",
  host: process.env.DB_HOST || "db",
  port: process.env.DB_PORT || 3306,
  database: process.env.DB_NAME || "givingbridge",
  username: process.env.DB_USER || "root",
  password: process.env.DB_PASSWORD || "root",
});

module.exports = sequelize;
