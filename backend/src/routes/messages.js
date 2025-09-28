const express = require("express");
const { body, validationResult } = require("express-validator");
const router = express.Router();
const Message = require("../models/Message");

// Import authentication middleware from auth routes
const { authenticateToken } = require("./auth");

// Get all conversations for the authenticated user
router.get("/conversations", authenticateToken, async (req, res) => {
  try {
    const conversations = Message.findConversations(req.user.userId);

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
});

// Get messages for a specific conversation
router.get("/conversation/:userId", authenticateToken, async (req, res) => {
  try {
    const { userId } = req.params;
    const { page = 1, limit = 50 } = req.query;

    const messages = Message.findAll({
      userId: req.user.userId,
      conversationWith: parseInt(userId),
    });

    // Pagination
    const startIndex = (page - 1) * limit;
    const endIndex = startIndex + parseInt(limit);
    const paginatedMessages = messages.slice(startIndex, endIndex);

    // Mark messages as read
    Message.markConversationAsRead(req.user.userId, parseInt(userId));

    res.json({
      message: "Messages retrieved successfully",
      messages: paginatedMessages,
      total: messages.length,
      page: parseInt(page),
      totalPages: Math.ceil(messages.length / limit),
    });
  } catch (error) {
    console.error("Get conversation messages error:", error);
    res.status(500).json({
      message: "Failed to retrieve messages",
      error: error.message,
    });
  }
});

// Send a new message
router.post(
  "/",
  [
    authenticateToken,
    body("receiverId")
      .isInt({ min: 1 })
      .withMessage("Valid receiver ID is required"),
    body("content")
      .trim()
      .isLength({ min: 1, max: 1000 })
      .withMessage("Message content must be between 1 and 1000 characters"),
    body("donationId")
      .optional()
      .isInt({ min: 1 })
      .withMessage("Valid donation ID required if provided"),
    body("requestId")
      .optional()
      .isInt({ min: 1 })
      .withMessage("Valid request ID required if provided"),
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

      const { receiverId, content, donationId, requestId } = req.body;
      const { users } = require("./auth");
      const sender = users.find((u) => u.id === req.user.userId);
      const receiver = users.find((u) => u.id === parseInt(receiverId));

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

      const message = Message.create({
        senderId: sender.id,
        senderName: sender.name,
        receiverId: receiver.id,
        receiverName: receiver.name,
        donationId: donationId ? parseInt(donationId) : null,
        requestId: requestId ? parseInt(requestId) : null,
        content: content.trim(),
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
router.put("/:id/read", authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const message = Message.findById(id);

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

    const updatedMessage = Message.markAsRead(id);

    res.json({
      message: "Message marked as read",
      data: updatedMessage,
    });
  } catch (error) {
    console.error("Mark message as read error:", error);
    res.status(500).json({
      message: "Failed to mark message as read",
      error: error.message,
    });
  }
});

// Get unread message count for the authenticated user
router.get("/unread-count", authenticateToken, async (req, res) => {
  try {
    const unreadCount = Message.getUnreadCount(req.user.userId);

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
});

// Delete a message (only sender can delete)
router.delete("/:id", authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const message = Message.findById(id);

    if (!message) {
      return res.status(404).json({
        message: "Message not found",
      });
    }

    // Check if the user is the sender of the message or admin
    const { users } = require("./auth");
    const user = users.find((u) => u.id === req.user.userId);

    if (message.senderId !== req.user.userId && user.role !== "admin") {
      return res.status(403).json({
        message: "You can only delete your own messages",
      });
    }

    const deleted = Message.delete(id);

    if (deleted) {
      res.json({
        message: "Message deleted successfully",
      });
    } else {
      res.status(500).json({
        message: "Failed to delete message",
      });
    }
  } catch (error) {
    console.error("Delete message error:", error);
    res.status(500).json({
      message: "Failed to delete message",
      error: error.message,
    });
  }
});

// Get message statistics (for admin dashboard)
router.get("/admin/stats", authenticateToken, async (req, res) => {
  try {
    // Check if user is admin
    const { users } = require("./auth");
    const user = users.find((u) => u.id === req.user.userId);

    if (user.role !== "admin") {
      return res.status(403).json({
        message: "Admin access required",
      });
    }

    const stats = Message.getStats();

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
});

module.exports = router;
