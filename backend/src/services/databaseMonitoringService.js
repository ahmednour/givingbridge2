/**
 * Database Monitoring Service
 * Monitors database performance, connection health, and query patterns
 */

const logger = require("../utils/logger");
const { productionDb } = require("../config/database-production");

/**
 * Database monitoring service class
 */
class DatabaseMonitoringService {
  constructor() {
    this.isMonitoring = false;
    this.monitoringInterval = null;
    this.alertThresholds = {
      slowQueryTime: parseInt(process.env.SLOW_QUERY_THRESHOLD) || 2000,
      highConnectionUtilization: 80, // percentage
      maxWaitingConnections: 5,
      maxFailedQueries: 10, // per minute
      maxResponseTime: 5000 // milliseconds
    };
    this.alertCooldowns = new Map();
    this.performanceHistory = [];
    this.maxHistorySize = 100;
  }

  /**
   * Start database monitoring
   */
  start() {
    if (this.isMonitoring) {
      logger.warn("Database monitoring is already running");
      return;
    }

    logger.info("Starting database monitoring service");
    this.isMonitoring = true;

    // Monitor every 30 seconds
    this.monitoringInterval = setInterval(() => {
      this.performHealthCheck();
    }, 30000);

    // Performance snapshot every 5 minutes
    setInterval(() => {
      this.capturePerformanceSnapshot();
    }, 300000);

    logger.info("Database monitoring service started");
  }

  /**
   * Stop database monitoring
   */
  stop() {
    if (!this.isMonitoring) {
      return;
    }

    logger.info("Stopping database monitoring service");
    
    if (this.monitoringInterval) {
      clearInterval(this.monitoringInterval);
      this.monitoringInterval = null;
    }

    this.isMonitoring = false;
    logger.info("Database monitoring service stopped");
  }

  /**
   * Perform comprehensive health check
   */
  async performHealthCheck() {
    try {
      const healthData = await productionDb.healthCheck();
      
      if (healthData.status === 'healthy') {
        this.checkPerformanceThresholds(healthData);
        this.updatePerformanceHistory(healthData);
      } else {
        this.handleUnhealthyDatabase(healthData);
      }
    } catch (error) {
      logger.error("Database health check failed", {
        error: error.message,
        stack: error.stack
      });
    }
  }

  /**
   * Check performance against thresholds and alert if necessary
   */
  checkPerformanceThresholds(healthData) {
    const { metrics, responseTime } = healthData;

    // Check response time
    if (responseTime > this.alertThresholds.maxResponseTime) {
      this.sendAlert('HIGH_RESPONSE_TIME', {
        responseTime,
        threshold: this.alertThresholds.maxResponseTime
      });
    }

    // Check connection pool utilization
    if (metrics.pool) {
      const utilizationRate = (metrics.pool.using / metrics.pool.size) * 100;
      if (utilizationRate > this.alertThresholds.highConnectionUtilization) {
        this.sendAlert('HIGH_CONNECTION_UTILIZATION', {
          utilizationRate: utilizationRate.toFixed(2),
          threshold: this.alertThresholds.highConnectionUtilization,
          poolStats: metrics.pool
        });
      }

      // Check waiting connections
      if (metrics.pool.waiting > this.alertThresholds.maxWaitingConnections) {
        this.sendAlert('HIGH_WAITING_CONNECTIONS', {
          waiting: metrics.pool.waiting,
          threshold: this.alertThresholds.maxWaitingConnections,
          poolStats: metrics.pool
        });
      }
    }

    // Check failed queries rate
    const failedQueriesRate = this.calculateFailedQueriesRate(metrics);
    if (failedQueriesRate > this.alertThresholds.maxFailedQueries) {
      this.sendAlert('HIGH_FAILED_QUERIES_RATE', {
        rate: failedQueriesRate,
        threshold: this.alertThresholds.maxFailedQueries,
        totalFailed: metrics.queries.failed
      });
    }

    // Check slow queries
    if (metrics.queries.slow > 0) {
      const slowQueryRate = (metrics.queries.slow / metrics.queries.total) * 100;
      if (slowQueryRate > 5) { // More than 5% slow queries
        this.sendAlert('HIGH_SLOW_QUERY_RATE', {
          slowQueryRate: slowQueryRate.toFixed(2),
          totalSlow: metrics.queries.slow,
          totalQueries: metrics.queries.total
        });
      }
    }
  }

  /**
   * Calculate failed queries rate per minute
   */
  calculateFailedQueriesRate(metrics) {
    const now = Date.now();
    const oneMinuteAgo = now - 60000;
    
    // This is a simplified calculation
    // In a real implementation, you'd track failed queries over time
    return metrics.queries.failed || 0;
  }

  /**
   * Handle unhealthy database state
   */
  handleUnhealthyDatabase(healthData) {
    logger.error("Database is unhealthy", healthData);
    
    this.sendAlert('DATABASE_UNHEALTHY', {
      error: healthData.error,
      timestamp: healthData.timestamp
    });

    // Attempt to reconnect if connection is lost
    this.attemptReconnection();
  }

  /**
   * Attempt database reconnection
   */
  async attemptReconnection() {
    try {
      logger.info("Attempting database reconnection...");
      
      // Close existing connection
      await productionDb.shutdown();
      
      // Wait a bit before reconnecting
      await new Promise(resolve => setTimeout(resolve, 5000));
      
      // Reinitialize connection
      await productionDb.initialize();
      
      logger.info("Database reconnection successful");
      
      this.sendAlert('DATABASE_RECONNECTED', {
        timestamp: new Date().toISOString()
      });
    } catch (error) {
      logger.error("Database reconnection failed", {
        error: error.message
      });
    }
  }

  /**
   * Send alert with cooldown to prevent spam
   */
  sendAlert(alertType, data) {
    const cooldownKey = alertType;
    const cooldownPeriod = 300000; // 5 minutes
    const now = Date.now();

    // Check if alert is in cooldown
    if (this.alertCooldowns.has(cooldownKey)) {
      const lastAlert = this.alertCooldowns.get(cooldownKey);
      if (now - lastAlert < cooldownPeriod) {
        return; // Skip alert due to cooldown
      }
    }

    // Set cooldown
    this.alertCooldowns.set(cooldownKey, now);

    // Log alert
    logger.warn(`Database Alert: ${alertType}`, {
      alertType,
      data,
      timestamp: new Date().toISOString()
    });

    // In a real implementation, you might send notifications via:
    // - Email
    // - Slack
    // - PagerDuty
    // - SMS
    // - Webhook
  }

  /**
   * Capture performance snapshot for historical analysis
   */
  capturePerformanceSnapshot() {
    try {
      const metrics = productionDb.getMetrics();
      
      const snapshot = {
        timestamp: new Date().toISOString(),
        queries: { ...metrics.queries },
        performance: { ...metrics.performance },
        connections: { ...metrics.connections },
        pool: metrics.pool ? { ...metrics.pool } : null,
        uptime: metrics.uptime
      };

      this.performanceHistory.push(snapshot);

      // Maintain history size limit
      if (this.performanceHistory.length > this.maxHistorySize) {
        this.performanceHistory.shift();
      }

      logger.debug("Performance snapshot captured", {
        snapshotCount: this.performanceHistory.length,
        snapshot
      });
    } catch (error) {
      logger.error("Failed to capture performance snapshot", {
        error: error.message
      });
    }
  }

  /**
   * Get performance report
   */
  getPerformanceReport() {
    const currentMetrics = productionDb.getMetrics();
    
    // Calculate trends from history
    const trends = this.calculateTrends();
    
    return {
      current: currentMetrics,
      trends,
      history: this.performanceHistory.slice(-10), // Last 10 snapshots
      alerts: {
        thresholds: this.alertThresholds,
        activeCooldowns: Array.from(this.alertCooldowns.keys())
      },
      monitoring: {
        isActive: this.isMonitoring,
        uptime: process.uptime()
      }
    };
  }

  /**
   * Calculate performance trends
   */
  calculateTrends() {
    if (this.performanceHistory.length < 2) {
      return null;
    }

    const recent = this.performanceHistory.slice(-5); // Last 5 snapshots
    const older = this.performanceHistory.slice(-10, -5); // Previous 5 snapshots

    if (recent.length === 0 || older.length === 0) {
      return null;
    }

    const recentAvg = this.calculateAverageMetrics(recent);
    const olderAvg = this.calculateAverageMetrics(older);

    return {
      responseTime: {
        trend: recentAvg.avgResponseTime > olderAvg.avgResponseTime ? 'increasing' : 'decreasing',
        change: ((recentAvg.avgResponseTime - olderAvg.avgResponseTime) / olderAvg.avgResponseTime * 100).toFixed(2)
      },
      queryRate: {
        trend: recentAvg.totalQueries > olderAvg.totalQueries ? 'increasing' : 'decreasing',
        change: ((recentAvg.totalQueries - olderAvg.totalQueries) / olderAvg.totalQueries * 100).toFixed(2)
      },
      connectionUtilization: {
        trend: recentAvg.connectionUsage > olderAvg.connectionUsage ? 'increasing' : 'decreasing',
        change: ((recentAvg.connectionUsage - olderAvg.connectionUsage) / olderAvg.connectionUsage * 100).toFixed(2)
      }
    };
  }

  /**
   * Calculate average metrics from snapshots
   */
  calculateAverageMetrics(snapshots) {
    const totals = snapshots.reduce((acc, snapshot) => {
      acc.avgResponseTime += snapshot.performance.avgResponseTime || 0;
      acc.totalQueries += snapshot.queries.total || 0;
      acc.connectionUsage += snapshot.pool ? (snapshot.pool.using / snapshot.pool.size) : 0;
      return acc;
    }, { avgResponseTime: 0, totalQueries: 0, connectionUsage: 0 });

    const count = snapshots.length;
    return {
      avgResponseTime: totals.avgResponseTime / count,
      totalQueries: totals.totalQueries / count,
      connectionUsage: totals.connectionUsage / count
    };
  }

  /**
   * Get database status for health endpoint
   */
  async getStatus() {
    try {
      const healthData = await productionDb.healthCheck();
      const performanceReport = this.getPerformanceReport();

      return {
        status: healthData.status,
        responseTime: healthData.responseTime,
        monitoring: this.isMonitoring,
        metrics: performanceReport.current,
        trends: performanceReport.trends,
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      return {
        status: 'error',
        error: error.message,
        monitoring: this.isMonitoring,
        timestamp: new Date().toISOString()
      };
    }
  }
}

// Export singleton instance
const databaseMonitoringService = new DatabaseMonitoringService();

module.exports = {
  DatabaseMonitoringService,
  databaseMonitoringService
};