import 'package:flutter/foundation.dart';
import '../repositories/request_repository.dart';
import '../core/constants/api_constants.dart';

/// Provider for managing request state and operations
class RequestProvider extends ChangeNotifier {
  final RequestRepository _repository = RequestRepository();

  // State
  List<dynamic> _requests = [];
  List<dynamic> _myRequests = [];
  List<dynamic> _incomingRequests = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = false;
  bool _isLoadingMyRequests = false;
  bool _isLoadingIncomingRequests = false;
  bool _isLoadingStats = false;
  String? _error;
  String? _statusFilter;
  int _currentPage = 1;
  bool _hasMoreData = true;

  // Getters
  List<dynamic> get requests => _requests;
  List<dynamic> get myRequests => _myRequests;
  List<dynamic> get incomingRequests => _incomingRequests;
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  bool get isLoadingMyRequests => _isLoadingMyRequests;
  bool get isLoadingIncomingRequests => _isLoadingIncomingRequests;
  bool get isLoadingStats => _isLoadingStats;
  String? get error => _error;
  String? get statusFilter => _statusFilter;
  int get currentPage => _currentPage;
  bool get hasMoreData => _hasMoreData;

  // Filtered requests based on current filters
  List<dynamic> get filteredRequests {
    List<dynamic> filtered = List.from(_requests);

    if (_statusFilter != null) {
      filtered = filtered
          .where((request) => request['status'] == _statusFilter)
          .toList();
    }

    return filtered;
  }

  List<dynamic> get filteredMyRequests {
    List<dynamic> filtered = List.from(_myRequests);

    if (_statusFilter != null) {
      filtered = filtered
          .where((request) => request['status'] == _statusFilter)
          .toList();
    }

    return filtered;
  }

  List<dynamic> get filteredIncomingRequests {
    List<dynamic> filtered = List.from(_incomingRequests);

    if (_statusFilter != null) {
      filtered = filtered
          .where((request) => request['status'] == _statusFilter)
          .toList();
    }

    return filtered;
  }

  /// Load all requests
  Future<void> loadRequests({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _requests.clear();
    }

    if (!_hasMoreData) return;

    _setLoading(true);
    _clearError();

    try {
      final response = await _repository.getRequests(
        status: _statusFilter,
        page: _currentPage,
        limit: APIConstants.defaultLimit,
      );

      if (response.success && response.data != null) {
        if (refresh) {
          _requests = response.data!;
        } else {
          _requests.addAll(response.data!);
        }

        _hasMoreData = response.data!.length == APIConstants.defaultLimit;
        _currentPage++;
        notifyListeners();
      } else {
        _setError(response.error ?? 'Failed to load requests');
      }
    } catch (e) {
      _setError('Error loading requests: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Load my requests (as receiver)
  Future<void> loadMyRequests({bool refresh = false}) async {
    _setLoadingMyRequests(true);
    _clearError();

    try {
      final response = await _repository.getMyRequests(
        status: _statusFilter,
        page: 1,
        limit: APIConstants.maxLimit,
      );

      if (response.success && response.data != null) {
        _myRequests = response.data!;
        notifyListeners();
      } else {
        _setError(response.error ?? 'Failed to load your requests');
      }
    } catch (e) {
      _setError('Error loading your requests: ${e.toString()}');
    } finally {
      _setLoadingMyRequests(false);
    }
  }

  /// Load incoming requests (as donor)
  Future<void> loadIncomingRequests({bool refresh = false}) async {
    _setLoadingIncomingRequests(true);
    _clearError();

    try {
      final response = await _repository.getIncomingRequests(
        status: _statusFilter,
        page: 1,
        limit: APIConstants.maxLimit,
      );

      if (response.success && response.data != null) {
        _incomingRequests = response.data!;
        notifyListeners();
      } else {
        _setError(response.error ?? 'Failed to load incoming requests');
      }
    } catch (e) {
      _setError('Error loading incoming requests: ${e.toString()}');
    } finally {
      _setLoadingIncomingRequests(false);
    }
  }

  /// Load request statistics
  Future<void> loadStats() async {
    _setLoadingStats(true);
    _clearError();

    try {
      final response = await _repository.getRequestStats();

      if (response.success && response.data != null) {
        _stats = response.data!;
        notifyListeners();
      } else {
        _setError(response.error ?? 'Failed to load statistics');
      }
    } catch (e) {
      _setError('Error loading statistics: ${e.toString()}');
    } finally {
      _setLoadingStats(false);
    }
  }

  /// Create new request
  Future<bool> createRequest({
    required String donationId,
    String? message,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _repository.createRequest(
        donationId: donationId,
        message: message,
      );

      if (response.success && response.data != null) {
        _myRequests.insert(0, response.data!);
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to create request');
        return false;
      }
    } catch (e) {
      _setError('Error creating request: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update request status
  Future<bool> updateRequestStatus({
    required String requestId,
    required String status,
    String? responseMessage,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _repository.updateRequestStatus(
        requestId: requestId,
        status: status,
        responseMessage: responseMessage,
      );

      if (response.success && response.data != null) {
        // Update in requests list
        final index =
            _requests.indexWhere((r) => r['id'].toString() == requestId);
        if (index != -1) {
          _requests[index] = response.data!;
        }

        // Update in my requests list
        final myIndex =
            _myRequests.indexWhere((r) => r['id'].toString() == requestId);
        if (myIndex != -1) {
          _myRequests[myIndex] = response.data!;
        }

        // Update in incoming requests list
        final incomingIndex = _incomingRequests
            .indexWhere((r) => r['id'].toString() == requestId);
        if (incomingIndex != -1) {
          _incomingRequests[incomingIndex] = response.data!;
        }

        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to update request');
        return false;
      }
    } catch (e) {
      _setError('Error updating request: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete request
  Future<bool> deleteRequest(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _repository.deleteRequest(id);

      if (response.success) {
        _requests.removeWhere((r) => r['id'].toString() == id);
        _myRequests.removeWhere((r) => r['id'].toString() == id);
        _incomingRequests.removeWhere((r) => r['id'].toString() == id);
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to delete request');
        return false;
      }
    } catch (e) {
      _setError('Error deleting request: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Set status filter
  void setStatusFilter(String? status) {
    _statusFilter = status;
    _currentPage = 1;
    _hasMoreData = true;
    _requests.clear();
    loadRequests(refresh: true);
  }

  /// Clear filters
  void clearFilters() {
    _statusFilter = null;
    _currentPage = 1;
    _hasMoreData = true;
    _requests.clear();
    loadRequests(refresh: true);
  }

  /// Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadRequests(refresh: true),
      loadMyRequests(refresh: true),
      loadIncomingRequests(refresh: true),
      loadStats(),
    ]);
  }

  /// Get request by ID
  dynamic getRequestById(String id) {
    try {
      return _requests.firstWhere((r) => r['id'].toString() == id);
    } catch (e) {
      try {
        return _myRequests.firstWhere((r) => r['id'].toString() == id);
      } catch (e) {
        return _incomingRequests.firstWhere((r) => r['id'].toString() == id);
      }
    }
  }

  /// Get requests by donation ID
  List<dynamic> getRequestsByDonationId(String donationId) {
    return _requests
        .where((r) => r['donationId'].toString() == donationId)
        .toList();
  }

  /// Get pending requests count
  int get pendingRequestsCount {
    return _incomingRequests.where((r) => r['status'] == 'pending').length;
  }

  /// Get my pending requests count
  int get myPendingRequestsCount {
    return _myRequests.where((r) => r['status'] == 'pending').length;
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingMyRequests(bool loading) {
    _isLoadingMyRequests = loading;
    notifyListeners();
  }

  void _setLoadingIncomingRequests(bool loading) {
    _isLoadingIncomingRequests = loading;
    notifyListeners();
  }

  void _setLoadingStats(bool loading) {
    _isLoadingStats = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
