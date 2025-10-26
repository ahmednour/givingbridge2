const { Sequelize } = require("sequelize");
const path = require("path");
const fs = require("fs");

class MigrationRunner {
  constructor(sequelize) {
    this.sequelize = sequelize;
    this.migrationsPath = path.join(__dirname, "..", "migrations");
  }

  async init() {
    try {
      // Create migrations table if it doesn't exist
      await this.sequelize.query(`
        CREATE TABLE IF NOT EXISTS \`SequelizeMeta\` (
          \`name\` VARCHAR(255) NOT NULL PRIMARY KEY
        );
      `);
      return true;
    } catch (error) {
      console.error("❌ Failed to initialize migrations table:", error.message);
      return false;
    }
  }

  async getExecutedMigrations() {
    try {
      const [results] = await this.sequelize.query(
        "SELECT name FROM `SequelizeMeta` ORDER BY name"
      );
      return results.map((row) => row.name);
    } catch (error) {
      console.error("❌ Failed to get executed migrations:", error.message);
      return [];
    }
  }

  async markMigrationAsExecuted(name) {
    try {
      await this.sequelize.query(
        "INSERT INTO `SequelizeMeta` (name) VALUES (?)",
        { replacements: [name] }
      );
      return true;
    } catch (error) {
      console.error(
        `❌ Failed to mark migration ${name} as executed:`,
        error.message
      );
      return false;
    }
  }

  async getPendingMigrations() {
    try {
      const migrationFiles = fs
        .readdirSync(this.migrationsPath)
        .filter((file) => file.endsWith(".js"))
        .sort();

      const executedMigrations = await this.getExecutedMigrations();

      return migrationFiles.filter(
        (file) => !executedMigrations.includes(file)
      );
    } catch (error) {
      console.error("❌ Failed to get pending migrations:", error.message);
      return [];
    }
  }

  async runMigrations() {
    const isInitialized = await this.init();
    if (!isInitialized) {
      console.log("🟡 Skipping migrations due to initialization failure");
      return;
    }

    const pendingMigrations = await this.getPendingMigrations();

    if (pendingMigrations.length === 0) {
      console.log("✅ No pending migrations");
      return;
    }

    console.log(`🔄 Running ${pendingMigrations.length} pending migrations...`);

    for (const migrationFile of pendingMigrations) {
      console.log(`📦 Running migration: ${migrationFile}`);

      try {
        const migration = require(path.join(
          this.migrationsPath,
          migrationFile
        ));
        await migration.up(this.sequelize.getQueryInterface(), Sequelize);
        const marked = await this.markMigrationAsExecuted(migrationFile);

        if (marked) {
          console.log(`✅ Migration ${migrationFile} completed`);
        } else {
          console.log(
            `⚠️ Migration ${migrationFile} completed but failed to mark as executed`
          );
        }
      } catch (error) {
        console.error(`❌ Migration ${migrationFile} failed:`, error.message);
        // Continue with other migrations instead of stopping everything
        continue;
      }
    }

    console.log("✅ Migration process completed");
  }

  async rollbackLastMigration() {
    const isInitialized = await this.init();
    if (!isInitialized) {
      console.log("🟡 Skipping rollback due to initialization failure");
      return;
    }

    const executedMigrations = await this.getExecutedMigrations();

    if (executedMigrations.length === 0) {
      console.log("No migrations to rollback");
      return;
    }

    const lastMigration = executedMigrations[executedMigrations.length - 1];
    console.log(`🔄 Rolling back migration: ${lastMigration}`);

    try {
      const migration = require(path.join(this.migrationsPath, lastMigration));
      await migration.down(this.sequelize.getQueryInterface(), Sequelize);

      // Remove from executed migrations
      await this.sequelize.query("DELETE FROM `SequelizeMeta` WHERE name = ?", {
        replacements: [lastMigration],
      });

      console.log(`✅ Migration ${lastMigration} rolled back`);
    } catch (error) {
      console.error(`❌ Rollback of ${lastMigration} failed:`, error.message);
      throw error;
    }
  }
}

module.exports = MigrationRunner;
