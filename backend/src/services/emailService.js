const nodemailer = require("nodemailer");
const fs = require("fs").promises;
const path = require("path");

/**
 * Email Service
 *
 * Handles sending various types of emails using nodemailer
 */
class EmailService {
  constructor() {
    this.transporter = null;
    this.initialized = false;
    this.fromEmail = process.env.EMAIL_FROM || "noreply@givingbridge.org";
    this.appName = process.env.APP_NAME || "GivingBridge";
  }

  /**
   * Initialize email transporter
   */
  initialize() {
    // Check if email configuration exists
    const emailHost = process.env.EMAIL_HOST;
    const emailPort = process.env.EMAIL_PORT;
    const emailUser = process.env.EMAIL_USER;
    const emailPass = process.env.EMAIL_PASS;

    if (!emailHost || !emailPort || !emailUser || !emailPass) {
      console.warn(
        "⚠️  Email configuration incomplete. Email notifications will be disabled."
      );
      console.warn(
        "   Please set EMAIL_HOST, EMAIL_PORT, EMAIL_USER, and EMAIL_PASS environment variables."
      );
      return;
    }

    try {
      this.transporter = nodemailer.createTransporter({
        host: emailHost,
        port: emailPort,
        secure: emailPort == 465, // true for 465, false for other ports
        auth: {
          user: emailUser,
          pass: emailPass,
        },
      });

      this.initialized = true;
      console.log("✅ Email service initialized successfully");
    } catch (error) {
      console.error("❌ Email service initialization failed:", error.message);
      console.warn("⚠️  Email notifications will be disabled");
    }
  }

  /**
   * Check if service is initialized
   */
  isInitialized() {
    return this.initialized;
  }

  /**
   * Send email
   * @param {string} to - Recipient email address
   * @param {string} subject - Email subject
   * @param {string} html - HTML content
   * @param {string} text - Plain text content (optional)
   */
  async sendEmail(to, subject, html, text = "") {
    if (!this.initialized) {
      console.warn("⚠️  Email service not initialized, skipping email");
      return { success: false, error: "Email service not initialized" };
    }

    try {
      const mailOptions = {
        from: `"${this.appName}" <${this.fromEmail}>`,
        to,
        subject,
        html,
        text,
      };

      const info = await this.transporter.sendMail(mailOptions);
      console.log("✅ Email sent successfully:", info.messageId);
      return { success: true, messageId: info.messageId };
    } catch (error) {
      console.error("❌ Failed to send email:", error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Load email template
   * @param {string} templateName - Name of template file (without extension)
   * @param {object} data - Data to replace in template
   */
  async loadTemplate(templateName, data = {}) {
    try {
      const templatePath = path.join(
        __dirname,
        "..",
        "templates",
        "emails",
        `${templateName}.html`
      );
      let template = await fs.readFile(templatePath, "utf8");

      // Replace placeholders with data
      Object.keys(data).forEach((key) => {
        const regex = new RegExp(`{{${key}}}`, "g");
        template = template.replace(regex, data[key] || "");
      });

      return template;
    } catch (error) {
      console.error(`❌ Failed to load email template ${templateName}:`, error);
      return `<p>${data.message || "No message content"}</p>`;
    }
  }

  /**
   * Send email verification email
   * @param {object} user - User object
   * @param {string} verificationToken - Email verification token
   */
  async sendEmailVerification(user, verificationToken) {
    const verificationUrl = `${
      process.env.FRONTEND_URL || "http://localhost:3000"
    }/verify-email?token=${verificationToken}&email=${encodeURIComponent(
      user.email
    )}`;

    const html = await this.loadTemplate("email-verification", {
      appName: this.appName,
      name: user.name,
      verificationUrl,
    });

    return this.sendEmail(
      user.email,
      `Verify your email address - ${this.appName}`,
      html
    );
  }

  /**
   * Send password reset email
   * @param {object} user - User object
   * @param {string} resetToken - Password reset token
   */
  async sendPasswordReset(user, resetToken) {
    const resetUrl = `${
      process.env.FRONTEND_URL || "http://localhost:3000"
    }/reset-password?token=${resetToken}&email=${encodeURIComponent(
      user.email
    )}`;

    const html = await this.loadTemplate("password-reset", {
      appName: this.appName,
      name: user.name,
      resetUrl,
    });

    return this.sendEmail(
      user.email,
      `Password Reset Request - ${this.appName}`,
      html
    );
  }

  /**
   * Send donation request approval notification
   * @param {object} receiver - Request receiver user object
   * @param {object} donor - Donor user object
   * @param {object} request - Request object
   */
  async sendRequestApproval(receiver, donor, request) {
    const html = await this.loadTemplate("request-approved", {
      appName: this.appName,
      receiverName: receiver.name,
      donorName: donor.name,
      donationTitle: request.donationTitle,
      message: request.message,
    });

    return this.sendEmail(
      receiver.email,
      `Your donation request was approved! - ${this.appName}`,
      html
    );
  }

  /**
   * Send donation confirmation email
   * @param {object} donor - Donor user object
   * @param {object} receiver - Request receiver user object
   * @param {object} donation - Donation object
   */
  async sendDonationConfirmation(donor, receiver, donation) {
    // Send to donor
    const donorHtml = await this.loadTemplate("donation-confirmation-donor", {
      appName: this.appName,
      donorName: donor.name,
      receiverName: receiver.name,
      donationTitle: donation.title,
      donationCategory: donation.category,
    });

    const donorResult = await this.sendEmail(
      donor.email,
      `Donation Confirmation - ${this.appName}`,
      donorHtml
    );

    // Send to receiver
    const receiverHtml = await this.loadTemplate(
      "donation-confirmation-receiver",
      {
        appName: this.appName,
        donorName: donor.name,
        receiverName: receiver.name,
        donationTitle: donation.title,
        donationCategory: donation.category,
      }
    );

    const receiverResult = await this.sendEmail(
      receiver.email,
      `Donation Received Confirmation - ${this.appName}`,
      receiverHtml
    );

    return {
      donor: donorResult,
      receiver: receiverResult,
    };
  }

  /**
   * Send request update notification
   * @param {object} donor - Donor user object
   * @param {object} receiver - Request receiver user object
   * @param {object} request - Request object
   * @param {object} update - Request update object
   */
  async sendRequestUpdate(donor, receiver, request, update) {
    const dashboardUrl = `${
      process.env.FRONTEND_URL || "http://localhost:3000"
    }/dashboard/requests/${request.id}`;

    const html = await this.loadTemplate("request-update", {
      appName: this.appName,
      donorName: donor.name,
      receiverName: receiver.name,
      donationTitle: request.donation.title,
      updateTitle: update.title,
      updateDescription: update.description,
      updateDate: new Date(update.createdAt).toLocaleDateString(),
      dashboardUrl,
    });

    return this.sendEmail(
      donor.email,
      `Request Update Posted - ${this.appName}`,
      html
    );
  }

  /**
   * Send status update notification
   * @param {object} user - User object
   * @param {string} updateType - Type of update
   * @param {object} data - Update data
   */
  async sendStatusUpdate(user, updateType, data) {
    let subject, templateName;

    switch (updateType) {
      case "donation_completed":
        subject = `Donation Completed - ${this.appName}`;
        templateName = "status-update-donation-completed";
        break;
      case "request_expired":
        subject = `Donation Request Expired - ${this.appName}`;
        templateName = "status-update-request-expired";
        break;
      default:
        subject = `Status Update - ${this.appName}`;
        templateName = "status-update-generic";
    }

    const html = await this.loadTemplate(templateName, {
      appName: this.appName,
      name: user.name,
      ...data,
    });

    return this.sendEmail(user.email, subject, html);
  }

  /**
   * Send donation approval/rejection notification email
   * @param {object} donor - Donor user object
   * @param {object} donation - Donation object
   * @param {string} status - Approval status (approved/rejected)
   * @param {string} reason - Rejection reason (optional)
   */
  async sendDonationApprovalNotification(donor, donation, status, reason = null) {
    if (!this.initialized) {
      console.warn("Email service not initialized. Skipping approval notification email.");
      return;
    }

    const subject = status === "approved" 
      ? `✅ Your Donation "${donation.title}" Has Been Approved!`
      : `❌ Your Donation "${donation.title}" Requires Attention`;

    const htmlContent = status === "approved"
      ? `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #10b981;">Great News! Your Donation Has Been Approved</h2>
          
          <p>Dear ${donor.name},</p>
          
          <p>We're pleased to inform you that your donation has been approved and is now visible to receivers on our platform.</p>
          
          <div style="background-color: #f3f4f6; padding: 20px; border-radius: 8px; margin: 20px 0;">
            <h3 style="margin-top: 0; color: #374151;">Donation Details:</h3>
            <p><strong>Title:</strong> ${donation.title}</p>
            <p><strong>Category:</strong> ${donation.category}</p>
            <p><strong>Condition:</strong> ${donation.condition}</p>
            <p><strong>Location:</strong> ${donation.location}</p>
          </div>
          
          <p>Your generosity will help someone in need. Receivers can now see and request your donation.</p>
          
          <p>Thank you for being part of the ${this.appName} community!</p>
          
          <p style="margin-top: 30px;">
            Best regards,<br>
            The ${this.appName} Team
          </p>
        </div>
      `
      : `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #ef4444;">Donation Review Update</h2>
          
          <p>Dear ${donor.name},</p>
          
          <p>Thank you for your donation submission. After review, we're unable to approve your donation at this time.</p>
          
          <div style="background-color: #fef2f2; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #ef4444;">
            <h3 style="margin-top: 0; color: #991b1b;">Donation Details:</h3>
            <p><strong>Title:</strong> ${donation.title}</p>
            <p><strong>Category:</strong> ${donation.category}</p>
            ${reason ? `<p><strong>Reason:</strong> ${reason}</p>` : ''}
          </div>
          
          <p>If you believe this is an error or would like to submit a revised donation, please feel free to create a new donation listing or contact our support team.</p>
          
          <p>We appreciate your understanding and your commitment to helping others.</p>
          
          <p style="margin-top: 30px;">
            Best regards,<br>
            The ${this.appName} Team
          </p>
        </div>
      `;

    return this.sendEmail(donor.email, subject, htmlContent);
  }
}

// Export singleton instance
module.exports = new EmailService();
