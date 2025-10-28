/**
 * Disaster Recovery Service Tests
 */

const disasterRecoveryService = require('../services/disasterRecoveryService');
const backupMonitoringService = require('../services/backupMonitoringService');
const fs = require('fs').promises;
const path = require('path');

// Mock dependencies
jest.mock('../services/backupMonitoringService');
jest.mock('fs', () => ({
  promises: {
    mkdir: jest.fn(),
    access: jest.fn(),
    readFile: jest.fn(),
    writeFile: jest.fn()
  }
}));
jest.mock('child_process');

describe('DisasterRecoveryService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('checkSystemHealth', () => {
    it('should check system health successfully', async () => {
      const { exec } = require('child_process');
      const { promisify } = require('util');
      
      // Mock exec to return successful health check
      const mockExec = jest.fn().mockResolvedValue({
        stdout: '[SUCCESS] Database connection OK\n[SUCCESS] Application directory OK',
        stderr: ''
      });
      
      require('util').promisify = jest.fn(() => mockExec);

      const health = await disasterRecoveryService.checkSystemHealth();

      expect(health).toHaveProperty('status', 'healthy');
      expect(health).toHaveProperty('issues', 0);
      expect(health).toHaveProperty('warnings', 0);
      expect(health).toHaveProperty('timestamp');
    });

    it('should detect system health issues', async () => {
      const { exec } = require('child_process');
      
      // Mock exec to return health issues
      const mockExec = jest.fn().mockResolvedValue({
        stdout: '[SUCCESS] Database connection OK',
        stderr: '[ERROR] Application directory not found\n[WARNING] Backup directory not found'
      });
      
      require('util').promisify = jest.fn(() => mockExec);

      const health = await disasterRecoveryService.checkSystemHealth();

      expect(health).toHaveProperty('status', 'unhealthy');
      expect(health).toHaveProperty('issues', 1);
      expect(health).toHaveProperty('warnings', 1);
    });

    it('should handle health check errors', async () => {
      const mockExec = jest.fn().mockRejectedValue(new Error('Script execution failed'));
      require('util').promisify = jest.fn(() => mockExec);

      const health = await disasterRecoveryService.checkSystemHealth();

      expect(health).toHaveProperty('status', 'error');
      expect(health).toHaveProperty('error', 'Script execution failed');
    });
  });

  describe('monitorRecoveryReadiness', () => {
    it('should determine recovery readiness correctly', async () => {
      // Mock backup status
      backupMonitoringService.getBackupStatus.mockResolvedValue({
        database: {
          lastBackupAge: 1200, // 20 minutes
          status: 'success'
        },
        files: {
          lastBackupAge: 1800, // 30 minutes
          status: 'success'
        }
      });

      // Mock system health check
      const mockExec = jest.fn().mockResolvedValue({
        stdout: '[SUCCESS] All systems OK',
        stderr: ''
      });
      require('util').promisify = jest.fn(() => mockExec);

      const readiness = await disasterRecoveryService.monitorRecoveryReadiness();

      expect(readiness).toHaveProperty('ready', true);
      expect(readiness).toHaveProperty('backupFresh', true);
      expect(readiness).toHaveProperty('systemHealthy', true);
      expect(readiness).toHaveProperty('backupAge', 1200);
    });

    it('should detect when recovery is not ready', async () => {
      // Mock stale backup
      backupMonitoringService.getBackupStatus.mockResolvedValue({
        database: {
          lastBackupAge: 7200, // 2 hours (exceeds RPO)
          status: 'success'
        }
      });

      // Mock unhealthy system
      const mockExec = jest.fn().mockResolvedValue({
        stdout: '',
        stderr: '[ERROR] Database connection failed'
      });
      require('util').promisify = jest.fn(() => mockExec);

      const readiness = await disasterRecoveryService.monitorRecoveryReadiness();

      expect(readiness).toHaveProperty('ready', false);
      expect(readiness).toHaveProperty('backupFresh', false);
      expect(readiness).toHaveProperty('systemHealthy', false);
    });
  });

  describe('testRecoveryProcedures', () => {
    it('should run recovery test successfully', async () => {
      const mockExec = jest.fn().mockResolvedValue({
        stdout: '[SUCCESS] Recovery test completed successfully',
        stderr: '[INFO] Testing database recovery\n[SUCCESS] Database recovery test passed'
      });
      require('util').promisify = jest.fn(() => mockExec);

      // Mock file operations
      fs.access.mockResolvedValue();
      fs.readFile.mockResolvedValue('LAST_RECOVERY_TEST=2023-01-01');
      fs.writeFile.mockResolvedValue();

      const result = await disasterRecoveryService.testRecoveryProcedures();

      expect(result).toHaveProperty('success', true);
      expect(result).toHaveProperty('duration');
      expect(result).toHaveProperty('timestamp');
      expect(result).toHaveProperty('withinObjective');
    });

    it('should handle recovery test failures', async () => {
      const mockExec = jest.fn().mockResolvedValue({
        stdout: '',
        stderr: '[ERROR] Database recovery test failed\n[CRITICAL] Recovery test aborted'
      });
      require('util').promisify = jest.fn(() => mockExec);

      const result = await disasterRecoveryService.testRecoveryProcedures();

      expect(result).toHaveProperty('success', false);
    });
  });

  describe('performDisasterRecovery', () => {
    it('should require explicit confirmation', async () => {
      await expect(disasterRecoveryService.performDisasterRecovery(false))
        .rejects.toThrow('Disaster recovery requires explicit confirmation');
    });

    it('should perform recovery with confirmation', async () => {
      const mockExec = jest.fn().mockResolvedValue({
        stdout: '[SUCCESS] Disaster recovery completed',
        stderr: '[CRITICAL] RECOVERY COMPLETED'
      });
      require('util').promisify = jest.fn(() => mockExec);

      // Mock file operations
      fs.access.mockResolvedValue();
      fs.readFile.mockResolvedValue('');
      fs.writeFile.mockResolvedValue();

      const result = await disasterRecoveryService.performDisasterRecovery(true);

      expect(result).toHaveProperty('success', true);
      expect(result).toHaveProperty('duration');
      expect(result).toHaveProperty('timestamp');
    });
  });

  describe('getRecoveryStatus', () => {
    it('should return comprehensive recovery status', async () => {
      // Mock all dependencies
      backupMonitoringService.getBackupStatus.mockResolvedValue({
        database: { lastBackupAge: 1200, status: 'success' }
      });

      const mockExec = jest.fn().mockResolvedValue({
        stdout: '[SUCCESS] All systems OK',
        stderr: ''
      });
      require('util').promisify = jest.fn(() => mockExec);

      const status = await disasterRecoveryService.getRecoveryStatus();

      expect(status).toHaveProperty('config');
      expect(status).toHaveProperty('metrics');
      expect(status).toHaveProperty('readiness');
      expect(status).toHaveProperty('timestamp');
    });
  });

  describe('getRecoveryTimeMetrics', () => {
    it('should return recovery time metrics', () => {
      const metrics = disasterRecoveryService.getRecoveryTimeMetrics();

      expect(metrics).toHaveProperty('recoveryTimeObjective');
      expect(metrics).toHaveProperty('recoveryPointObjective');
      expect(metrics).toHaveProperty('recoveryReadiness');
      expect(metrics).toHaveProperty('systemHealth');
    });
  });
});