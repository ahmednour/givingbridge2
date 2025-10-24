const { Op } = require("sequelize");
const Message = require("../models/Message");
const User = require("../models/User");
const { NotFoundError, ValidationError } = require("../utils/errorHandler");

class MessageController {
  /**
   * Get all conversations for a user
   * @param {number} userId - User ID
   * @returns {Promise<Array>} List of conversations
   */
  static async getConversations(userId) {
    // Get all messages where user is sender or receiver
    const messages = await Message.findAll({
      where: {
        [Op.or]: [{ senderId: userId }, { receiverId: userId }],
      },
      order: [["createdAt", "DESC"]],
    });

    // Group messages by conversation partner
    const conversationsMap = new Map();

    for (const message of messages) {
      const otherUserId =
        message.senderId === userId ? message.receiverId : message.senderId;
      const otherUserName =
        message.senderId === userId ? message.receiverName : message.senderName;

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
          userName: otherUserName,
          lastMessage: message,
          unreadCount,
          donationId: message.donationId,
          requestId: message.requestId,
        });
      }
    }

    return Array.from(conversationsMap.values());
  }

  /**
   * Get messages for a specific conversation
   * @param {number} userId - Current user ID
   * @param {number} otherUserId - Other user ID
   * @param {Object} pagination - Pagination options
   * @returns {Promise<Object>} Paginated messages
   */
  static async getConversationMessages(userId, otherUserId, pagination = {}) {
    const { page = 1, limit = 50 } = pagination;
    const offset = (page - 1) * parseInt(limit);

    const { count, rows: messages } = await Message.findAndCountAll({
      where: {
        [Op.or]: [
          { senderId: userId, receiverId: otherUserId },
          { senderId: otherUserId, receiverId: userId },
        ],
      },
      order: [["createdAt", "ASC"]],
      limit: parseInt(limit),
      offset,
    });

    // Mark messages from other user as read
    await Message.update(
      { isRead: true },
      {
        where: {
          senderId: otherUserId,
          receiverId: userId,
          isRead: false,
        },
      }
    );

    return {
      messages,
      pagination: {
        total: count,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(count / parseInt(limit)),
        hasMore: offset + messages.length < count,
      },
    };
  }

  /**
   * Send a message
   * @param {Object} messageData - Message data
   * @param {number} senderId - Sender ID
   * @returns {Promise<Object>} Created message
   */
  static async sendMessage(messageData, senderId) {
    const { receiverId, content, donationId, requestId } = messageData;

    const sender = await User.findByPk(senderId);
    const receiver = await User.findByPk(parseInt(receiverId));

    if (!sender) {
      throw new NotFoundError("Sender not found");
    }

    if (!receiver) {
      throw new NotFoundError("Receiver not found");
    }

    // Prevent sending messages to yourself
    if (sender.id === receiver.id) {
      throw new ValidationError("Cannot send message to yourself");
    }

    return await Message.create({
      senderId: sender.id,
      senderName: sender.name,
      receiverId: receiver.id,
      receiverName: receiver.name,
      donationId: donationId ? parseInt(donationId) : null,
      requestId: requestId ? parseInt(requestId) : null,
      content: content.trim(),
    });
  }

  /**
   * Mark message as read
   * @param {number} messageId - Message ID
   * @param {number} userId - Current user ID
   * @returns {Promise<Object>} Updated message
   */
  static async markAsRead(messageId, userId) {
    const message = await Message.findByPk(messageId);

    if (!message) {
      throw new NotFoundError("Message not found");
    }

    // Check if the user is the receiver of the message
    if (message.receiverId !== userId) {
      throw new ValidationError(
        "You can only mark messages sent to you as read"
      );
    }

    await message.update({ isRead: true });
    return message;
  }

  /**
   * Mark all messages from a user as read
   * @param {number} userId - Current user ID
   * @param {number} fromUserId - Sender user ID
   * @returns {Promise<number>} Number of messages marked as read
   */
  static async markAllAsRead(userId, fromUserId) {
    const [affectedCount] = await Message.update(
      { isRead: true },
      {
        where: {
          senderId: fromUserId,
          receiverId: userId,
          isRead: false,
        },
      }
    );

    return affectedCount;
  }

  /**
   * Get unread message count
   * @param {number} userId - User ID
   * @returns {Promise<number>} Unread message count
   */
  static async getUnreadCount(userId) {
    return await Message.count({
      where: {
        receiverId: userId,
        isRead: false,
      },
    });
  }

  /**
   * Delete message
   * @param {number} messageId - Message ID
   * @param {Object} user - Current user
   * @returns {Promise<void>}
   */
  static async deleteMessage(messageId, user) {
    const message = await Message.findByPk(messageId);

    if (!message) {
      throw new NotFoundError("Message not found");
    }

    // Check if the user is the sender of the message or admin
    if (message.senderId !== user.id && user.role !== "admin") {
      throw new ValidationError("You can only delete your own messages");
    }

    await message.destroy();
  }

  /**
   * Get message statistics (admin only)
   * @returns {Promise<Object>} Message statistics
   */
  static async getMessageStats() {
    const total = await Message.count();
    const unread = await Message.count({ where: { isRead: false } });

    return {
      total,
      unread,
      read: total - unread,
    };
  }

  /**
   * Search messages by content
   * @param {number} userId - User ID
   * @param {string} query - Search query
   * @param {Object} pagination - Pagination options
   * @returns {Promise<Object>} Search results
   */
  static async searchMessages(userId, query, pagination = {}) {
    const { page = 1, limit = 20 } = pagination;
    const offset = (page - 1) * parseInt(limit);

    const { count, rows: messages } = await Message.findAndCountAll({
      where: {
        [Op.and]: [
          {
            [Op.or]: [{ senderId: userId }, { receiverId: userId }],
          },
          {
            content: { [Op.like]: `%${query}%` },
          },
        ],
      },
      order: [["createdAt", "DESC"]],
      limit: parseInt(limit),
      offset,
    });

    return {
      messages,
      pagination: {
        total: count,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(count / parseInt(limit)),
        hasMore: offset + messages.length < count,
      },
    };
  }

  /**
   * Archive a conversation
   * @param {number} userId - Current user ID
   * @param {number} otherUserId - Other user ID
   * @returns {Promise<number>} Number of messages archived
   */
  static async archiveConversation(userId, otherUserId) {
    // Update messages where user is sender
    const [senderCount] = await Message.update(
      { archivedBySender: true },
      {
        where: {
          senderId: userId,
          receiverId: otherUserId,
        },
      }
    );

    // Update messages where user is receiver
    const [receiverCount] = await Message.update(
      { archivedByReceiver: true },
      {
        where: {
          senderId: otherUserId,
          receiverId: userId,
        },
      }
    );

    return senderCount + receiverCount;
  }

  /**
   * Unarchive a conversation
   * @param {number} userId - Current user ID
   * @param {number} otherUserId - Other user ID
   * @returns {Promise<number>} Number of messages unarchived
   */
  static async unarchiveConversation(userId, otherUserId) {
    // Update messages where user is sender
    const [senderCount] = await Message.update(
      { archivedBySender: false },
      {
        where: {
          senderId: userId,
          receiverId: otherUserId,
        },
      }
    );

    // Update messages where user is receiver
    const [receiverCount] = await Message.update(
      { archivedByReceiver: false },
      {
        where: {
          senderId: otherUserId,
          receiverId: userId,
        },
      }
    );

    return senderCount + receiverCount;
  }
}
