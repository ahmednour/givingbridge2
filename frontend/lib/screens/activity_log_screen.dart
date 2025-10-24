import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/design_system.dart';
import '../models/activity_log.dart';
import '../services/api_service.dart';
import '../widgets/common/gb_empty_state.dart';
import '../widgets/common/gb_filter_chips.dart';
import '../widgets/common/gb_button.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({Key? key}) : super(key: key);

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  List<ActivityLog> _logs = [];
  bool _isLoading = true;
  String? _errorMessage;
  List<String> _selectedCategories = [];
  int _currentPage = 1;
  bool _hasMore = true;

  final List<GBFilterOption<String>> _categoryFilters = [
    GBFilterOption(label: 'All', value: ''),
    GBFilterOption(label: 'Auth', value: 'auth'),
    GBFilterOption(label: 'Donations', value: 'donation'),
    GBFilterOption(label: 'Requests', value: 'request'),
    GBFilterOption(label: 'Messages', value: 'message'),
    GBFilterOption(label: 'Users', value: 'user'),
    GBFilterOption(label: 'Admin', value: 'admin'),
    GBFilterOption(label: 'Reports', value: 'report'),
  ];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _logs.clear();
      });
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await ApiService.getActivityLogs(
      actionCategory:
          _selectedCategories.isNotEmpty && _selectedCategories.first.isNotEmpty
              ? _selectedCategories.first
              : null,
      page: _currentPage,
      limit: 20,
    );

    if (!mounted) return;

    if (response.success && response.data != null) {
      setState(() {
        if (refresh) {
          _logs = response.data!.items;
        } else {
          _logs.addAll(response.data!.items);
        }
        _hasMore = response.data!.pagination.hasMore;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response.error;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _currentPage++);
    await _loadLogs();
  }

  void _onCategoryFilterChanged(List<String> categories) {
    setState(() {
      _selectedCategories = categories;
    });
    _loadLogs(refresh: true);
  }

  Future<void> _exportLogs() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final response = await ApiService.exportActivityLogs(
      actionCategory:
          _selectedCategories.isNotEmpty && _selectedCategories.first.isNotEmpty
              ? _selectedCategories.first
              : null,
    );

    if (!mounted) return;

    Navigator.of(context).pop(); // Close loading dialog

    if (response.success && response.data != null) {
      // In a real app, you'd save this to a file
      // For now, just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Activity logs exported successfully!'),
              ),
            ],
          ),
          backgroundColor: DesignSystem.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(response.error ?? 'Failed to export logs'),
              ),
            ],
          ),
          backgroundColor: DesignSystem.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? DesignSystem.neutral900 : DesignSystem.neutral100,
      appBar: AppBar(
        backgroundColor: isDark ? DesignSystem.neutral900 : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Activity Logs',
          style: TextStyle(
            color: isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!_isLoading && _logs.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.refresh,
                color:
                    isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
              ),
              onPressed: () => _loadLogs(refresh: true),
              tooltip: 'Refresh',
            ),
          if (!_isLoading && _logs.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.file_download,
                color:
                    isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
              ),
              onPressed: _exportLogs,
              tooltip: 'Export CSV',
            ),
        ],
      ),
      body: Column(
        children: [
          // Category filter
          Container(
            color: isDark ? DesignSystem.neutral900 : Colors.white,
            padding: const EdgeInsets.all(16),
            child: GBFilterChips<String>(
              options: _categoryFilters,
              selectedValues: _selectedCategories,
              onChanged: _onCategoryFilterChanged,
              multiSelect: false,
            ),
          ),

          // Logs list
          Expanded(
            child: _buildBody(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading && _logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                DesignSystem.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading activity logs...',
              style: TextStyle(
                color:
                    isDark ? DesignSystem.neutral400 : DesignSystem.neutral600,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null && _logs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color:
                    isDark ? DesignSystem.neutral600 : DesignSystem.neutral400,
              ),
              const SizedBox(height: 16),
              Text(
                'Error Loading Logs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? DesignSystem.neutral200
                      : DesignSystem.neutral900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? DesignSystem.neutral400
                      : DesignSystem.neutral600,
                ),
              ),
              const SizedBox(height: 24),
              GBButton(
                text: 'Retry',
                onPressed: () => _loadLogs(refresh: true),
                variant: GBButtonVariant.primary,
                size: GBButtonSize.medium,
              ),
            ],
          ),
        ),
      );
    }

    if (_logs.isEmpty) {
      return GBEmptyState(
        icon: Icons.history,
        title: 'No Activity Logs',
        message: _selectedCategories.isNotEmpty
            ? 'No logs found for the selected category'
            : 'Your activity will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadLogs(refresh: true),
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (!_isLoading &&
              _hasMore &&
              scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 200) {
            _loadMore();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _logs.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _logs.length) {
              // Loading indicator at the bottom
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final log = _logs[index];
            final isFirst = index == 0;
            final isLast = index == _logs.length - 1 && !_hasMore;

            return _buildActivityLogItem(log, isFirst, isLast)
                .animate(delay: Duration(milliseconds: index * 50))
                .fadeIn(duration: 300.ms)
                .slideX(begin: 0.1, end: 0);
          },
        ),
      ),
    );
  }

  Widget _buildActivityLogItem(ActivityLog log, bool isFirst, bool isLast) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator column
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Top line (hidden for first item)
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 12,
                    color: DesignSystem.neutral300,
                  ),

                // Event indicator
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: log.categoryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: log.categoryColor,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    log.categoryIcon,
                    size: 20,
                    color: log.categoryColor,
                  ),
                ),

                // Bottom line (hidden for last item)
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: DesignSystem.neutral300,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Event content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : 16,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? DesignSystem.neutral800 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        // Category badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: log.categoryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            log.categoryDisplayName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: log.categoryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Time ago
                        Expanded(
                          child: Text(
                            log.timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? DesignSystem.neutral500
                                  : DesignSystem.neutral600,
                            ),
                          ),
                        ),

                        // Full timestamp
                        Text(
                          log.formattedDate,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? DesignSystem.neutral600
                                : DesignSystem.neutral500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Description
                    Text(
                      log.description,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? DesignSystem.neutral200
                            : DesignSystem.neutral900,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // User info
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: isDark
                              ? DesignSystem.neutral500
                              : DesignSystem.neutral600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          log.userName,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? DesignSystem.neutral400
                                : DesignSystem.neutral600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: DesignSystem.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            log.userRole.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: DesignSystem.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Entity info (if available)
                    if (log.entityType != null && log.entityId != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.link,
                            size: 14,
                            color: isDark
                                ? DesignSystem.neutral500
                                : DesignSystem.neutral600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${log.entityType} #${log.entityId}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? DesignSystem.neutral400
                                  : DesignSystem.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
