/**
 * Disaster Recovery Service
 * Monitors system health, backup status, and provides recovery capabilities
 */

console.log('Loading disaster recovery service dependencies...');

const fs = require('fs').promises;
const path = require('path');
const { exec } = require('child_process');
const { promisify } = require('util');

console.log('Loading logger...');
const logger = require('../utils/logger');

console.log('Loading backup monitoring service...');
const backupMonitoringService = require('./backupMonitoringService');

console.log('All dependencies loaded successfully');

const execAsync = promisify(exec);

class DisasterRecoveryService {
  constructor() {
    try {
      this.recoveryConfig = {
        recoveryTimeObjective: parseInt(process.env.RECOVERY_TIME_OBJECTIVE) || 3600, // 1 hour
        recoveryPointObjective: parseInt(process.env.RECOVERY_POINT_OBJECTIVE) || 1800, // 30 minutes
        backupDir: process.env.BACKUP_DIR || path.join(process.cwd(), 'backups'),
        recoveryLogDir: process.env.RECOVERY_LOG_DIR || path.join(process.cwd(), 'logs', 'recovery'),
        scriptPath: path.join(process.cwd(), '..', 'scripts', 'disaster-recovery.sh')
      };
      
      this.recoveryMetrics = {
        lastRecoveryTest: null,
        lastRecoveryTime: null,
        lastRecoveryDuration: null,
        recoveryReadiness: false,
        systemHealth: 'unknown'
      };
      
      // Initialize asynchronously to avoid blocking constructor
      this.initializeService().catch(error => {
        console.error('Failed to initialize disaster recovery service:', error);
      });
    } catch (error) {
      console.error('Error in DisasterRecoveryService constructor:', error);
      throw error;
    }
  }

  /**
   * Initialize the disaster recovery service
   */
  async initializeService() {
    try {
      await this.ensureDirectories();
      await this.loadRecoveryMetrics();
      logger.info('Disaster Recovery Service initialized');
    } catch (error) {
      logger.error('Failed to initialize Disaster Recovery Service:', error);
    }
  }

  /**
   * Ensure required directories exist
   */
  async ensureDirectories() {
    try {
      await fs.mkdir(this.recoveryConfig.recoveryLogDir, { recursive: true });
      await fs.mkdir(this.recoveryConfig.backupDir, { recursive: true });
    } catch (error) {
      logger.error('Failed to create recovery directories:', error);
      throw error;
    }
  }

  /**
   * Load recovery metrics from configuration file
   */
  async loadRecoveryMetrics() {
    try {
      const configPath = path.join(process.cwd(), '.recovery-config');
      const configExists = await fs.access(configPath).then(() => true).catch(() => false);
      
      if (configExists) {
        const configContent = await fs.readFile(configPath, 'utf8');
        const lines = configContent.split('\n');
        
        for (const line of lines) {
          if (line.startsWith('LAST_RECOVERY_TEST=')) {
            this.recoveryMetrics.lastRecoveryTest = line.split('=')[1];
          } else if (line.startsWith('LAST_RECOVERY_TIME=')) {
            this.recoveryMetrics.lastRecoveryTime = line.split('=')[1];
          } else if (line.startsWith('LAST_RECOVERY_DURATION=')) {
            this.recoveryMetrics.lastRecoveryDuration = parseInt(line.split('=')[1]);
          }
        }
      }
    } catch (error) {
      logger.warn('Failed to load recovery metrics:', error);
    }
  }

  /**
   * Check system health for disaster recovery readiness
   */
  async checkSystemHealth() {
    try {
      logger.info('Checking system health for disaster recovery');
      
      const { stdout, stderr } = await execAsync(`bash "${this.recoveryConfig.scriptPath}" health`);
      
      // Parse health check output
      const healthIssues = (stderr.match(/\[ERROR\]/g) || []).length;
      const healthWarnings = (stderr.match(/\[WARNING\]/g) || []).length;
      
      const healthStatus = {
        status: healthIssues === 0 ? 'healthy' : 'unhealthy',
        issues: healthIssues,
        warnings: healthWarnings,
        timestamp: new Date().toISOString(),
        details: stdout
      };
      
      this.recoveryMetrics.systemHealth = healthStatus.status;
      
      logger.info(`System health check completed: ${healthStatus.status} (${healthIssues} issues, ${healthWarnings} warnings)`);
      
      return healthStatus;
    } catch (error) {
      logger.error('System health check failed:', error);
      this.recoveryMetrics.systemHealth = 'error';
      
      return {
        status: 'error',
        issues: -1,
        warnings: -1,
        timestamp: new Date().toISOString(),
        error: error.message
      };
    }
  }

  /**
   * Monitor recovery readiness
   */
  async monitorRecoveryReadiness() {
    try {
      logger.info('Monitoring disaster recovery readiness');
      
      // Check backup freshness
      const backupStatus = await backupMonitoringService.getBackupStatus();
      
      // Check system health
      const healthStatus = await this.checkSystemHealth();
      
      // Determine recovery readiness
      const backupFresh = backupStatus.database.lastBackupAge <= this.recoveryConfig.recoveryPointObjective;
      const systemHealthy = healthStatus.status === 'healthy';
      
      const readiness = {
        ready: backupFresh && systemHealthy,
        backupFresh,
        systemHealthy,
        backupAge: backupStatus.database.lastBackupAge,
        recoveryPointObjective: this.recoveryConfig.recoveryPointObjective,
        recoveryTimeObjective: this.recoveryConfig.recoveryTimeObjective,
        timestamp: new Date().toISOString(),
        details: {
          backup: backupStatus,
          health: healthStatus
        }
      };
      
      this.recoveryMetrics.recoveryReadiness = readiness.ready;
      
      logger.info(`Recovery readiness: ${readiness.ready ? 'READY' : 'NOT READY'}`);
      
      return readiness;
    } catch (error) {
      logger.error('Recovery readiness monitoring failed:', error);
      this.recoveryMetrics.recoveryReadiness = false;
      
      return {
        ready: false,
        error: error.message,
        timestamp: new Date().toISOString()
      };
    }
  }

  /**
   * Test disaster recovery procedures
   */
  async testRecoveryProcedures() {
    try {
      logger.info('Starting disaster recovery test');
      
      const testStartTime = Date.now();
      
      const { stdout, stderr } = await execAsync(`bash "${this.recoveryConfig.scriptPath}" test`);
      
      const testEndTime = Date.now();
      const testDuration = Math.floor((testEndTime - testStartTime) / 1000);
      
      // Check if test was successful
      const testSuccess = !stderr.includes('[ERROR]') && !stderr.includes('[CRITICAL]');
      
      const testResult = {
        success: testSuccess,
        duration: testDuration,
        timestamp: new Date().toISOString(),
        output: stdout,
        errors: stderr,
        withinObjective: testDuration <= this.recoveryConfig.recoveryTimeObjective
      };
      
      // Update metrics
      this.recoveryMetrics.lastRecoveryTest = testResult.timestamp;
      
      // Save test result to config
      await this.updateRecoveryConfig({
        LAST_RECOVERY_TEST: testResult.timestamp,
        LAST_TEST_STATUS: testSuccess ? 'success' : 'failed',
        LAST_TEST_DURATION: testDuration
      });
      
      logger.info(`Recovery test completed: ${testSuccess ? 'SUCCESS' : 'FAILED'} (${testDuration}s)`);
      
      return testResult;
    } catch (error) {
      logger.error('Recovery test failed:', error);
      
      return {
        success: false,
        error: error.message,
        timestamp: new Date().toISOString()
      };
    }
  }

  /**
   * Perform actual disaster recovery (DESTRUCTIVE)
   */
  async performDisasterRecovery(confirmation = false) {
    if (!confirmation) {
      throw new Error('Disaster recovery requires explicit confirmation');
    }
    
    try {
      logger.critical('Starting FULL DISASTER RECOVERY - This is DESTRUCTIVE!');
      
      const recoveryStartTime = Date.now();
      
      const { stdout, stderr } = await execAsync(`bash "${this.recoveryConfig.scriptPath}" recover`, {
        input: 'YES\n' // Auto-confirm the recovery
      });
      
      const recoveryEndTime = Date.now();
      const recoveryDuration = Math.floor((recoveryEndTime - recoveryStartTime) / 1000);
      
      // Check if recovery was successful
      const recoverySuccess = !stderr.includes('[CRITICAL]') && stderr.includes('RECOVERY COMPLETED');
      
      const recoveryResult = {
        success: recoverySuccess,
        duration: recoveryDuration,
        timestamp: new Date().toISOString(),
        output: stdout,
        errors: stderr,
        withinObjective: recoveryDuration <= this.recoveryConfig.recoveryTimeObjective
      };
      
      // Update metrics
      this.recoveryMetrics.lastRecoveryTime = recoveryResult.timestamp;
      this.recoveryMetrics.lastRecoveryDuration = recoveryDuration;
      
      // Save recovery result to config
      await this.updateRecoveryConfig({
        LAST_RECOVERY_TIME: recoveryResult.timestamp,
        LAST_RECOVERY_STATUS: recoverySuccess ? 'success' : 'failed',
        LAST_RECOVERY_DURATION: recoveryDuration
      });
      
      logger.critical(`Disaster recovery completed: ${recoverySuccess ? 'SUCCESS' : 'FAILED'} (${recoveryDuration}s)`);
      
      return recoveryResult;
    } catch (error) {
      logger.error('Disaster recovery failed:', error);
      
      return {
        success: false,
        error: error.message,
        timestamp: new Date().toISOString()
      };
    }
  }

  /**
   * Get recovery status and metrics
   */
  async getRecoveryStatus() {
    try {
      const readiness = await this.monitorRecoveryReadiness();
      
      return {
        config: this.recoveryConfig,
        metrics: this.recoveryMetrics,
        readiness,
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      logger.error('Failed to get recovery status:', error);
      
      return {
        error: error.message,
        timestamp: new Date().toISOString()
      };
    }
  }

  /**
   * Update recovery configuration file
   */
  async updateRecoveryConfig(updates) {
    try {
      const configPath = path.join(process.cwd(), '.recovery-config');
      
      let configContent = '';
      const configExists = await fs.access(configPath).then(() => true).catch(() => false);
      
      if (configExists) {
        configContent = await fs.readFile(configPath, 'utf8');
      }
      
      // Update or add configuration values
      for (const [key, value] of Object.entries(updates)) {
        const regex = new RegExp(`^${key}=.*$`, 'm');
        const newLine = `${key}=${value}`;
        
        if (regex.test(configContent)) {
          configContent = configContent.replace(regex, newLine);
        } else {
          configContent += `\n${newLine}`;
        }
      }
      
      await fs.writeFile(configPath, configContent);
      logger.info('Recovery configuration updated');
    } catch (error) {
      logger.error('Failed to update recovery configuration:', error);
    }
  }

  /**
   * Get recovery time metrics
   */
  getRecoveryTimeMetrics() {
    return {
      recoveryTimeObjective: this.recoveryConfig.recoveryTimeObjective,
      recoveryPointObjective: this.recoveryConfig.recoveryPointObjective,
      lastRecoveryDuration: this.recoveryMetrics.lastRecoveryDuration,
      lastTestTime: this.recoveryMetrics.lastRecoveryTest,
      lastRecoveryTime: this.recoveryMetrics.lastRecoveryTime,
      recoveryReadiness: this.recoveryMetrics.recoveryReadiness,
      systemHealth: this.recoveryMetrics.systemHealth
    };
  }
}

try {
  console.log('Creating DisasterRecoveryService instance...');
  const instance = new DisasterRecoveryService();
  console.log('DisasterRecoveryService instance created successfully');
  module.exports = instance;
} catch (error) {
  console.error('Failed to create DisasterRecoveryService instance:', error);
  module.exports = {};
}