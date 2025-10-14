import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../models/donation.dart';
import '../models/user.dart';
import '../core/config/api_config.dart';

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String profileEndpoint = '/auth/me';

  // Users endpoints
  static const String usersEndpoint = '/users';

  // Requests endpoints
  static const String requestsEndpoint = '/requests';

  // Helper method to get headers with auth token
  static Future<Map<String, String>> _getHeaders(
      {bool includeAuth = false}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (includeAuth) {
      String? token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Token management
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<bool> hasToken() async {
    String? token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Auth methods
  static Future<ApiResponse<AuthResult>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$loginEndpoint'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResult = AuthResult.fromJson(data);
        await saveToken(authResult.token);

        return ApiResponse.success(authResult);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  static Future<ApiResponse<AuthResult>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? location,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$registerEndpoint'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          'phone': phone,
          'location': location,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final authResult = AuthResult.fromJson(data);
        await saveToken(authResult.token);

        return ApiResponse.success(authResult);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  static Future<ApiResponse<User>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$profileEndpoint'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['user']);
        return ApiResponse.success(user);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(error['message'] ?? 'Failed to get profile');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  static Future<void> logout() async {
    await deleteToken();
  }

  // Update user profile
  static Future<ApiResponse<User>> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? location,
    String? avatarUrl,
  }) async {
    try {
      Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;
      if (location != null) body['location'] = location;
      if (avatarUrl != null) body['avatarUrl'] = avatarUrl;

      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['user']);
        return ApiResponse.success(user);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(error['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Get all users (admin only)
  static Future<ApiResponse<List<User>>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users =
            (data['users'] as List).map((json) => User.fromJson(json)).toList();
        return ApiResponse.success(users);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(error['message'] ?? 'Failed to load users');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // ========== DONATION METHODS ==========

  // Get all donations with optional filters
  static Future<ApiResponse<List<Donation>>> getDonations({
    String? category,
    String? location,
    bool? available,
  }) async {
    try {
      String queryParams = '';
      List<String> params = [];

      if (category != null) params.add('category=$category');
      if (location != null) params.add('location=$location');
      if (available != null) params.add('available=$available');

      if (params.isNotEmpty) {
        queryParams = '?${params.join('&')}';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/donations$queryParams'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final donations = (data['donations'] as List)
            .map((json) => Donation.fromJson(json))
            .toList();
        return ApiResponse.success(donations);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to load donations');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Get donation by ID
  static Future<ApiResponse<Donation>> getDonation(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/donations/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final donation = Donation.fromJson(data['donation']);
        return ApiResponse.success(donation);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(error['message'] ?? 'Failed to load donation');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Get my donations (for donor)
  static Future<ApiResponse<List<Donation>>> getMyDonations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/donations/donor/my-donations'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final donations = (data['donations'] as List)
            .map((json) => Donation.fromJson(json))
            .toList();
        return ApiResponse.success(donations);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to load your donations');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Create new donation
  static Future<ApiResponse<Donation>> createDonation({
    required String title,
    required String description,
    required String category,
    required String condition,
    required String location,
    String? imageUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/donations'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode({
          'title': title,
          'description': description,
          'category': category,
          'condition': condition,
          'location': location,
          if (imageUrl != null) 'imageUrl': imageUrl,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final donation = Donation.fromJson(data['donation']);
        return ApiResponse.success(donation);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to create donation');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Update donation
  static Future<ApiResponse<Donation>> updateDonation({
    required String id,
    String? title,
    String? description,
    String? category,
    String? condition,
    String? location,
    String? imageUrl,
    bool? isAvailable,
  }) async {
    try {
      Map<String, dynamic> body = {};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (category != null) body['category'] = category;
      if (condition != null) body['condition'] = condition;
      if (location != null) body['location'] = location;
      if (imageUrl != null) body['imageUrl'] = imageUrl;
      if (isAvailable != null) body['isAvailable'] = isAvailable;

      final response = await http.put(
        Uri.parse('$baseUrl/donations/$id'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final donation = Donation.fromJson(data['donation']);
        return ApiResponse.success(donation);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to update donation');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Delete donation
  static Future<ApiResponse<String>> deleteDonation(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/donations/$id'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(data['message']);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to delete donation');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // ========== REQUEST METHODS ==========

  // Get all requests (filtered by user role)
  static Future<ApiResponse<List<DonationRequest>>> getRequests({
    String? donationId,
    String? status,
  }) async {
    try {
      String queryParams = '';
      List<String> params = [];

      if (donationId != null) params.add('donationId=$donationId');
      if (status != null) params.add('status=$status');

      if (params.isNotEmpty) {
        queryParams = '?${params.join('&')}';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/requests$queryParams'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final requests = (data['requests'] as List)
            .map((json) => DonationRequest.fromJson(json))
            .toList();
        return ApiResponse.success(requests);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(error['message'] ?? 'Failed to load requests');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Get my requests (as receiver)
  static Future<ApiResponse<List<DonationRequest>>> getMyRequests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/requests/receiver/my-requests'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final requests = (data['requests'] as List)
            .map((json) => DonationRequest.fromJson(json))
            .toList();
        return ApiResponse.success(requests);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to load your requests');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Get incoming requests (as donor)
  static Future<ApiResponse<List<DonationRequest>>>
      getIncomingRequests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/requests/donor/incoming-requests'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final requests = (data['requests'] as List)
            .map((json) => DonationRequest.fromJson(json))
            .toList();
        return ApiResponse.success(requests);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to load incoming requests');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Create donation request
  static Future<ApiResponse<DonationRequest>> createRequest({
    required String donationId,
    String? message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/requests'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode({
          'donationId': int.parse(donationId),
          if (message != null && message.isNotEmpty) 'message': message,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final request = DonationRequest.fromJson(data['request']);
        return ApiResponse.success(request);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to create request');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Update request status
  static Future<ApiResponse<DonationRequest>> updateRequestStatus({
    required String requestId,
    required String status,
    String? responseMessage,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/requests/$requestId/status'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode({
          'status': status,
          if (responseMessage != null && responseMessage.isNotEmpty)
            'responseMessage': responseMessage,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final request = DonationRequest.fromJson(data['request']);
        return ApiResponse.success(request);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to update request');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Delete request
  static Future<ApiResponse<String>> deleteRequest(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/requests/$id'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(data['message']);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to delete request');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // ========== MESSAGE METHODS ==========

  // Get all conversations
  static Future<ApiResponse<List<Conversation>>> getConversations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/conversations'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final conversations = (data['conversations'] as List)
            .map((json) => Conversation.fromJson(json))
            .toList();
        return ApiResponse.success(conversations);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to load conversations');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Get messages in a conversation
  static Future<ApiResponse<List<ChatMessage>>> getMessages({
    required String userId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/messages/conversation/$userId?page=$page&limit=$limit'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final messages = (data['messages'] as List)
            .map((json) => ChatMessage.fromJson(json))
            .toList();
        return ApiResponse.success(messages);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(error['message'] ?? 'Failed to load messages');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Send a message
  static Future<ApiResponse<ChatMessage>> sendMessage({
    required String receiverId,
    required String content,
    String? donationId,
    String? requestId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode({
          'receiverId': int.parse(receiverId),
          'content': content,
          if (donationId != null) 'donationId': int.parse(donationId),
          if (requestId != null) 'requestId': int.parse(requestId),
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final message = ChatMessage.fromJson(data['data']);
        return ApiResponse.success(message);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(error['message'] ?? 'Failed to send message');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Mark message as read
  static Future<ApiResponse<String>> markMessageAsRead(String messageId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/messages/$messageId/read'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
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

  // Get unread message count
  static Future<ApiResponse<int>> getUnreadMessageCount() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/unread-count'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
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
}

// Data models
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponse.success(this.data)
      : success = true,
        error = null;
  ApiResponse.error(this.error)
      : success = false,
        data = null;
}

class AuthResult {
  final String message;
  final User user;
  final String token;

  AuthResult({
    required this.message,
    required this.user,
    required this.token,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      message: json['message'],
      user: User.fromJson(json['user']),
      token: json['token'],
    );
  }
}

class DonationRequest {
  final int id;
  final int donationId;
  final int donorId;
  final String donorName;
  final int receiverId;
  final String receiverName;
  final String receiverEmail;
  final String? receiverPhone;
  final String? message;
  final String status;
  final String? responseMessage;
  final String createdAt;
  final String updatedAt;
  final String? respondedAt;

  DonationRequest({
    required this.id,
    required this.donationId,
    required this.donorId,
    required this.donorName,
    required this.receiverId,
    required this.receiverName,
    required this.receiverEmail,
    this.receiverPhone,
    this.message,
    required this.status,
    this.responseMessage,
    required this.createdAt,
    required this.updatedAt,
    this.respondedAt,
  });

  factory DonationRequest.fromJson(Map<String, dynamic> json) {
    return DonationRequest(
      id: json['id'],
      donationId: json['donationId'],
      donorId: json['donorId'],
      donorName: json['donorName'],
      receiverId: json['receiverId'],
      receiverName: json['receiverName'],
      receiverEmail: json['receiverEmail'],
      receiverPhone: json['receiverPhone'],
      message: json['message'],
      status: json['status'],
      responseMessage: json['responseMessage'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      respondedAt: json['respondedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donationId': donationId,
      'donorId': donorId,
      'donorName': donorName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverEmail': receiverEmail,
      'receiverPhone': receiverPhone,
      'message': message,
      'status': status,
      'responseMessage': responseMessage,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'respondedAt': respondedAt,
    };
  }

  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'declined':
        return 'Declined';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isDeclined => status == 'declined';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
}

class ChatMessage {
  final int id;
  final int senderId;
  final String senderName;
  final int receiverId;
  final String receiverName;
  final int? donationId;
  final int? requestId;
  final String content;
  final bool isRead;
  final String createdAt;
  final String updatedAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    this.donationId,
    this.requestId,
    required this.content,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['senderId'] ?? json['sender_id'],
      senderName: json['senderName'] ?? json['sender_name'],
      receiverId: json['receiverId'] ?? json['receiver_id'],
      receiverName: json['receiverName'] ?? json['receiver_name'],
      donationId: json['donationId'] ?? json['donation_id'],
      requestId: json['requestId'] ?? json['request_id'],
      content: json['content'],
      isRead: json['isRead'] ?? json['is_read'],
      createdAt: json['createdAt'] ?? json['created_at'] ?? json['createdAt'],
      updatedAt: json['updatedAt'] ?? json['updated_at'] ?? json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'donationId': donationId,
      'requestId': requestId,
      'content': content,
      'isRead': isRead,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class Conversation {
  final int userId;
  final String userName;
  final ChatMessage lastMessage;
  final int unreadCount;
  final int? donationId;
  final int? requestId;

  Conversation({
    required this.userId,
    required this.userName,
    required this.lastMessage,
    required this.unreadCount,
    this.donationId,
    this.requestId,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      userId: json['userId'],
      userName: json['userName'],
      lastMessage: ChatMessage.fromJson(json['lastMessage']),
      unreadCount: json['unreadCount'],
      donationId: json['donationId'],
      requestId: json['requestId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'lastMessage': lastMessage.toJson(),
      'unreadCount': unreadCount,
      'donationId': donationId,
      'requestId': requestId,
    };
  }

  bool get hasUnreadMessages => unreadCount > 0;
}
