const Redis = require('ioredis');
const logger = require('../utils/logger');

/**
 * Redis Cache Service
 * Provides caching for frequently accessed data
 */

class CacheService {
  constructor() {
    this.client = null;
    this.isConnected = false;
  }

  /**
   * Initialize Redis connection
   */
  async initialize() {
    try {
      this.client = new Redis({
        host: process.env.REDIS_HOST || 'localhost',
        port: process.env.REDIS_PORT || 6379,
        password: process.env.REDIS_PASSWORD || undefined,
        retryStrategy: (times) => {
          const delay = Math.min(times * 50, 2000);
          return delay;
        },
        maxRetriesPerRequest: 3
      });

      this.client.on('connect', () => {
        this.isConnected = true;
        console.log('✅ Redis cache connected');
      });

      this.client.on('error', (error) => {
        this.isConnected = false;
        console.log('⚠️  Redis cache error:', error.message);
      });

      this.client.on('close', () => {
        this.isConnected = false;
        console.log('🔴 Redis cache disconnected');
      });

      // Test connection
      await this.client.ping();
      
    } catch (error) {
      console.log('⚠️  Redis cache not available:', error.message);
      this.client = null;
    }
  }

  /**
   * Get value from cache
   */
  async get(key) {
    if (!this.isConnected || !this.client) return null;
    
    try {
      const value = await this.client.get(key);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      logger.warn('Cache get error', { key, error: error.message });
      return null;
    }
  }

  /**
   * Set value in cache with expiry
   */
  async set(key, value, expirySeconds = 300) {
    if (!this.isConnected || !this.client) return false;
    
    try {
      await this.client.setex(key, expirySeconds, JSON.stringify(value));
      return true;
    } catch (error) {
      logger.warn('Cache set error', { key, error: error.message });
      return false;
    }
  }

  /**
   * Delete value from cache
   */
  async del(key) {
    if (!this.isConnected || !this.client) return false;
    
    try {
      await this.client.del(key);
      return true;
    } catch (error) {
      logger.warn('Cache delete error', { key, error: error.message });
      return false;
    }
  }

  /**
   * Clear all cache
   */
  async clear() {
    if (!this.isConnected || !this.client) return false;
    
    try {
      await this.client.flushdb();
      return true;
    } catch (error) {
      logger.warn('Cache clear error', { error: error.message });
      return false;
    }
  }

  /**
   * Cache middleware for Express routes
   */
  middleware(duration = 300) {
    return async (req, res, next) => {
      // Only cache GET requests
      if (req.method !== 'GET') {
        return next();
      }

      // Skip if cache not available
      if (!this.isConnected) {
        return next();
      }

      const key = `cache:${req.originalUrl}`;

      try {
        // Try to get from cache
        const cached = await this.get(key);
        
        if (cached) {
          res.setHeader('X-Cache', 'HIT');
          return res.json(cached);
        }

        // Cache miss - intercept response
        res.setHeader('X-Cache', 'MISS');
        const originalJson = res.json.bind(res);
        
        res.json = (body) => {
          // Cache the response
          this.set(key, body, duration).catch(err => {
            logger.warn('Failed to cache response', { key, error: err.message });
          });
          
          return originalJson(body);
        };

        next();
      } catch (error) {
        logger.warn('Cache middleware error', { error: error.message });
        next();
      }
    };
  }

  /**
   * Invalidate cache by pattern
   */
  async invalidatePattern(pattern) {
    if (!this.isConnected || !this.client) return false;
    
    try {
      const keys = await this.client.keys(pattern);
      if (keys.length > 0) {
        await this.client.del(...keys);
      }
      return true;
    } catch (error) {
      logger.warn('Cache invalidate error', { pattern, error: error.message });
      return false;
    }
  }
}

// Export singleton instance
const cacheService = new CacheService();

module.exports = cacheService;
