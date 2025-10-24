import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../core/config/api_config.dart';

/// Platform overview statistics
class PlatformOverview {
  final UserStats users;
  final DonationStats donations;
  final RequestStats requests;

  PlatformOverview({
    required this.users,
    required this.donations,
    required this.requests,
  });

  factory PlatformOverview.fromJson(Map<String, dynamic> json) {
    return PlatformOverview(
      users: UserStats.fromJson(json['users']),
      donations: DonationStats.fromJson(json['donations']),
      requests: RequestStats.fromJson(json['requests']),
    );
  }
}

class UserStats {
  final int total;
  final int donors;
  final int receivers;
  final int admins;

  UserStats({
    required this.total,
    required this.donors,
    required this.receivers,
    required this.admins,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      total: json['total'] ?? 0,
      donors: json['donors'] ?? 0,
      receivers: json['receivers'] ?? 0,
      admins: json['admins'] ?? 0,
    );
  }
}

class DonationStats {
  final int total;
  final int available;
  final int completed;

  DonationStats({
    required this.total,
    required this.available,
    required this.completed,
  });

  factory DonationStats.fromJson(Map<String, dynamic> json) {
    return DonationStats(
      total: json['total'] ?? 0,
      available: json['available'] ?? 0,
      completed: json['completed'] ?? 0,
    );
  }
}

class RequestStats {
  final int total;
  final int pending;
  final int approved;
  final int completed;
  final int declined;

  RequestStats({
    required this.total,
    required this.pending,
    required this.approved,
    required this.completed,
    required this.declined,
  });

  factory RequestStats.fromJson(Map<String, dynamic> json) {
    return RequestStats(
      total: json['total'] ?? 0,
      pending: json['pending'] ?? 0,
      approved: json['approved'] ?? 0,
      completed: json['completed'] ?? 0,
      declined: json['declined'] ?? 0,
    );
  }
}

/// Trend data point
class TrendDataPoint {
  final String date;
  final int count;

  TrendDataPoint({
    required this.date,
    required this.count,
  });

  factory TrendDataPoint.fromJson(Map<String, dynamic> json) {
    return TrendDataPoint(
      date: json['date'],
      count: json['count'] ?? 0,
    );
  }
}

/// Category distribution
class CategoryDistribution {
  final String category;
  final int count;
  final double percentage;

  CategoryDistribution({
    required this.category,
    required this.count,
    required this.percentage,
  });

  factory CategoryDistribution.fromJson(Map<String, dynamic> json) {
    return CategoryDistribution(
      category: json['category'],
      count: json['count'] ?? 0,
      percentage: (json['percentage'] is int)
          ? (json['percentage'] as int).toDouble()
          : json['percentage'] ?? 0.0,
    );
  }
}

/// Status distribution
class StatusDistribution {
  final String status;
  final int count;

  StatusDistribution({
    required this.status,
    required this.count,
  });

  factory StatusDistribution.fromJson(Map<String, dynamic> json) {
    return StatusDistribution(
      status: json['status'],
      count: json['count'] ?? 0,
    );
  }
}

/// Top donor
class TopDonor {
  final int id;
  final String name;
  final int donationCount;
  final double? averageRating;
  final int? ratingCount;

  TopDonor({
    required this.id,
    required this.name,
    required this.donationCount,
    this.averageRating,
    this.ratingCount,
  });

  factory TopDonor.fromJson(Map<String, dynamic> json) {
    return TopDonor(
      id: json['id'],
      name: json['name'],
      donationCount: json['donationCount'] ?? 0,
      averageRating: json['averageRating'] != null
          ? (json['averageRating'] is int
              ? (json['averageRating'] as int).toDouble()
              : json['averageRating'])
          : null,
      ratingCount: json['ratingCount'],
    );
  }
}

/// Recent activity item
class RecentActivity {
  final String type;
  final String userName;
  final String? donationTitle;
  final String status;
  final DateTime timestamp;

  RecentActivity({
    required this.type,
    required this.userName,
    this.donationTitle,
    required this.status,
    required this.timestamp,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      type: json['type'],
      userName: json['userName'],
      donationTitle: json['donationTitle'],
      status: json['status'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// Platform statistics
class PlatformStats {
  final int totalUsers;
  final int totalDonations;
  final int totalRequests;
  final int totalMessages;
  final int completedDonations;
  final double completionRate;
  final int activeDonors;
  final int activeReceivers;

  PlatformStats({
    required this.totalUsers,
    required this.totalDonations,
    required this.totalRequests,
    required this.totalMessages,
    required this.completedDonations,
    required this.completionRate,
    required this.activeDonors,
    required this.activeReceivers,
  });

  factory PlatformStats.fromJson(Map<String, dynamic> json) {
    return PlatformStats(
      totalUsers: json['totalUsers'] ?? 0,
      totalDonations: json['totalDonations'] ?? 0,
      totalRequests: json['totalRequests'] ?? 0,
      totalMessages: json['totalMessages'] ?? 0,
      completedDonations: json['completedDonations'] ?? 0,
      completionRate: (json['completionRate'] is int)
          ? (json['completionRate'] as int).toDouble()
          : json['completionRate'] ?? 0.0,
      activeDonors: json['activeDonors'] ?? 0,
      activeReceivers: json['activeReceivers'] ?? 0,
    );
  }
}

/// Service for backend analytics API endpoints (Admin only)
class AnalyticsService {
  static String get baseUrl => '${ApiConfig.baseUrl}/analytics';

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

  /// Get platform overview statistics
  static Future<ApiResponse<PlatformOverview>> getOverview() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/overview'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final overview = PlatformOverview.fromJson(data['data']);
        return ApiResponse.success(overview);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(error['message'] ?? 'Failed to get overview');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Get donation trends over time
  static Future<ApiResponse<List<TrendDataPoint>>> getDonationTrends({
    int days = 30,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/donations/trends?days=$days'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final trends = (data['data'] as List)
            .map((json) => TrendDataPoint.fromJson(json))
            .toList();
        return ApiResponse.success(trends);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to get donation trends');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Get user growth over time
  static Future<ApiResponse<List<TrendDataPoint>>> getUserGrowth({
    int days = 30,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/growth?days=$days'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final trends = (data['data'] as List)
            .map((json) => TrendDataPoint.fromJson(json))
            .toList();
        return ApiResponse.success(trends);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to get user growth');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Get category distribution
  static Future<ApiResponse<List<CategoryDistribution>>>
      getCategoryDistribution() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/donations/categories'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final distribution = (data['data'] as List)
            .map((json) => CategoryDistribution.fromJson(json))
            .toList();
        return ApiResponse.success(distribution);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to get category distribution');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Get status distribution
  static Future<ApiResponse<List<StatusDistribution>>>
      getStatusDistribution() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/donations/status'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final distribution = (data['data'] as List)
            .map((json) => StatusDistribution.fromJson(json))
            .toList();
        return ApiResponse.success(distribution);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to get status distribution');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Get top donors
  static Future<ApiResponse<List<TopDonor>>> getTopDonors({
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/donors/top?limit=$limit'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final topDonors = (data['data'] as List)
            .map((json) => TopDonor.fromJson(json))
            .toList();
        return ApiResponse.success(topDonors);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to get top donors');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Get recent activity
  static Future<ApiResponse<List<RecentActivity>>> getRecentActivity({
    int limit = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/activity/recent?limit=$limit'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final activities = (data['data'] as List)
            .map((json) => RecentActivity.fromJson(json))
            .toList();
        return ApiResponse.success(activities);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to get recent activity');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Get comprehensive platform statistics
  static Future<ApiResponse<PlatformStats>> getPlatformStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/platform/stats'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final stats = PlatformStats.fromJson(data['data']);
        return ApiResponse.success(stats);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to get platform stats');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
}
