const fs = require("fs").promises;
const path = require("path");
const { testSequelize } = require("../config/test-db");

class TestMigrationRunner {
  constructor() {
    this.migrationsPath = path.join(__dirname, "../migrations");
    this.executedMigrations = new Set();
  }

  async getMigrationFiles() {
    try {
      const files = await fs.readdir(this.migrationsPath);
      return files
        .filter(file => file.endsWith(".js"))
        .sort()
        .map(file => ({
          name: file,
          path: path.join(this.migrationsPath, file),
        }));
    } catch (error) {
      console.error("❌ Failed to read migration files:", error);
      return [];
    }
  }

  async createMigrationsTable() {
    try {
      await testSequelize.query(`
        CREATE TABLE IF NOT EXISTS test_migrations (
          id INT PRIMARY KEY AUTO_INCREMENT,
          name VARCHAR(255) NOT NULL UNIQUE,
          executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      `);
      console.log("✅ Test migrations table created");
    } catch (error) {
      console.error("❌ Failed to create migrations table:", error);
      throw error;
    }
  }

  async getExecutedMigrations() {
    try {
      const [results] = await testSequelize.query(
        "SELECT name FROM test_migrations ORDER BY executed_at"
      );
      return results.map(row => row.name);
    } catch (error) {
      console.warn("⚠️ Could not fetch executed migrations:", error.message);
      return [];
    }
  }

  async executeMigration(migrationFile) {
    try {
      console.log(`🔄 Executing migration: ${migrationFile.name}`);
      
      // Load and execute the migration
      const migration = require(migrationFile.path);
      
      if (typeof migration.up === "function") {
        await migration.up(testSequelize.getQueryInterface(), testSequelize.constructor);
      } else {
        console.warn(`⚠️ Migration ${migrationFile.name} has no 'up' function`);
      }

      // Record the migration as executed
      await testSequelize.query(
        "INSERT INTO test_migrations (name) VALUES (?)",
        {
          replacements: [migrationFile.name],
        }
      );

      this.executedMigrations.add(migrationFile.name);
      console.log(`✅ Migration ${migrationFile.name} executed successfully`);
    } catch (error) {
      console.error(`❌ Failed to execute migration ${migrationFile.name}:`, error);
      throw error;
    }
  }

  async runMigrations() {
    try {
      console.log("🚀 Running test database migrations...");

      // Create migrations tracking table
      await this.createMigrationsTable();

      // Get all migration files
      const migrationFiles = await this.getMigrationFiles();
      if (migrationFiles.length === 0) {
        console.log("📝 No migration files found");
        return;
      }

      // Get already executed migrations
      const executedMigrations = await this.getExecutedMigrations();
      
      // Filter out already executed migrations
      const pendingMigrations = migrationFiles.filter(
        file => !executedMigrations.includes(file.name)
      );

      if (pendingMigrations.length === 0) {
        console.log("✅ All migrations are up to date");
        return;
      }

      console.log(`📋 Found ${pendingMigrations.length} pending migrations`);

      // Execute pending migrations
      for (const migrationFile of pendingMigrations) {
        await this.executeMigration(migrationFile);
      }

      console.log("✅ All test migrations completed successfully");
    } catch (error) {
      console.error("❌ Migration execution failed:", error);
      throw error;
    }
  }

  async rollbackMigration(migrationName) {
    try {
      console.log(`🔄 Rolling back migration: ${migrationName}`);
      
      const migrationPath = path.join(this.migrationsPath, migrationName);
      const migration = require(migrationPath);
      
      if (typeof migration.down === "function") {
        await migration.down(testSequelize.getQueryInterface(), testSequelize.constructor);
      } else {
        console.warn(`⚠️ Migration ${migrationName} has no 'down' function`);
      }

      // Remove from executed migrations
      await testSequelize.query(
        "DELETE FROM test_migrations WHERE name = ?",
        {
          replacements: [migrationName],
        }
      );

      this.executedMigrations.delete(migrationName);
      console.log(`✅ Migration ${migrationName} rolled back successfully`);
    } catch (error) {
      console.error(`❌ Failed to rollback migration ${migrationName}:`, error);
      throw error;
    }
  }

  async resetDatabase() {
    try {
      console.log("🔄 Resetting test database...");

      // Drop all tables
      await testSequelize.query("SET FOREIGN_KEY_CHECKS = 0");
      
      const [tables] = await testSequelize.query(
        "SELECT table_name FROM information_schema.tables WHERE table_schema = DATABASE()"
      );

      for (const table of tables) {
        await testSequelize.query(`DROP TABLE IF EXISTS \`${table.table_name}\``);
      }

      await testSequelize.query("SET FOREIGN_KEY_CHECKS = 1");

      // Clear executed migrations tracking
      this.executedMigrations.clear();

      console.log("✅ Test database reset successfully");
    } catch (error) {
      console.error("❌ Failed to reset test database:", error);
      throw error;
    }
  }

  async syncModels() {
    try {
      console.log("🔄 Syncing test database models...");
      
      // Import all models to ensure they're loaded
      require("../models");
      
      // Sync all models
      await testSequelize.sync({ force: true });
      
      console.log("✅ Test database models synced successfully");
    } catch (error) {
      console.error("❌ Failed to sync test database models:", error);
      throw error;
    }
  }
}

module.exports = TestMigrationRunner;