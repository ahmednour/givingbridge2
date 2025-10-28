import 'package:flutter/foundation.dart';
import 'dart:io';
import '../repositories/message_repository.dart';
import '../core/constants/api_constants.dart';
import '../services/api_service.dart';
import '../models/chat_message.dart' as models;

/// Provider for managing message state and operations
class MessageProvider extends ChangeNotifier {
  final MessageRepository _repository = MessageRepository();

  // State
  List<dynamic> _conversations = [];
  List<dynamic> _messages = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  bool _isLoadingMessages = false;
  bool _isLoadingConversations = false;
  String? _error;
  String? _currentUserId; // Conversation partner ID
  String? _authenticatedUserId; // Current authenticated user ID
  int _currentPage = 1;
  bool _hasMoreMessages = true;
  Set<int> _blockedUserIds = {}; // Track blocked users

  // Getters
  List<dynamic> get conversations => _conversations;
  List<dynamic> get messages => _messages;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isLoadingConversations => _isLoadingConversations;
  String? get error => _error;
  String? get currentUserId => _currentUserId;
  String? get authenticatedUserId => _authenticatedUserId;
  int get currentPage => _currentPage;
  bool get hasMoreMessages => _hasMoreMessages;

  /// Set the authenticated user ID
  void setAuthenticatedUserId(String userId) {
    _authenticatedUserId = userId;
  }

  /// Load all conversations
  Future<void> loadConversations() async {
    _setLoadingConversations(true);
    _clearError();

    try {
      // Load blocked users first
      await _loadBlockedUsers();

      final response = await _repository.getConversations();

      if (response.success && response.data != null) {
        // Filter out conversations with blocked users
        _conversations = response.data!.where((conversation) {
          final userId = conversation['userId'] as int?;
          return userId != null && !_blockedUserIds.contains(userId);
        }).toList();
        notifyListeners();
      } else {
        _setError(response.error ?? 'Failed to load conversations');
      }
    } catch (e) {
      _setError('Error loading conversations: ${e.toString()}');
    } finally {
      _setLoadingConversations(false);
    }
  }

  /// Load messages for a conversation
  Future<void> loadMessages(String otherUserId, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreMessages = true;
      _messages.clear();
    }

    if (!_hasMoreMessages) return;

    _currentUserId = otherUserId; // Store the conversation partner ID
    _setLoadingMessages(true);
    _clearError();

    try {
      final response = await _repository.getMessages(
        userId: otherUserId,
        page: _currentPage,
        limit: APIConstants.defaultLimit,
      );

      if (response.success && response.data != null) {
        if (refresh) {
          _messages = response.data!;
        } else {
          _messages.addAll(response.data!);
        }

        _hasMoreMessages = response.data!.length == APIConstants.defaultLimit;
        _currentPage++;
        notifyListeners();
      } else {
        _setError(response.error ?? 'Failed to load messages');
      }
    } catch (e) {
      _setError('Error loading messages: ${e.toString()}');
    } finally {
      _setLoadingMessages(false);
    }
  }

  /// Load more messages (pagination)
  Future<void> loadMoreMessages() async {
    if (!_isLoadingMessages && _hasMoreMessages && _currentUserId != null) {
      await loadMessages(_currentUserId!);
    }
  }

  /// Send a message
  Future<bool> sendMessage({
    required String receiverId,
    required String content,
    String? donationId,
    String? requestId,
    String? messageType,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _repository.sendMessage(
        receiverId: receiverId,
        content: content,
        donationId: donationId,
        requestId: requestId,
        messageType: messageType,
        attachmentUrl: attachmentUrl,
        attachmentName: attachmentName,
        attachmentSize: attachmentSize,
      );

      if (response.success && response.data != null) {
        _messages.add(response.data!);
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to send message');
        return false;
      }
    } catch (e) {
      _setError('Error sending message: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Mark message as read
  Future<bool> markMessageAsRead(String messageId) async {
    try {
      final response = await _repository.markMessageAsRead(messageId);

      if (response.success) {
        // Update message in list
        final index =
            _messages.indexWhere((m) => m['id'].toString() == messageId);
        if (index != -1) {
          _messages[index]['isRead'] = true;
          notifyListeners();
        }
        return true;
      } else {
        _setError(response.error ?? 'Failed to mark message as read');
        return false;
      }
    } catch (e) {
      _setError('Error marking message as read: ${e.toString()}');
      return false;
    }
  }

  /// Mark conversation as read
  Future<bool> markConversationAsRead(String userId) async {
    try {
      final response = await _repository.markConversationAsRead(userId);

      if (response.success) {
        // Mark all messages in current conversation as read
        for (var message in _messages) {
          message['isRead'] = true;
        }
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to mark conversation as read');
        return false;
      }
    } catch (e) {
      _setError('Error marking conversation as read: ${e.toString()}');
      return false;
    }
  }

  /// Load unread message count
  Future<void> loadUnreadCount() async {
    try {
      final response = await _repository.getUnreadMessageCount();

      if (response.success && response.data != null) {
        _unreadCount = response.data!;
        notifyListeners();
      }
    } catch (e) {
      // Silently fail for unread count
      debugPrint('Error loading unread count: ${e.toString()}');
    }
  }

  /// Delete message
  Future<bool> deleteMessage(String messageId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _repository.deleteMessage(messageId);

      if (response.success) {
        _messages.removeWhere((m) => m['id'].toString() == messageId);
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to delete message');
        return false;
      }
    } catch (e) {
      _setError('Error deleting message: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Search messages
  Future<void> searchMessages(String query, {String? userId}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _repository.searchMessages(
        query: query,
        userId: userId,
        page: 1,
        limit: APIConstants.maxLimit,
      );

      if (response.success && response.data != null) {
        _messages = response.data!;
        notifyListeners();
      } else {
        _setError(response.error ?? 'Failed to search messages');
      }
    } catch (e) {
      _setError('Error searching messages: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadConversations(),
      loadUnreadCount(),
      if (_currentUserId != null) loadMessages(_currentUserId!, refresh: true),
    ]);
  }

  /// Get conversation by user ID
  dynamic getConversationByUserId(String userId) {
    try {
      return _conversations.firstWhere((c) => c['userId'].toString() == userId);
    } catch (e) {
      return null;
    }
  }

  /// Get messages by user ID
  List<dynamic> getMessagesByUserId(String userId) {
    // Filter messages between current authenticated user and the specified user
    return _messages.where((m) {
      final senderId =
          m is ChatMessage ? m.senderId.toString() : m['senderId'].toString();
      final receiverId = m is ChatMessage
          ? m.receiverId.toString()
          : m['receiverId'].toString();

      // Messages between current authenticated user and the specified user
      return (senderId == userId && receiverId == _authenticatedUserId) ||
          (senderId == _authenticatedUserId && receiverId == userId);
    }).toList();
  }

  /// Get unread messages count for a specific user
  int getUnreadCountForUser(String userId) {
    return _messages
        .where(
            (m) => m['receiverId'].toString() == userId && m['isRead'] == false)
        .length;
  }

  /// Clear current conversation
  void clearCurrentConversation() {
    _currentUserId = null;
    _messages.clear();
    _currentPage = 1;
    _hasMoreMessages = true;
    notifyListeners();
  }

  /// Add new message (for real-time updates)
  void addNewMessage(dynamic message) {
    // Get message ID
    final messageId = message is ChatMessage ? message.id : message['id'];

    // Check if this is replacing an optimistic message (negative ID indicates optimistic)
    if (messageId is int && messageId > 0) {
      // This is a confirmed message, check if we have an optimistic version
      final optimisticIndex = _messages.indexWhere((m) {
        final existingMessageId = m is ChatMessage ? m.id : m['id'];
        // Look for optimistic messages (negative IDs or temporary IDs)
        return existingMessageId is int && existingMessageId < 0;
      });

      if (optimisticIndex != -1) {
        // Replace optimistic message with confirmed one
        _messages[optimisticIndex] = message;
      } else {
        // Check for exact duplicate
        final exists = _messages.any((m) {
          final existingMessageId = m is ChatMessage ? m.id : m['id'];
          return existingMessageId == messageId;
        });

        if (!exists) {
          _messages.add(message);
        }
      }
    } else {
      // This is either an optimistic message or a message without a proper ID
      // Check for exact duplicate
      final exists = _messages.any((m) {
        final existingMessageId = m is ChatMessage ? m.id : m['id'];
        return existingMessageId == messageId;
      });

      if (!exists) {
        _messages.add(message);
      }
    }

    // Update or create conversation in list
    _updateConversationWithNewMessage(message);

    notifyListeners();
  }

  /// Update conversation list with new message
  void _updateConversationWithNewMessage(dynamic message) {
    final senderId =
        message is ChatMessage ? message.senderId : message['senderId'];
    final receiverId =
        message is ChatMessage ? message.receiverId : message['receiverId'];
    final senderName =
        message is ChatMessage ? message.senderName : message['senderName'];
    final receiverName =
        message is ChatMessage ? message.receiverName : message['receiverName'];
    final content =
        message is ChatMessage ? message.content : message['content'];
    final createdAt =
        message is ChatMessage ? message.createdAt : message['createdAt'];
    final isRead = message is ChatMessage ? message.isRead : message['isRead'];

    // Determine the other user (conversation partner)
    int otherUserId;
    String otherUserName;

    // Assuming current user info is available through auth
    // For now, we'll use a simple check
    if (_currentUserId != null) {
      final currentId = int.tryParse(_currentUserId!);
      if (currentId == senderId) {
        otherUserId =
            receiverId is int ? receiverId : int.parse(receiverId.toString());
        otherUserName = receiverName ?? 'Unknown';
      } else {
        otherUserId =
            senderId is int ? senderId : int.parse(senderId.toString());
        otherUserName = senderName ?? 'Unknown';
      }
    } else {
      // Fallback
      otherUserId = senderId is int ? senderId : int.parse(senderId.toString());
      otherUserName = senderName ?? 'Unknown';
    }

    // Find existing conversation
    final conversationIndex =
        _conversations.indexWhere((c) => c['userId'] == otherUserId);

    if (conversationIndex != -1) {
      // Update existing conversation
      final conversation = _conversations[conversationIndex];
      conversation['lastMessage'] = {
        'content': content,
        'createdAt': createdAt,
        'isRead': isRead,
      };

      // Increment unread count if message is for current user and unread
      if (_currentUserId != null &&
          receiverId.toString() == _currentUserId &&
          !isRead) {
        conversation['unreadCount'] = (conversation['unreadCount'] ?? 0) + 1;
      }

      // Move conversation to top
      _conversations.removeAt(conversationIndex);
      _conversations.insert(0, conversation);
    } else {
      // Create new conversation
      final newConversation = {
        'userId': otherUserId,
        'userName': otherUserName,
        'lastMessage': {
          'content': content,
          'createdAt': createdAt,
          'isRead': isRead,
        },
        'unreadCount': (_currentUserId != null &&
                receiverId.toString() == _currentUserId &&
                !isRead)
            ? 1
            : 0,
        'donationId':
            message is ChatMessage ? message.donationId : message['donationId'],
        'requestId':
            message is ChatMessage ? message.requestId : message['requestId'],
      };

      _conversations.insert(0, newConversation);
    }
  }

  /// Update message (for real-time updates)
  void updateMessage(dynamic message) {
    final index = _messages.indexWhere((m) => m['id'] == message['id']);
    if (index != -1) {
      _messages[index] = message;
      notifyListeners();
    }
  }

  /// Update unread count (for real-time updates)
  void updateUnreadCount(int count) {
    _unreadCount = count;
    notifyListeners();
  }

  /// Load blocked users
  Future<void> _loadBlockedUsers() async {
    try {
      final response = await ApiService.getBlockedUsers();
      if (response.success && response.data != null) {
        _blockedUserIds = response.data!.map((bu) => bu.blockedId).toSet();
      }
    } catch (e) {
      debugPrint('Error loading blocked users: ${e.toString()}');
    }
  }

  /// Check if user is blocked
  bool isUserBlocked(int userId) {
    return _blockedUserIds.contains(userId);
  }

  /// Refresh blocked users list
  Future<void> refreshBlockedUsers() async {
    await _loadBlockedUsers();
    await loadConversations(); // Reload conversations to apply filter
  }

  /// Archive a conversation
  Future<bool> archiveConversation(int userId) async {
    try {
      final response = await ApiService.archiveConversation(userId);

      if (response.success) {
        // Remove conversation from list
        _conversations.removeWhere((c) => c['userId'] == userId);
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to archive conversation');
        return false;
      }
    } catch (e) {
      _setError('Error archiving conversation: ${e.toString()}');
      return false;
    }
  }

  /// Unarchive a conversation
  Future<bool> unarchiveConversation(int userId) async {
    try {
      final response = await ApiService.unarchiveConversation(userId);

      if (response.success) {
        // Reload conversations to show unarchived one
        await loadConversations();
        return true;
      } else {
        _setError(response.error ?? 'Failed to unarchive conversation');
        return false;
      }
    } catch (e) {
      _setError('Error unarchiving conversation: ${e.toString()}');
      return false;
    }
  }

  /// Load archived conversations
  Future<List<dynamic>> loadArchivedConversations() async {
    try {
      final response = await ApiService.getArchivedConversations();

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        _setError(response.error ?? 'Failed to load archived conversations');
        return [];
      }
    } catch (e) {
      _setError('Error loading archived conversations: ${e.toString()}');
      return [];
    }
  }

  /// Start a new conversation with a user
  Future<bool> startConversation(int userId, String userName) async {
    // Check if conversation already exists
    final existingConversation = _conversations.firstWhere(
      (c) => c['userId'] == userId,
      orElse: () => null,
    );

    if (existingConversation != null) {
      // Conversation already exists, just navigate to it
      return true;
    }

    // Create a placeholder conversation (will be populated when first message is sent)
    final newConversation = {
      'userId': userId,
      'userName': userName,
      'lastMessage': null,
      'unreadCount': 0,
      'donationId': null,
      'requestId': null,
    };

    _conversations.insert(0, newConversation);
    notifyListeners();
    return true;
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingMessages(bool loading) {
    _isLoadingMessages = loading;
    notifyListeners();
  }

  void _setLoadingConversations(bool loading) {
    _isLoadingConversations = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Upload image
  Future<ApiResponse<Map<String, dynamic>>?> uploadImage(File imageFile) async {
    try {
      _setLoading(true);
      final response = await ApiService.uploadImage(imageFile);
      _setLoading(false);
      return response;
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _setLoading(false);
      return null;
    }
  }
}
