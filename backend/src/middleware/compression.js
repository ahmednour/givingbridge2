const compression = require('compression');

/**
 * Response Compression Middleware
 * Reduces response size by 70-90%
 */

const compressionMiddleware = compression({
  // Only compress responses larger than 1KB
  threshold: 1024,
  
  // Compression level (0-9, 6 is balanced)
  level: 6,
  
  // Filter function to determine what to compress
  filter: (req, res) => {
    // Don't compress if client doesn't support it
    if (req.headers['x-no-compression']) {
      return false;
    }
    
    // Don't compress images (already compressed)
    const contentType = res.getHeader('Content-Type');
    if (contentType && contentType.includes('image/')) {
      return false;
    }
    
    // Use compression filter
    return compression.filter(req, res);
  },
  
  // Memory level (1-9, 8 is default)
  memLevel: 8
});

module.exports = compressionMiddleware;
