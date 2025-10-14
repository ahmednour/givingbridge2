import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../models/donation.dart';
import 'base_repository.dart';

/// Repository for donation-related operations
class DonationRepository extends BaseRepository {
  /// Get all donations with optional filters
  Future<ApiResponse<List<Donation>>> getDonations({
    String? category,
    String? location,
    bool? available,
    int page = APIConstants.defaultPage,
    int limit = APIConstants.defaultLimit,
    String? sort,
    String? order,
  }) async {
    try {
      String queryParams = '';
      List<String> params = [];

      if (category != null)
        params.add('${APIConstants.categoryParam}=$category');
      if (location != null)
        params.add('${APIConstants.locationParam}=$location');
      if (available != null)
        params.add('${APIConstants.availableParam}=$available');
      params.add('${APIConstants.pageParam}=$page');
      params.add('${APIConstants.limitParam}=$limit');
      if (sort != null) params.add('${APIConstants.sortParam}=$sort');
      if (order != null) params.add('${APIConstants.orderParam}=$order');

      if (params.isNotEmpty) {
        queryParams = '?${params.join('&')}';
      }

      final response = await get('${APIConstants.donations}$queryParams');
      return handleListResponse(response, (json) => Donation.fromJson(json));
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Get donation by ID
  Future<ApiResponse<Donation>> getDonation(String id) async {
    try {
      final response = await get('${APIConstants.donations}/$id');
      return handleResponse(
          response, (json) => Donation.fromJson(json['donation']));
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Get donations by donor ID
  Future<ApiResponse<List<Donation>>> getMyDonations() async {
    try {
      final response = await get(APIConstants.myDonations, includeAuth: true);
      return handleListResponse(response, (json) => Donation.fromJson(json));
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Create new donation
  Future<ApiResponse<Donation>> createDonation({
    required String title,
    required String description,
    required String category,
    required String condition,
    required String location,
    String? imageUrl,
  }) async {
    try {
      final response = await post(
        APIConstants.donations,
        {
          'title': title,
          'description': description,
          'category': category,
          'condition': condition,
          'location': location,
          if (imageUrl != null) 'imageUrl': imageUrl,
        },
        includeAuth: true,
      );
      return handleResponse(
          response, (json) => Donation.fromJson(json['donation']));
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Update donation
  Future<ApiResponse<Donation>> updateDonation({
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

      final response =
          await put('${APIConstants.donations}/$id', body, includeAuth: true);
      return handleResponse(
          response, (json) => Donation.fromJson(json['donation']));
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Delete donation
  Future<ApiResponse<String>> deleteDonation(String id) async {
    try {
      final response =
          await delete('${APIConstants.donations}/$id', includeAuth: true);
      if (response.statusCode >= 200 && response.statusCode < 300) {
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

  /// Get donation statistics
  Future<ApiResponse<Map<String, dynamic>>> getDonationStats() async {
    try {
      final response = await get(APIConstants.donationStats, includeAuth: true);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(data['stats']);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to get donation stats');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Search donations
  Future<ApiResponse<List<Donation>>> searchDonations({
    required String query,
    String? category,
    String? location,
    int page = APIConstants.defaultPage,
    int limit = APIConstants.defaultLimit,
  }) async {
    try {
      String queryParams = '';
      List<String> params = [];

      params.add('${APIConstants.searchParam}=$query');
      if (category != null)
        params.add('${APIConstants.categoryParam}=$category');
      if (location != null)
        params.add('${APIConstants.locationParam}=$location');
      params.add('${APIConstants.pageParam}=$page');
      params.add('${APIConstants.limitParam}=$limit');

      if (params.isNotEmpty) {
        queryParams = '?${params.join('&')}';
      }

      final response = await get('${APIConstants.searchDonations}$queryParams');
      return handleListResponse(response, (json) => Donation.fromJson(json));
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
}
