import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../core/config/env_config.dart';
import '../services/api_service.dart';

/// Base repository class with common functionality
abstract class BaseRepository {
  String get baseUrl => EnvConfig.apiBaseUrl;

  Future<Map<String, String>> _getHeaders({bool includeAuth = false}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (includeAuth) {
      String? token = await ApiService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<http.Response> get(String endpoint, {bool includeAuth = false}) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl$endpoint'),
          headers: await _getHeaders(includeAuth: includeAuth),
        )
        .timeout(APIConstants.receiveTimeout);
    return response;
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body,
      {bool includeAuth = false}) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl$endpoint'),
          headers: await _getHeaders(includeAuth: includeAuth),
          body: jsonEncode(body),
        )
        .timeout(APIConstants.sendTimeout);
    return response;
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body,
      {bool includeAuth = false}) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl$endpoint'),
          headers: await _getHeaders(includeAuth: includeAuth),
          body: jsonEncode(body),
        )
        .timeout(APIConstants.sendTimeout);
    return response;
  }

  Future<http.Response> delete(String endpoint,
      {bool includeAuth = false}) async {
    final response = await http
        .delete(
          Uri.parse('$baseUrl$endpoint'),
          headers: await _getHeaders(includeAuth: includeAuth),
        )
        .timeout(APIConstants.receiveTimeout);
    return response;
  }

  ApiResponse<T> handleResponse<T>(
      http.Response response, T Function(Map<String, dynamic>) fromJson) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return ApiResponse.success(fromJson(data));
    } else {
      final error = jsonDecode(response.body);
      return ApiResponse.error(error['message'] ?? 'Request failed');
    }
  }

  ApiResponse<List<T>> handleListResponse<T>(
      http.Response response, T Function(Map<String, dynamic>) fromJson) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      // Handle different response formats
      List<dynamic> itemsList;
      if (data['donations'] != null) {
        // For donations
        itemsList = data['donations'] as List;
      } else if (data['messages'] != null) {
        // For messages
        itemsList = data['messages'] as List;
      } else if (data['requests'] != null) {
        // For requests
        itemsList = data['requests'] as List;
      } else if (data['users'] != null) {
        // For users
        itemsList = data['users'] as List;
      } else if (data['notifications'] != null) {
        // For notifications
        itemsList = data['notifications'] as List;
      } else if (data['conversations'] != null) {
        // For conversations
        itemsList = data['conversations'] as List;
      } else if (data is List) {
        // If data itself is a list
        itemsList = data;
      } else {
        // Default to empty list
        itemsList = [];
      }

      final items = itemsList.map((json) => fromJson(json)).toList();
      return ApiResponse.success(items);
    } else {
      final error = jsonDecode(response.body);
      return ApiResponse.error(error['message'] ?? 'Request failed');
    }
  }
}

/// Generic API response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponse._(this.success, this.data, this.error);

  factory ApiResponse.success(T data) => ApiResponse._(true, data, null);
  factory ApiResponse.error(String error) => ApiResponse._(false, null, error);
}
