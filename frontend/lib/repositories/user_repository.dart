import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../models/user.dart';
import 'base_repository.dart';

/// Repository for user-related operations
class UserRepository extends BaseRepository {
  /// Get user profile
  Future<ApiResponse<User>> getProfile() async {
    try {
      final response = await get(APIConstants.profile, includeAuth: true);
      return handleResponse(response, (json) => User.fromJson(json['user']));
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<ApiResponse<User>> updateProfile({
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

      final response =
          await put('${APIConstants.users}/$userId', body, includeAuth: true);
      return handleResponse(response, (json) => User.fromJson(json['user']));
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Get all users (admin only)
  Future<ApiResponse<List<User>>> getAllUsers({
    int page = APIConstants.defaultPage,
    int limit = APIConstants.defaultLimit,
    String? role,
    String? search,
  }) async {
    try {
      String queryParams = '';
      List<String> params = [];

      params.add('${APIConstants.pageParam}=$page');
      params.add('${APIConstants.limitParam}=$limit');
      if (role != null) params.add('role=$role');
      if (search != null) params.add('${APIConstants.searchParam}=$search');

      if (params.isNotEmpty) {
        queryParams = '?${params.join('&')}';
      }

      final response =
          await get('${APIConstants.users}$queryParams', includeAuth: true);
      return handleListResponse(response, (json) => User.fromJson(json));
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Get user by ID
  Future<ApiResponse<User>> getUserById(String userId) async {
    try {
      final response =
          await get('${APIConstants.users}/$userId', includeAuth: true);
      return handleResponse(response, (json) => User.fromJson(json['user']));
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Delete user (admin only)
  Future<ApiResponse<String>> deleteUser(String userId) async {
    try {
      final response =
          await delete('${APIConstants.users}/$userId', includeAuth: true);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(data['message']);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(error['message'] ?? 'Failed to delete user');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Get user statistics
  Future<ApiResponse<Map<String, dynamic>>> getUserStats(String userId) async {
    try {
      final response =
          await get('${APIConstants.users}/$userId/stats', includeAuth: true);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(data['stats']);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to get user stats');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Search users
  Future<ApiResponse<List<User>>> searchUsers({
    required String query,
    String? role,
    int page = APIConstants.defaultPage,
    int limit = APIConstants.defaultLimit,
  }) async {
    try {
      String queryParams = '';
      List<String> params = [];

      params.add('${APIConstants.searchParam}=$query');
      if (role != null) params.add('role=$role');
      params.add('${APIConstants.pageParam}=$page');
      params.add('${APIConstants.limitParam}=$limit');

      if (params.isNotEmpty) {
        queryParams = '?${params.join('&')}';
      }

      final response = await get('${APIConstants.searchUsers}$queryParams',
          includeAuth: true);
      return handleListResponse(response, (json) => User.fromJson(json));
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Change password
  Future<ApiResponse<String>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await put(
        APIConstants.changePassword,
        {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        includeAuth: true,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(data['message']);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Upload avatar
  Future<ApiResponse<String>> uploadAvatar(String imagePath) async {
    try {
      // This would typically use multipart request for file upload
      // For now, returning a placeholder
      return ApiResponse.success('Avatar uploaded successfully');
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
}
