const fs = require('fs');
const path = require('path');

/**
 * Structured logging system for the GivingBridge application
 * Provides different log levels and structured output
 */

class Logger {
  constructor() {
    this.logLevels = {
      ERROR: 0,
      WARN: 1,
      INFO: 2,
      DEBUG: 3
    };

    this.currentLevel = this.getLogLevel();
    this.logDir = path.join(__dirname, '../../logs');
    this.ensureLogDirectory();
  }

  getLogLevel() {
    const level = process.env.LOG_LEVEL?.toUpperCase() || 'INFO';
    return this.logLevels[level] !== undefined ? this.logLevels[level] : this.logLevels.INFO;
  }

  ensureLogDirectory() {
    if (!fs.existsSync(this.logDir)) {
      try {
        fs.mkdirSync(this.logDir, { recursive: true });
      } catch (error) {
        console.error('Failed to create log directory:', error.message);
      }
    }
  }

  formatLogEntry(level, message, meta = {}) {
    const timestamp = new Date().toISOString();
    const logEntry = {
      timestamp,
      level,
      message,
      ...meta
    };

    // Add request context if available
    if (meta.req) {
      logEntry.request = {
        method: meta.req.method,
        url: meta.req.originalUrl || meta.req.url,
        userAgent: meta.req.get('User-Agent'),
        ip: meta.req.ip || meta.req.connection.remoteAddress,
        userId: meta.req.user?.id || meta.req.user?.userId
      };
      delete logEntry.req; // Remove the original req object
    }

    // Add error details if available
    if (meta.error && meta.error instanceof Error) {
      logEntry.error = {
        name: meta.error.name,
        message: meta.error.message,
        stack: meta.error.stack,
        statusCode: meta.error.statusCode
      };
      delete logEntry.error; // Remove the original error object
    }

    return logEntry;
  }

  writeToFile(level, logEntry) {
    try {
      const filename = `${level.toLowerCase()}.log`;
      const filepath = path.join(this.logDir, filename);
      const logLine = JSON.stringify(logEntry) + '\n';
      
      fs.appendFileSync(filepath, logLine);
    } catch (error) {
      console.error('Failed to write to log file:', error.message);
    }
  }

  writeToConsole(level, logEntry) {
    const colorCodes = {
      ERROR: '\x1b[31m', // Red
      WARN: '\x1b[33m',  // Yellow
      INFO: '\x1b[36m',  // Cyan
      DEBUG: '\x1b[90m'  // Gray
    };

    const resetCode = '\x1b[0m';
    const color = colorCodes[level] || '';
    
    const consoleMessage = `${color}[${logEntry.timestamp}] ${level}: ${logEntry.message}${resetCode}`;
    
    if (level === 'ERROR') {
      console.error(consoleMessage);
      if (logEntry.error?.stack) {
        console.error(logEntry.error.stack);
      }
    } else if (level === 'WARN') {
      console.warn(consoleMessage);
    } else {
      console.log(consoleMessage);
    }
  }

  log(level, message, meta = {}) {
    const levelValue = this.logLevels[level];
    
    if (levelValue <= this.currentLevel) {
      const logEntry = this.formatLogEntry(level, message, meta);
      
      // Always write to console in development
      if (process.env.NODE_ENV === 'development' || process.env.NODE_ENV === 'test') {
        this.writeToConsole(level, logEntry);
      }
      
      // Write to file in production or when explicitly enabled
      if (process.env.NODE_ENV === 'production' || process.env.ENABLE_FILE_LOGGING === 'true') {
        this.writeToFile(level, logEntry);
      }
    }
  }

  error(message, meta = {}) {
    this.log('ERROR', message, meta);
  }

  warn(message, meta = {}) {
    this.log('WARN', message, meta);
  }

  info(message, meta = {}) {
    this.log('INFO', message, meta);
  }

  debug(message, meta = {}) {
    this.log('DEBUG', message, meta);
  }

  // Request logging middleware
  requestLogger() {
    return (req, res, next) => {
      const startTime = Date.now();
      
      // Log incoming request
      this.info('Incoming request', {
        req,
        body: req.method === 'POST' || req.method === 'PUT' ? req.body : undefined
      });

      // Override res.end to log response
      const originalEnd = res.end;
      res.end = function(chunk, encoding) {
        const duration = Date.now() - startTime;
        
        // Log response
        logger.info('Request completed', {
          req,
          statusCode: res.statusCode,
          duration: `${duration}ms`
        });

        originalEnd.call(this, chunk, encoding);
      };

      next();
    };
  }

  // Error logging middleware
  errorLogger() {
    return (error, req, res, next) => {
      this.error('Request error', {
        req,
        error,
        statusCode: error.statusCode || 500
      });

      next(error);
    };
  }

  // Database query logging
  logDatabaseQuery(query, duration, error = null) {
    if (error) {
      this.error('Database query failed', {
        query: query.substring(0, 200) + (query.length > 200 ? '...' : ''),
        duration: `${duration}ms`,
        error
      });
    } else {
      this.debug('Database query executed', {
        query: query.substring(0, 200) + (query.length > 200 ? '...' : ''),
        duration: `${duration}ms`
      });
    }
  }

  // Authentication logging
  logAuthEvent(event, userId, details = {}) {
    this.info(`Auth event: ${event}`, {
      userId,
      event,
      ...details
    });
  }

  // Business logic logging
  logBusinessEvent(event, details = {}) {
    this.info(`Business event: ${event}`, {
      event,
      ...details
    });
  }

  // Performance logging
  logPerformance(operation, duration, details = {}) {
    const level = duration > 1000 ? 'WARN' : 'INFO';
    this.log(level, `Performance: ${operation}`, {
      operation,
      duration: `${duration}ms`,
      ...details
    });
  }

  // Security logging
  logSecurityEvent(event, severity = 'INFO', details = {}) {
    const level = severity === 'HIGH' ? 'ERROR' : severity === 'MEDIUM' ? 'WARN' : 'INFO';
    this.log(level, `Security event: ${event}`, {
      event,
      severity,
      ...details
    });
  }

  // Cleanup old log files
  cleanupLogs(daysToKeep = 30) {
    try {
      const files = fs.readdirSync(this.logDir);
      const cutoffDate = new Date();
      cutoffDate.setDate(cutoffDate.getDate() - daysToKeep);

      for (const file of files) {
        const filepath = path.join(this.logDir, file);
        const stats = fs.statSync(filepath);
        
        if (stats.mtime < cutoffDate) {
          fs.unlinkSync(filepath);
          this.info(`Cleaned up old log file: ${file}`);
        }
      }
    } catch (error) {
      this.error('Failed to cleanup log files', { error });
    }
  }
}

// Create singleton instance
const logger = new Logger();

// Schedule log cleanup (run daily)
if (process.env.NODE_ENV === 'production') {
  setInterval(() => {
    logger.cleanupLogs();
  }, 24 * 60 * 60 * 1000); // 24 hours
}

module.exports = logger;