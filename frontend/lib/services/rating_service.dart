import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../core/config/api_config.dart';

/// Model for rating
class Rating {
  final int id;
  final int requestId;
  final int donorId;
  final int receiverId;
  final String ratedBy; // 'donor' or 'receiver'
  final int rating; // 1-5
  final String? feedback;
  final DateTime createdAt;
  final DateTime updatedAt;

  Rating({
    required this.id,
    required this.requestId,
    required this.donorId,
    required this.receiverId,
    required this.ratedBy,
    required this.rating,
    this.feedback,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      requestId: json['requestId'],
      donorId: json['donorId'],
      receiverId: json['receiverId'],
      ratedBy: json['ratedBy'],
      rating: json['rating'],
      feedback: json['feedback'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestId': requestId,
      'donorId': donorId,
      'receiverId': receiverId,
      'ratedBy': ratedBy,
      'rating': rating,
      'feedback': feedback,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isDonorRating => ratedBy == 'donor';
  bool get isReceiverRating => ratedBy == 'receiver';
}

/// Average rating response
class AverageRating {
  final double average;
  final int count;

  AverageRating({
    required this.average,
    required this.count,
  });

  factory AverageRating.fromJson(Map<String, dynamic> json) {
    return AverageRating(
      average: (json['average'] is int)
          ? (json['average'] as int).toDouble()
          : json['average'] ?? 0.0,
      count: json['count'] ?? 0,
    );
  }
}

/// Response for ratings with average
class RatingsWithAverage {
  final List<Rating> ratings;
  final double average;
  final int count;

  RatingsWithAverage({
    required this.ratings,
    required this.average,
    required this.count,
  });
}

/// Service for backend rating API endpoints
class RatingService {
  static String get baseUrl => '${ApiConfig.baseUrl}/ratings';

  /// Helper method to get headers with auth token
  static Future<Map<String, String>> _getHeaders() async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    String? token = await ApiService.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Create a rating
  static Future<ApiResponse<Rating>> createRating({
    required int requestId,
    required int rating,
    String? feedback,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await _getHeaders(),
        body: jsonEncode({
          'requestId': requestId,
          'rating': rating,
          if (feedback != null && feedback.isNotEmpty) 'feedback': feedback,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final ratingObj = Rating.fromJson(data['rating']);
        return ApiResponse.success(ratingObj);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(error['message'] ?? 'Failed to create rating');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Get rating by request ID
  static Future<ApiResponse<Rating>> getRatingByRequest(int requestId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/request/$requestId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rating = Rating.fromJson(data['rating']);
        return ApiResponse.success(rating);
      } else if (response.statusCode == 404) {
        return ApiResponse.error('No rating found for this request');
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(error['message'] ?? 'Failed to get rating');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Get all ratings for a donor with average
  static Future<ApiResponse<RatingsWithAverage>> getDonorRatings(
      int donorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/donor/$donorId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final ratings = (data['ratings'] as List)
            .map((json) => Rating.fromJson(json))
            .toList();

        final average = (data['average'] is int)
            ? (data['average'] as int).toDouble()
            : data['average'] ?? 0.0;
        final count = data['count'] ?? 0;

        return ApiResponse.success(
          RatingsWithAverage(
            ratings: ratings,
            average: average,
            count: count,
          ),
        );
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to get donor ratings');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Get all ratings for a receiver with average
  static Future<ApiResponse<RatingsWithAverage>> getReceiverRatings(
      int receiverId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/receiver/$receiverId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final ratings = (data['ratings'] as List)
            .map((json) => Rating.fromJson(json))
            .toList();

        final average = (data['average'] is int)
            ? (data['average'] as int).toDouble()
            : data['average'] ?? 0.0;
        final count = data['count'] ?? 0;

        return ApiResponse.success(
          RatingsWithAverage(
            ratings: ratings,
            average: average,
            count: count,
          ),
        );
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to get receiver ratings');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Update a rating
  static Future<ApiResponse<Rating>> updateRating({
    required int requestId,
    required int rating,
    String? feedback,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/request/$requestId'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'rating': rating,
          if (feedback != null) 'feedback': feedback,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final ratingObj = Rating.fromJson(data['rating']);
        return ApiResponse.success(ratingObj);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(error['message'] ?? 'Failed to update rating');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Delete a rating
  static Future<ApiResponse<String>> deleteRating(int requestId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/request/$requestId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(data['message'] ?? 'Rating deleted');
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(error['message'] ?? 'Failed to delete rating');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Get donor average rating only
  static Future<ApiResponse<AverageRating>> getDonorAverageRating(
      int donorId) async {
    final response = await getDonorRatings(donorId);
    if (response.success && response.data != null) {
      return ApiResponse.success(
        AverageRating(
          average: response.data!.average,
          count: response.data!.count,
        ),
      );
    } else {
      return ApiResponse.error(
          response.error ?? 'Failed to get average rating');
    }
  }

  /// Get receiver average rating only
  static Future<ApiResponse<AverageRating>> getReceiverAverageRating(
      int receiverId) async {
    final response = await getReceiverRatings(receiverId);
    if (response.success && response.data != null) {
      return ApiResponse.success(
        AverageRating(
          average: response.data!.average,
          count: response.data!.count,
        ),
      );
    } else {
      return ApiResponse.error(
          response.error ?? 'Failed to get average rating');
    }
  }
}
