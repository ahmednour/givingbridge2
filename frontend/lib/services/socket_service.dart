import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/chat_message.dart' as models;
import '../core/constants/api_constants.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  String? _currentUserId;

  // Callbacks
  Function(models.ChatMessage)? onNewMessage;
  Function(models.ChatMessage)? onMessageSent;
  Function(int)? onUnreadCount;
  Function(String, bool)? onUserTyping;
  Function(int)? onMessageRead;
  Function(String)? onUserOnline;
  Function(String)? onUserOffline;
  Function(String)? onError;

  bool get isConnected => _isConnected;
  String? get currentUserId => _currentUserId;

  /// Initialize and connect to Socket.io server
  Future<void> connect() async {
    if (_isConnected && _socket != null) {
      debugPrint('Socket already connected');
      return;
    }

    try {
      final token = await ApiService.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('No auth token available for socket connection');
        return;
      }

      debugPrint('Connecting to Socket.IO server...');

      _socket = IO.io(
        APIConstants.socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': token})
            .build(),
      );

      _setupEventListeners();
      _socket!.connect();
    } catch (e) {
      debugPrint('Error connecting to socket: $e');
      if (onError != null) onError!('Connection error: $e');
    }
  }

  /// Setup event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    // Connection events
    _socket!.on('connect', (_) {
      _isConnected = true;
      debugPrint('✅ Socket connected');
      _requestUnreadCount();
    });

    _socket!.on('disconnect', (_) {
      _isConnected = false;
      debugPrint('❌ Socket disconnected');
    });

    _socket!.on('connect_error', (error) {
      _isConnected = false;
      debugPrint('Connection error: $error');
      if (onError != null) onError!('Connection error: $error');
    });

    // Message events
    _socket!.on('new_message', (data) {
      debugPrint('📨 New message received');
      try {
        final message = models.ChatMessage.fromJson(data);
        if (onNewMessage != null) onNewMessage!(message);
      } catch (e) {
        debugPrint('Error parsing new message: $e');
      }
    });

    _socket!.on('message_sent', (data) {
      debugPrint('✅ Message sent confirmation');
      try {
        if (data['success'] == true && data['message'] != null) {
          final message = models.ChatMessage.fromJson(data['message']);
          if (onMessageSent != null) onMessageSent!(message);
        }
      } catch (e) {
        debugPrint('Error parsing sent message: $e');
      }
    });

    _socket!.on('message_read', (data) {
      debugPrint('✅ Message read');
      try {
        final messageId = data['messageId'];
        if (onMessageRead != null && messageId != null) {
          onMessageRead!(messageId);
        }
      } catch (e) {
        debugPrint('Error parsing message read: $e');
      }
    });

    // Unread count
    _socket!.on('unread_count', (data) {
      debugPrint('📊 Unread count: ${data['count']}');
      try {
        final count = data['count'] ?? 0;
        if (onUnreadCount != null) onUnreadCount!(count);
      } catch (e) {
        debugPrint('Error parsing unread count: $e');
      }
    });

    // Typing indicator
    _socket!.on('user_typing', (data) {
      debugPrint('✍️ User typing: ${data['userId']}');
      try {
        final userId = data['userId'].toString();
        final typing = data['typing'] ?? false;
        if (onUserTyping != null) onUserTyping!(userId, typing);
      } catch (e) {
        debugPrint('Error parsing typing indicator: $e');
      }
    });

    // Online/offline status
    _socket!.on('user_online', (data) {
      debugPrint('🟢 User online: ${data['userId']}');
      try {
        final userId = data['userId'].toString();
        if (onUserOnline != null) onUserOnline!(userId);
      } catch (e) {
        debugPrint('Error parsing user online: $e');
      }
    });

    _socket!.on('user_offline', (data) {
      debugPrint('⚪ User offline: ${data['userId']}');
      try {
        final userId = data['userId'].toString();
        if (onUserOffline != null) onUserOffline!(userId);
      } catch (e) {
        debugPrint('Error parsing user offline: $e');
      }
    });

    // Error events
    _socket!.on('error', (data) {
      debugPrint('❌ Socket error: $data');
      if (onError != null) {
        onError!(data['message'] ?? 'Unknown error');
      }
    });
  }

  /// Send a message
  void sendMessage({
    required String receiverId,
    required String content,
    String? donationId,
    String? requestId,
  }) {
    if (!_isConnected || _socket == null) {
      debugPrint('Cannot send message: Socket not connected');
      if (onError != null) onError!('Not connected to server');
      return;
    }

    debugPrint('Sending message to user $receiverId');
    _socket!.emit('send_message', {
      'receiverId': receiverId,
      'content': content,
      'donationId': donationId,
      'requestId': requestId,
    });
  }

  /// Send typing indicator
  void sendTyping(String receiverId) {
    if (!_isConnected || _socket == null) return;
    _socket!.emit('typing', {'receiverId': receiverId});
  }

  /// Stop typing indicator
  void stopTyping(String receiverId) {
    if (!_isConnected || _socket == null) return;
    _socket!.emit('stop_typing', {'receiverId': receiverId});
  }

  /// Mark a message as read
  void markAsRead(int messageId) {
    if (!_isConnected || _socket == null) return;
    debugPrint('Marking message $messageId as read');
    _socket!.emit('mark_as_read', {'messageId': messageId});
  }

  /// Mark entire conversation as read
  void markConversationRead(String otherUserId) {
    if (!_isConnected || _socket == null) return;
    debugPrint('Marking conversation with user $otherUserId as read');
    _socket!.emit('mark_conversation_read', {'otherUserId': otherUserId});
  }

  /// Join a conversation room
  void joinConversation(String otherUserId) {
    if (!_isConnected || _socket == null) return;
    debugPrint('Joining conversation with user $otherUserId');
    _socket!.emit('join_conversation', {'otherUserId': otherUserId});
  }

  /// Leave a conversation room
  void leaveConversation(String otherUserId) {
    if (!_isConnected || _socket == null) return;
    debugPrint('Leaving conversation with user $otherUserId');
    _socket!.emit('leave_conversation', {'otherUserId': otherUserId});
  }

  /// Request unread count
  void _requestUnreadCount() {
    if (!_isConnected || _socket == null) return;
    _socket!.emit('get_unread_count');
  }

  /// Manually request unread count
  void getUnreadCount() {
    _requestUnreadCount();
  }

  /// Disconnect from socket
  void disconnect() {
    if (_socket != null) {
      debugPrint('Disconnecting socket...');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
    }
  }

  /// Clear all callbacks
  void clearCallbacks() {
    onNewMessage = null;
    onMessageSent = null;
    onUnreadCount = null;
    onUserTyping = null;
    onMessageRead = null;
    onUserOnline = null;
    onUserOffline = null;
    onError = null;
  }
}
