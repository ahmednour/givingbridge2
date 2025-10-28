/**
 * Backup Monitoring Service
 * Monitors backup operations, verifies integrity, and sends alerts
 */

const fs = require('fs').promises;
const path = require('path');
const { spawn } = require('child_process');
const logger = require('../utils/logger');

class BackupMonitoringService {
  constructor() {
    this.config = {
      backupDir: process.env.BACKUP_DIR || './backups/database',
      maxBackupAge: parseInt(process.env.MAX_BACKUP_AGE_HOURS) || 25, // 25 hours
      minBackupSize: parseInt(process.env.MIN_BACKUP_SIZE_MB) || 1, // 1 MB minimum
      alertThreshold: parseInt(process.env.BACKUP_ALERT_THRESHOLD) || 2, // Alert after 2 failed checks
      checkInterval: parseInt(process.env.BACKUP_CHECK_INTERVAL) || 3600000, // 1 hour
      retentionDays: parseInt(process.env.BACKUP_RETENTION_DAYS) || 30
    };
    
    this.metrics = {
      lastBackupTime: null,
      lastBackupSize: 0,
      backupCount: 0,
      failedChecks: 0,
      successfulBackups: 0,
      failedBackups: 0,
      averageBackupSize: 0,
      compressionRatio: 0
    };
    
    this.alerts = [];
    this.isMonitoring = false;
    this.monitoringInterval = null;
  }

  /**
   * Start backup monitoring
   */
  async startMonitoring() {
    if (this.isMonitoring) {
      logger.warn('Backup monitoring is already running');
      return;
    }

    logger.info('Starting backup monitoring service', {
      config: this.config
    });

    try {
      // Initial backup check
      await this.checkBackupStatus();
      
      // Start periodic monitoring
      this.monitoringInterval = setInterval(async () => {
        try {
          await this.checkBackupStatus();
        } catch (error) {
          logger.error('Error during backup monitoring check', {
            error: error.message,
            stack: error.stack
          });
        }
      }, this.config.checkInterval);
      
      this.isMonitoring = true;
      logger.info('Backup monitoring started successfully');
    } catch (error) {
      logger.error('Failed to start backup monitoring', {
        error: error.message
      });
      throw error;
    }
  }

  /**
   * Stop backup monitoring
   */
  stopMonitoring() {
    if (this.monitoringInterval) {
      clearInterval(this.monitoringInterval);
      this.monitoringInterval = null;
    }
    
    this.isMonitoring = false;
    logger.info('Backup monitoring stopped');
  }

  /**
   * Check backup status and health
   */
  async checkBackupStatus() {
    logger.debug('Checking backup status...');
    
    try {
      // Check if backup directory exists
      await this.ensureBackupDirectory();
      
      // Get backup files
      const backupFiles = await this.getBackupFiles();
      
      if (backupFiles.length === 0) {
        await this.handleNoBackupsFound();
        return;
      }
      
      // Check latest backup
      const latestBackup = await this.getLatestBackup(backupFiles);
      await this.verifyBackupHealth(latestBackup);
      
      // Update metrics
      await this.updateMetrics(backupFiles);
      
      // Check for old backups
      await this.checkBackupRetention(backupFiles);
      
      // Reset failed checks on success
      this.metrics.failedChecks = 0;
      
      logger.debug('Backup status check completed successfully');
    } catch (error) {
      this.metrics.failedChecks++;
      logger.error('Backup status check failed', {
        error: error.message,
        failedChecks: this.metrics.failedChecks
      });
      
      // Send alert if threshold reached
      if (this.metrics.failedChecks >= this.config.alertThreshold) {
        await this.sendAlert('BACKUP_CHECK_FAILED', {
          error: error.message,
          failedChecks: this.metrics.failedChecks
        });
      }
      
      throw error;
    }
  }

  /**
   * Ensure backup directory exists
   */
  async ensureBackupDirectory() {
    try {
      await fs.access(this.config.backupDir);
    } catch (error) {
      if (error.code === 'ENOENT') {
        logger.warn('Backup directory does not exist', {
          directory: this.config.backupDir
        });
        throw new Error(`Backup directory not found: ${this.config.backupDir}`);
      }
      throw error;
    }
  }

  /**
   * Get all backup files
   */
  async getBackupFiles() {
    const files = await fs.readdir(this.config.backupDir);
    const backupFiles = [];
    
    for (const file of files) {
      if (file.match(/.*_backup_\d{8}_\d{6}\.(sql|sql\.gz)$/)) {
        const filePath = path.join(this.config.backupDir, file);
        const stats = await fs.stat(filePath);
        
        backupFiles.push({
          name: file,
          path: filePath,
          size: stats.size,
          mtime: stats.mtime,
          isCompressed: file.endsWith('.gz')
        });
      }
    }
    
    // Sort by modification time (newest first)
    backupFiles.sort((a, b) => b.mtime - a.mtime);
    
    return backupFiles;
  }

  /**
   * Get latest backup file
   */
  async getLatestBackup(backupFiles) {
    if (backupFiles.length === 0) {
      throw new Error('No backup files found');
    }
    
    return backupFiles[0];
  }

  /**
   * Verify backup health
   */
  async verifyBackupHealth(backup) {
    logger.debug('Verifying backup health', {
      file: backup.name,
      size: backup.size,
      mtime: backup.mtime
    });
    
    // Check backup age
    const backupAge = Date.now() - backup.mtime.getTime();
    const maxAge = this.config.maxBackupAge * 60 * 60 * 1000; // Convert hours to ms
    
    if (backupAge > maxAge) {
      const ageHours = Math.round(backupAge / (60 * 60 * 1000));
      await this.sendAlert('BACKUP_TOO_OLD', {
        file: backup.name,
        ageHours,
        maxAgeHours: this.config.maxBackupAge
      });
      throw new Error(`Backup is too old: ${ageHours} hours (max: ${this.config.maxBackupAge})`);
    }
    
    // Check backup size
    const minSize = this.config.minBackupSize * 1024 * 1024; // Convert MB to bytes
    if (backup.size < minSize) {
      await this.sendAlert('BACKUP_TOO_SMALL', {
        file: backup.name,
        sizeMB: Math.round(backup.size / (1024 * 1024)),
        minSizeMB: this.config.minBackupSize
      });
      throw new Error(`Backup is too small: ${backup.size} bytes (min: ${minSize})`);
    }
    
    // Verify file integrity
    await this.verifyFileIntegrity(backup);
    
    logger.debug('Backup health verification passed', {
      file: backup.name
    });
  }

  /**
   * Verify file integrity
   */
  async verifyFileIntegrity(backup) {
    return new Promise((resolve, reject) => {
      let command, args;
      
      if (backup.isCompressed) {
        // Test gzip integrity
        command = 'gzip';
        args = ['-t', backup.path];
      } else {
        // Check if file contains valid SQL
        command = 'head';
        args = ['-n', '5', backup.path];
      }
      
      const process = spawn(command, args);
      let output = '';
      let error = '';
      
      process.stdout.on('data', (data) => {
        output += data.toString();
      });
      
      process.stderr.on('data', (data) => {
        error += data.toString();
      });
      
      process.on('close', (code) => {
        if (code !== 0) {
          reject(new Error(`File integrity check failed: ${error}`));
          return;
        }
        
        // For uncompressed files, check SQL content
        if (!backup.isCompressed) {
          if (!output.includes('-- MySQL dump')) {
            reject(new Error('File does not appear to be a valid MySQL dump'));
            return;
          }
        }
        
        resolve();
      });
      
      process.on('error', (err) => {
        reject(new Error(`Failed to verify file integrity: ${err.message}`));
      });
    });
  }

  /**
   * Update backup metrics
   */
  async updateMetrics(backupFiles) {
    if (backupFiles.length === 0) {
      return;
    }
    
    const latestBackup = backupFiles[0];
    
    this.metrics.lastBackupTime = latestBackup.mtime;
    this.metrics.lastBackupSize = latestBackup.size;
    this.metrics.backupCount = backupFiles.length;
    
    // Calculate average backup size
    const totalSize = backupFiles.reduce((sum, file) => sum + file.size, 0);
    this.metrics.averageBackupSize = Math.round(totalSize / backupFiles.length);
    
    // Calculate compression ratio (if applicable)
    const compressedFiles = backupFiles.filter(f => f.isCompressed);
    if (compressedFiles.length > 0) {
      // This is an approximation - actual ratio would need uncompressed size
      this.metrics.compressionRatio = 0.3; // Typical SQL compression ratio
    }
    
    logger.debug('Backup metrics updated', {
      metrics: this.metrics
    });
  }

  /**
   * Check backup retention policy
   */
  async checkBackupRetention(backupFiles) {
    const retentionTime = this.config.retentionDays * 24 * 60 * 60 * 1000; // Convert days to ms
    const cutoffTime = Date.now() - retentionTime;
    
    const oldBackups = backupFiles.filter(backup => backup.mtime.getTime() < cutoffTime);
    
    if (oldBackups.length > 0) {
      logger.info('Found old backups that should be cleaned up', {
        count: oldBackups.length,
        retentionDays: this.config.retentionDays
      });
      
      // Log old backup details
      oldBackups.forEach(backup => {
        const ageDays = Math.round((Date.now() - backup.mtime.getTime()) / (24 * 60 * 60 * 1000));
        logger.debug('Old backup found', {
          file: backup.name,
          ageDays
        });
      });
    }
  }

  /**
   * Handle no backups found scenario
   */
  async handleNoBackupsFound() {
    logger.warn('No backup files found in backup directory', {
      directory: this.config.backupDir
    });
    
    await this.sendAlert('NO_BACKUPS_FOUND', {
      directory: this.config.backupDir
    });
    
    throw new Error('No backup files found');
  }

  /**
   * Send alert
   */
  async sendAlert(type, data) {
    const alert = {
      id: `${type}_${Date.now()}`,
      type,
      timestamp: new Date(),
      data,
      severity: this.getAlertSeverity(type)
    };
    
    this.alerts.push(alert);
    
    // Keep only last 100 alerts
    if (this.alerts.length > 100) {
      this.alerts = this.alerts.slice(-100);
    }
    
    logger.warn('Backup alert generated', {
      alert
    });
    
    // Here you could integrate with external alerting systems
    // like email, Slack, PagerDuty, etc.
    await this.processAlert(alert);
  }

  /**
   * Get alert severity level
   */
  getAlertSeverity(type) {
    const severityMap = {
      'NO_BACKUPS_FOUND': 'critical',
      'BACKUP_TOO_OLD': 'high',
      'BACKUP_TOO_SMALL': 'medium',
      'BACKUP_CHECK_FAILED': 'high',
      'FILE_INTEGRITY_FAILED': 'high'
    };
    
    return severityMap[type] || 'low';
  }

  /**
   * Process alert (integrate with external systems)
   */
  async processAlert(alert) {
    // Log to application logs
    logger.error('BACKUP ALERT', {
      type: alert.type,
      severity: alert.severity,
      data: alert.data
    });
    
    // Here you can add integrations with:
    // - Email notifications
    // - Slack webhooks
    // - PagerDuty
    // - SMS alerts
    // - etc.
    
    // Example: Send to webhook (if configured)
    const webhookUrl = process.env.BACKUP_ALERT_WEBHOOK;
    if (webhookUrl) {
      try {
        const fetch = require('node-fetch');
        await fetch(webhookUrl, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            text: `🚨 Backup Alert: ${alert.type}`,
            severity: alert.severity,
            timestamp: alert.timestamp,
            data: alert.data
          })
        });
      } catch (error) {
        logger.error('Failed to send webhook alert', {
          error: error.message
        });
      }
    }
  }

  /**
   * Get backup status report
   */
  getStatusReport() {
    return {
      isMonitoring: this.isMonitoring,
      config: this.config,
      metrics: this.metrics,
      recentAlerts: this.alerts.slice(-10), // Last 10 alerts
      lastCheck: new Date()
    };
  }

  /**
   * Get backup health summary
   */
  async getHealthSummary() {
    try {
      const backupFiles = await this.getBackupFiles();
      const latestBackup = backupFiles.length > 0 ? backupFiles[0] : null;
      
      let status = 'healthy';
      let issues = [];
      
      if (!latestBackup) {
        status = 'critical';
        issues.push('No backups found');
      } else {
        const backupAge = Date.now() - latestBackup.mtime.getTime();
        const maxAge = this.config.maxBackupAge * 60 * 60 * 1000;
        
        if (backupAge > maxAge) {
          status = 'warning';
          issues.push(`Latest backup is ${Math.round(backupAge / (60 * 60 * 1000))} hours old`);
        }
        
        const minSize = this.config.minBackupSize * 1024 * 1024;
        if (latestBackup.size < minSize) {
          status = 'warning';
          issues.push(`Latest backup is smaller than expected (${Math.round(latestBackup.size / (1024 * 1024))} MB)`);
        }
      }
      
      if (this.metrics.failedChecks > 0) {
        status = 'warning';
        issues.push(`${this.metrics.failedChecks} recent failed checks`);
      }
      
      return {
        status,
        issues,
        latestBackup: latestBackup ? {
          name: latestBackup.name,
          size: latestBackup.size,
          age: latestBackup ? Date.now() - latestBackup.mtime.getTime() : null
        } : null,
        totalBackups: backupFiles.length,
        metrics: this.metrics
      };
    } catch (error) {
      return {
        status: 'error',
        issues: [error.message],
        latestBackup: null,
        totalBackups: 0,
        metrics: this.metrics
      };
    }
  }

  /**
   * Trigger manual backup verification
   */
  async triggerManualCheck() {
    logger.info('Manual backup check triggered');
    
    try {
      await this.checkBackupStatus();
      return {
        success: true,
        message: 'Backup check completed successfully',
        timestamp: new Date()
      };
    } catch (error) {
      return {
        success: false,
        message: error.message,
        timestamp: new Date()
      };
    }
  }
}

// Export singleton instance
const backupMonitoringService = new BackupMonitoringService();

module.exports = {
  BackupMonitoringService,
  backupMonitoringService,
  startMonitoring: () => backupMonitoringService.startMonitoring(),
  stopMonitoring: () => backupMonitoringService.stopMonitoring(),
  getStatusReport: () => backupMonitoringService.getStatusReport(),
  getHealthSummary: () => backupMonitoringService.getHealthSummary(),
  triggerManualCheck: () => backupMonitoringService.triggerManualCheck()
};