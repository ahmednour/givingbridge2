import 'package:flutter/foundation.dart';

class FilterProvider extends ChangeNotifier {
  // Search
  String _searchQuery = '';

  // Categories and statuses
  List<String> _selectedCategories = [];
  List<String> _selectedStatuses = [];
  List<String> _selectedLocations = [];

  // Date range
  DateTime? _startDate;
  DateTime? _endDate;

  // Amount range
  double? _minAmount;
  double? _maxAmount;

  // Flags
  bool _verifiedOnly = false;
  bool _urgentOnly = false;

  // Location
  double? _distance;
  String? _selectedDistance;

  // Conditions
  List<String> _selectedConditions = [];

  // Sorting and pagination
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';
  int _pageSize = 20;

  // Presets
  Map<String, Map<String, dynamic>> _savedFilterPresets = {};

  // Search suggestions and history
  List<SearchSuggestion> _searchSuggestions = [];
  List<SearchHistoryItem> _searchHistory = [];
  List<PopularSearchTerm> _popularTerms = [];
  bool _isLoadingSuggestions = false;
  bool _isLoadingHistory = false;

  // Getters
  String get searchQuery => _searchQuery;
  List<String> get selectedCategories => _selectedCategories;
  List<String> get selectedStatuses => _selectedStatuses;
  List<String> get selectedLocations => _selectedLocations;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  double? get minAmount => _minAmount;
  double? get maxAmount => _maxAmount;
  bool get verifiedOnly => _verifiedOnly;
  bool get urgentOnly => _urgentOnly;
  double? get distance => _distance;
  String? get selectedDistance => _selectedDistance;
  List<String> get selectedConditions => _selectedConditions;
  String get sortBy => _sortBy;
  String get sortOrder => _sortOrder;
  int get pageSize => _pageSize;
  Map<String, Map<String, dynamic>> get savedFilterPresets =>
      _savedFilterPresets;
  List<SearchSuggestion> get searchSuggestions => _searchSuggestions;
  List<SearchHistoryItem> get searchHistory => _searchHistory;
  List<PopularSearchTerm> get popularTerms => _popularTerms;
  bool get isLoadingSuggestions => _isLoadingSuggestions;
  bool get isLoadingHistory => _isLoadingHistory;

  bool get hasActiveFilters {
    return _searchQuery.isNotEmpty ||
        _selectedCategories.isNotEmpty ||
        _selectedStatuses.isNotEmpty ||
        _selectedLocations.isNotEmpty ||
        _startDate != null ||
        _endDate != null ||
        _minAmount != null ||
        _maxAmount != null ||
        _verifiedOnly ||
        _urgentOnly ||
        _distance != null;
  }

  int get activeFiltersCount {
    int count = 0;
    if (_searchQuery.isNotEmpty) count++;
    if (_selectedCategories.isNotEmpty) count++;
    if (_selectedStatuses.isNotEmpty) count++;
    if (_selectedLocations.isNotEmpty) count++;
    if (_startDate != null || _endDate != null) count++;
    if (_minAmount != null || _maxAmount != null) count++;
    if (_verifiedOnly) count++;
    if (_urgentOnly) count++;
    if (_distance != null) count++;
    return count;
  }

  Map<String, dynamic> get filterSummary {
    return {
      'searchQuery': _searchQuery,
      'categories': _selectedCategories,
      'statuses': _selectedStatuses,
      'locations': _selectedLocations,
      'startDate': _startDate?.toString().split(' ')[0],
      'endDate': _endDate?.toString().split(' ')[0],
      'minAmount': _minAmount,
      'maxAmount': _maxAmount,
      'verifiedOnly': _verifiedOnly,
      'urgentOnly': _urgentOnly,
      'distance': _distance,
      'sortBy': _sortBy,
      'sortOrder': _sortOrder,
      'pageSize': _pageSize,
    };
  }

  // Setters
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategories(List<String> categories) {
    _selectedCategories = categories;
    notifyListeners();
  }

  void setStatuses(List<String> statuses) {
    _selectedStatuses = statuses;
    notifyListeners();
  }

  void setLocations(List<String> locations) {
    _selectedLocations = locations;
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void setAmountRange(double? min, double? max) {
    _minAmount = min;
    _maxAmount = max;
    notifyListeners();
  }

  void setVerifiedOnly(bool value) {
    _verifiedOnly = value;
    notifyListeners();
  }

  void setUrgentOnly(bool value) {
    _urgentOnly = value;
    notifyListeners();
  }

  void setDistance(String? value) {
    _selectedDistance = value;
    _distance = value != null && value != 'any' ? double.tryParse(value) : null;
    notifyListeners();
  }

  void setConditions(List<String> conditions) {
    _selectedConditions = conditions;
    notifyListeners();
  }

  void setSortBy(String value) {
    _sortBy = value;
    notifyListeners();
  }

  void setSortOrder(String value) {
    _sortOrder = value;
    notifyListeners();
  }

  void setSort(String sortBy, String sortOrder) {
    _sortBy = sortBy;
    _sortOrder = sortOrder;
    notifyListeners();
  }

  void setPageSize(int value) {
    _pageSize = value;
    notifyListeners();
  }

  void clearDateRange() {
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  void clearAmountRange() {
    _minAmount = null;
    _maxAmount = null;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void removeCategory(String category) {
    _selectedCategories.remove(category);
    notifyListeners();
  }

  void removeStatus(String status) {
    _selectedStatuses.remove(status);
    notifyListeners();
  }

  void removeLocation(String location) {
    _selectedLocations.remove(location);
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategories = [];
    _selectedStatuses = [];
    _selectedLocations = [];
    _selectedConditions = [];
    _startDate = null;
    _endDate = null;
    _minAmount = null;
    _maxAmount = null;
    _verifiedOnly = false;
    _urgentOnly = false;
    _distance = null;
    _selectedDistance = null;
    notifyListeners();
  }

  void initialize() {
    // Initialize with default values if needed
    notifyListeners();
  }

  // Preset management
  Future<void> saveFilterPreset(String name) async {
    _savedFilterPresets[name] = {
      'searchQuery': _searchQuery,
      'categories': List<String>.from(_selectedCategories),
      'statuses': List<String>.from(_selectedStatuses),
      'locations': List<String>.from(_selectedLocations),
      'conditions': List<String>.from(_selectedConditions),
      'startDate': _startDate?.toIso8601String(),
      'endDate': _endDate?.toIso8601String(),
      'minAmount': _minAmount,
      'maxAmount': _maxAmount,
      'verifiedOnly': _verifiedOnly,
      'urgentOnly': _urgentOnly,
      'distance': _distance,
      'selectedDistance': _selectedDistance,
      'sortBy': _sortBy,
      'sortOrder': _sortOrder,
    };
    notifyListeners();
  }

  void loadFilterPreset(String name) {
    final preset = _savedFilterPresets[name];
    if (preset == null) return;

    _searchQuery = preset['searchQuery'] ?? '';
    _selectedCategories = List<String>.from(preset['categories'] ?? []);
    _selectedStatuses = List<String>.from(preset['statuses'] ?? []);
    _selectedLocations = List<String>.from(preset['locations'] ?? []);
    _selectedConditions = List<String>.from(preset['conditions'] ?? []);
    _startDate = preset['startDate'] != null
        ? DateTime.parse(preset['startDate'])
        : null;
    _endDate =
        preset['endDate'] != null ? DateTime.parse(preset['endDate']) : null;
    _minAmount = preset['minAmount'];
    _maxAmount = preset['maxAmount'];
    _verifiedOnly = preset['verifiedOnly'] ?? false;
    _urgentOnly = preset['urgentOnly'] ?? false;
    _distance = preset['distance'];
    _selectedDistance = preset['selectedDistance'];
    _sortBy = preset['sortBy'] ?? 'createdAt';
    _sortOrder = preset['sortOrder'] ?? 'desc';
    notifyListeners();
  }

  Future<void> deleteFilterPreset(String name) async {
    _savedFilterPresets.remove(name);
    notifyListeners();
  }

  // Search suggestions methods
  Future<void> getSearchSuggestions(String query, {String type = 'all'}) async {
    if (query.length < 2) {
      _searchSuggestions = [];
      notifyListeners();
      return;
    }

    _isLoadingSuggestions = true;
    notifyListeners();

    try {
      // Simulate API call - replace with actual SearchService call
      await Future.delayed(const Duration(milliseconds: 300));

      // Mock suggestions
      _searchSuggestions = [
        SearchSuggestion(
          text: query,
          type: 'donation_title',
          category: 'food',
        ),
      ];
    } catch (e) {
      if (kDebugMode) {
        print('Error getting search suggestions: $e');
      }
      _searchSuggestions = [];
    } finally {
      _isLoadingSuggestions = false;
      notifyListeners();
    }
  }

  void clearSearchSuggestions() {
    _searchSuggestions = [];
    notifyListeners();
  }

  Future<void> loadSearchHistory() async {
    _isLoadingHistory = true;
    notifyListeners();

    try {
      // Simulate API call - replace with actual SearchService call
      await Future.delayed(const Duration(milliseconds: 200));

      // Mock history
      _searchHistory = [];
    } catch (e) {
      if (kDebugMode) {
        print('Error loading search history: $e');
      }
      _searchHistory = [];
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<bool> clearSearchHistory() async {
    try {
      // Simulate API call - replace with actual SearchService call
      await Future.delayed(const Duration(milliseconds: 200));

      _searchHistory = [];
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing search history: $e');
      }
      return false;
    }
  }

  Future<void> loadPopularTerms() async {
    try {
      // Simulate API call - replace with actual SearchService call
      await Future.delayed(const Duration(milliseconds: 200));

      // Mock popular terms
      _popularTerms = [];
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading popular terms: $e');
      }
      _popularTerms = [];
    }
  }
}

// Model classes for search functionality
class SearchSuggestion {
  final String text;
  final String type;
  final String category;
  final String? location;

  SearchSuggestion({
    required this.text,
    required this.type,
    required this.category,
    this.location,
  });
}

class SearchHistoryItem {
  final String term;
  final DateTime lastSearched;

  SearchHistoryItem({
    required this.term,
    required this.lastSearched,
  });
}

class PopularSearchTerm {
  final String searchTerm;
  final int searchCount;

  PopularSearchTerm({
    required this.searchTerm,
    required this.searchCount,
  });
}
