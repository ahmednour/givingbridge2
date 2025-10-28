const EmailService = require("./emailService");
const PushNotificationService = require("./pushNotificationService");
const NotificationController = require("../controllers/notificationController");

/**
 * Unified Notification Service
 *
 * Coordinates sending notifications via email, push notifications, and in-app notifications
 */
class NotificationService {
  constructor() {
    this.emailService = EmailService;
    this.pushService = PushNotificationService;
  }

  /**
   * Initialize all notification services
   */
  initialize() {
    console.log("🔄 Initializing notification services...");

    // Initialize email service
    this.emailService.initialize();

    // Initialize push notification service
    this.pushService.initialize();

    console.log("✅ Notification services initialization complete");
  }

  /**
   * Send email verification notification
   * @param {object} user - User object
   * @param {string} verificationToken - Email verification token
   */
  async sendEmailVerification(user, verificationToken) {
    // Create in-app notification
    await NotificationController.createNotification({
      userId: user.id,
      type: "system",
      title: "Email Verification Required",
      message: "Please verify your email address to complete your registration",
      metadata: { action: "verify_email" },
    });

    // Send email notification
    if (this.emailService.isInitialized()) {
      await this.emailService.sendEmailVerification(user, verificationToken);
    }

    // Send push notification if user has FCM token
    if (this.pushService.isInitialized() && user.fcmToken) {
      await this.pushService.sendToDevice(
        user.fcmToken,
        {
          title: "Email Verification Required",
          body: "Please verify your email address to complete your registration",
        },
        {
          type: "email_verification",
          action: "verify_email",
        }
      );
    }
  }

  /**
   * Send password reset notification
   * @param {object} user - User object
   * @param {string} resetToken - Password reset token
   */
  async sendPasswordReset(user, resetToken) {
    // Create in-app notification
    await NotificationController.createNotification({
      userId: user.id,
      type: "system",
      title: "Password Reset Request",
      message: "A password reset request was made for your account",
      metadata: { action: "reset_password" },
    });

    // Send email notification
    if (this.emailService.isInitialized()) {
      await this.emailService.sendPasswordReset(user, resetToken);
    }

    // Send push notification if user has FCM token
    if (this.pushService.isInitialized() && user.fcmToken) {
      await this.pushService.sendToDevice(
        user.fcmToken,
        {
          title: "Password Reset Request",
          body: "A password reset request was made for your account",
        },
        {
          type: "password_reset",
          action: "reset_password",
        }
      );
    }
  }

  /**
   * Send request approval notification
   * @param {object} receiver - Request receiver user object
   * @param {object} donor - Donor user object
   * @param {object} request - Request object
   */
  async sendRequestApproval(receiver, donor, request) {
    // Create in-app notification for receiver
    await NotificationController.createNotification({
      userId: receiver.id,
      type: "donation_approved",
      title: "Request Approved!",
      message: `${donor.name} approved your request for: ${request.donationTitle}`,
      relatedId: request.id,
      relatedType: "request",
    });

    // Send email notification to receiver
    if (this.emailService.isInitialized()) {
      await this.emailService.sendRequestApproval(receiver, donor, request);
    }

    // Send push notification to receiver if they have FCM token
    if (this.pushService.isInitialized() && receiver.fcmToken) {
      await this.pushService.notifyRequestStatusChange(
        receiver,
        request.donationTitle,
        "approved"
      );
    }
  }

  /**
   * Send donation confirmation notification
   * @param {object} donor - Donor user object
   * @param {object} receiver - Request receiver user object
   * @param {object} donation - Donation object
   */
  async sendDonationConfirmation(donor, receiver, donation) {
    // Create in-app notifications for both users
    await NotificationController.createNotification({
      userId: donor.id,
      type: "celebration",
      title: "Donation Confirmed!",
      message: `Your donation "${donation.title}" to ${receiver.name} has been confirmed`,
      relatedId: donation.id,
      relatedType: "donation",
    });

    await NotificationController.createNotification({
      userId: receiver.id,
      type: "celebration",
      title: "Donation Received!",
      message: `You've received "${donation.title}" from ${donor.name}`,
      relatedId: donation.id,
      relatedType: "donation",
    });

    // Send email notifications
    if (this.emailService.isInitialized()) {
      await this.emailService.sendDonationConfirmation(
        donor,
        receiver,
        donation
      );
    }

    // Send push notifications if users have FCM tokens
    if (this.pushService.isInitialized()) {
      // Notify donor
      if (donor.fcmToken) {
        await this.pushService.sendToDevice(
          donor.fcmToken,
          {
            title: "Donation Confirmed!",
            body: `Your donation "${donation.title}" to ${receiver.name} has been confirmed`,
          },
          {
            type: "donation_confirmed",
            donationId: donation.id,
          }
        );
      }

      // Notify receiver
      if (receiver.fcmToken) {
        await this.pushService.sendToDevice(
          receiver.fcmToken,
          {
            title: "Donation Received!",
            body: `You've received "${donation.title}" from ${donor.name}`,
          },
          {
            type: "donation_received",
            donationId: donation.id,
          }
        );
      }
    }
  }

  /**
   * Send request update notification
   * @param {object} donor - Donor user object
   * @param {object} receiver - Request receiver user object
   * @param {object} request - Request object
   * @param {object} update - Request update object
   */
  async sendRequestUpdate(donor, receiver, request, update) {
    // Create in-app notification for donor
    await NotificationController.createNotification({
      userId: donor.id,
      type: "request_update",
      title: "Request Update Posted!",
      message: `${receiver.name} posted an update on your funded request: ${request.donation.title}`,
      relatedId: request.id,
      relatedType: "request",
      metadata: { updateId: update.id },
    });

    // Send email notification to donor
    if (this.emailService.isInitialized()) {
      await this.emailService.sendRequestUpdate(
        donor,
        receiver,
        request,
        update
      );
    }

    // Send push notification to donor if they have FCM token
    if (this.pushService.isInitialized() && donor.fcmToken) {
      await this.pushService.sendToDevice(
        donor.fcmToken,
        {
          title: "Request Update Posted!",
          body: `${receiver.name} posted an update on your funded request: ${request.donation.title}`,
        },
        {
          type: "request_update",
          requestId: request.id,
          updateId: update.id,
        }
      );
    }
  }

  /**
   * Send status update notification
   * @param {object} user - User object
   * @param {string} updateType - Type of update
   * @param {object} data - Update data
   */
  async sendStatusUpdate(user, updateType, data) {
    let title, message;

    switch (updateType) {
      case "donation_completed":
        title = "Donation Completed!";
        message = `Your donation "${data.donationTitle}" has been successfully completed`;
        break;
      case "request_expired":
        title = "Request Expired";
        message = `Your request for "${data.donationTitle}" has expired`;
        break;
      default:
        title = "Status Update";
        message = data.message || "You have a status update";
    }

    // Create in-app notification
    await NotificationController.createNotification({
      userId: user.id,
      type: "system",
      title,
      message,
      metadata: { updateType, ...data },
    });

    // Send email notification
    if (this.emailService.isInitialized()) {
      await this.emailService.sendStatusUpdate(user, updateType, data);
    }

    // Send push notification if user has FCM token
    if (this.pushService.isInitialized() && user.fcmToken) {
      await this.pushService.sendToDevice(
        user.fcmToken,
        { title, body: message },
        { type: "status_update", updateType, ...data }
      );
    }
  }

  /**
   * Send new donation notification to interested users
   * @param {array} users - Array of user objects
   * @param {object} donation - Donation object
   */
  async sendNewDonationNotification(users, donation) {
    const userIds = users.map((user) => user.id);

    // Create in-app notifications
    await NotificationController.notifyNewDonation(
      userIds,
      donation.title,
      donation.id
    );

    // Send push notifications to users with FCM tokens
    if (this.pushService.isInitialized()) {
      const tokens = users
        .filter((user) => user.fcmToken)
        .map((user) => user.fcmToken);

      if (tokens.length > 0) {
        await this.pushService.notifyNewDonation(
          "all_users",
          donation.donorName,
          donation.title,
          donation.category
        );
      }
    }
  }
}

// Export singleton instance
module.exports = new NotificationService();
