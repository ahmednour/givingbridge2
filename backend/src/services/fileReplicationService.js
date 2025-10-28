/**
 * File Replication Service
 * Provides real-time file replication and backup capabilities
 */

const fs = require('fs').promises;
const path = require('path');
const chokidar = require('chokidar');
const { spawn } = require('child_process');
const crypto = require('crypto');
const logger = require('../utils/logger');

class FileReplicationService {
  constructor() {
    this.config = {
      uploadsDir: process.env.UPLOADS_DIR || path.join(__dirname, '../../uploads'),
      replicationDir: process.env.REPLICATION_DIR || path.join(__dirname, '../../backups/replication'),
      enableRealTimeReplication: process.env.ENABLE_REALTIME_REPLICATION === 'true',
      replicationDelay: parseInt(process.env.REPLICATION_DELAY) || 5000, // 5 seconds
      maxRetries: parseInt(process.env.REPLICATION_MAX_RETRIES) || 3,
      verifyReplicas: process.env.VERIFY_REPLICAS !== 'false',
      
      // Cloud replication settings
      s3Bucket: process.env.S3_FILES_BUCKET || '',
      s3Prefix: process.env.S3_FILES_PREFIX || 'givingbridge/files',
      awsRegion: process.env.AWS_REGION || 'us-east-1',
      
      // Remote replication settings
      rsyncRemote: process.env.RSYNC_REMOTE || '',
      rsyncOptions: process.env.RSYNC_OPTIONS || '-avz --progress'
    };
    
    this.watcher = null;
    this.replicationQueue = new Map();
    this.processingQueue = false;
    this.metrics = {
      filesReplicated: 0,
      replicationErrors: 0,
      totalSize: 0,
      lastReplication: null,
      queueSize: 0
    };
    
    this.isRunning = false;
  }

  /**
   * Start file replication service
   */
  async start() {
    if (this.isRunning) {
      logger.warn('File replication service is already running');
      return;
    }

    logger.info('Starting file replication service', {
      config: this.config
    });

    try {
      // Ensure directories exist
      await this.ensureDirectories();
      
      // Start file watcher if real-time replication is enabled
      if (this.config.enableRealTimeReplication) {
        await this.startFileWatcher();
      }
      
      // Start queue processor
      this.startQueueProcessor();
      
      this.isRunning = true;
      logger.info('File replication service started successfully');
    } catch (error) {
      logger.error('Failed to start file replication service', {
        error: error.message
      });
      throw error;
    }
  }

  /**
   * Stop file replication service
   */
  async stop() {
    logger.info('Stopping file replication service...');
    
    if (this.watcher) {
      await this.watcher.close();
      this.watcher = null;
    }
    
    this.processingQueue = false;
    this.isRunning = false;
    
    logger.info('File replication service stopped');
  }

  /**
   * Ensure required directories exist
   */
  async ensureDirectories() {
    const directories = [
      this.config.uploadsDir,
      this.config.replicationDir,
      path.join(this.config.replicationDir, 'avatars'),
      path.join(this.config.replicationDir, 'images'),
      path.join(this.config.replicationDir, 'request-images')
    ];

    for (const dir of directories) {
      try {
        await fs.access(dir);
      } catch (error) {
        if (error.code === 'ENOENT') {
          await fs.mkdir(dir, { recursive: true });
          logger.info('Created directory', { directory: dir });
        } else {
          throw error;
        }
      }
    }
  }

  /**
   * Start file system watcher
   */
  async startFileWatcher() {
    logger.info('Starting file system watcher', {
      watchPath: this.config.uploadsDir
    });

    this.watcher = chokidar.watch(this.config.uploadsDir, {
      ignored: /(^|[\/\\])\../, // ignore dotfiles
      persistent: true,
      ignoreInitial: false,
      followSymlinks: false,
      depth: 10
    });

    // Handle file events
    this.watcher
      .on('add', (filePath) => this.handleFileEvent('add', filePath))
      .on('change', (filePath) => this.handleFileEvent('change', filePath))
      .on('unlink', (filePath) => this.handleFileEvent('delete', filePath))
      .on('error', (error) => {
        logger.error('File watcher error', { error: error.message });
      })
      .on('ready', () => {
        logger.info('File watcher ready');
      });
  }

  /**
   * Handle file system events
   */
  async handleFileEvent(event, filePath) {
    const relativePath = path.relative(this.config.uploadsDir, filePath);
    
    logger.debug('File event detected', {
      event,
      file: relativePath
    });

    // Add to replication queue with delay to handle rapid changes
    const queueKey = `${event}:${relativePath}`;
    
    if (this.replicationQueue.has(queueKey)) {
      clearTimeout(this.replicationQueue.get(queueKey).timeout);
    }

    const timeout = setTimeout(async () => {
      try {
        await this.processFileEvent(event, filePath, relativePath);
        this.replicationQueue.delete(queueKey);
      } catch (error) {
        logger.error('Failed to process file event', {
          event,
          file: relativePath,
          error: error.message
        });
        this.metrics.replicationErrors++;
      }
    }, this.config.replicationDelay);

    this.replicationQueue.set(queueKey, {
      event,
      filePath,
      relativePath,
      timeout,
      timestamp: Date.now()
    });

    this.metrics.queueSize = this.replicationQueue.size;
  }

  /**
   * Process individual file event
   */
  async processFileEvent(event, filePath, relativePath) {
    const replicaPath = path.join(this.config.replicationDir, relativePath);

    switch (event) {
      case 'add':
      case 'change':
        await this.replicateFile(filePath, replicaPath, relativePath);
        break;
      case 'delete':
        await this.deleteReplica(replicaPath, relativePath);
        break;
    }
  }

  /**
   * Replicate a single file
   */
  async replicateFile(sourcePath, replicaPath, relativePath) {
    let retries = 0;
    
    while (retries < this.config.maxRetries) {
      try {
        // Ensure destination directory exists
        const replicaDir = path.dirname(replicaPath);
        await fs.mkdir(replicaDir, { recursive: true });
        
        // Get source file stats
        const sourceStats = await fs.stat(sourcePath);
        
        // Copy file
        await fs.copyFile(sourcePath, replicaPath);
        
        // Verify replication if enabled
        if (this.config.verifyReplicas) {
          await this.verifyReplication(sourcePath, replicaPath);
        }
        
        // Update metrics
        this.metrics.filesReplicated++;
        this.metrics.totalSize += sourceStats.size;
        this.metrics.lastReplication = new Date();
        
        logger.debug('File replicated successfully', {
          file: relativePath,
          size: sourceStats.size
        });
        
        // Replicate to cloud storage if configured
        await this.replicateToCloud(sourcePath, relativePath);
        
        return;
      } catch (error) {
        retries++;
        logger.warn('File replication attempt failed', {
          file: relativePath,
          attempt: retries,
          error: error.message
        });
        
        if (retries >= this.config.maxRetries) {
          this.metrics.replicationErrors++;
          throw new Error(`Failed to replicate file after ${this.config.maxRetries} attempts: ${error.message}`);
        }
        
        // Wait before retry
        await new Promise(resolve => setTimeout(resolve, 1000 * retries));
      }
    }
  }

  /**
   * Delete replica file
   */
  async deleteReplica(replicaPath, relativePath) {
    try {
      await fs.unlink(replicaPath);
      
      logger.debug('Replica deleted', {
        file: relativePath
      });
      
      // Delete from cloud storage if configured
      await this.deleteFromCloud(relativePath);
    } catch (error) {
      if (error.code !== 'ENOENT') {
        logger.error('Failed to delete replica', {
          file: relativePath,
          error: error.message
        });
        throw error;
      }
    }
  }

  /**
   * Verify file replication integrity
   */
  async verifyReplication(sourcePath, replicaPath) {
    const [sourceChecksum, replicaChecksum] = await Promise.all([
      this.calculateChecksum(sourcePath),
      this.calculateChecksum(replicaPath)
    ]);

    if (sourceChecksum !== replicaChecksum) {
      throw new Error('Checksum mismatch between source and replica');
    }
  }

  /**
   * Calculate file checksum
   */
  async calculateChecksum(filePath) {
    return new Promise((resolve, reject) => {
      const hash = crypto.createHash('md5');
      const stream = require('fs').createReadStream(filePath);
      
      stream.on('data', (data) => hash.update(data));
      stream.on('end', () => resolve(hash.digest('hex')));
      stream.on('error', reject);
    });
  }

  /**
   * Replicate file to cloud storage
   */
  async replicateToCloud(sourcePath, relativePath) {
    // S3 replication
    if (this.config.s3Bucket) {
      await this.replicateToS3(sourcePath, relativePath);
    }
    
    // Rsync replication
    if (this.config.rsyncRemote) {
      await this.replicateViaRsync(sourcePath, relativePath);
    }
  }

  /**
   * Replicate file to S3
   */
  async replicateToS3(sourcePath, relativePath) {
    return new Promise((resolve, reject) => {
      const s3Key = `${this.config.s3Prefix}/${relativePath}`;
      
      const awsProcess = spawn('aws', [
        's3', 'cp',
        sourcePath,
        `s3://${this.config.s3Bucket}/${s3Key}`,
        '--region', this.config.awsRegion,
        '--storage-class', 'STANDARD_IA'
      ]);
      
      let output = '';
      let error = '';
      
      awsProcess.stdout.on('data', (data) => {
        output += data.toString();
      });
      
      awsProcess.stderr.on('data', (data) => {
        error += data.toString();
      });
      
      awsProcess.on('close', (code) => {
        if (code === 0) {
          logger.debug('File replicated to S3', {
            file: relativePath,
            s3Key
          });
          resolve();
        } else {
          logger.error('S3 replication failed', {
            file: relativePath,
            error
          });
          reject(new Error(`S3 replication failed: ${error}`));
        }
      });
      
      awsProcess.on('error', (err) => {
        reject(new Error(`Failed to start S3 replication: ${err.message}`));
      });
    });
  }

  /**
   * Replicate file via rsync
   */
  async replicateViaRsync(sourcePath, relativePath) {
    return new Promise((resolve, reject) => {
      const remotePath = `${this.config.rsyncRemote}/${relativePath}`;
      const options = this.config.rsyncOptions.split(' ');
      
      const rsyncProcess = spawn('rsync', [...options, sourcePath, remotePath]);
      
      let output = '';
      let error = '';
      
      rsyncProcess.stdout.on('data', (data) => {
        output += data.toString();
      });
      
      rsyncProcess.stderr.on('data', (data) => {
        error += data.toString();
      });
      
      rsyncProcess.on('close', (code) => {
        if (code === 0) {
          logger.debug('File replicated via rsync', {
            file: relativePath,
            remotePath
          });
          resolve();
        } else {
          logger.error('Rsync replication failed', {
            file: relativePath,
            error
          });
          reject(new Error(`Rsync replication failed: ${error}`));
        }
      });
      
      rsyncProcess.on('error', (err) => {
        reject(new Error(`Failed to start rsync replication: ${err.message}`));
      });
    });
  }

  /**
   * Delete file from cloud storage
   */
  async deleteFromCloud(relativePath) {
    // Delete from S3
    if (this.config.s3Bucket) {
      await this.deleteFromS3(relativePath);
    }
  }

  /**
   * Delete file from S3
   */
  async deleteFromS3(relativePath) {
    return new Promise((resolve, reject) => {
      const s3Key = `${this.config.s3Prefix}/${relativePath}`;
      
      const awsProcess = spawn('aws', [
        's3', 'rm',
        `s3://${this.config.s3Bucket}/${s3Key}`,
        '--region', this.config.awsRegion
      ]);
      
      let error = '';
      
      awsProcess.stderr.on('data', (data) => {
        error += data.toString();
      });
      
      awsProcess.on('close', (code) => {
        if (code === 0) {
          logger.debug('File deleted from S3', {
            file: relativePath,
            s3Key
          });
        } else {
          logger.warn('S3 deletion failed', {
            file: relativePath,
            error
          });
        }
        resolve(); // Don't fail on deletion errors
      });
      
      awsProcess.on('error', (err) => {
        logger.warn('Failed to delete from S3', {
          file: relativePath,
          error: err.message
        });
        resolve(); // Don't fail on deletion errors
      });
    });
  }

  /**
   * Start queue processor
   */
  startQueueProcessor() {
    this.processingQueue = true;
    
    const processQueue = async () => {
      if (!this.processingQueue) return;
      
      // Process any pending items in the queue
      const now = Date.now();
      const expiredItems = [];
      
      for (const [key, item] of this.replicationQueue.entries()) {
        if (now - item.timestamp > this.config.replicationDelay * 2) {
          expiredItems.push(key);
        }
      }
      
      // Clean up expired items
      for (const key of expiredItems) {
        const item = this.replicationQueue.get(key);
        if (item && item.timeout) {
          clearTimeout(item.timeout);
        }
        this.replicationQueue.delete(key);
      }
      
      this.metrics.queueSize = this.replicationQueue.size;
      
      // Schedule next check
      setTimeout(processQueue, 30000); // Check every 30 seconds
    };
    
    processQueue();
  }

  /**
   * Manually replicate a file
   */
  async replicateFileManually(filePath) {
    const relativePath = path.relative(this.config.uploadsDir, filePath);
    const replicaPath = path.join(this.config.replicationDir, relativePath);
    
    await this.replicateFile(filePath, replicaPath, relativePath);
    
    return {
      success: true,
      file: relativePath,
      timestamp: new Date()
    };
  }

  /**
   * Sync all files (initial replication)
   */
  async syncAllFiles() {
    logger.info('Starting full file synchronization...');
    
    const files = await this.getAllFiles(this.config.uploadsDir);
    let synced = 0;
    let errors = 0;
    
    for (const filePath of files) {
      try {
        await this.replicateFileManually(filePath);
        synced++;
        
        if (synced % 100 === 0) {
          logger.info(`Synced ${synced}/${files.length} files...`);
        }
      } catch (error) {
        errors++;
        logger.error('Failed to sync file', {
          file: filePath,
          error: error.message
        });
      }
    }
    
    logger.info('File synchronization completed', {
      totalFiles: files.length,
      synced,
      errors
    });
    
    return {
      totalFiles: files.length,
      synced,
      errors
    };
  }

  /**
   * Get all files in directory recursively
   */
  async getAllFiles(dir) {
    const files = [];
    
    const scan = async (currentDir) => {
      const items = await fs.readdir(currentDir);
      
      for (const item of items) {
        const fullPath = path.join(currentDir, item);
        const stats = await fs.stat(fullPath);
        
        if (stats.isDirectory()) {
          await scan(fullPath);
        } else if (stats.isFile()) {
          files.push(fullPath);
        }
      }
    };
    
    await scan(dir);
    return files;
  }

  /**
   * Get replication status
   */
  getStatus() {
    return {
      isRunning: this.isRunning,
      config: this.config,
      metrics: this.metrics,
      queueSize: this.replicationQueue.size
    };
  }

  /**
   * Get health summary
   */
  getHealthSummary() {
    const status = this.isRunning ? 'running' : 'stopped';
    const issues = [];
    
    if (this.metrics.replicationErrors > 0) {
      issues.push(`${this.metrics.replicationErrors} replication errors`);
    }
    
    if (this.replicationQueue.size > 100) {
      issues.push(`Large replication queue (${this.replicationQueue.size} items)`);
    }
    
    return {
      status,
      issues,
      metrics: this.metrics,
      lastReplication: this.metrics.lastReplication
    };
  }
}

// Export singleton instance
const fileReplicationService = new FileReplicationService();

module.exports = {
  FileReplicationService,
  fileReplicationService,
  start: () => fileReplicationService.start(),
  stop: () => fileReplicationService.stop(),
  getStatus: () => fileReplicationService.getStatus(),
  getHealthSummary: () => fileReplicationService.getHealthSummary(),
  syncAllFiles: () => fileReplicationService.syncAllFiles(),
  replicateFile: (filePath) => fileReplicationService.replicateFileManually(filePath)
};