import 'dart:convert';
import '../core/constants/api_constants.dart';
import 'base_repository.dart';

/// Repository for message-related operations
class MessageRepository extends BaseRepository {
  /// Get all conversations
  Future<ApiResponse<List<dynamic>>> getConversations() async {
    try {
      final response = await get(APIConstants.conversations, includeAuth: true);
      return handleListResponse(response, (json) => json);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Get messages in a conversation
  Future<ApiResponse<List<dynamic>>> getMessages({
    required String userId,
    int page = APIConstants.defaultPage,
    int limit = APIConstants.defaultLimit,
  }) async {
    try {
      String queryParams = '';
      List<String> params = [];

      params.add('${APIConstants.pageParam}=$page');
      params.add('${APIConstants.limitParam}=$limit');

      if (params.isNotEmpty) {
        queryParams = '?${params.join('&')}';
      }

      final response = await get(
          '${APIConstants.conversationMessages.replaceAll('{userId}', userId)}$queryParams',
          includeAuth: true);
      return handleListResponse(response, (json) => json);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Send a message
  Future<ApiResponse<dynamic>> sendMessage({
    required String receiverId,
    required String content,
    String? donationId,
    String? requestId,
  }) async {
    try {
      final response = await post(
        APIConstants.messages,
        {
          'receiverId': int.parse(receiverId),
          'content': content,
          if (donationId != null) 'donationId': int.parse(donationId),
          if (requestId != null) 'requestId': int.parse(requestId),
        },
        includeAuth: true,
      );
      return handleResponse(response, (json) => json['data']);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Mark message as read
  Future<ApiResponse<String>> markMessageAsRead(String messageId) async {
    try {
      final response = await put(
        '${APIConstants.messages}/$messageId/read',
        {},
        includeAuth: true,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(data['message']);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to mark message as read');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Mark conversation as read
  Future<ApiResponse<String>> markConversationAsRead(String userId) async {
    try {
      final response = await put(
        '${APIConstants.conversationMessages.replaceAll('{userId}', userId)}/read',
        {},
        includeAuth: true,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(data['message']);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to mark conversation as read');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Get unread message count
  Future<ApiResponse<int>> getUnreadMessageCount() async {
    try {
      final response = await get(APIConstants.unreadCount, includeAuth: true);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(data['unreadCount']);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to get unread count');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Delete message
  Future<ApiResponse<String>> deleteMessage(String messageId) async {
    try {
      final response = await delete('${APIConstants.messages}/$messageId',
          includeAuth: true);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(data['message']);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to delete message');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Get message by ID
  Future<ApiResponse<dynamic>> getMessageById(String messageId) async {
    try {
      final response =
          await get('${APIConstants.messages}/$messageId', includeAuth: true);
      return handleResponse(response, (json) => json['message']);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Search messages
  Future<ApiResponse<List<dynamic>>> searchMessages({
    required String query,
    String? userId,
    int page = APIConstants.defaultPage,
    int limit = APIConstants.defaultLimit,
  }) async {
    try {
      String queryParams = '';
      List<String> params = [];

      params.add('${APIConstants.searchParam}=$query');
      if (userId != null) params.add('userId=$userId');
      params.add('${APIConstants.pageParam}=$page');
      params.add('${APIConstants.limitParam}=$limit');

      if (params.isNotEmpty) {
        queryParams = '?${params.join('&')}';
      }

      final response = await get('${APIConstants.messages}/search$queryParams',
          includeAuth: true);
      return handleListResponse(response, (json) => json);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
}
