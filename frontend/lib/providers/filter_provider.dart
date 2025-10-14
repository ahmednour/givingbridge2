import 'package:flutter/foundation.dart';

/// Provider for managing filter state across screens
class FilterProvider extends ChangeNotifier {
  // Search and Filter State
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedLocation;
  String? _selectedCondition;
  String? _selectedStatus;
  bool? _availableFilter;
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';
  int _pageSize = 20;

  // Getters
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  String? get selectedLocation => _selectedLocation;
  String? get selectedCondition => _selectedCondition;
  String? get selectedStatus => _selectedStatus;
  bool? get availableFilter => _availableFilter;
  String get sortBy => _sortBy;
  String get sortOrder => _sortOrder;
  int get pageSize => _pageSize;

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Set category filter
  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Set location filter
  void setLocation(String? location) {
    _selectedLocation = location;
    notifyListeners();
  }

  /// Set condition filter
  void setCondition(String? condition) {
    _selectedCondition = condition;
    notifyListeners();
  }

  /// Set status filter
  void setStatus(String? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  /// Set availability filter
  void setAvailable(bool? available) {
    _availableFilter = available;
    notifyListeners();
  }

  /// Set sort options
  void setSort(String sortBy, String sortOrder) {
    _sortBy = sortBy;
    _sortOrder = sortOrder;
    notifyListeners();
  }

  /// Set page size
  void setPageSize(int size) {
    _pageSize = size;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedLocation = null;
    _selectedCondition = null;
    _selectedStatus = null;
    _availableFilter = null;
    _sortBy = 'createdAt';
    _sortOrder = 'desc';
    notifyListeners();
  }

  /// Clear search only
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Clear category filter
  void clearCategory() {
    _selectedCategory = null;
    notifyListeners();
  }

  /// Clear location filter
  void clearLocation() {
    _selectedLocation = null;
    notifyListeners();
  }

  /// Clear condition filter
  void clearCondition() {
    _selectedCondition = null;
    notifyListeners();
  }

  /// Clear status filter
  void clearStatus() {
    _selectedStatus = null;
    notifyListeners();
  }

  /// Clear availability filter
  void clearAvailable() {
    _availableFilter = null;
    notifyListeners();
  }

  /// Check if any filters are active
  bool get hasActiveFilters {
    return _searchQuery.isNotEmpty ||
        _selectedCategory != null ||
        _selectedLocation != null ||
        _selectedCondition != null ||
        _selectedStatus != null ||
        _availableFilter != null;
  }

  /// Get active filters count
  int get activeFiltersCount {
    int count = 0;
    if (_searchQuery.isNotEmpty) count++;
    if (_selectedCategory != null) count++;
    if (_selectedLocation != null) count++;
    if (_selectedCondition != null) count++;
    if (_selectedStatus != null) count++;
    if (_availableFilter != null) count++;
    return count;
  }

  /// Get filter summary for display
  Map<String, dynamic> get filterSummary {
    return {
      'searchQuery': _searchQuery,
      'category': _selectedCategory,
      'location': _selectedLocation,
      'condition': _selectedCondition,
      'status': _selectedStatus,
      'available': _availableFilter,
      'sortBy': _sortBy,
      'sortOrder': _sortOrder,
      'pageSize': _pageSize,
      'hasActiveFilters': hasActiveFilters,
      'activeFiltersCount': activeFiltersCount,
    };
  }

  /// Apply filters from external source
  void applyFilters(Map<String, dynamic> filters) {
    _searchQuery = filters['searchQuery'] ?? '';
    _selectedCategory = filters['category'];
    _selectedLocation = filters['location'];
    _selectedCondition = filters['condition'];
    _selectedStatus = filters['status'];
    _availableFilter = filters['available'];
    _sortBy = filters['sortBy'] ?? 'createdAt';
    _sortOrder = filters['sortOrder'] ?? 'desc';
    _pageSize = filters['pageSize'] ?? 20;
    notifyListeners();
  }

  /// Reset to default values
  void reset() {
    clearFilters();
  }
}
