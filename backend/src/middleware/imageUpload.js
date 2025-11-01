const multer = require("multer");
const path = require("path");
const fs = require("fs");
const imageOptimizationService = require("../services/imageOptimizationService");

// Ensure uploads directory exists
const uploadDir = path.join(__dirname, "../../uploads/images");
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Configure multer storage for general images
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    // Generate unique filename: userId-timestamp-originalname
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    const ext = path.extname(file.originalname);
    const userId = req.user?.id || 'anonymous';
    cb(null, `user-${userId}-${uniqueSuffix}${ext}`);
  },
});

// File filter for images only
const fileFilter = (req, file, cb) => {
  // Log file details for debugging
  console.log("File upload attempt:", {
    originalname: file.originalname,
    mimetype: file.mimetype,
    size: file.size,
  });

  const allowedTypes = /jpeg|jpg|png|gif|webp/;
  const extname = allowedTypes.test(
    path.extname(file.originalname).toLowerCase()
  );
  const mimetype = allowedTypes.test(file.mimetype);

  console.log("Validation results:", {
    extname: extname,
    mimetype: mimetype,
    extension: path.extname(file.originalname).toLowerCase(),
    mimetypeValue: file.mimetype,
  });

  if (mimetype && extname) {
    return cb(null, true);
  } else {
    console.error("File rejected:", {
      reason: !mimetype ? "Invalid MIME type" : "Invalid extension",
      mimetype: file.mimetype,
      extension: path.extname(file.originalname),
    });
    cb(new Error("Only image files (jpeg, jpg, png, gif, webp) are allowed!"));
  }
};

// Configure multer for image uploads with memory storage for optimization
const imageUpload = multer({
  storage: multer.memoryStorage(), // Store in memory for optimization
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB max file size (will be optimized)
  },
  fileFilter: fileFilter,
});

/**
 * Middleware to optimize uploaded images
 */
const optimizeUploadedImage = async (req, res, next) => {
  if (!req.file) {
    return next();
  }

  try {
    const userId = req.user?.id || 'anonymous';
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    const ext = path.extname(req.file.originalname);
    const filename = `user-${userId}-${uniqueSuffix}${ext}`;
    const filepath = path.join(uploadDir, filename);
    
    // Optimize image
    const optimized = await imageOptimizationService.optimizeImage(req.file.buffer);
    
    // Generate thumbnail
    const thumbnailFilename = `user-${userId}-${uniqueSuffix}_thumb${ext}`;
    const thumbnailPath = path.join(uploadDir, thumbnailFilename);
    const thumbnail = await imageOptimizationService.generateThumbnail(req.file.buffer);
    
    // Save optimized image and thumbnail
    await fs.promises.writeFile(filepath, optimized);
    await fs.promises.writeFile(thumbnailPath, thumbnail);
    
    // Update req.file with new information
    req.file.filename = filename;
    req.file.path = filepath;
    req.file.size = optimized.length;
    req.file.thumbnailFilename = thumbnailFilename;
    req.file.thumbnailPath = thumbnailPath;
    req.file.originalSize = req.file.buffer.length;
    req.file.optimizedSize = optimized.length;
    req.file.savings = ((req.file.originalSize - optimized.length) / req.file.originalSize * 100).toFixed(2);
    
    console.log(`✅ Image optimized: ${req.file.originalSize} → ${optimized.length} bytes (${req.file.savings}% savings)`);
    
    next();
  } catch (error) {
    console.error('Image optimization error:', error);
    next(error);
  }
};

module.exports = imageUpload;
module.exports.optimizeUploadedImage = optimizeUploadedImage;
