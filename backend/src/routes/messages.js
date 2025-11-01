const express = require("express");
const { body, validationResult } = require("express-validator");
const { Op } = require("sequelize");
const router = express.Router();
const Message = require("../models/Message");
const User = require("../models/User");
const MessageController = require("../controllers/messageController");
const {
  generalRateLimit,
} = require("../middleware/rateLimiting");

// Import authentication middleware from auth routes
const { authenticateToken } = require("./auth");

// Get all conversations for the authenticated user
router.get(
  "/conversations",
  authenticateToken,
  generalRateLimit,
  async (req, res) => {
    try {
      const userId = req.user.userId;

      // Get all messages where user is sender or receiver
      const messages = await Message.findAll({
        where: {
          [Op.or]: [{ senderId: userId }, { receiverId: userId }],
        },
        include: [
          {
            model: User,
            as: "sender",
            attributes: ["id", "name", "email", "avatarUrl"],
          },
          {
            model: User,
            as: "receiver",
            attributes: ["id", "name", "email", "avatarUrl"],
          },
        ],
        order: [["createdAt", "DESC"]],
      });

      // Group messages by conversation partner
      const conversationsMap = new Map();

      for (const message of messages) {
        const otherUserId =
          message.senderId === userId ? message.receiverId : message.senderId;
        const otherUser =
          message.senderId === userId ? message.receiver : message.sender;

        if (!conversationsMap.has(otherUserId)) {
          const unreadCount = await Message.count({
            where: {
              senderId: otherUserId,
              receiverId: userId,
              isRead: false,
            },
          });

          conversationsMap.set(otherUserId, {
            userId: otherUserId,
            userName: otherUser.name,
            userAvatar: otherUser.avatarUrl,
            lastMessage: message,
            unreadCount,
            donationId: message.donationId,
            requestId: message.requestId,
          });
        }
      }

      const conversations = Array.from(conversationsMap.values());

      res.json({
        message: "Conversations retrieved successfully",
        conversations,
        total: conversations.length,
      });
    } catch (error) {
      console.error("Get conversations error:", error);
      res.status(500).json({
        message: "Failed to retrieve conversations",
        error: error.message,
      });
    }
  }
);

// Get messages for a specific conversation
router.get(
  "/conversation/:userId",
  authenticateToken,
  generalRateLimit,
  async (req, res) => {
    try {
      const { userId: otherUserId } = req.params;
      const { page = 1, limit = 50 } = req.query;

      const offset = (page - 1) * parseInt(limit);

      const { count, rows: messages } = await Message.findAndCountAll({
        where: {
          [Op.or]: [
            {
              senderId: req.user.userId,
              receiverId: parseInt(otherUserId),
            },
            {
              senderId: parseInt(otherUserId),
              receiverId: req.user.userId,
            },
          ],
        },
        order: [["createdAt", "ASC"]],
        limit: parseInt(limit),
        offset: offset,
      });

      // Mark messages from other user as read
      await Message.update(
        { isRead: true },
        {
          where: {
            senderId: parseInt(otherUserId),
            receiverId: req.user.userId,
            isRead: false,
          },
        }
      );

      res.json({
        message: "Messages retrieved successfully",
        messages,
        total: count,
        page: parseInt(page),
        totalPages: Math.ceil(count / parseInt(limit)),
      });
    } catch (error) {
      console.error("Get conversation messages error:", error);
      res.status(500).json({
        message: "Failed to retrieve messages",
        error: error.message,
      });
    }
  }
);

// Send a new message
router.post(
  "/",
  [
    authenticateToken,
    generalRateLimit, // Apply general rate limiting
    body("receiverId")
      .isInt({ min: 1 })
      .withMessage("Valid receiver ID is required"),
    body("content")
      .trim()
      .isLength({ min: 1, max: 5000 })
      .withMessage("Message content must be between 1 and 5000 characters"),
    body("donationId")
      .optional()
      .isInt({ min: 1 })
      .withMessage("Valid donation ID required if provided"),
    body("requestId")
      .optional()
      .isInt({ min: 1 })
      .withMessage("Valid request ID required if provided"),
    body("messageType")
      .optional()
      .isIn(["text", "image", "file"])
      .withMessage("Message type must be text, image, or file"),
    body("attachmentUrl")
      .optional()
      .isURL()
      .withMessage("Valid attachment URL required if provided"),
    body("attachmentName")
      .optional()
      .trim()
      .isLength({ max: 255 })
      .withMessage("Attachment name must be at most 255 characters"),
    body("attachmentSize")
      .optional()
      .isInt({ min: 0 })
      .withMessage("Valid attachment size required if provided"),
  ],
  async (req, res) => {
    try {
      // Check for validation errors
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          message: "Validation failed",
          errors: errors.array(),
        });
      }

      const {
        receiverId,
        content,
        donationId,
        requestId,
        messageType,
        attachmentUrl,
        attachmentName,
        attachmentSize,
      } = req.body;

      const sender = await User.findByPk(req.user.userId);
      const receiver = await User.findByPk(parseInt(receiverId));

      if (!sender) {
        return res.status(404).json({
          message: "Sender not found",
        });
      }

      if (!receiver) {
        return res.status(404).json({
          message: "Receiver not found",
        });
      }

      // Prevent sending messages to yourself
      if (sender.id === receiver.id) {
        return res.status(400).json({
          message: "Cannot send message to yourself",
        });
      }

      const message = await Message.create({
        senderId: sender.id,
        senderName: sender.name,
        receiverId: receiver.id,
        receiverName: receiver.name,
        donationId: donationId ? parseInt(donationId) : null,
        requestId: requestId ? parseInt(requestId) : null,
        content: content.trim(),
        messageType: messageType || "text",
        attachmentUrl: attachmentUrl || null,
        attachmentName: attachmentName || null,
        attachmentSize: attachmentSize || null,
      });

      res.status(201).json({
        message: "Message sent successfully",
        data: message,
      });
    } catch (error) {
      console.error("Send message error:", error);
      res.status(500).json({
        message: "Failed to send message",
        error: error.message,
      });
    }
  }
);

// Mark a message as read
router.put("/:id/read", authenticateToken, generalRateLimit, async (req, res) => {
  try {
    const { id } = req.params;
    const message = await Message.findByPk(id);

    if (!message) {
      return res.status(404).json({
        message: "Message not found",
      });
    }

    // Check if the user is the receiver of the message
    if (message.receiverId !== req.user.userId) {
      return res.status(403).json({
        message: "You can only mark messages sent to you as read",
      });
    }

    await message.update({ isRead: true });

    res.json({
      message: "Message marked as read",
      data: message,
    });
  } catch (error) {
    console.error("Mark message as read error:", error);
    res.status(500).json({
      message: "Failed to mark message as read",
      error: error.message,
    });
  }
});

// Mark all messages in a conversation as read
router.put(
  "/conversation/:userId/read",
  authenticateToken,
  generalRateLimit, // Apply general rate limiting
  async (req, res) => {
    try {
      const otherUserId = parseInt(req.params.userId);

      const [updatedCount] = await Message.update(
        { isRead: true },
        {
          where: {
            senderId: otherUserId,
            receiverId: req.user.userId,
            isRead: false,
          },
        }
      );

      res.json({
        message: "Messages marked as read",
        updatedCount,
      });
    } catch (error) {
      console.error("Mark conversation as read error:", error);
      res.status(500).json({
        message: "Failed to mark messages as read",
        error: error.message,
      });
    }
  }
);

// Get unread message count for the authenticated user
router.get(
  "/unread-count",
  authenticateToken,
  generalRateLimit,
  async (req, res) => {
    try {
      const unreadCount = await Message.count({
        where: {
          receiverId: req.user.userId,
          isRead: false,
        },
      });

      res.json({
        message: "Unread count retrieved successfully",
        unreadCount,
      });
    } catch (error) {
      console.error("Get unread count error:", error);
      res.status(500).json({
        message: "Failed to retrieve unread count",
        error: error.message,
      });
    }
  }
);

// Delete a message (only sender can delete)
router.delete("/:id", authenticateToken, generalRateLimit, async (req, res) => {
  try {
    const { id } = req.params;
    const message = await Message.findByPk(id);

    if (!message) {
      return res.status(404).json({
        message: "Message not found",
      });
    }

    // Check if the user is the sender of the message or admin
    const user = await User.findByPk(req.user.userId);

    if (message.senderId !== req.user.userId && user.role !== "admin") {
      return res.status(403).json({
        message: "You can only delete your own messages",
      });
    }

    await message.destroy();

    res.json({
      message: "Message deleted successfully",
    });
  } catch (error) {
    console.error("Delete message error:", error);
    res.status(500).json({
      message: "Failed to delete message",
      error: error.message,
    });
  }
});

// Get message statistics (for admin dashboard)
router.get(
  "/admin/stats",
  authenticateToken,
  generalRateLimit,
  async (req, res) => {
    try {
      // Check if user is admin
      const user = await User.findByPk(req.user.userId);

      if (user.role !== "admin") {
        return res.status(403).json({
          message: "Admin access required",
        });
      }

      const total = await Message.count();
      const unread = await Message.count({ where: { isRead: false } });

      const stats = {
        total,
        unread,
      };

      res.json({
        message: "Message statistics retrieved successfully",
        stats,
      });
    } catch (error) {
      console.error("Get message stats error:", error);
      res.status(500).json({
        message: "Failed to retrieve message statistics",
        error: error.message,
      });
    }
  }
);

// Get archived conversations for the authenticated user
router.get(
  "/conversations/archived",
  authenticateToken,
  generalRateLimit,
  async (req, res) => {
    try {
      const userId = req.user.userId;

      // Get all archived messages where user is sender or receiver
      const messages = await Message.findAll({
        where: {
          [Op.or]: [
            {
              senderId: userId,
              archivedBySender: true,
            },
            {
              receiverId: userId,
              archivedByReceiver: true,
            },
          ],
        },
        include: [
          {
            model: User,
            as: "sender",
            attributes: ["id", "name", "email", "avatarUrl"],
          },
          {
            model: User,
            as: "receiver",
            attributes: ["id", "name", "email", "avatarUrl"],
          },
        ],
        order: [["createdAt", "DESC"]],
      });

      // Group messages by conversation partner
      const conversationsMap = new Map();

      for (const message of messages) {
        const otherUserId =
          message.senderId === userId ? message.receiverId : message.senderId;
        const otherUser =
          message.senderId === userId ? message.receiver : message.sender;

        if (!conversationsMap.has(otherUserId)) {
          const unreadCount = await Message.count({
            where: {
              senderId: otherUserId,
              receiverId: userId,
              isRead: false,
            },
          });

          conversationsMap.set(otherUserId, {
            userId: otherUserId,
            userName: otherUser.name,
            userAvatar: otherUser.avatarUrl,
            lastMessage: message,
            unreadCount,
            donationId: message.donationId,
            requestId: message.requestId,
          });
        }
      }

      const conversations = Array.from(conversationsMap.values());

      res.json({
        message: "Archived conversations retrieved successfully",
        conversations,
        total: conversations.length,
      });
    } catch (error) {
      console.error("Get archived conversations error:", error);
      res.status(500).json({
        message: "Failed to retrieve archived conversations",
        error: error.message,
      });
    }
  }
);

// Archive a conversation
router.put(
  "/conversation/:userId/archive",
  authenticateToken,
  generalRateLimit, // Apply general rate limiting
  async (req, res) => {
    try {
      const otherUserId = parseInt(req.params.userId);
      const affectedCount = await MessageController.archiveConversation(
        req.user.userId,
        otherUserId
      );

      res.json({
        message: "Conversation archived successfully",
        affectedCount,
      });
    } catch (error) {
      console.error("Archive conversation error:", error);
      res.status(500).json({
        message: "Failed to archive conversation",
        error: error.message,
      });
    }
  }
);

// Unarchive a conversation
router.put(
  "/conversation/:userId/unarchive",
  authenticateToken,
  generalRateLimit, // Apply general rate limiting
  async (req, res) => {
    try {
      const otherUserId = parseInt(req.params.userId);
      const affectedCount = await MessageController.unarchiveConversation(
        req.user.userId,
        otherUserId
      );

      res.json({
        message: "Conversation unarchived successfully",
        affectedCount,
      });
    } catch (error) {
      console.error("Unarchive conversation error:", error);
      res.status(500).json({
        message: "Failed to unarchive conversation",
        error: error.message,
      });
    }
  }
);

module.exports = router;
