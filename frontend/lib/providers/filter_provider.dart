import 'package:flutter/foundation.dart';
import '../services/cache_service.dart';
import '../services/search_service.dart';

/// Provider for managing filter state across screens
class FilterProvider extends ChangeNotifier {
  // Search and Filter State
  String _searchQuery = '';
  List<String> _selectedCategories = [];
  List<String> _selectedLocations = [];
  List<String> _selectedConditions = [];
  List<String> _selectedStatuses = [];
  bool? _availableFilter;
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';
  int _pageSize = 20;
  
  // Date range filters
  DateTime? _startDate;
  DateTime? _endDate;
  
  // Amount range filters
  double? _minAmount;
  double? _maxAmount;
  
  // Advanced filters
  bool _verifiedOnly = false;
  bool _urgentOnly = false;
  String? _selectedDistance;
  
  // Filter persistence
  final CacheService _cacheService = CacheService();
  final SearchService _searchService = SearchService();
  static const String _filterCacheKey = 'saved_filters';
  static const String _activeFilterCacheKey = 'active_filters';
  
  // Filter presets
  Map<String, Map<String, dynamic>> _savedFilterPresets = {};
  
  // Search suggestions and history
  List<SearchSuggestion> _searchSuggestions = [];
  List<SearchHistoryItem> _searchHistory = [];
  List<PopularSearchTerm> _popularTerms = [];
  bool _isLoadingSuggestions = false;
  bool _isLoadingHistory = false;
  
  bool _isInitialized = false;

  // Getters
  String get searchQuery => _searchQuery;
  List<String> get selectedCategories => List.unmodifiable(_selectedCategories);
  List<String> get selectedLocations => List.unmodifiable(_selectedLocations);
  List<String> get selectedConditions => List.unmodifiable(_selectedConditions);
  List<String> get selectedStatuses => List.unmodifiable(_selectedStatuses);
  bool? get availableFilter => _availableFilter;
  String get sortBy => _sortBy;
  String get sortOrder => _sortOrder;
  int get pageSize => _pageSize;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  double? get minAmount => _minAmount;
  double? get maxAmount => _maxAmount;
  bool get verifiedOnly => _verifiedOnly;
  bool get urgentOnly => _urgentOnly;
  String? get selectedDistance => _selectedDistance;
  Map<String, Map<String, dynamic>> get savedFilterPresets => Map.unmodifiable(_savedFilterPresets);
  bool get isInitialized => _isInitialized;
  
  // Search suggestions and history getters
  List<SearchSuggestion> get searchSuggestions => List.unmodifiable(_searchSuggestions);
  List<SearchHistoryItem> get searchHistory => List.unmodifiable(_searchHistory);
  List<PopularSearchTerm> get popularTerms => List.unmodifiable(_popularTerms);
  bool get isLoadingSuggestions => _isLoadingSuggestions;
  bool get isLoadingHistory => _isLoadingHistory;
  
  // Legacy getters for backward compatibility
  String? get selectedCategory => _selectedCategories.isNotEmpty ? _selectedCategories.first : null;
  String? get selectedLocation => _selectedLocations.isNotEmpty ? _selectedLocations.first : null;
  String? get selectedCondition => _selectedConditions.isNotEmpty ? _selectedConditions.first : null;
  String? get selectedStatus => _selectedStatuses.isNotEmpty ? _selectedStatuses.first : null;

  /// Initialize the filter provider and load saved filters
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _loadSavedFilters();
    await _loadActiveFilters();
    _isInitialized = true;
    notifyListeners();
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _saveActiveFilters();
    
    // Add to search history if not empty
    if (query.trim().isNotEmpty) {
      _searchService.addToLocalHistory(query.trim());
    }
    
    notifyListeners();
  }

  /// Set multiple categories
  void setCategories(List<String> categories) {
    _selectedCategories = List.from(categories);
    _saveActiveFilters();
    notifyListeners();
  }

  /// Add category to selection
  void addCategory(String category) {
    if (!_selectedCategories.contains(category)) {
      _selectedCategories.add(category);
      _saveActiveFilters();
      notifyListeners();
    }
  }

  /// Remove category from selection
  void removeCategory(String category) {
    _selectedCategories.remove(category);
    _saveActiveFilters();
    notifyListeners();
  }

  /// Toggle category selection
  void toggleCategory(String category) {
    if (_selectedCategories.contains(category)) {
      removeCategory(category);
    } else {
      addCategory(category);
    }
  }

  /// Set multiple locations
  void setLocations(List<String> locations) {
    _selectedLocations = List.from(locations);
    _saveActiveFilters();
    notifyListeners();
  }

  /// Add location to selection
  void addLocation(String location) {
    if (!_selectedLocations.contains(location)) {
      _selectedLocations.add(location);
      _saveActiveFilters();
      notifyListeners();
    }
  }

  /// Remove location from selection
  void removeLocation(String location) {
    _selectedLocations.remove(location);
    _saveActiveFilters();
    notifyListeners();
  }

  /// Toggle location selection
  void toggleLocation(String location) {
    if (_selectedLocations.contains(location)) {
      removeLocation(location);
    } else {
      addLocation(location);
    }
  }

  /// Set multiple conditions
  void setConditions(List<String> conditions) {
    _selectedConditions = List.from(conditions);
    _saveActiveFilters();
    notifyListeners();
  }

  /// Add condition to selection
  void addCondition(String condition) {
    if (!_selectedConditions.contains(condition)) {
      _selectedConditions.add(condition);
      _saveActiveFilters();
      notifyListeners();
    }
  }

  /// Remove condition from selection
  void removeCondition(String condition) {
    _selectedConditions.remove(condition);
    _saveActiveFilters();
    notifyListeners();
  }

  /// Toggle condition selection
  void toggleCondition(String condition) {
    if (_selectedConditions.contains(condition)) {
      removeCondition(condition);
    } else {
      addCondition(condition);
    }
  }

  /// Set multiple statuses
  void setStatuses(List<String> statuses) {
    _selectedStatuses = List.from(statuses);
    _saveActiveFilters();
    notifyListeners();
  }

  /// Add status to selection
  void addStatus(String status) {
    if (!_selectedStatuses.contains(status)) {
      _selectedStatuses.add(status);
      _saveActiveFilters();
      notifyListeners();
    }
  }

  /// Remove status from selection
  void removeStatus(String status) {
    _selectedStatuses.remove(status);
    _saveActiveFilters();
    notifyListeners();
  }

  /// Toggle status selection
  void toggleStatus(String status) {
    if (_selectedStatuses.contains(status)) {
      removeStatus(status);
    } else {
      addStatus(status);
    }
  }

  /// Set availability filter
  void setAvailable(bool? available) {
    _availableFilter = available;
    _saveActiveFilters();
    notifyListeners();
  }

  /// Set date range filter
  void setDateRange(DateTime? startDate, DateTime? endDate) {
    _startDate = startDate;
    _endDate = endDate;
    _saveActiveFilters();
    notifyListeners();
  }

  /// Set amount range filter
  void setAmountRange(double? minAmount, double? maxAmount) {
    _minAmount = minAmount;
    _maxAmount = maxAmount;
    _saveActiveFilters();
    notifyListeners();
  }

  /// Set verified only filter
  void setVerifiedOnly(bool verifiedOnly) {
    _verifiedOnly = verifiedOnly;
    _saveActiveFilters();
    notifyListeners();
  }

  /// Set urgent only filter
  void setUrgentOnly(bool urgentOnly) {
    _urgentOnly = urgentOnly;
    _saveActiveFilters();
    notifyListeners();
  }

  /// Set distance filter
  void setDistance(String? distance) {
    _selectedDistance = distance;
    _saveActiveFilters();
    notifyListeners();
  }

  /// Set sort options
  void setSort(String sortBy, String sortOrder) {
    _sortBy = sortBy;
    _sortOrder = sortOrder;
    _saveActiveFilters();
    notifyListeners();
  }

  /// Set page size
  void setPageSize(int size) {
    _pageSize = size;
    _saveActiveFilters();
    notifyListeners();
  }

  // Legacy setters for backward compatibility
  void setCategory(String? category) {
    if (category != null) {
      setCategories([category]);
    } else {
      setCategories([]);
    }
  }

  void setLocation(String? location) {
    if (location != null) {
      setLocations([location]);
    } else {
      setLocations([]);
    }
  }

  void setCondition(String? condition) {
    if (condition != null) {
      setConditions([condition]);
    } else {
      setConditions([]);
    }
  }

  void setStatus(String? status) {
    if (status != null) {
      setStatuses([status]);
    } else {
      setStatuses([]);
    }
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategories.clear();
    _selectedLocations.clear();
    _selectedConditions.clear();
    _selectedStatuses.clear();
    _availableFilter = null;
    _startDate = null;
    _endDate = null;
    _minAmount = null;
    _maxAmount = null;
    _verifiedOnly = false;
    _urgentOnly = false;
    _selectedDistance = null;
    _sortBy = 'createdAt';
    _sortOrder = 'desc';
    _saveActiveFilters();
    notifyListeners();
  }

  /// Clear search only
  void clearSearch() {
    _searchQuery = '';
    _saveActiveFilters();
    notifyListeners();
  }

  /// Clear category filters
  void clearCategories() {
    _selectedCategories.clear();
    _saveActiveFilters();
    notifyListeners();
  }

  /// Clear location filters
  void clearLocations() {
    _selectedLocations.clear();
    _saveActiveFilters();
    notifyListeners();
  }

  /// Clear condition filters
  void clearConditions() {
    _selectedConditions.clear();
    _saveActiveFilters();
    notifyListeners();
  }

  /// Clear status filters
  void clearStatuses() {
    _selectedStatuses.clear();
    _saveActiveFilters();
    notifyListeners();
  }

  /// Clear availability filter
  void clearAvailable() {
    _availableFilter = null;
    _saveActiveFilters();
    notifyListeners();
  }

  /// Clear date range filter
  void clearDateRange() {
    _startDate = null;
    _endDate = null;
    _saveActiveFilters();
    notifyListeners();
  }

  /// Clear amount range filter
  void clearAmountRange() {
    _minAmount = null;
    _maxAmount = null;
    _saveActiveFilters();
    notifyListeners();
  }

  /// Clear advanced filters
  void clearAdvancedFilters() {
    _verifiedOnly = false;
    _urgentOnly = false;
    _selectedDistance = null;
    _saveActiveFilters();
    notifyListeners();
  }

  // Legacy clear methods for backward compatibility
  void clearCategory() => clearCategories();
  void clearLocation() => clearLocations();
  void clearCondition() => clearConditions();
  void clearStatus() => clearStatuses();

  /// Check if any filters are active
  bool get hasActiveFilters {
    return _searchQuery.isNotEmpty ||
        _selectedCategories.isNotEmpty ||
        _selectedLocations.isNotEmpty ||
        _selectedConditions.isNotEmpty ||
        _selectedStatuses.isNotEmpty ||
        _availableFilter != null ||
        _startDate != null ||
        _endDate != null ||
        _minAmount != null ||
        _maxAmount != null ||
        _verifiedOnly ||
        _urgentOnly ||
        _selectedDistance != null;
  }

  /// Get active filters count
  int get activeFiltersCount {
    int count = 0;
    if (_searchQuery.isNotEmpty) count++;
    if (_selectedCategories.isNotEmpty) count++;
    if (_selectedLocations.isNotEmpty) count++;
    if (_selectedConditions.isNotEmpty) count++;
    if (_selectedStatuses.isNotEmpty) count++;
    if (_availableFilter != null) count++;
    if (_startDate != null || _endDate != null) count++;
    if (_minAmount != null || _maxAmount != null) count++;
    if (_verifiedOnly) count++;
    if (_urgentOnly) count++;
    if (_selectedDistance != null) count++;
    return count;
  }

  /// Get detailed active filters breakdown
  Map<String, int> get activeFiltersBreakdown {
    return {
      'search': _searchQuery.isNotEmpty ? 1 : 0,
      'categories': _selectedCategories.length,
      'locations': _selectedLocations.length,
      'conditions': _selectedConditions.length,
      'statuses': _selectedStatuses.length,
      'availability': _availableFilter != null ? 1 : 0,
      'dateRange': (_startDate != null || _endDate != null) ? 1 : 0,
      'amountRange': (_minAmount != null || _maxAmount != null) ? 1 : 0,
      'verified': _verifiedOnly ? 1 : 0,
      'urgent': _urgentOnly ? 1 : 0,
      'distance': _selectedDistance != null ? 1 : 0,
    };
  }

  /// Get filter summary for display
  Map<String, dynamic> get filterSummary {
    return {
      'searchQuery': _searchQuery,
      'categories': _selectedCategories,
      'locations': _selectedLocations,
      'conditions': _selectedConditions,
      'statuses': _selectedStatuses,
      'available': _availableFilter,
      'startDate': _startDate?.toIso8601String(),
      'endDate': _endDate?.toIso8601String(),
      'minAmount': _minAmount,
      'maxAmount': _maxAmount,
      'verifiedOnly': _verifiedOnly,
      'urgentOnly': _urgentOnly,
      'distance': _selectedDistance,
      'sortBy': _sortBy,
      'sortOrder': _sortOrder,
      'pageSize': _pageSize,
      'hasActiveFilters': hasActiveFilters,
      'activeFiltersCount': activeFiltersCount,
      'activeFiltersBreakdown': activeFiltersBreakdown,
    };
  }

  /// Apply filters from external source
  void applyFilters(Map<String, dynamic> filters) {
    _searchQuery = filters['searchQuery'] ?? '';
    _selectedCategories = List<String>.from(filters['categories'] ?? []);
    _selectedLocations = List<String>.from(filters['locations'] ?? []);
    _selectedConditions = List<String>.from(filters['conditions'] ?? []);
    _selectedStatuses = List<String>.from(filters['statuses'] ?? []);
    _availableFilter = filters['available'];
    _startDate = filters['startDate'] != null ? DateTime.parse(filters['startDate']) : null;
    _endDate = filters['endDate'] != null ? DateTime.parse(filters['endDate']) : null;
    _minAmount = filters['minAmount']?.toDouble();
    _maxAmount = filters['maxAmount']?.toDouble();
    _verifiedOnly = filters['verifiedOnly'] ?? false;
    _urgentOnly = filters['urgentOnly'] ?? false;
    _selectedDistance = filters['distance'];
    _sortBy = filters['sortBy'] ?? 'createdAt';
    _sortOrder = filters['sortOrder'] ?? 'desc';
    _pageSize = filters['pageSize'] ?? 20;
    _saveActiveFilters();
    notifyListeners();
  }

  /// Save current filters as a preset
  Future<void> saveFilterPreset(String name) async {
    final preset = Map<String, dynamic>.from(filterSummary);
    preset.remove('hasActiveFilters');
    preset.remove('activeFiltersCount');
    preset.remove('activeFiltersBreakdown');
    
    _savedFilterPresets[name] = preset;
    await _saveSavedFilters();
    notifyListeners();
  }

  /// Load a saved filter preset
  void loadFilterPreset(String name) {
    final preset = _savedFilterPresets[name];
    if (preset != null) {
      applyFilters(preset);
    }
  }

  /// Delete a saved filter preset
  Future<void> deleteFilterPreset(String name) async {
    _savedFilterPresets.remove(name);
    await _saveSavedFilters();
    notifyListeners();
  }

  /// Get query parameters for API calls
  Map<String, dynamic> get queryParameters {
    final params = <String, dynamic>{};
    
    if (_searchQuery.isNotEmpty) params['search'] = _searchQuery;
    if (_selectedCategories.isNotEmpty) params['categories'] = _selectedCategories.join(',');
    if (_selectedLocations.isNotEmpty) params['locations'] = _selectedLocations.join(',');
    if (_selectedConditions.isNotEmpty) params['conditions'] = _selectedConditions.join(',');
    if (_selectedStatuses.isNotEmpty) params['statuses'] = _selectedStatuses.join(',');
    if (_availableFilter != null) params['available'] = _availableFilter.toString();
    if (_startDate != null) params['startDate'] = _startDate!.toIso8601String();
    if (_endDate != null) params['endDate'] = _endDate!.toIso8601String();
    if (_minAmount != null) params['minAmount'] = _minAmount.toString();
    if (_maxAmount != null) params['maxAmount'] = _maxAmount.toString();
    if (_verifiedOnly) params['verifiedOnly'] = 'true';
    if (_urgentOnly) params['urgentOnly'] = 'true';
    if (_selectedDistance != null) params['distance'] = _selectedDistance;
    
    params['sortBy'] = _sortBy;
    params['sortOrder'] = _sortOrder;
    params['pageSize'] = _pageSize.toString();
    
    return params;
  }

  /// Load saved filters from cache
  Future<void> _loadSavedFilters() async {
    try {
      final savedFilters = await _cacheService.retrieve<Map<String, dynamic>>(_filterCacheKey);
      if (savedFilters != null) {
        _savedFilterPresets = Map<String, Map<String, dynamic>>.from(
          savedFilters.map((key, value) => MapEntry(key, Map<String, dynamic>.from(value)))
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading saved filters: $e');
      }
    }
  }

  /// Save filter presets to cache
  Future<void> _saveSavedFilters() async {
    try {
      await _cacheService.store(_filterCacheKey, _savedFilterPresets, expiry: const Duration(days: 365));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving filter presets: $e');
      }
    }
  }

  /// Load active filters from cache
  Future<void> _loadActiveFilters() async {
    try {
      final activeFilters = await _cacheService.retrieve<Map<String, dynamic>>(_activeFilterCacheKey);
      if (activeFilters != null) {
        applyFilters(activeFilters);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading active filters: $e');
      }
    }
  }

  /// Save active filters to cache
  Future<void> _saveActiveFilters() async {
    try {
      final summary = filterSummary;
      summary.remove('hasActiveFilters');
      summary.remove('activeFiltersCount');
      summary.remove('activeFiltersBreakdown');
      await _cacheService.store(_activeFilterCacheKey, summary, expiry: const Duration(days: 7));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving active filters: $e');
      }
    }
  }

  /// Get search suggestions based on partial input
  Future<void> getSearchSuggestions(String partialTerm, {String type = 'all'}) async {
    if (partialTerm.length < 2) {
      _searchSuggestions.clear();
      notifyListeners();
      return;
    }

    _isLoadingSuggestions = true;
    notifyListeners();

    try {
      final suggestions = await _searchService.getSearchSuggestionsDebounced(
        partialTerm,
        type: type,
        limit: 10,
      );
      
      _searchSuggestions = suggestions;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting search suggestions: $e');
      }
      _searchSuggestions.clear();
    } finally {
      _isLoadingSuggestions = false;
      notifyListeners();
    }
  }

  /// Load search history
  Future<void> loadSearchHistory() async {
    _isLoadingHistory = true;
    notifyListeners();

    try {
      final history = await _searchService.getSearchHistory(limit: 20);
      _searchHistory = history;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading search history: $e');
      }
      _searchHistory.clear();
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  /// Clear search history
  Future<bool> clearSearchHistory() async {
    try {
      final success = await _searchService.clearSearchHistory();
      if (success) {
        _searchHistory.clear();
        notifyListeners();
      }
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing search history: $e');
      }
      return false;
    }
  }

  /// Load popular search terms
  Future<void> loadPopularTerms() async {
    try {
      final terms = await _searchService.getPopularSearchTerms(limit: 10);
      _popularTerms = terms;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading popular terms: $e');
      }
    }
  }

  /// Clear search suggestions
  void clearSearchSuggestions() {
    _searchSuggestions.clear();
    notifyListeners();
  }

  /// Select a search suggestion
  void selectSearchSuggestion(SearchSuggestion suggestion) {
    setSearchQuery(suggestion.text);
    clearSearchSuggestions();
  }

  /// Select a search history item
  void selectSearchHistoryItem(SearchHistoryItem historyItem) {
    setSearchQuery(historyItem.term);
  }

  /// Select a popular search term
  void selectPopularTerm(PopularSearchTerm popularTerm) {
    setSearchQuery(popularTerm.searchTerm);
  }

  /// Reset to default values
  void reset() {
    clearFilters();
  }
}
