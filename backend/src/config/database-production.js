/**
 * Production Database Configuration
 * Optimized for performance, reliability, and monitoring
 */

const { Sequelize } = require("sequelize");
const logger = require("../utils/logger");

/**
 * Database configuration class for production environment
 */
class ProductionDatabaseConfig {
  constructor() {
    this.config = this.getProductionConfig();
    this.sequelize = null;
    this.connectionPool = null;
    this.metrics = {
      connections: {
        active: 0,
        idle: 0,
        total: 0
      },
      queries: {
        total: 0,
        slow: 0,
        failed: 0
      },
      performance: {
        avgResponseTime: 0,
        maxResponseTime: 0,
        minResponseTime: Infinity
      }
    };
  }

  /**
   * Get production database configuration
   */
  getProductionConfig() {
    return {
      // Basic connection settings
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT) || 3306,
      database: process.env.DB_NAME || 'givingbridge',
      username: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      
      // Connection pool settings
      pool: {
        max: parseInt(process.env.DB_POOL_MAX) || 20,        // Maximum connections
        min: parseInt(process.env.DB_POOL_MIN) || 5,         // Minimum connections
        acquire: parseInt(process.env.DB_POOL_ACQUIRE) || 60000,  // 60 seconds
        idle: parseInt(process.env.DB_POOL_IDLE) || 10000,   // 10 seconds
        evict: parseInt(process.env.DB_POOL_EVICT) || 1000,  // 1 second
        handleDisconnects: true,
        validate: this.validateConnection.bind(this)
      },
      
      // Sequelize options
      dialect: 'mysql',
      dialectOptions: {
        charset: 'utf8mb4',
        collate: 'utf8mb4_unicode_ci',
        connectTimeout: parseInt(process.env.DB_CONNECT_TIMEOUT) || 30000,
        acquireTimeout: parseInt(process.env.DB_ACQUIRE_TIMEOUT) || 60000,
        timeout: parseInt(process.env.DB_QUERY_TIMEOUT) || 30000,
        
        // SSL configuration for production
        ssl: process.env.NODE_ENV === 'production' ? {
          require: true,
          rejectUnauthorized: false
        } : false,
        
        // Additional MySQL options
        supportBigNumbers: true,
        bigNumberStrings: true,
        dateStrings: false,
        debug: process.env.DB_DEBUG === 'true',
        
        // Connection flags
        flags: [
          'FOUND_ROWS',
          'IGNORE_SPACE',
          'INTERACTIVE',
          'LOCAL_FILES',
          'LONG_FLAG',
          'LONG_PASSWORD',
          'MULTI_RESULTS',
          'MULTI_STATEMENTS',
          'PROTOCOL_41',
          'SECURE_CONNECTION',
          'TRANSACTIONS'
        ]
      },
      
      // Logging configuration
      logging: this.createQueryLogger(),
      
      // Performance settings
      benchmark: true,
      
      // Retry configuration
      retry: {
        max: 3,
        match: [
          /ETIMEDOUT/,
          /EHOSTUNREACH/,
          /ECONNRESET/,
          /ECONNREFUSED/,
          /ENOTFOUND/,
          /SequelizeConnectionError/,
          /SequelizeConnectionRefusedError/,
          /SequelizeHostNotFoundError/,
          /SequelizeHostNotReachableError/,
          /SequelizeInvalidConnectionError/,
          /SequelizeConnectionTimedOutError/
        ]
      },
      
      // Query options
      define: {
        charset: 'utf8mb4',
        collate: 'utf8mb4_unicode_ci',
        timestamps: true,
        underscored: false,
        freezeTableName: true,
        paranoid: false
      },
      
      // Timezone
      timezone: '+00:00'
    };
  }

  /**
   * Create query logger with performance monitoring
   */
  createQueryLogger() {
    return (sql, timing) => {
      const duration = timing || 0;
      
      // Update metrics
      this.updateQueryMetrics(duration);
      
      // Log slow queries
      const slowQueryThreshold = parseInt(process.env.SLOW_QUERY_THRESHOLD) || 2000;
      if (duration > slowQueryThreshold) {
        this.metrics.queries.slow++;
        logger.warn("Slow query detected", {
          sql: sql.substring(0, 500), // Limit SQL length in logs
          duration,
          threshold: slowQueryThreshold
        });
      }
      
      // Log all queries in debug mode
      if (process.env.LOG_LEVEL === 'debug') {
        logger.debug("Database query", {
          sql: sql.substring(0, 200),
          duration
        });
      }
    };
  }

  /**
   * Validate database connection
   */
  async validateConnection(connection) {
    try {
      await connection.ping();
      return true;
    } catch (error) {
      logger.error("Connection validation failed", { error: error.message });
      return false;
    }
  }

  /**
   * Update query performance metrics
   */
  updateQueryMetrics(duration) {
    this.metrics.queries.total++;
    
    if (duration > this.metrics.performance.maxResponseTime) {
      this.metrics.performance.maxResponseTime = duration;
    }
    
    if (duration < this.metrics.performance.minResponseTime) {
      this.metrics.performance.minResponseTime = duration;
    }
    
    // Calculate rolling average
    const totalQueries = this.metrics.queries.total;
    const currentAvg = this.metrics.performance.avgResponseTime;
    this.metrics.performance.avgResponseTime = 
      ((currentAvg * (totalQueries - 1)) + duration) / totalQueries;
  }

  /**
   * Initialize database connection with monitoring
   */
  async initialize() {
    try {
      logger.info("Initializing production database connection...");
      
      this.sequelize = new Sequelize(this.config);
      
      // Set up connection pool monitoring
      this.setupPoolMonitoring();
      
      // Set up query hooks for monitoring
      this.setupQueryHooks();
      
      // Test connection
      await this.testConnection();
      
      logger.info("Database connection initialized successfully", {
        host: this.config.host,
        database: this.config.database,
        poolMax: this.config.pool.max,
        poolMin: this.config.pool.min
      });
      
      return this.sequelize;
    } catch (error) {
      logger.error("Failed to initialize database connection", {
        error: error.message,
        stack: error.stack
      });
      throw error;
    }
  }

  /**
   * Set up connection pool monitoring
   */
  setupPoolMonitoring() {
    const pool = this.sequelize.connectionManager.pool;
    
    // Monitor pool events
    pool.on('acquire', (connection) => {
      this.metrics.connections.active++;
      logger.debug("Connection acquired from pool", {
        activeConnections: this.metrics.connections.active,
        totalConnections: pool.size
      });
    });
    
    pool.on('release', (connection) => {
      this.metrics.connections.active--;
      this.metrics.connections.idle++;
      logger.debug("Connection released to pool", {
        activeConnections: this.metrics.connections.active,
        idleConnections: this.metrics.connections.idle
      });
    });
    
    pool.on('remove', (connection) => {
      this.metrics.connections.total--;
      logger.debug("Connection removed from pool", {
        totalConnections: this.metrics.connections.total
      });
    });
    
    pool.on('create', (connection) => {
      this.metrics.connections.total++;
      logger.debug("New connection created", {
        totalConnections: this.metrics.connections.total
      });
    });
    
    // Periodic pool health check
    setInterval(() => {
      this.checkPoolHealth();
    }, 60000); // Every minute
  }

  /**
   * Set up query performance hooks
   */
  setupQueryHooks() {
    this.sequelize.addHook('beforeQuery', (options) => {
      options.startTime = Date.now();
    });
    
    this.sequelize.addHook('afterQuery', (options, result) => {
      const duration = Date.now() - options.startTime;
      this.updateQueryMetrics(duration);
    });
    
    this.sequelize.addHook('queryError', (error, options) => {
      this.metrics.queries.failed++;
      logger.error("Query failed", {
        error: error.message,
        sql: options.sql?.substring(0, 200),
        bind: options.bind
      });
    });
  }

  /**
   * Test database connection
   */
  async testConnection() {
    try {
      await this.sequelize.authenticate();
      logger.info("Database connection test successful");
      
      // Test query performance
      const startTime = Date.now();
      await this.sequelize.query('SELECT 1 as test');
      const duration = Date.now() - startTime;
      
      logger.info("Database query test successful", { duration });
      
      return true;
    } catch (error) {
      logger.error("Database connection test failed", {
        error: error.message
      });
      throw error;
    }
  }

  /**
   * Check connection pool health
   */
  checkPoolHealth() {
    const pool = this.sequelize.connectionManager.pool;
    const poolStats = {
      size: pool.size,
      available: pool.available,
      using: pool.using,
      waiting: pool.waiting
    };
    
    // Log pool statistics
    logger.debug("Connection pool health check", {
      ...poolStats,
      metrics: this.metrics
    });
    
    // Alert if pool is under stress
    const utilizationRate = (poolStats.using / poolStats.size) * 100;
    if (utilizationRate > 80) {
      logger.warn("High database connection pool utilization", {
        utilizationRate: `${utilizationRate.toFixed(2)}%`,
        ...poolStats
      });
    }
    
    // Alert if too many waiting connections
    if (poolStats.waiting > 5) {
      logger.warn("High number of waiting database connections", {
        waiting: poolStats.waiting,
        ...poolStats
      });
    }
  }

  /**
   * Get database metrics
   */
  getMetrics() {
    const pool = this.sequelize?.connectionManager?.pool;
    
    return {
      ...this.metrics,
      pool: pool ? {
        size: pool.size,
        available: pool.available,
        using: pool.using,
        waiting: pool.waiting
      } : null,
      uptime: process.uptime()
    };
  }

  /**
   * Graceful shutdown
   */
  async shutdown() {
    try {
      logger.info("Shutting down database connection...");
      
      if (this.sequelize) {
        await this.sequelize.close();
        logger.info("Database connection closed successfully");
      }
    } catch (error) {
      logger.error("Error during database shutdown", {
        error: error.message
      });
    }
  }

  /**
   * Health check for monitoring
   */
  async healthCheck() {
    try {
      const startTime = Date.now();
      await this.sequelize.query('SELECT 1 as health_check');
      const responseTime = Date.now() - startTime;
      
      const metrics = this.getMetrics();
      
      return {
        status: 'healthy',
        responseTime,
        metrics,
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      return {
        status: 'unhealthy',
        error: error.message,
        timestamp: new Date().toISOString()
      };
    }
  }
}

// Export singleton instance
const productionDb = new ProductionDatabaseConfig();

module.exports = {
  ProductionDatabaseConfig,
  productionDb,
  initialize: () => productionDb.initialize(),
  getMetrics: () => productionDb.getMetrics(),
  healthCheck: () => productionDb.healthCheck(),
  shutdown: () => productionDb.shutdown()
};