import 'package:flutter/material.dart';
import '../services/analytics_service.dart';
import '../services/api_service.dart';

/// Provider for managing analytics data (Admin only)
class AnalyticsProvider extends ChangeNotifier {
  PlatformOverview? _overview;
  List<TrendDataPoint> _donationTrends = [];
  List<TrendDataPoint> _userGrowth = [];
  List<CategoryDistribution> _categoryDistribution = [];
  List<StatusDistribution> _statusDistribution = [];
  List<TopDonor> _topDonors = [];
  List<RecentActivity> _recentActivity = [];
  PlatformStats? _platformStats;

  bool _isLoading = false;
  String? _error;
  DateTime? _lastUpdated;

  // Getters
  PlatformOverview? get overview => _overview;
  List<TrendDataPoint> get donationTrends => _donationTrends;
  List<TrendDataPoint> get userGrowth => _userGrowth;
  List<CategoryDistribution> get categoryDistribution => _categoryDistribution;
  List<StatusDistribution> get statusDistribution => _statusDistribution;
  List<TopDonor> get topDonors => _topDonors;
  List<RecentActivity> get recentActivity => _recentActivity;
  PlatformStats? get platformStats => _platformStats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;

  /// Load all analytics data
  Future<void> loadAllAnalytics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load all analytics data in parallel
      final futures = [
        AnalyticsService.getOverview(),
        AnalyticsService.getDonationTrends(days: 30),
        AnalyticsService.getUserGrowth(days: 30),
        AnalyticsService.getCategoryDistribution(),
        AnalyticsService.getStatusDistribution(),
        AnalyticsService.getTopDonors(limit: 10),
        AnalyticsService.getRecentActivity(limit: 20),
        AnalyticsService.getPlatformStats(),
      ];

      final results = await Future.wait(futures);

      // Process overview
      final overviewResponse = results[0] as ApiResponse<PlatformOverview>;
      if (overviewResponse.success && overviewResponse.data != null) {
        _overview = overviewResponse.data;
      }

      // Process donation trends
      final trendsResponse = results[1] as ApiResponse<List<TrendDataPoint>>;
      if (trendsResponse.success && trendsResponse.data != null) {
        _donationTrends = trendsResponse.data!;
      }

      // Process user growth
      final growthResponse = results[2] as ApiResponse<List<TrendDataPoint>>;
      if (growthResponse.success && growthResponse.data != null) {
        _userGrowth = growthResponse.data!;
      }

      // Process category distribution
      final categoryResponse =
          results[3] as ApiResponse<List<CategoryDistribution>>;
      if (categoryResponse.success && categoryResponse.data != null) {
        _categoryDistribution = categoryResponse.data!;
      }

      // Process status distribution
      final statusResponse =
          results[4] as ApiResponse<List<StatusDistribution>>;
      if (statusResponse.success && statusResponse.data != null) {
        _statusDistribution = statusResponse.data!;
      }

      // Process top donors
      final donorsResponse = results[5] as ApiResponse<List<TopDonor>>;
      if (donorsResponse.success && donorsResponse.data != null) {
        _topDonors = donorsResponse.data!;
      }

      // Process recent activity
      final activityResponse = results[6] as ApiResponse<List<RecentActivity>>;
      if (activityResponse.success && activityResponse.data != null) {
        _recentActivity = activityResponse.data!;
      }

      // Process platform stats
      final statsResponse = results[7] as ApiResponse<PlatformStats>;
      if (statsResponse.success && statsResponse.data != null) {
        _platformStats = statsResponse.data;
      }

      _lastUpdated = DateTime.now();
    } catch (e) {
      _error = 'Error loading analytics data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh analytics data
  Future<void> refresh() async {
    await loadAllAnalytics();
  }

  /// Load platform overview only
  Future<void> loadOverview() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AnalyticsService.getOverview();
      if (response.success && response.data != null) {
        _overview = response.data;
        _lastUpdated = DateTime.now();
      } else {
        _error = response.error ?? 'Failed to load overview';
      }
    } catch (e) {
      _error = 'Error loading overview: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load donation trends
  Future<void> loadDonationTrends({int days = 30}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AnalyticsService.getDonationTrends(days: days);
      if (response.success && response.data != null) {
        _donationTrends = response.data!;
      } else {
        _error = response.error ?? 'Failed to load donation trends';
      }
    } catch (e) {
      _error = 'Error loading donation trends: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load user growth data
  Future<void> loadUserGrowth({int days = 30}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AnalyticsService.getUserGrowth(days: days);
      if (response.success && response.data != null) {
        _userGrowth = response.data!;
      } else {
        _error = response.error ?? 'Failed to load user growth';
      }
    } catch (e) {
      _error = 'Error loading user growth: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load category distribution
  Future<void> loadCategoryDistribution() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AnalyticsService.getCategoryDistribution();
      if (response.success && response.data != null) {
        _categoryDistribution = response.data!;
      } else {
        _error = response.error ?? 'Failed to load category distribution';
      }
    } catch (e) {
      _error = 'Error loading category distribution: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load status distribution
  Future<void> loadStatusDistribution() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AnalyticsService.getStatusDistribution();
      if (response.success && response.data != null) {
        _statusDistribution = response.data!;
      } else {
        _error = response.error ?? 'Failed to load status distribution';
      }
    } catch (e) {
      _error = 'Error loading status distribution: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load top donors
  Future<void> loadTopDonors({int limit = 10}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AnalyticsService.getTopDonors(limit: limit);
      if (response.success && response.data != null) {
        _topDonors = response.data!;
      } else {
        _error = response.error ?? 'Failed to load top donors';
      }
    } catch (e) {
      _error = 'Error loading top donors: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load recent activity
  Future<void> loadRecentActivity({int limit = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AnalyticsService.getRecentActivity(limit: limit);
      if (response.success && response.data != null) {
        _recentActivity = response.data!;
      } else {
        _error = response.error ?? 'Failed to load recent activity';
      }
    } catch (e) {
      _error = 'Error loading recent activity: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load platform stats
  Future<void> loadPlatformStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AnalyticsService.getPlatformStats();
      if (response.success && response.data != null) {
        _platformStats = response.data;
        _lastUpdated = DateTime.now();
      } else {
        _error = response.error ?? 'Failed to load platform stats';
      }
    } catch (e) {
      _error = 'Error loading platform stats: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get total users
  int get totalUsers => _overview?.users.total ?? 0;

  /// Get total donations
  int get totalDonations => _overview?.donations.total ?? 0;

  /// Get total requests
  int get totalRequests => _overview?.requests.total ?? 0;

  /// Get completion rate (completed donations / total donations)
  double get completionRate {
    if (_platformStats != null) {
      return _platformStats!.completionRate;
    }
    if (_overview != null && _overview!.donations.total > 0) {
      return (_overview!.donations.completed / _overview!.donations.total);
    }
    return 0.0;
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _overview = null;
    _donationTrends = [];
    _userGrowth = [];
    _categoryDistribution = [];
    _statusDistribution = [];
    _topDonors = [];
    _recentActivity = [];
    _platformStats = null;
    _error = null;
    _lastUpdated = null;
    notifyListeners();
  }
}
