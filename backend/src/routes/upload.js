const express = require("express");
const { authenticateToken } = require("./auth");
const UploadController = require("../controllers/uploadController");
const imageUpload = require("../middleware/imageUpload");
const router = express.Router();

// Upload an image
router.post(
  "/image",
  authenticateToken,
  imageUpload.single("image"),
  async (req, res) => {
    try {
      const result = await UploadController.uploadImage(req.user, req.file);
      res.status(200).json(result);
    } catch (error) {
      console.error("Upload image error:", error);
      const status = error.statusCode || 500;
      res.status(status).json({
        success: false,
        message: error.message || "Failed to upload image",
      });
    }
  }
);

// Delete an image (admin or owner only)
router.delete("/image/:filename", authenticateToken, async (req, res) => {
  try {
    // In a real implementation, you would check if the user owns the file
    // or is an admin before allowing deletion
    const { filename } = req.params;
    const result = await UploadController.deleteImage(filename);
    res.json(result);
  } catch (error) {
    console.error("Delete image error:", error);
    const status = error.statusCode || 500;
    res.status(status).json({
      success: false,
      message: error.message || "Failed to delete image",
    });
  }
});

module.exports = router;
