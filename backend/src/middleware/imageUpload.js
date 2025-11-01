const multer = require("multer");
const path = require("path");
const fs = require("fs");

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

// Configure multer for image uploads (simplified for MVP)
const imageUpload = multer({
  storage: storage, // Use disk storage directly
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB max file size (no optimization)
  },
  fileFilter: fileFilter,
});

/**
 * Simple middleware for basic image upload (MVP version)
 */
const processUploadedImage = (req, res, next) => {
  if (!req.file) {
    return next();
  }

  console.log(`✅ Image uploaded: ${req.file.filename} (${req.file.size} bytes)`);
  next();
};

module.exports = imageUpload;
module.exports.processUploadedImage = processUploadedImage;
