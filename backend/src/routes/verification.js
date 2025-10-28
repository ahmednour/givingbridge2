const express = require("express");
const router = express.Router();
const VerificationController = require("../controllers/verificationController");
const {
  authenticateToken,
  requireAdmin,
  asyncHandler,
} = require("../middleware");
const upload = require("../middleware/upload");
const {
  generalLimiter,
  heavyOperationLimiter,
} = require("../middleware/rateLimiting");

// All routes require authentication
router.use(authenticateToken);

// Upload user verification document
router.post(
  "/user/documents",
  generalLimiter, // Apply general rate limiting
  upload.single("document"),
  asyncHandler(async (req, res) => {
    const { documentType } = req.body;
    const userId = req.user.id;

    // Handle document upload
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "Document file is required",
      });
    }

    const documentData = {
      documentType,
      documentUrl: `/uploads/${req.file.filename}`,
      documentName: req.file.originalname,
      documentSize: req.file.size,
    };

    const document =
      await VerificationController.uploadUserVerificationDocument(
        documentData,
        userId
      );

    res.status(201).json({
      success: true,
      message: "Verification document uploaded successfully",
      data: document,
    });
  })
);

// Get user verification documents
router.get(
  "/user/documents",
  generalLimiter, // Apply general rate limiting
  asyncHandler(async (req, res) => {
    const userId = req.user.id;

    const documents = await VerificationController.getUserVerificationDocuments(
      userId
    );

    res.json({
      success: true,
      message: "User verification documents retrieved successfully",
      data: documents,
    });
  })
);

// Verify user document (admin only)
router.put(
  "/user/documents/:documentId/verify",
  [
    requireAdmin,
    generalLimiter, // Apply general rate limiting
  ],
  asyncHandler(async (req, res) => {
    const { documentId } = req.params;
    const { isVerified, rejectionReason } = req.body;
    const adminId = req.user.id;

    const verificationData = { isVerified, rejectionReason };

    const document = await VerificationController.verifyUserDocument(
      documentId,
      adminId,
      verificationData
    );

    res.json({
      success: true,
      message: "User document verification updated successfully",
      data: document,
    });
  })
);

// Upload request verification document
router.post(
  "/request/:requestId/documents",
  generalLimiter, // Apply general rate limiting
  upload.single("document"),
  asyncHandler(async (req, res) => {
    const { requestId } = req.params;
    const { documentType } = req.body;
    const userId = req.user.id;

    // Handle document upload
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "Document file is required",
      });
    }

    const documentData = {
      documentType,
      documentUrl: `/uploads/${req.file.filename}`,
      documentName: req.file.originalname,
      documentSize: req.file.size,
    };

    const document =
      await VerificationController.uploadRequestVerificationDocument(
        documentData,
        requestId,
        userId
      );

    res.status(201).json({
      success: true,
      message: "Request verification document uploaded successfully",
      data: document,
    });
  })
);

// Get request verification documents
router.get(
  "/request/:requestId/documents",
  generalLimiter, // Apply general rate limiting
  asyncHandler(async (req, res) => {
    const { requestId } = req.params;
    const user = req.user;

    const documents =
      await VerificationController.getRequestVerificationDocuments(
        requestId,
        user
      );

    res.json({
      success: true,
      message: "Request verification documents retrieved successfully",
      data: documents,
    });
  })
);

// Verify request document (admin only)
router.put(
  "/request/documents/:documentId/verify",
  [
    requireAdmin,
    generalLimiter, // Apply general rate limiting
  ],
  asyncHandler(async (req, res) => {
    const { documentId } = req.params;
    const { isVerified, rejectionReason } = req.body;
    const adminId = req.user.id;

    const verificationData = { isVerified, rejectionReason };

    const document = await VerificationController.verifyRequestDocument(
      documentId,
      adminId,
      verificationData
    );

    res.json({
      success: true,
      message: "Request document verification updated successfully",
      data: document,
    });
  })
);

// Get verification statistics (admin only)
router.get(
  "/statistics",
  [
    requireAdmin,
    heavyOperationLimiter, // Apply heavy operation rate limiting
  ],
  asyncHandler(async (req, res) => {
    const statistics = await VerificationController.getVerificationStatistics();

    res.json({
      success: true,
      message: "Verification statistics retrieved successfully",
      data: statistics,
    });
  })
);

// Get pending verification documents (admin only)
router.get(
  "/pending/:type",
  [
    requireAdmin,
    generalLimiter, // Apply general rate limiting
  ],
  asyncHandler(async (req, res) => {
    const { type } = req.params; // user or request

    const documents =
      await VerificationController.getPendingVerificationDocuments(type);

    res.json({
      success: true,
      message: "Pending verification documents retrieved successfully",
      data: documents,
    });
  })
);

module.exports = router;
