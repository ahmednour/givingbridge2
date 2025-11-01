const jwt = require("jsonwebtoken");
const Message = require("./models/Message");
const User = require("./models/User");

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

        // Simplified notification - just log for MVP
        console.log(`📨 New message notification for user ${receiverId}`);
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

        // Simplified for MVP - no notification management needed

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

    // Notification handlers removed for MVP simplification

    // Handle errors
    socket.on("error", (error) => {
      console.error("Socket error:", error);
    });
  });

  console.log("🔌 Socket.IO handlers configured for MVP");
};
