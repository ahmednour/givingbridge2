// Mock message storage (replace with database in production)
let messages = [];
let nextMessageId = 1;

class Message {
  constructor({
    senderId,
    senderName,
    receiverId,
    receiverName,
    donationId = null,
    requestId = null,
    content,
    isRead = false,
  }) {
    this.id = nextMessageId++;
    this.senderId = senderId;
    this.senderName = senderName;
    this.receiverId = receiverId;
    this.receiverName = receiverName;
    this.donationId = donationId;
    this.requestId = requestId;
    this.content = content;
    this.isRead = isRead;
    this.createdAt = new Date().toISOString();
    this.updatedAt = new Date().toISOString();
  }

  static create(messageData) {
    const message = new Message(messageData);
    messages.push(message);
    return message;
  }

  static findAll(filters = {}) {
    let filteredMessages = messages;

    if (filters.userId) {
      filteredMessages = filteredMessages.filter(
        (m) => m.senderId === filters.userId || m.receiverId === filters.userId
      );
    }

    if (filters.donationId) {
      filteredMessages = filteredMessages.filter(
        (m) => m.donationId === parseInt(filters.donationId)
      );
    }

    if (filters.requestId) {
      filteredMessages = filteredMessages.filter(
        (m) => m.requestId === parseInt(filters.requestId)
      );
    }

    if (filters.conversationWith) {
      filteredMessages = filteredMessages.filter(
        (m) =>
          (m.senderId === filters.userId &&
            m.receiverId === filters.conversationWith) ||
          (m.senderId === filters.conversationWith &&
            m.receiverId === filters.userId)
      );
    }

    return filteredMessages.sort(
      (a, b) => new Date(a.createdAt) - new Date(b.createdAt)
    );
  }

  static findById(id) {
    return messages.find((m) => m.id === parseInt(id));
  }

  static findConversations(userId) {
    const userMessages = messages.filter(
      (m) => m.senderId === userId || m.receiverId === userId
    );

    const conversationsMap = new Map();

    userMessages.forEach((message) => {
      const otherUserId =
        message.senderId === userId ? message.receiverId : message.senderId;
      const otherUserName =
        message.senderId === userId ? message.receiverName : message.senderName;

      if (!conversationsMap.has(otherUserId)) {
        conversationsMap.set(otherUserId, {
          userId: otherUserId,
          userName: otherUserName,
          lastMessage: message,
          unreadCount: 0,
          donationId: message.donationId,
          requestId: message.requestId,
        });
      } else {
        // Update with the latest message
        const existing = conversationsMap.get(otherUserId);
        if (
          new Date(message.createdAt) > new Date(existing.lastMessage.createdAt)
        ) {
          existing.lastMessage = message;
        }
      }

      // Count unread messages (messages sent to the current user that are unread)
      if (message.receiverId === userId && !message.isRead) {
        conversationsMap.get(otherUserId).unreadCount++;
      }
    });

    return Array.from(conversationsMap.values()).sort(
      (a, b) =>
        new Date(b.lastMessage.createdAt) - new Date(a.lastMessage.createdAt)
    );
  }

  static markAsRead(messageId) {
    const messageIndex = messages.findIndex(
      (m) => m.id === parseInt(messageId)
    );
    if (messageIndex === -1) return null;

    messages[messageIndex] = {
      ...messages[messageIndex],
      isRead: true,
      updatedAt: new Date().toISOString(),
    };

    return messages[messageIndex];
  }

  static markConversationAsRead(userId, otherUserId) {
    const conversationMessages = messages.filter(
      (m) => m.senderId === otherUserId && m.receiverId === userId && !m.isRead
    );

    conversationMessages.forEach((message) => {
      const messageIndex = messages.findIndex((m) => m.id === message.id);
      if (messageIndex !== -1) {
        messages[messageIndex] = {
          ...messages[messageIndex],
          isRead: true,
          updatedAt: new Date().toISOString(),
        };
      }
    });

    return conversationMessages.length;
  }

  static delete(id) {
    const messageIndex = messages.findIndex((m) => m.id === parseInt(id));
    if (messageIndex === -1) return false;

    messages.splice(messageIndex, 1);
    return true;
  }

  static getStats() {
    return {
      total: messages.length,
      unread: messages.filter((m) => !m.isRead).length,
    };
  }

  static getUnreadCount(userId) {
    return messages.filter((m) => m.receiverId === userId && !m.isRead).length;
  }
}

module.exports = Message;
