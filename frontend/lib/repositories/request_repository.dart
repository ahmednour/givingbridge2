import 'dart:convert';
import '../core/constants/api_constants.dart';
import 'base_repository.dart';

/// Repository for request-related operations
class RequestRepository extends BaseRepository {
  /// Get all requests with optional filters
  Future<ApiResponse<List<dynamic>>> getRequests({
    String? donationId,
    String? status,
    int page = APIConstants.defaultPage,
    int limit = APIConstants.defaultLimit,
  }) async {
    try {
      String queryParams = '';
      List<String> params = [];

      if (donationId != null) params.add('donationId=$donationId');
      if (status != null) params.add('${APIConstants.statusParam}=$status');
      params.add('${APIConstants.pageParam}=$page');
      params.add('${APIConstants.limitParam}=$limit');

      if (params.isNotEmpty) {
        queryParams = '?${params.join('&')}';
      }

      final response =
          await get('${APIConstants.requests}$queryParams', includeAuth: true);
      return handleListResponse(response, (json) => json);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Get my requests (as receiver)
  Future<ApiResponse<List<dynamic>>> getMyRequests({
    String? status,
    int page = APIConstants.defaultPage,
    int limit = APIConstants.defaultLimit,
  }) async {
    try {
      String queryParams = '';
      List<String> params = [];

      if (status != null) params.add('${APIConstants.statusParam}=$status');
      params.add('${APIConstants.pageParam}=$page');
      params.add('${APIConstants.limitParam}=$limit');

      if (params.isNotEmpty) {
        queryParams = '?${params.join('&')}';
      }

      final response = await get('${APIConstants.myRequests}$queryParams',
          includeAuth: true);
      return handleListResponse(response, (json) => json);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Get incoming requests (as donor)
  Future<ApiResponse<List<dynamic>>> getIncomingRequests({
    String? status,
    int page = APIConstants.defaultPage,
    int limit = APIConstants.defaultLimit,
  }) async {
    try {
      String queryParams = '';
      List<String> params = [];

      if (status != null) params.add('${APIConstants.statusParam}=$status');
      params.add('${APIConstants.pageParam}=$page');
      params.add('${APIConstants.limitParam}=$limit');

      if (params.isNotEmpty) {
        queryParams = '?${params.join('&')}';
      }

      final response = await get('${APIConstants.incomingRequests}$queryParams',
          includeAuth: true);
      return handleListResponse(response, (json) => json);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Create donation request
  Future<ApiResponse<dynamic>> createRequest({
    required String donationId,
    String? message,
  }) async {
    try {
      final response = await post(
        APIConstants.requests,
        {
          'donationId': int.parse(donationId),
          if (message != null && message.isNotEmpty) 'message': message,
        },
        includeAuth: true,
      );
      return handleResponse(response, (json) => json['request']);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Update request status
  Future<ApiResponse<dynamic>> updateRequestStatus({
    required String requestId,
    required String status,
    String? responseMessage,
  }) async {
    try {
      final response = await put(
        '${APIConstants.requests}/$requestId/status',
        {
          'status': status,
          if (responseMessage != null && responseMessage.isNotEmpty)
            'responseMessage': responseMessage,
        },
        includeAuth: true,
      );
      return handleResponse(response, (json) => json['request']);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Delete request
  Future<ApiResponse<String>> deleteRequest(String id) async {
    try {
      final response =
          await delete('${APIConstants.requests}/$id', includeAuth: true);
      if (response.statusCode >= 200 && response.statusCode < 300) {
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

  /// Get request by ID
  Future<ApiResponse<dynamic>> getRequestById(String requestId) async {
    try {
      final response =
          await get('${APIConstants.requests}/$requestId', includeAuth: true);
      return handleResponse(response, (json) => json['request']);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Get request statistics
  Future<ApiResponse<Map<String, dynamic>>> getRequestStats() async {
    try {
      final response = await get(APIConstants.requestStats, includeAuth: true);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(data['stats']);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to get request stats');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Search requests
  Future<ApiResponse<List<dynamic>>> searchRequests({
    required String query,
    String? status,
    int page = APIConstants.defaultPage,
    int limit = APIConstants.defaultLimit,
  }) async {
    try {
      String queryParams = '';
      List<String> params = [];

      params.add('${APIConstants.searchParam}=$query');
      if (status != null) params.add('${APIConstants.statusParam}=$status');
      params.add('${APIConstants.pageParam}=$page');
      params.add('${APIConstants.limitParam}=$limit');

      if (params.isNotEmpty) {
        queryParams = '?${params.join('&')}';
      }

      final response = await get('${APIConstants.searchRequests}$queryParams',
          includeAuth: true);
      return handleListResponse(response, (json) => json);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
}
