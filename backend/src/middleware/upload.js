const multer = require("multer");
const path = require("path");
const fs = require("fs");
const crypto = require("crypto");
const { getFileUploadSecurityMiddleware } = require("../config/security");
const logger = require("../utils/logger");

// Ensure uploads directory exists with proper permissions
const uploadDir = path.join(__dirname, "../../uploads/avatars");
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true, mode: 0o755 });
}

// Configure multer storage with enhanced security
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    // Validate destination directory
    if (!fs.existsSync(uploadDir)) {
      return cb(new Error("Upload directory not accessible"));
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    try {
      // Generate cryptographically secure filename
      const randomBytes = crypto.randomBytes(16).toString('hex');
      const timestamp = Date.now();
      const userId = req.user?.id || 'anonymous';
      const ext = path.extname(file.originalname).toLowerCase();
      
      // Sanitize and validate extension
      const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
      if (!allowedExtensions.includes(ext)) {
        return cb(new Error("Invalid file extension"));
      }
      
      const filename = `user-${userId}-${timestamp}-${randomBytes}${ext}`;
      
      // Log file upload attempt
      logger.info("File upload initiated", {
        userId,
        originalName: file.originalname,
        generatedName: filename,
        size: file.size,
        mimetype: file.mimetype
      });
      
      cb(null, filename);
    } catch (error) {
      cb(new Error("Failed to generate secure filename"));
    }
  },
});

// Enhanced file filter with comprehensive security checks
const fileFilter = (req, file, cb) => {
  try {
    // Check MIME type
    const allowedMimeTypes = [
      'image/jpeg',
      'image/jpg', 
      'image/png',
      'image/gif',
      'image/webp'
    ];
    
    if (!allowedMimeTypes.includes(file.mimetype)) {
      logger.logSecurityEvent("Invalid MIME type upload attempt", "MEDIUM", {
        mimetype: file.mimetype,
        originalname: file.originalname,
        ip: req.ip,
        userId: req.user?.id
      });
      return cb(new Error(`Invalid file type. Allowed types: ${allowedMimeTypes.join(', ')}`));
    }

    // Check file extension
    const ext = path.extname(file.originalname).toLowerCase();
    const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    
    if (!allowedExtensions.includes(ext)) {
      logger.logSecurityEvent("Invalid file extension upload attempt", "MEDIUM", {
        extension: ext,
        originalname: file.originalname,
        ip: req.ip,
        userId: req.user?.id
      });
      return cb(new Error(`Invalid file extension. Allowed extensions: ${allowedExtensions.join(', ')}`));
    }

    // Check for suspicious file names
    const suspiciousPatterns = [
      /\.\./,           // Directory traversal
      /[<>:"|?*]/,      // Invalid characters
      /^(con|prn|aux|nul|com[1-9]|lpt[1-9])$/i, // Windows reserved names
      /\.php$/i,        // Executable files
      /\.exe$/i,
      /\.bat$/i,
      /\.cmd$/i,
      /\.scr$/i
    ];

    for (const pattern of suspiciousPatterns) {
      if (pattern.test(file.originalname)) {
        logger.logSecurityEvent("Suspicious filename upload attempt", "HIGH", {
          filename: file.originalname,
          pattern: pattern.toString(),
          ip: req.ip,
          userId: req.user?.id
        });
        return cb(new Error("Invalid file name"));
      }
    }

    // Validate file name length
    if (file.originalname.length > 255) {
      return cb(new Error("File name too long"));
    }

    // Check for null bytes (security vulnerability)
    if (file.originalname.includes('\0')) {
      logger.logSecurityEvent("Null byte in filename", "HIGH", {
        filename: file.originalname,
        ip: req.ip,
        userId: req.user?.id
      });
      return cb(new Error("Invalid file name"));
    }

    cb(null, true);
  } catch (error) {
    logger.error("File filter error", { error: error.message, file: file.originalname });
    cb(new Error("File validation failed"));
  }
};

// Configure multer with enhanced security
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB max file size
    files: 1, // Maximum 1 file per request
    fields: 10, // Maximum 10 fields
    fieldNameSize: 100, // Maximum field name size
    fieldSize: 1024 * 1024, // Maximum field value size (1MB)
    headerPairs: 2000 // Maximum number of header pairs
  },
  fileFilter: fileFilter,
});

// Error handling middleware for multer
const handleUploadError = (error, req, res, next) => {
  if (error instanceof multer.MulterError) {
    logger.logSecurityEvent("File upload error", "MEDIUM", {
      error: error.message,
      code: error.code,
      field: error.field,
      ip: req.ip,
      userId: req.user?.id
    });

    switch (error.code) {
      case 'LIMIT_FILE_SIZE':
        return res.status(400).json({
          success: false,
          message: "File too large. Maximum size is 10MB.",
          errorType: "FILE_TOO_LARGE"
        });
      case 'LIMIT_FILE_COUNT':
        return res.status(400).json({
          success: false,
          message: "Too many files. Maximum 1 file allowed.",
          errorType: "TOO_MANY_FILES"
        });
      case 'LIMIT_UNEXPECTED_FILE':
        return res.status(400).json({
          success: false,
          message: "Unexpected file field.",
          errorType: "UNEXPECTED_FILE"
        });
      default:
        return res.status(400).json({
          success: false,
          message: "File upload error.",
          errorType: "UPLOAD_ERROR"
        });
    }
  }

  if (error.message.includes("Only image files") || 
      error.message.includes("Invalid file") ||
      error.message.includes("File validation failed")) {
    return res.status(400).json({
      success: false,
      message: error.message,
      errorType: "INVALID_FILE_TYPE"
    });
  }

  next(error);
};

// Create upload middleware with security checks
const secureUpload = (fieldName = 'avatar') => {
  return [
    getFileUploadSecurityMiddleware(),
    upload.single(fieldName),
    handleUploadError
  ];
};

// Multiple file upload with security
const secureMultipleUpload = (fieldName = 'files', maxCount = 5) => {
  return [
    getFileUploadSecurityMiddleware(),
    upload.array(fieldName, maxCount),
    handleUploadError
  ];
};

module.exports = {
  upload,
  secureUpload,
  secureMultipleUpload,
  handleUploadError
};
