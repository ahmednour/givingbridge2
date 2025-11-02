const EmailService = require("./emailService");

/**
 * Unified Notification Service
 *
 * Coordinates sending notifications via email, push notifications, and in-app notifications
 */
class NotificationService {
  constructor() {
    this.emailService = EmailService;
  }

  /**
   * Initialize notification services (simplified for MVP)
   */
  initialize() {
    console.log("🔄 Initializing notification services...");

    // Initialize email service
    this.emailService.initialize();

    console.log("✅ Notification services initialization complete");
  }

  /**
   * Send email verification notification (simplified for MVP)
   * @param {object} user - User object
   * @param {string} verificationToken - Email verification token
   */
  async sendEmailVerification(user, verificationToken) {
    // Send email notification
    if (this.emailService.isInitialized()) {
      await this.emailService.sendEmailVerification(user, verificationToken);
    }
  }

  /**
   * Send password reset notification (simplified for MVP)
   * @param {object} user - User object
   * @param {string} resetToken - Password reset token
   */
  async sendPasswordReset(user, resetToken) {
    // Send email notification
    if (this.emailService.isInitialized()) {
      await this.emailService.sendPasswordReset(user, resetToken);
    }
  }

  /**
   * Send request approval notification (simplified for MVP)
   * @param {object} receiver - Request receiver user object
   * @param {object} donor - Donor user object
   * @param {object} request - Request object
   */
  async sendRequestApproval(receiver, donor, request) {
    // Send email notification to receiver
    if (this.emailService.isInitialized()) {
      await this.emailService.sendRequestApproval(receiver, donor, request);
    }
  }

  /**
   * Send donation confirmation notification (simplified for MVP)
   * @param {object} donor - Donor user object
   * @param {object} receiver - Request receiver user object
   * @param {object} donation - Donation object
   */
  async sendDonationConfirmation(donor, receiver, donation) {
    // Send email notifications
    if (this.emailService.isInitialized()) {
      await this.emailService.sendDonationConfirmation(
        donor,
        receiver,
        donation
      );
    }
  }

  /**
   * Send request update notification (simplified for MVP)
   * @param {object} donor - Donor user object
   * @param {object} receiver - Request receiver user object
   * @param {object} request - Request object
   * @param {object} update - Request update object
   */
  async sendRequestUpdate(donor, receiver, request, update) {
    // Send email notification to donor
    if (this.emailService.isInitialized()) {
      await this.emailService.sendRequestUpdate(
        donor,
        receiver,
        request,
        update
      );
    }
  }

  /**
   * Send status update notification (simplified for MVP)
   * @param {object} user - User object
   * @param {string} updateType - Type of update
   * @param {object} data - Update data
   */
  async sendStatusUpdate(user, updateType, data) {
    // Send email notification
    if (this.emailService.isInitialized()) {
      await this.emailService.sendStatusUpdate(user, updateType, data);
    }
  }

  /**
   * Send new donation notification to interested users (simplified for MVP)
   * @param {array} users - Array of user objects
   * @param {object} donation - Donation object
   */
  async sendNewDonationNotification(users, donation) {
    // Simplified for MVP - basic email notifications only
    console.log(`New donation notification for ${users.length} users: ${donation.title}`);
  }

  /**
   * Send donation approval/rejection notification to donor
   * @param {object} donor - Donor user object
   * @param {object} donation - Donation object
   * @param {string} status - Approval status (approved/rejected)
   * @param {string} reason - Rejection reason (optional)
   */
  async sendDonationApprovalNotification(donor, donation, status, reason = null) {
    // Send email notification
    if (this.emailService.isInitialized()) {
      await this.emailService.sendDonationApprovalNotification(
        donor,
        donation,
        status,
        reason
      );
    }
  }
}

// Export singleton instance
module.exports = new NotificationService();
