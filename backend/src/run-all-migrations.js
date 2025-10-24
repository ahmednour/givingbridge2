const { Sequelize } = require("sequelize");
require("dotenv").config();

const sequelize = new Sequelize(
  process.env.DB_NAME || "givingbridge",
  process.env.DB_USER || "givingbridge_user",
  process.env.DB_PASSWORD || "secure_prod_password_2024",
  {
    host: process.env.DB_HOST || "db",
    port: process.env.DB_PORT || 3306,
    dialect: "mysql",
    logging: false, // Reduce noise
  }
);

// List of migrations to run in order
const migrations = [
  { file: "006_create_notifications_table", name: "notifications" },
  { file: "007_create_ratings_table", name: "ratings" },
  { file: "008_create_blocked_users_table", name: "blocked_users" },
  { file: "009_create_user_reports_table", name: "user_reports" },
  { file: "011_add_archived_to_messages", name: "archived column in messages" },
  {
    file: "012_create_notification_preferences_table",
    name: "notification_preferences",
  },
];

async function runAllMigrations() {
  try {
    console.log("🔌 Connecting to database...");
    await sequelize.authenticate();
    console.log("✅ Database connection established\n");

    const queryInterface = sequelize.getQueryInterface();
    let successCount = 0;
    let skipCount = 0;
    let errorCount = 0;

    for (const migration of migrations) {
      try {
        console.log(`📦 Running migration: ${migration.file}...`);
        const migrationModule = require(`./migrations/${migration.file}`);

        await migrationModule.up(queryInterface, Sequelize);
        console.log(`✅ Successfully created: ${migration.name}\n`);
        successCount++;
      } catch (error) {
        if (error.message && error.message.includes("already exists")) {
          console.log(`⏭️  Skipped (already exists): ${migration.name}\n`);
          skipCount++;
        } else {
          console.error(
            `❌ Failed to create ${migration.name}:`,
            error.message
          );
          errorCount++;
        }
      }
    }

    console.log("\n" + "=".repeat(50));
    console.log("📊 Migration Summary:");
    console.log(`✅ Successful: ${successCount}`);
    console.log(`⏭️  Skipped: ${skipCount}`);
    console.log(`❌ Failed: ${errorCount}`);
    console.log("=".repeat(50));

    await sequelize.close();

    if (errorCount > 0) {
      console.log(
        "\n⚠️  Some migrations failed. Please check the errors above."
      );
      process.exit(1);
    } else {
      console.log("\n🎉 All migrations completed successfully!");
      process.exit(0);
    }
  } catch (error) {
    console.error("❌ Migration process failed:", error);
    await sequelize.close();
    process.exit(1);
  }
}

runAllMigrations();
