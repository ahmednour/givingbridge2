const path = require("path");
const fs = require("fs").promises;

/**
 * Upload Controller
 * Handles file upload and management operations
 */
class UploadController {
  /**
   * Upload an image file
   * @param {Object} user - The authenticated user
   * @param {Object} file - The uploaded file object from multer
   * @returns {Object} - Result with success status and file information
   */
  static async uploadImage(user, file) {
    if (!file) {
      const error = new Error("No file uploaded");
      error.statusCode = 400;
      throw error;
    }

    // Generate public URL for the uploaded file
    const imageUrl = `/uploads/images/${file.filename}`;

    return {
      success: true,
      message: "Image uploaded successfully",
      data: {
        filename: file.filename,
        originalName: file.originalname,
        url: imageUrl,
        size: file.size,
        mimeType: file.mimetype,
      },
    };
  }

  /**
   * Delete an image file
   * @param {string} filename - The name of the file to delete
   * @returns {Object} - Result with success status
   */
  static async deleteImage(filename) {
    if (!filename) {
      const error = new Error("Filename is required");
      error.statusCode = 400;
      throw error;
    }

    try {
      // Construct the full file path
      const filePath = path.join(__dirname, "../../uploads/images", filename);

      // Check if file exists
      try {
        await fs.access(filePath);
      } catch (err) {
        const error = new Error("File not found");
        error.statusCode = 404;
        throw error;
      }

      // Delete the file
      await fs.unlink(filePath);

      return {
        success: true,
        message: "Image deleted successfully",
      };
    } catch (error) {
      if (error.statusCode) {
        throw error;
      }

      const deleteError = new Error("Failed to delete image");
      deleteError.statusCode = 500;
      throw deleteError;
    }
  }
}

module.exports = UploadController;
