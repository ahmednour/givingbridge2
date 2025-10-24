const { Sequelize } = require("sequelize");
require("dotenv").config();

const sequelize = new Sequelize(
  process.env.DB_NAME || "givingbridge",
  process.env.DB_USER || "root",
  process.env.DB_PASSWORD || "",
  {
    host: process.env.DB_HOST || "localhost",
    port: process.env.DB_PORT || 3307,
    dialect: "mysql",
    logging: console.log,
  }
);

async function runMigration() {
  try {
    // Test connection
    await sequelize.authenticate();
    console.log("✓ Database connection established");

    // Run the activity_logs migration
    const migration = require("./migrations/010_create_activity_logs_table");
    const queryInterface = sequelize.getQueryInterface();

    console.log("\nRunning migration: 010_create_activity_logs_table...");
    await migration.up(queryInterface, Sequelize);
    console.log("✓ Migration completed successfully");

    await sequelize.close();
    process.exit(0);
  } catch (error) {
    console.error("✗ Migration failed:", error);
    await sequelize.close();
    process.exit(1);
  }
}

runMigration();
