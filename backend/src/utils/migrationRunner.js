const { Sequelize } = require("sequelize");
const path = require("path");
const fs = require("fs");

class MigrationRunner {
  constructor(sequelize) {
    this.sequelize = sequelize;
    this.migrationsPath = path.join(__dirname, "..", "migrations");
    // SECURITY: Hardcoded table names to prevent SQL injection
    // These are system tables and should never come from user input
    this.migrationStatusTable = "SequelizeMeta";
    this.migrationHistoryTable = "MigrationHistory";
    
    // Validate table names are safe (alphanumeric only)
    this._validateTableName(this.migrationStatusTable);
    this._validateTableName(this.migrationHistoryTable);
  }

  /**
   * SECURITY: Validate table names to prevent SQL injection
   * Only allows alphanumeric characters and underscores
   */
  _validateTableName(tableName) {
    if (!/^[a-zA-Z0-9_]+$/.test(tableName)) {
      throw new Error(`Invalid table name: ${tableName}. Only alphanumeric characters and underscores allowed.`);
    }
  }

  async init() {
    try {
      // SECURITY: Table names are validated and hardcoded
      // Using backticks to properly escape identifiers
      await this.sequelize.query(
        `CREATE TABLE IF NOT EXISTS \`${this.migrationStatusTable}\` (
          \`name\` VARCHAR(255) NOT NULL PRIMARY KEY,
          \`executed_at\` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );`,
        { type: Sequelize.QueryTypes.RAW }
      );

      await this.sequelize.query(
        `CREATE TABLE IF NOT EXISTS \`${this.migrationHistoryTable}\` (
          \`id\` INT AUTO_INCREMENT PRIMARY KEY,
          \`migration_name\` VARCHAR(255) NOT NULL,
          \`action\` ENUM('up', 'down') NOT NULL,
          \`status\` ENUM('started', 'completed', 'failed', 'rolled_back') NOT NULL,
          \`error_message\` TEXT NULL,
          \`execution_time_ms\` INT NULL,
          \`executed_at\` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          INDEX \`idx_migration_name\` (\`migration_name\`),
          INDEX \`idx_executed_at\` (\`executed_at\`)
        );`,
        { type: Sequelize.QueryTypes.RAW }
      );

      console.log("✅ Migration tables initialized successfully");
      return true;
    } catch (error) {
      console.error("❌ Failed to initialize migration tables:", error.message);
      return false;
    }
  }

  async getExecutedMigrations() {
    try {
      // SECURITY: Using parameterized query with validated table name
      const [results] = await this.sequelize.query(
        `SELECT name, executed_at FROM \`${this.migrationStatusTable}\` ORDER BY name`,
        { type: Sequelize.QueryTypes.SELECT }
      );
      return results.map((row) => ({
        name: row.name,
        executedAt: row.executed_at
      }));
    } catch (error) {
      console.error("❌ Failed to get executed migrations:", error.message);
      return [];
    }
  }

  async markMigrationAsExecuted(name) {
    try {
      // SECURITY: Using parameterized query with replacements
      await this.sequelize.query(
        `INSERT INTO \`${this.migrationStatusTable}\` (name, executed_at) VALUES (?, NOW())`,
        { 
          replacements: [name],
          type: Sequelize.QueryTypes.INSERT
        }
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

  async removeMigrationFromExecuted(name) {
    try {
      // SECURITY: Using parameterized query with replacements
      await this.sequelize.query(
        `DELETE FROM \`${this.migrationStatusTable}\` WHERE name = ?`,
        { 
          replacements: [name],
          type: Sequelize.QueryTypes.DELETE
        }
      );
      return true;
    } catch (error) {
      console.error(
        `❌ Failed to remove migration ${name} from executed:`,
        error.message
      );
      return false;
    }
  }

  async logMigrationHistory(migrationName, action, status, errorMessage = null, executionTime = null) {
    try {
      // SECURITY: Using parameterized query with replacements
      await this.sequelize.query(
        `INSERT INTO \`${this.migrationHistoryTable}\` 
         (migration_name, action, status, error_message, execution_time_ms, executed_at) 
         VALUES (?, ?, ?, ?, ?, NOW())`,
        { 
          replacements: [migrationName, action, status, errorMessage, executionTime],
          type: Sequelize.QueryTypes.INSERT
        }
      );
    } catch (error) {
      console.error(`⚠️ Failed to log migration history for ${migrationName}:`, error.message);
    }
  }

  async getPendingMigrations() {
    try {
      // Check if migrations directory exists
      if (!fs.existsSync(this.migrationsPath)) {
        console.log(`📁 Migrations directory not found: ${this.migrationsPath}`);
        return [];
      }

      const migrationFiles = fs
        .readdirSync(this.migrationsPath)
        .filter((file) => file.endsWith(".js"))
        .sort();

      const executedMigrations = await this.getExecutedMigrations();
      const executedNames = executedMigrations.map(m => m.name);

      const pendingMigrations = migrationFiles.filter(
        (file) => !executedNames.includes(file)
      );

      console.log(`📋 Found ${migrationFiles.length} total migrations, ${pendingMigrations.length} pending`);
      return pendingMigrations;
    } catch (error) {
      console.error("❌ Failed to get pending migrations:", error.message);
      return [];
    }
  }

  async validateMigrationFile(migrationFile) {
    try {
      const migrationPath = path.join(this.migrationsPath, migrationFile);
      const migration = require(migrationPath);
      
      if (typeof migration.up !== 'function') {
        throw new Error(`Migration ${migrationFile} is missing 'up' function`);
      }
      
      if (typeof migration.down !== 'function') {
        console.warn(`⚠️ Migration ${migrationFile} is missing 'down' function (rollback not possible)`);
      }
      
      return true;
    } catch (error) {
      console.error(`❌ Invalid migration file ${migrationFile}:`, error.message);
      return false;
    }
  }

  async runMigrations() {
    const isInitialized = await this.init();
    if (!isInitialized) {
      console.log("🟡 Skipping migrations due to initialization failure");
      return { success: false, error: "Initialization failed" };
    }

    const pendingMigrations = await this.getPendingMigrations();

    if (pendingMigrations.length === 0) {
      console.log("✅ No pending migrations");
      return { success: true, migrationsRun: 0 };
    }

    console.log(`🔄 Running ${pendingMigrations.length} pending migrations...`);

    const results = {
      success: true,
      migrationsRun: 0,
      failed: [],
      completed: []
    };

    for (const migrationFile of pendingMigrations) {
      console.log(`📦 Running migration: ${migrationFile}`);
      
      // Validate migration file first
      const isValid = await this.validateMigrationFile(migrationFile);
      if (!isValid) {
        results.failed.push({ migration: migrationFile, error: "Invalid migration file" });
        continue;
      }

      const startTime = Date.now();
      
      // Log migration start
      await this.logMigrationHistory(migrationFile, 'up', 'started');

      try {
        const migration = require(path.join(this.migrationsPath, migrationFile));
        
        // Run migration within a transaction
        await this.sequelize.transaction(async (transaction) => {
          await migration.up(this.sequelize.getQueryInterface(), Sequelize, transaction);
        });

        const executionTime = Date.now() - startTime;
        const marked = await this.markMigrationAsExecuted(migrationFile);

        if (marked) {
          await this.logMigrationHistory(migrationFile, 'up', 'completed', null, executionTime);
          console.log(`✅ Migration ${migrationFile} completed in ${executionTime}ms`);
          results.completed.push(migrationFile);
          results.migrationsRun++;
        } else {
          await this.logMigrationHistory(migrationFile, 'up', 'failed', 'Failed to mark as executed');
          console.log(`⚠️ Migration ${migrationFile} completed but failed to mark as executed`);
          results.failed.push({ migration: migrationFile, error: "Failed to mark as executed" });
        }
      } catch (error) {
        const executionTime = Date.now() - startTime;
        await this.logMigrationHistory(migrationFile, 'up', 'failed', error.message, executionTime);
        console.error(`❌ Migration ${migrationFile} failed after ${executionTime}ms:`, error.message);
        
        results.failed.push({ migration: migrationFile, error: error.message });
        results.success = false;
        
        // Continue with other migrations instead of stopping everything
        continue;
      }
    }

    if (results.failed.length > 0) {
      console.log(`⚠️ Migration process completed with ${results.failed.length} failures`);
    } else {
      console.log("✅ All migrations completed successfully");
    }

    return results;
  }

  async rollbackLastMigration() {
    const isInitialized = await this.init();
    if (!isInitialized) {
      console.log("🟡 Skipping rollback due to initialization failure");
      return { success: false, error: "Initialization failed" };
    }

    const executedMigrations = await this.getExecutedMigrations();

    if (executedMigrations.length === 0) {
      console.log("No migrations to rollback");
      return { success: true, message: "No migrations to rollback" };
    }

    // Get the last executed migration
    const lastMigration = executedMigrations[executedMigrations.length - 1];
    const migrationName = lastMigration.name;
    
    console.log(`🔄 Rolling back migration: ${migrationName}`);

    const startTime = Date.now();
    
    // Log rollback start
    await this.logMigrationHistory(migrationName, 'down', 'started');

    try {
      const migrationPath = path.join(this.migrationsPath, migrationName);
      
      // Check if migration file exists
      if (!fs.existsSync(migrationPath)) {
        throw new Error(`Migration file not found: ${migrationName}`);
      }

      const migration = require(migrationPath);
      
      // Check if down method exists
      if (typeof migration.down !== 'function') {
        throw new Error(`Migration ${migrationName} does not support rollback (no 'down' method)`);
      }

      // Run rollback within a transaction
      await this.sequelize.transaction(async (transaction) => {
        await migration.down(this.sequelize.getQueryInterface(), Sequelize, transaction);
      });

      // Remove from executed migrations
      const removed = await this.removeMigrationFromExecuted(migrationName);
      
      if (!removed) {
        throw new Error("Failed to remove migration from executed list");
      }

      const executionTime = Date.now() - startTime;
      await this.logMigrationHistory(migrationName, 'down', 'completed', null, executionTime);

      console.log(`✅ Migration ${migrationName} rolled back successfully in ${executionTime}ms`);
      return { success: true, migration: migrationName, executionTime };
      
    } catch (error) {
      const executionTime = Date.now() - startTime;
      await this.logMigrationHistory(migrationName, 'down', 'failed', error.message, executionTime);
      console.error(`❌ Rollback of ${migrationName} failed after ${executionTime}ms:`, error.message);
      return { success: false, error: error.message, migration: migrationName };
    }
  }

  async rollbackToMigration(targetMigration) {
    const isInitialized = await this.init();
    if (!isInitialized) {
      console.log("🟡 Skipping rollback due to initialization failure");
      return { success: false, error: "Initialization failed" };
    }

    const executedMigrations = await this.getExecutedMigrations();
    const executedNames = executedMigrations.map(m => m.name).sort();
    
    // Find the target migration index
    const targetIndex = executedNames.indexOf(targetMigration);
    
    if (targetIndex === -1) {
      return { success: false, error: `Target migration ${targetMigration} not found in executed migrations` };
    }

    // Get migrations to rollback (all migrations after the target)
    const migrationsToRollback = executedNames.slice(targetIndex + 1).reverse();
    
    if (migrationsToRollback.length === 0) {
      return { success: true, message: `Already at migration ${targetMigration}` };
    }

    console.log(`🔄 Rolling back ${migrationsToRollback.length} migrations to reach ${targetMigration}`);

    const results = {
      success: true,
      rolledBack: [],
      failed: []
    };

    for (const migrationName of migrationsToRollback) {
      const result = await this.rollbackLastMigration();
      
      if (result.success) {
        results.rolledBack.push(migrationName);
      } else {
        results.failed.push({ migration: migrationName, error: result.error });
        results.success = false;
        break; // Stop on first failure
      }
    }

    return results;
  }

  async getMigrationStatus() {
    try {
      const executedMigrations = await this.getExecutedMigrations();
      const pendingMigrations = await this.getPendingMigrations();
      
      // Get migration history
      const [historyResults] = await this.sequelize.query(
        `SELECT migration_name, action, status, error_message, execution_time_ms, executed_at 
         FROM \`${this.migrationHistoryTable}\` 
         ORDER BY executed_at DESC 
         LIMIT 10`
      );

      return {
        executed: executedMigrations,
        pending: pendingMigrations,
        recentHistory: historyResults
      };
    } catch (error) {
      console.error("❌ Failed to get migration status:", error.message);
      return { error: error.message };
    }
  }
}

module.exports = MigrationRunner;
