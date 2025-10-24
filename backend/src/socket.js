const jwt = require("jsonwebtoken");
const Message = require("./models/Message");
const User = require("./models/User");
const Notification = require("./models/Notification");
const NotificationController = require("./controllers/notificationController");
const pushNotificationService = require("./services/pushNotificationService");

const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) {
  throw new Error("JWT_SECRET environment variable is required");
}

// Store connected users
const connectedUsers = new Map(); // userId -> socketId

module.exports = (io) => {
  // Middleware to authenticate socket connections
  io.use((socket, next) => {
    const token = socket.handshake.auth.token;

    if (!token) {
      return next(new Error("Authentication error: No token provided"));
    }

    try {
      const decoded = jwt.verify(token, JWT_SECRET);
      socket.userId = decoded.userId;
      socket.userEmail = decoded.email;
      socket.userRole = decoded.role;
      next();
    } catch (error) {
      next(new Error("Authentication error: Invalid token"));
    }
  });

  io.on("connection", (socket) => {
    console.log(`✅ User connected: ${socket.userId} (${socket.userEmail})`);

    // Store user connection
    connectedUsers.set(socket.userId, socket.id);

    // Notify all users about online status
    io.emit("user_online", { userId: socket.userId });

    // Join user's personal room
    socket.join(`user_${socket.userId}`);

    // Handle sending messages
    socket.on("send_message", async (data) => {
      try {
        const { receiverId, content, donationId, requestId } = data;

        // Validate input
        if (!receiverId || !content) {
          socket.emit("error", { message: "Missing required fields" });
          return;
        }

        // Get sender and receiver info
        const sender = await User.findByPk(socket.userId);
        const receiver = await User.findByPk(parseInt(receiverId));

        if (!sender || !receiver) {
          socket.emit("error", { message: "User not found" });
          return;
        }

        // Create message in database
        const message = await Message.create({
          senderId: sender.id,
          senderName: sender.name,
          receiverId: receiver.id,
          receiverName: receiver.name,
          donationId: donationId ? parseInt(donationId) : null,
          requestId: requestId ? parseInt(requestId) : null,
          content: content.trim(),
          isRead: false,
        });

        // Prepare message object
        const messageData = {
          id: message.id,
          senderId: message.senderId,
          senderName: message.senderName,
          receiverId: message.receiverId,
          receiverName: message.receiverName,
          donationId: message.donationId,
          requestId: message.requestId,
          content: message.content,
          isRead: message.isRead,
          createdAt: message.createdAt,
          updatedAt: message.updatedAt,
        };

        // Send to sender (confirmation)
        socket.emit("message_sent", { success: true, message: messageData });

        // Send to receiver (if online)
        io.to(`user_${receiverId}`).emit("new_message", messageData);

        // Update unread count for receiver
        const unreadCount = await Message.count({
          where: {
            receiverId: parseInt(receiverId),
            isRead: false,
          },
        });

        io.to(`user_${receiverId}`).emit("unread_count", {
          count: unreadCount,
        });

        // Create notification for receiver
        try {
          const notification = await NotificationController.notifyNewMessage(
            parseInt(receiverId),
            sender.name,
            message.id
          );

          // Send notification via socket if user is online
          io.to(`user_${receiverId}`).emit("new_notification", {
            id: notification.id,
            type: notification.type,
            title: notification.title,
            message: notification.message,
            isRead: notification.isRead,
            relatedId: notification.relatedId,
            relatedType: notification.relatedType,
            createdAt: notification.createdAt,
          });

          // Update unread notification count
          const unreadNotifCount = await Notification.count({
            where: {
              userId: parseInt(receiverId),
              isRead: false,
            },
          });

          io.to(`user_${receiverId}`).emit("unread_notification_count", {
            count: unreadNotifCount,
          });

          // Send push notification if user is offline or on different device
          const isReceiverOnline = connectedUsers.has(parseInt(receiverId));
          if (pushNotificationService.isInitialized()) {
            await pushNotificationService.notifyNewMessage(
              receiver,
              sender.name,
              content.substring(0, 100)
            );
            console.log(`📩 Push notification sent to ${receiver.name}`);
          }
        } catch (notifError) {
          console.error("Error creating message notification:", notifError);
          // Don't fail the message send if notification fails
        }
        console.log(`📨 Message sent from ${sender.name} to ${receiver.name}`);
      } catch (error) {
        console.error("Error sending message:", error);
        socket.emit("error", {
          message: "Failed to send message",
          error: error.message,
        });
      }
    });

    // Handle typing indicator
    socket.on("typing", (data) => {
      const { receiverId } = data;
      io.to(`user_${receiverId}`).emit("user_typing", {
        userId: socket.userId,
        typing: true,
      });
    });

    socket.on("stop_typing", (data) => {
      const { receiverId } = data;
      io.to(`user_${receiverId}`).emit("user_typing", {
        userId: socket.userId,
        typing: false,
      });
    });

    // Handle marking messages as read
    socket.on("mark_as_read", async (data) => {
      try {
        const { messageId } = data;

        const message = await Message.findByPk(messageId);

        if (!message) {
          socket.emit("error", { message: "Message not found" });
          return;
        }

        // Only receiver can mark as read
        if (message.receiverId !== socket.userId) {
          socket.emit("error", { message: "Unauthorized" });
          return;
        }

        await message.update({ isRead: true });

        // Notify sender that message was read
        io.to(`user_${message.senderId}`).emit("message_read", {
          messageId: message.id,
          readBy: socket.userId,
        });

        // Update unread count
        const unreadCount = await Message.count({
          where: {
            receiverId: socket.userId,
            isRead: false,
          },
        });

        socket.emit("unread_count", { count: unreadCount });

        console.log(`✅ Message ${messageId} marked as read`);
      } catch (error) {
        console.error("Error marking message as read:", error);
        socket.emit("error", { message: "Failed to mark message as read" });
      }
    });

    // Handle marking conversation as read
    socket.on("mark_conversation_read", async (data) => {
      try {
        const { otherUserId } = data;

        const [affectedCount] = await Message.update(
          { isRead: true },
          {
            where: {
              senderId: parseInt(otherUserId),
              receiverId: socket.userId,
              isRead: false,
            },
          }
        );

        // Update unread count
        const unreadCount = await Message.count({
          where: {
            receiverId: socket.userId,
            isRead: false,
          },
        });

        socket.emit("unread_count", { count: unreadCount });

        // Notify sender that messages were read
        io.to(`user_${otherUserId}`).emit("conversation_read", {
          userId: socket.userId,
          messagesRead: affectedCount,
        });

        // Mark related notifications as read
        if (affectedCount > 0) {
          await Notification.update(
            { isRead: true },
            {
              where: {
                userId: socket.userId,
                type: "message",
                relatedType: "message",
                isRead: false,
              },
            }
          );

          // Update notification count
          const unreadNotifCount = await Notification.count({
            where: {
              userId: socket.userId,
              isRead: false,
            },
          });

          socket.emit("unread_notification_count", {
            count: unreadNotifCount,
          });
        }

        console.log(
          `✅ Conversation with user ${otherUserId} marked as read (${affectedCount} messages)`
        );
      } catch (error) {
        console.error("Error marking conversation as read:", error);
        socket.emit("error", {
          message: "Failed to mark conversation as read",
        });
      }
    });

    // Handle getting unread count
    socket.on("get_unread_count", async () => {
      try {
        const unreadCount = await Message.count({
          where: {
            receiverId: socket.userId,
            isRead: false,
          },
        });

        socket.emit("unread_count", { count: unreadCount });
      } catch (error) {
        console.error("Error getting unread count:", error);
        socket.emit("error", { message: "Failed to get unread count" });
      }
    });

    // Handle joining a conversation room
    socket.on("join_conversation", (data) => {
      const { otherUserId } = data;
      const roomName = `conversation_${Math.min(
        socket.userId,
        otherUserId
      )}_${Math.max(socket.userId, otherUserId)}`;
      socket.join(roomName);
      console.log(
        `👥 User ${socket.userId} joined conversation with ${otherUserId}`
      );
    });

    // Handle leaving a conversation room
    socket.on("leave_conversation", (data) => {
      const { otherUserId } = data;
      const roomName = `conversation_${Math.min(
        socket.userId,
        otherUserId
      )}_${Math.max(socket.userId, otherUserId)}`;
      socket.leave(roomName);
      console.log(
        `👋 User ${socket.userId} left conversation with ${otherUserId}`
      );
    });

    // Handle disconnect
    socket.on("disconnect", () => {
      console.log(
        `❌ User disconnected: ${socket.userId} (${socket.userEmail})`
      );

      // Remove from connected users
      connectedUsers.delete(socket.userId);

      // Notify all users about offline status
      io.emit("user_offline", { userId: socket.userId });
    });

    // Handle marking notification as read
    socket.on("mark_notification_read", async (data) => {
      try {
        const { notificationId } = data;

        const notification = await Notification.findByPk(notificationId);

        if (!notification) {
          socket.emit("error", { message: "Notification not found" });
          return;
        }

        // Only owner can mark as read
        if (notification.userId !== socket.userId) {
          socket.emit("error", { message: "Unauthorized" });
          return;
        }

        await notification.update({ isRead: true });

        // Update unread notification count
        const unreadNotifCount = await Notification.count({
          where: {
            userId: socket.userId,
            isRead: false,
          },
        });

        socket.emit("unread_notification_count", { count: unreadNotifCount });

        console.log(`✅ Notification ${notificationId} marked as read`);
      } catch (error) {
        console.error("Error marking notification as read:", error);
        socket.emit("error", {
          message: "Failed to mark notification as read",
        });
      }
    });

    // Handle marking all notifications as read
    socket.on("mark_all_notifications_read", async () => {
      try {
        await Notification.update(
          { isRead: true },
          {
            where: {
              userId: socket.userId,
              isRead: false,
            },
          }
        );

        socket.emit("unread_notification_count", { count: 0 });

        console.log(
          `✅ All notifications marked as read for user ${socket.userId}`
        );
      } catch (error) {
        console.error("Error marking all notifications as read:", error);
        socket.emit("error", {
          message: "Failed to mark all notifications as read",
        });
      }
    });

    // Handle getting unread notification count
    socket.on("get_unread_notification_count", async () => {
      try {
        const unreadNotifCount = await Notification.count({
          where: {
            userId: socket.userId,
            isRead: false,
          },
        });

        socket.emit("unread_notification_count", { count: unreadNotifCount });
      } catch (error) {
        console.error("Error getting unread notification count:", error);
        socket.emit("error", {
          message: "Failed to get unread notification count",
        });
      }
    });

    // Handle errors
    socket.on("error", (error) => {
      console.error("Socket error:", error);
    });
  });

  // Expose helper function to send notifications
  io.sendNotification = async (userId, notificationData) => {
    try {
      // Create notification in database
      const notification = await Notification.create({
        userId,
        ...notificationData,
      });

      // Send to user if online
      io.to(`user_${userId}`).emit("new_notification", {
        id: notification.id,
        type: notification.type,
        title: notification.title,
        message: notification.message,
        isRead: notification.isRead,
        relatedId: notification.relatedId,
        relatedType: notification.relatedType,
        metadata: notification.metadata,
        createdAt: notification.createdAt,
      });

      // Update unread count
      const unreadCount = await Notification.count({
        where: {
          userId,
          isRead: false,
        },
      });

      io.to(`user_${userId}`).emit("unread_notification_count", {
        count: unreadCount,
      });

      // Send push notification
      if (pushNotificationService.isInitialized()) {
        try {
          const user = await User.findByPk(userId);
          if (user && user.fcmToken) {
            await pushNotificationService.sendToDevice(
              user.fcmToken,
              {
                title: notification.title,
                body: notification.message,
              },
              {
                type: notification.type,
                relatedId: notification.relatedId?.toString() || "",
                relatedType: notification.relatedType || "",
                badge: unreadCount,
              }
            );
            console.log(`📩 Push notification sent to user ${userId}`);
          }
        } catch (pushError) {
          console.error("Error sending push notification:", pushError);
          // Don't fail the notification if push fails
        }
      }

      console.log(
        `🔔 Notification sent to user ${userId}: ${notification.title}`
      );
      return notification;
    } catch (error) {
      console.error("Error sending notification:", error);
      throw error;
    }
  };

  // Expose helper function to broadcast system notifications
  io.broadcastSystemNotification = async (notificationData) => {
    try {
      const users = await User.findAll({ attributes: ["id"] });

      for (const user of users) {
        await io.sendNotification(user.id, notificationData);
      }

      console.log(
        `📢 System notification broadcasted to ${users.length} users`
      );
    } catch (error) {
      console.error("Error broadcasting system notification:", error);
      throw error;
    }
  };

  console.log("🔌 Socket.IO handlers configured with notification support");
};
