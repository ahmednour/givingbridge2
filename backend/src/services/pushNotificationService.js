const admin = require("firebase-admin");
const path = require("path");

/**
 * Firebase Cloud Messaging Service
 *
 * Handles push notifications to mobile/web clients
 */
class PushNotificationService {
  constructor() {
    this.initialized = false;
    this.messaging = null;
  }

  /**
   * Initialize Firebase Admin SDK
   */
  initialize() {
    if (this.initialized) {
      console.log("✅ Firebase Admin already initialized");
      return;
    }

    try {
      // Check if service account file exists
      const serviceAccountPath = path.join(
        __dirname,
        "../../config/firebase-service-account.json"
      );

      // Try to load service account
      let serviceAccount;
      try {
        serviceAccount = require(serviceAccountPath);
      } catch (error) {
        console.warn(
          "⚠️  Firebase service account file not found. Push notifications will be disabled."
        );
        console.warn(
          "   Please add firebase-service-account.json to backend/config/"
        );
        return;
      }

      // Initialize Firebase Admin
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        projectId: serviceAccount.project_id,
      });

      this.messaging = admin.messaging();
      this.initialized = true;

      console.log("✅ Firebase Admin initialized successfully");
      console.log(
        `📱 Push notifications enabled for project: ${serviceAccount.project_id}`
      );
    } catch (error) {
      console.error("❌ Firebase Admin initialization failed:", error.message);
      console.warn("⚠️  Push notifications will be disabled");
    }
  }

  /**
   * Check if service is initialized
   */
  isInitialized() {
    return this.initialized;
  }

  /**
   * Send notification to a specific device token
   * @param {string} token - FCM device token
   * @param {object} notification - Notification payload
   * @param {object} data - Additional data
   */
  async sendToDevice(token, notification, data = {}) {
    if (!this.initialized) {
      console.warn("⚠️  Firebase not initialized, skipping notification");
      return { success: false, error: "Firebase not initialized" };
    }

    try {
      const message = {
        token,
        notification: {
          title: notification.title,
          body: notification.body,
          imageUrl: notification.imageUrl,
        },
        data: {
          ...data,
          clickAction: data.clickAction || "FLUTTER_NOTIFICATION_CLICK",
        },
        webpush: {
          notification: {
            icon: "/icons/Icon-192.png",
            badge: "/icons/Icon-192.png",
            requireInteraction: false,
          },
          fcmOptions: {
            link: data.link || "/",
          },
        },
        android: {
          notification: {
            sound: "default",
            clickAction: data.clickAction || "FLUTTER_NOTIFICATION_CLICK",
            channelId: "high_importance_channel",
          },
          priority: "high",
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: data.badge || 1,
            },
          },
        },
      };

      const response = await this.messaging.send(message);
      console.log("✅ Notification sent successfully:", response);
      return { success: true, messageId: response };
    } catch (error) {
      console.error("❌ Failed to send notification:", error);

      // Handle invalid token
      if (
        error.code === "messaging/invalid-registration-token" ||
        error.code === "messaging/registration-token-not-registered"
      ) {
        console.warn(
          "⚠️  Invalid or expired token, should be removed from database"
        );
        return {
          success: false,
          error: "Invalid token",
          shouldRemoveToken: true,
        };
      }

      return { success: false, error: error.message };
    }
  }

  /**
   * Send notification to multiple devices
   * @param {string[]} tokens - Array of FCM tokens
   * @param {object} notification - Notification payload
   * @param {object} data - Additional data
   */
  async sendToMultipleDevices(tokens, notification, data = {}) {
    if (!this.initialized) {
      console.warn("⚠️  Firebase not initialized, skipping notifications");
      return { success: false, error: "Firebase not initialized" };
    }

    if (!tokens || tokens.length === 0) {
      return { success: false, error: "No tokens provided" };
    }

    try {
      const message = {
        notification: {
          title: notification.title,
          body: notification.body,
          imageUrl: notification.imageUrl,
        },
        data: {
          ...data,
          clickAction: data.clickAction || "FLUTTER_NOTIFICATION_CLICK",
        },
        tokens, // Send to multiple tokens
        webpush: {
          notification: {
            icon: "/icons/Icon-192.png",
            badge: "/icons/Icon-192.png",
          },
          fcmOptions: {
            link: data.link || "/",
          },
        },
        android: {
          notification: {
            sound: "default",
            channelId: "high_importance_channel",
          },
          priority: "high",
        },
      };

      const response = await this.messaging.sendEachForMulticast(message);

      console.log(
        `✅ Sent ${response.successCount}/${tokens.length} notifications`
      );

      if (response.failureCount > 0) {
        console.warn(`⚠️  ${response.failureCount} notifications failed`);
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            console.error(`   Token ${idx}: ${resp.error?.message}`);
          }
        });
      }

      return {
        success: true,
        successCount: response.successCount,
        failureCount: response.failureCount,
        responses: response.responses,
      };
    } catch (error) {
      console.error("❌ Failed to send multicast notification:", error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Send notification to a topic
   * @param {string} topic - Topic name (e.g., 'all_users', 'donor', 'receiver')
   * @param {object} notification - Notification payload
   * @param {object} data - Additional data
   */
  async sendToTopic(topic, notification, data = {}) {
    if (!this.initialized) {
      console.warn("⚠️  Firebase not initialized, skipping notification");
      return { success: false, error: "Firebase not initialized" };
    }

    try {
      const message = {
        topic,
        notification: {
          title: notification.title,
          body: notification.body,
          imageUrl: notification.imageUrl,
        },
        data: {
          ...data,
          clickAction: data.clickAction || "FLUTTER_NOTIFICATION_CLICK",
        },
        webpush: {
          notification: {
            icon: "/icons/Icon-192.png",
            badge: "/icons/Icon-192.png",
          },
          fcmOptions: {
            link: data.link || "/",
          },
        },
        android: {
          notification: {
            sound: "default",
            channelId: "high_importance_channel",
          },
          priority: "high",
        },
      };

      const response = await this.messaging.send(message);
      console.log(`✅ Topic notification sent to "${topic}":`, response);
      return { success: true, messageId: response };
    } catch (error) {
      console.error(
        `❌ Failed to send topic notification to "${topic}":`,
        error
      );
      return { success: false, error: error.message };
    }
  }

  /**
   * Subscribe tokens to a topic
   * @param {string[]} tokens - Array of FCM tokens
   * @param {string} topic - Topic name
   */
  async subscribeToTopic(tokens, topic) {
    if (!this.initialized) {
      console.warn("⚠️  Firebase not initialized, skipping subscription");
      return { success: false, error: "Firebase not initialized" };
    }

    try {
      const response = await this.messaging.subscribeToTopic(tokens, topic);
      console.log(
        `✅ Subscribed ${response.successCount} tokens to topic "${topic}"`
      );
      return { success: true, successCount: response.successCount };
    } catch (error) {
      console.error(`❌ Failed to subscribe to topic "${topic}":`, error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Unsubscribe tokens from a topic
   * @param {string[]} tokens - Array of FCM tokens
   * @param {string} topic - Topic name
   */
  async unsubscribeFromTopic(tokens, topic) {
    if (!this.initialized) {
      console.warn("⚠️  Firebase not initialized, skipping unsubscription");
      return { success: false, error: "Firebase not initialized" };
    }

    try {
      const response = await this.messaging.unsubscribeFromTopic(tokens, topic);
      console.log(
        `✅ Unsubscribed ${response.successCount} tokens from topic "${topic}"`
      );
      return { success: true, successCount: response.successCount };
    } catch (error) {
      console.error(`❌ Failed to unsubscribe from topic "${topic}":`, error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Send notification when new message is received
   * @param {object} receiver - Receiver user object
   * @param {string} senderName - Name of sender
   * @param {string} messagePreview - Message content preview
   */
  async notifyNewMessage(receiver, senderName, messagePreview) {
    if (!receiver.fcmToken) {
      console.log("ℹ️  User has no FCM token, skipping push notification");
      return { success: false, error: "No FCM token" };
    }

    return this.sendToDevice(
      receiver.fcmToken,
      {
        title: `New message from ${senderName}`,
        body: messagePreview.substring(0, 100),
      },
      {
        type: "message",
        senderId: receiver.id.toString(),
        senderName: senderName,
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
        link: "/messages",
      }
    );
  }

  /**
   * Send notification when donation request status changes
   * @param {object} receiver - Request creator user object
   * @param {string} donationTitle - Donation title
   * @param {string} status - New status (approved/rejected)
   */
  async notifyRequestStatusChange(receiver, donationTitle, status) {
    if (!receiver.fcmToken) {
      console.log("ℹ️  User has no FCM token, skipping push notification");
      return { success: false, error: "No FCM token" };
    }

    const title =
      status === "approved" ? "✅ Request Approved!" : "❌ Request Rejected";

    const body =
      status === "approved"
        ? `Your request for "${donationTitle}" was approved!`
        : `Your request for "${donationTitle}" was rejected.`;

    return this.sendToDevice(
      receiver.fcmToken,
      { title, body },
      {
        type: "request_status",
        status,
        donationTitle,
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
        link: "/requests",
      }
    );
  }

  /**
   * Send notification when new donation request is received
   * @param {object} donor - Donor user object
   * @param {string} receiverName - Name of receiver
   * @param {string} donationTitle - Donation title
   */
  async notifyNewRequest(donor, receiverName, donationTitle) {
    if (!donor.fcmToken) {
      console.log("ℹ️  User has no FCM token, skipping push notification");
      return { success: false, error: "No FCM token" };
    }

    return this.sendToDevice(
      donor.fcmToken,
      {
        title: "📬 New Donation Request",
        body: `${receiverName} requested "${donationTitle}"`,
      },
      {
        type: "new_request",
        receiverName,
        donationTitle,
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
        link: "/incoming-requests",
      }
    );
  }

  /**
   * Send notification when new donation is posted
   * @param {string} topic - Topic to send to (e.g., 'all_users')
   * @param {string} donorName - Name of donor
   * @param {string} donationTitle - Donation title
   * @param {string} category - Donation category
   */
  async notifyNewDonation(topic, donorName, donationTitle, category) {
    return this.sendToTopic(
      topic,
      {
        title: "🎁 New Donation Available",
        body: `${donorName} donated "${donationTitle}" (${category})`,
      },
      {
        type: "new_donation",
        donorName,
        donationTitle,
        category,
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
        link: "/browse-donations",
      }
    );
  }
}

// Export singleton instance
module.exports = new PushNotificationService();
