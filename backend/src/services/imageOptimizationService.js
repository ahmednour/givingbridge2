const sharp = require('sharp');
const path = require('path');
const fs = require('fs').promises;

/**
 * Image Optimization Service
 * Optimizes and resizes images for better performance
 */

class ImageOptimizationService {
  constructor() {
    this.maxWidth = 1200;
    this.maxHeight = 1200;
    this.quality = 85;
    this.thumbnailSize = 300;
  }

  /**
   * Optimize image
   * @param {Buffer} buffer - Image buffer
   * @param {Object} options - Optimization options
   * @returns {Promise<Buffer>} Optimized image buffer
   */
  async optimizeImage(buffer, options = {}) {
    const {
      maxWidth = this.maxWidth,
      maxHeight = this.maxHeight,
      quality = this.quality,
      format = 'jpeg'
    } = options;

    try {
      let pipeline = sharp(buffer)
        .resize(maxWidth, maxHeight, {
          fit: 'inside',
          withoutEnlargement: true
        });

      // Apply format-specific optimization
      if (format === 'jpeg' || format === 'jpg') {
        pipeline = pipeline.jpeg({
          quality,
          progressive: true,
          mozjpeg: true
        });
      } else if (format === 'png') {
        pipeline = pipeline.png({
          quality,
          compressionLevel: 9,
          progressive: true
        });
      } else if (format === 'webp') {
        pipeline = pipeline.webp({
          quality,
          effort: 6
        });
      }

      return await pipeline.toBuffer();
    } catch (error) {
      console.error('Image optimization error:', error);
      throw new Error('Failed to optimize image');
    }
  }

  /**
   * Generate thumbnail
   * @param {Buffer} buffer - Image buffer
   * @param {Number} size - Thumbnail size
   * @returns {Promise<Buffer>} Thumbnail buffer
   */
  async generateThumbnail(buffer, size = this.thumbnailSize) {
    try {
      return await sharp(buffer)
        .resize(size, size, {
          fit: 'cover',
          position: 'center'
        })
        .jpeg({
          quality: 80,
          progressive: true
        })
        .toBuffer();
    } catch (error) {
      console.error('Thumbnail generation error:', error);
      throw new Error('Failed to generate thumbnail');
    }
  }

  /**
   * Get image metadata
   * @param {Buffer} buffer - Image buffer
   * @returns {Promise<Object>} Image metadata
   */
  async getMetadata(buffer) {
    try {
      return await sharp(buffer).metadata();
    } catch (error) {
      console.error('Get metadata error:', error);
      throw new Error('Failed to get image metadata');
    }
  }

  /**
   * Optimize and save image with thumbnail
   * @param {Buffer} buffer - Image buffer
   * @param {String} outputPath - Output file path
   * @returns {Promise<Object>} Paths to optimized image and thumbnail
   */
  async optimizeAndSave(buffer, outputPath) {
    try {
      const ext = path.extname(outputPath);
      const basename = path.basename(outputPath, ext);
      const dirname = path.dirname(outputPath);
      
      // Optimize main image
      const optimized = await this.optimizeImage(buffer);
      await fs.writeFile(outputPath, optimized);
      
      // Generate and save thumbnail
      const thumbnailPath = path.join(dirname, `${basename}_thumb${ext}`);
      const thumbnail = await this.generateThumbnail(buffer);
      await fs.writeFile(thumbnailPath, thumbnail);
      
      // Get file sizes
      const originalSize = buffer.length;
      const optimizedSize = optimized.length;
      const thumbnailSize = thumbnail.length;
      
      return {
        original: outputPath,
        thumbnail: thumbnailPath,
        sizes: {
          original: originalSize,
          optimized: optimizedSize,
          thumbnail: thumbnailSize,
          savings: ((originalSize - optimizedSize) / originalSize * 100).toFixed(2) + '%'
        }
      };
    } catch (error) {
      console.error('Optimize and save error:', error);
      throw new Error('Failed to optimize and save image');
    }
  }

  /**
   * Convert image to WebP format
   * @param {Buffer} buffer - Image buffer
   * @returns {Promise<Buffer>} WebP image buffer
   */
  async convertToWebP(buffer) {
    try {
      return await sharp(buffer)
        .webp({
          quality: this.quality,
          effort: 6
        })
        .toBuffer();
    } catch (error) {
      console.error('WebP conversion error:', error);
      throw new Error('Failed to convert to WebP');
    }
  }

  /**
   * Validate image
   * @param {Buffer} buffer - Image buffer
   * @returns {Promise<Boolean>} True if valid
   */
  async validateImage(buffer) {
    try {
      const metadata = await this.getMetadata(buffer);
      
      // Check if it's a valid image
      if (!metadata.format) {
        return false;
      }
      
      // Check supported formats
      const supportedFormats = ['jpeg', 'jpg', 'png', 'webp', 'gif'];
      if (!supportedFormats.includes(metadata.format)) {
        return false;
      }
      
      // Check dimensions
      if (metadata.width > 10000 || metadata.height > 10000) {
        return false;
      }
      
      return true;
    } catch (error) {
      return false;
    }
  }
}

// Export singleton instance
const imageOptimizationService = new ImageOptimizationService();

module.exports = imageOptimizationService;
