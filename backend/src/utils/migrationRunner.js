const { Sequelize } = require("sequelize");
const path = require("path");
const fs = require("fs");

class MigrationRunner {
  constructor(sequelize) {
    this.sequelize = sequelize;
    this.migrationsPath = path.join(__dirname, "..", "migrations");
  }

  async init() {
    // Create migrations table if it doesn't exist
    await this.sequelize.query(`
      CREATE TABLE IF NOT EXISTS \`SequelizeMeta\` (
        \`name\` VARCHAR(255) NOT NULL PRIMARY KEY
      );
    `);
  }

  async getExecutedMigrations() {
    const [results] = await this.sequelize.query(
      "SELECT name FROM `SequelizeMeta` ORDER BY name"
    );
    return results.map((row) => row.name);
  }

  async markMigrationAsExecuted(name) {
    await this.sequelize.query(
      "INSERT INTO `SequelizeMeta` (name) VALUES (?)",
      { replacements: [name] }
    );
  }

  async getPendingMigrations() {
    const migrationFiles = fs
      .readdirSync(this.migrationsPath)
      .filter((file) => file.endsWith(".js"))
      .sort();

    const executedMigrations = await this.getExecutedMigrations();

    return migrationFiles.filter((file) => !executedMigrations.includes(file));
  }

  async runMigrations() {
    await this.init();

    const pendingMigrations = await this.getPendingMigrations();

    if (pendingMigrations.length === 0) {
      console.log("✅ No pending migrations");
      return;
    }

    console.log(`🔄 Running ${pendingMigrations.length} pending migrations...`);

    for (const migrationFile of pendingMigrations) {
      console.log(`📦 Running migration: ${migrationFile}`);

      const migration = require(path.join(this.migrationsPath, migrationFile));

      try {
        await migration.up(this.sequelize.getQueryInterface(), Sequelize);
        await this.markMigrationAsExecuted(migrationFile);
        console.log(`✅ Migration ${migrationFile} completed`);
      } catch (error) {
        console.error(`❌ Migration ${migrationFile} failed:`, error);
        throw error;
      }
    }

    console.log("✅ All migrations completed successfully");
  }

  async rollbackLastMigration() {
    await this.init();

    const executedMigrations = await this.getExecutedMigrations();

    if (executedMigrations.length === 0) {
      console.log("No migrations to rollback");
      return;
    }

    const lastMigration = executedMigrations[executedMigrations.length - 1];
    console.log(`🔄 Rolling back migration: ${lastMigration}`);

    const migration = require(path.join(this.migrationsPath, lastMigration));

    try {
      await migration.down(this.sequelize.getQueryInterface(), Sequelize);
      await this.sequelize.query("DELETE FROM `SequelizeMeta` WHERE name = ?", {
        replacements: [lastMigration],
      });
      console.log(`✅ Migration ${lastMigration} rolled back`);
    } catch (error) {
      console.error(`❌ Rollback of ${lastMigration} failed:`, error);
      throw error;
    }
  }
}

module.exports = MigrationRunner;
