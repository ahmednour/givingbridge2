import 'package:flutter/foundation.dart';
import '../models/donation.dart';
import '../repositories/donation_repository.dart';
import '../core/constants/donation_constants.dart';

/// Provider for managing donation state and operations
class DonationProvider extends ChangeNotifier {
  final DonationRepository _repository = DonationRepository();

  // State
  List<Donation> _donations = [];
  List<Donation> _myDonations = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = false;
  bool _isLoadingMyDonations = false;
  bool _isLoadingStats = false;
  String? _error;
  String? _searchQuery;
  String? _selectedCategory;
  String? _selectedLocation;
  bool? _availableFilter;
  int _currentPage = 1;
  bool _hasMoreData = true;

  // Getters
  List<Donation> get donations => _donations;
  List<Donation> get myDonations => _myDonations;
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  bool get isLoadingMyDonations => _isLoadingMyDonations;
  bool get isLoadingStats => _isLoadingStats;
  String? get error => _error;
  String? get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  String? get selectedLocation => _selectedLocation;
  bool? get availableFilter => _availableFilter;
  int get currentPage => _currentPage;
  bool get hasMoreData => _hasMoreData;

  // Filtered donations based on current filters
  List<Donation> get filteredDonations {
    List<Donation> filtered = List.from(_donations);

    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      filtered = filtered
          .where((donation) =>
              donation.title
                  .toLowerCase()
                  .contains(_searchQuery!.toLowerCase()) ||
              donation.description
                  .toLowerCase()
                  .contains(_searchQuery!.toLowerCase()) ||
              donation.location
                  .toLowerCase()
                  .contains(_searchQuery!.toLowerCase()))
          .toList();
    }

    if (_selectedCategory != null) {
      filtered = filtered
          .where((donation) => donation.category == _selectedCategory)
          .toList();
    }

    if (_selectedLocation != null && _selectedLocation!.isNotEmpty) {
      filtered = filtered
          .where((donation) => donation.location
              .toLowerCase()
              .contains(_selectedLocation!.toLowerCase()))
          .toList();
    }

    if (_availableFilter != null) {
      filtered = filtered
          .where((donation) => donation.isAvailable == _availableFilter)
          .toList();
    }

    return filtered;
  }

  /// Load all donations
  Future<void> loadDonations({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _donations.clear();
    }

    if (!_hasMoreData) return;

    _setLoading(true);
    _clearError();

    try {
      final response = await _repository.getDonations(
        category: _selectedCategory,
        location: _selectedLocation,
        available: _availableFilter,
        page: _currentPage,
        limit: DonationConstants.defaultPageSize,
      );

      if (response.success && response.data != null) {
        if (refresh) {
          _donations = response.data!;
        } else {
          _donations.addAll(response.data!);
        }

        _hasMoreData =
            response.data!.length == DonationConstants.defaultPageSize;
        _currentPage++;
        notifyListeners();
      } else {
        _setError(response.error ?? 'Failed to load donations');
      }
    } catch (e) {
      _setError('Error loading donations: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Load more donations (pagination)
  Future<void> loadMoreDonations() async {
    if (!_isLoading && _hasMoreData) {
      await loadDonations();
    }
  }

  /// Load my donations
  Future<void> loadMyDonations() async {
    _setLoadingMyDonations(true);
    _clearError();

    try {
      final response = await _repository.getMyDonations();

      if (response.success && response.data != null) {
        _myDonations = response.data!;
        notifyListeners();
      } else {
        _setError(response.error ?? 'Failed to load your donations');
      }
    } catch (e) {
      _setError('Error loading your donations: ${e.toString()}');
    } finally {
      _setLoadingMyDonations(false);
    }
  }

  /// Load donation statistics
  Future<void> loadStats() async {
    _setLoadingStats(true);
    _clearError();

    try {
      final response = await _repository.getDonationStats();

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

  /// Create new donation
  Future<bool> createDonation({
    required String title,
    required String description,
    required String category,
    required String condition,
    required String location,
    String? imagePath,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _repository.createDonation(
        title: title,
        description: description,
        category: category,
        condition: condition,
        location: location,
        imagePath: imagePath,
      );

      if (response.success && response.data != null) {
        _myDonations.insert(0, response.data!);
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to create donation');
        return false;
      }
    } catch (e) {
      _setError('Error creating donation: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update donation
  Future<bool> updateDonation({
    required String id,
    String? title,
    String? description,
    String? category,
    String? condition,
    String? location,
    String? imagePath,
    bool? isAvailable,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _repository.updateDonation(
        id: id,
        title: title,
        description: description,
        category: category,
        condition: condition,
        location: location,
        imagePath: imagePath,
        isAvailable: isAvailable,
      );

      if (response.success && response.data != null) {
        // Update in donations list
        final index = _donations.indexWhere((d) => d.id.toString() == id);
        if (index != -1) {
          _donations[index] = response.data!;
        }

        // Update in my donations list
        final myIndex = _myDonations.indexWhere((d) => d.id.toString() == id);
        if (myIndex != -1) {
          _myDonations[myIndex] = response.data!;
        }

        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to update donation');
        return false;
      }
    } catch (e) {
      _setError('Error updating donation: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete donation
  Future<bool> deleteDonation(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _repository.deleteDonation(id);

      if (response.success) {
        _donations.removeWhere((d) => d.id.toString() == id);
        _myDonations.removeWhere((d) => d.id.toString() == id);
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to delete donation');
        return false;
      }
    } catch (e) {
      _setError('Error deleting donation: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Search donations
  Future<void> searchDonations(String query) async {
    _searchQuery = query;
    _currentPage = 1;
    _hasMoreData = true;
    _donations.clear();

    if (query.isEmpty) {
      await loadDonations(refresh: true);
    } else {
      await loadDonations(refresh: true);
    }
  }

  /// Set category filter
  void setCategoryFilter(String? category) {
    _selectedCategory = category;
    _currentPage = 1;
    _hasMoreData = true;
    _donations.clear();
    loadDonations(refresh: true);
  }

  /// Set location filter
  void setLocationFilter(String? location) {
    _selectedLocation = location;
    _currentPage = 1;
    _hasMoreData = true;
    _donations.clear();
    loadDonations(refresh: true);
  }

  /// Set availability filter
  void setAvailabilityFilter(bool? available) {
    _availableFilter = available;
    _currentPage = 1;
    _hasMoreData = true;
    _donations.clear();
    loadDonations(refresh: true);
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = null;
    _selectedCategory = null;
    _selectedLocation = null;
    _availableFilter = null;
    _currentPage = 1;
    _hasMoreData = true;
    _donations.clear();
    loadDonations(refresh: true);
  }

  /// Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadDonations(refresh: true),
      loadMyDonations(),
      loadStats(),
    ]);
  }

  /// Get donation by ID
  Donation? getDonationById(String id) {
    try {
      return _donations.firstWhere((d) => d.id.toString() == id);
    } catch (e) {
      return _myDonations.firstWhere((d) => d.id.toString() == id);
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingMyDonations(bool loading) {
    _isLoadingMyDonations = loading;
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
