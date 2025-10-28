const User = require("../models/User");
const Request = require("../models/Request");
const UserVerificationDocument = require("../models/UserVerificationDocument");
const RequestVerificationDocument = require("../models/RequestVerificationDocument");
const {
  NotFoundError,
  ValidationError,
  ForbiddenError,
} = require("../utils/errorHandler");

/**
 * Verification Controller
 * Handles user and request verification functionality
 */
class VerificationController {
  /**
   * Upload user verification document
   * @param {Object} documentData - Document data
   * @param {number} userId - User ID
   * @returns {Promise<Object>} Created verification document
   */
  static async uploadUserVerificationDocument(documentData, userId) {
    const { documentType, documentUrl, documentName, documentSize } =
      documentData;

    // Validate input
    if (!documentType || !documentUrl || !documentName) {
      throw new ValidationError("Document type, URL, and name are required");
    }

    // Create the verification document
    const verificationDocument = await UserVerificationDocument.create({
      userId,
      documentType,
      documentUrl,
      documentName,
      documentSize,
    });

    // Update user's last verification attempt
    await User.update(
      { lastVerificationAttempt: new Date() },
      { where: { id: userId } }
    );

    // Include user information
    verificationDocument.user = await User.findByPk(userId, {
      attributes: ["id", "name", "email", "isVerified", "verificationLevel"],
    });

    return verificationDocument;
  }

  /**
   * Get user verification documents
   * @param {number} userId - User ID
   * @returns {Promise<Array>} User verification documents
   */
  static async getUserVerificationDocuments(userId) {
    return await UserVerificationDocument.findAll({
      where: { userId },
      include: [
        {
          model: User,
          as: "verifier",
          attributes: ["id", "name", "email"],
        },
      ],
      order: [["createdAt", "DESC"]],
    });
  }

  /**
   * Verify user document (admin only)
   * @param {number} documentId - Document ID
   * @param {number} adminId - Admin ID
   * @param {Object} verificationData - Verification data
   * @returns {Promise<Object>} Updated verification document
   */
  static async verifyUserDocument(documentId, adminId, verificationData) {
    const { isVerified, rejectionReason } = verificationData;

    const document = await UserVerificationDocument.findByPk(documentId);
    if (!document) {
      throw new NotFoundError("Verification document not found");
    }

    // Update the document
    await document.update({
      isVerified,
      verifiedBy: adminId,
      verifiedAt: new Date(),
      rejectionReason: isVerified ? null : rejectionReason,
    });

    // If document is verified, check if user should be marked as verified
    if (isVerified) {
      const userDocuments = await UserVerificationDocument.findAll({
        where: { userId: document.userId, isVerified: true },
      });

      // If user has at least one verified document, mark as verified
      if (userDocuments.length > 0) {
        const user = await User.findByPk(document.userId);
        // Update to basic verification level if not already verified
        if (user.verificationLevel === "unverified") {
          await user.update({
            isVerified: true,
            verificationLevel: "basic",
          });
        }
      }
    }

    // Include user and verifier information
    document.user = await User.findByPk(document.userId, {
      attributes: ["id", "name", "email", "isVerified", "verificationLevel"],
    });

    document.verifier = await User.findByPk(adminId, {
      attributes: ["id", "name", "email"],
    });

    return document;
  }

  /**
   * Upload request verification document
   * @param {Object} documentData - Document data
   * @param {number} requestId - Request ID
   * @param {number} userId - User ID
   * @returns {Promise<Object>} Created verification document
   */
  static async uploadRequestVerificationDocument(
    documentData,
    requestId,
    userId
  ) {
    const { documentType, documentUrl, documentName, documentSize } =
      documentData;

    // Validate input
    if (!documentType || !documentUrl || !documentName) {
      throw new ValidationError("Document type, URL, and name are required");
    }

    // Get the request
    const request = await Request.findByPk(requestId);
    if (!request) {
      throw new NotFoundError("Request not found");
    }

    // Check if user is authorized to upload document (receiver or donor)
    if (request.receiverId !== userId && request.donorId !== userId) {
      throw new ForbiddenError(
        "You are not authorized to upload documents for this request"
      );
    }

    // Create the verification document
    const verificationDocument = await RequestVerificationDocument.create({
      requestId,
      documentType,
      documentUrl,
      documentName,
      documentSize,
    });

    // Include request information
    verificationDocument.request = request;

    return verificationDocument;
  }

  /**
   * Get request verification documents
   * @param {number} requestId - Request ID
   * @param {Object} user - Current user
   * @returns {Promise<Array>} Request verification documents
   */
  static async getRequestVerificationDocuments(requestId, user) {
    // Get the request
    const request = await Request.findByPk(requestId);
    if (!request) {
      throw new NotFoundError("Request not found");
    }

    // Check if user is authorized to view documents (receiver, donor, or admin)
    if (
      user.role !== "admin" &&
      request.receiverId !== user.id &&
      request.donorId !== user.id
    ) {
      throw new ForbiddenError(
        "You are not authorized to view documents for this request"
      );
    }

    return await RequestVerificationDocument.findAll({
      where: { requestId },
      include: [
        {
          model: User,
          as: "verifier",
          attributes: ["id", "name", "email"],
        },
      ],
      order: [["createdAt", "DESC"]],
    });
  }

  /**
   * Verify request document (admin only)
   * @param {number} documentId - Document ID
   * @param {number} adminId - Admin ID
   * @param {Object} verificationData - Verification data
   * @returns {Promise<Object>} Updated verification document
   */
  static async verifyRequestDocument(documentId, adminId, verificationData) {
    const { isVerified, rejectionReason } = verificationData;

    const document = await RequestVerificationDocument.findByPk(documentId);
    if (!document) {
      throw new NotFoundError("Verification document not found");
    }

    // Update the document
    await document.update({
      isVerified,
      verifiedBy: adminId,
      verifiedAt: new Date(),
      rejectionReason: isVerified ? null : rejectionReason,
    });

    // If document is verified, mark request as verified
    if (isVerified) {
      const request = await Request.findByPk(document.requestId);
      if (request) {
        await request.update({
          isVerified: true,
        });
      }
    }

    // Include request and verifier information
    document.request = await Request.findByPk(document.requestId);

    document.verifier = await User.findByPk(adminId, {
      attributes: ["id", "name", "email"],
    });

    return document;
  }

  /**
   * Get verification statistics
   * @returns {Promise<Object>} Verification statistics
   */
  static async getVerificationStatistics() {
    // Get user verification stats
    const totalUsers = await User.count();
    const verifiedUsers = await User.count({ where: { isVerified: true } });

    const userVerificationLevels = await User.findAll({
      attributes: [
        "verificationLevel",
        [User.sequelize.fn("COUNT", User.sequelize.col("id")), "count"],
      ],
      group: ["verificationLevel"],
      raw: true,
    });

    // Get request verification stats
    const totalRequests = await Request.count();
    const verifiedRequests = await Request.count({
      where: { isVerified: true },
    });

    // Get document verification stats
    const totalUserDocuments = await UserVerificationDocument.count();
    const verifiedUserDocuments = await UserVerificationDocument.count({
      where: { isVerified: true },
    });

    const totalRequestDocuments = await RequestVerificationDocument.count();
    const verifiedRequestDocuments = await RequestVerificationDocument.count({
      where: { isVerified: true },
    });

    return {
      users: {
        total: totalUsers,
        verified: verifiedUsers,
        verificationRate:
          totalUsers > 0 ? ((verifiedUsers / totalUsers) * 100).toFixed(2) : 0,
        verificationLevels: userVerificationLevels.reduce((acc, level) => {
          acc[level.verificationLevel] = parseInt(level.count);
          return acc;
        }, {}),
      },
      requests: {
        total: totalRequests,
        verified: verifiedRequests,
        verificationRate:
          totalRequests > 0
            ? ((verifiedRequests / totalRequests) * 100).toFixed(2)
            : 0,
      },
      documents: {
        user: {
          total: totalUserDocuments,
          verified: verifiedUserDocuments,
          verificationRate:
            totalUserDocuments > 0
              ? ((verifiedUserDocuments / totalUserDocuments) * 100).toFixed(2)
              : 0,
        },
        request: {
          total: totalRequestDocuments,
          verified: verifiedRequestDocuments,
          verificationRate:
            totalRequestDocuments > 0
              ? (
                  (verifiedRequestDocuments / totalRequestDocuments) *
                  100
                ).toFixed(2)
              : 0,
        },
      },
    };
  }

  /**
   * Get pending verification documents
   * @param {string} type - Document type (user or request)
   * @returns {Promise<Array>} Pending verification documents
   */
  static async getPendingVerificationDocuments(type = "user") {
    if (type === "user") {
      return await UserVerificationDocument.findAll({
        where: { isVerified: false },
        include: [
          {
            model: User,
            as: "user",
            attributes: ["id", "name", "email"],
          },
        ],
        order: [["createdAt", "ASC"]],
      });
    } else {
      return await RequestVerificationDocument.findAll({
        where: { isVerified: false },
        include: [
          {
            model: Request,
            as: "request",
            attributes: ["id", "message"],
          },
        ],
        order: [["createdAt", "ASC"]],
      });
    }
  }
}

module.exports = VerificationController;
