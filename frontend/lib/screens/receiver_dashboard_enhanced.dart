import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/design_system.dart';
import '../core/theme/web_theme.dart';
import '../widgets/common/gb_button.dart';
import '../widgets/common/gb_dashboard_components.dart';
import '../widgets/common/gb_confetti.dart';
import '../widgets/common/gb_empty_state.dart';
import '../widgets/common/gb_search_bar.dart';
import '../widgets/common/gb_filter_chips.dart';
import '../widgets/common/web_sidebar_nav.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/donation.dart';
import 'chat_screen_enhanced.dart';
import 'messages_screen_enhanced.dart';
import '../l10n/app_localizations.dart';

class ReceiverDashboardEnhanced extends StatefulWidget {
  const ReceiverDashboardEnhanced({Key? key}) : super(key: key);

  @override
  State<ReceiverDashboardEnhanced> createState() =>
      _ReceiverDashboardEnhancedState();
}

class _ReceiverDashboardEnhancedState extends State<ReceiverDashboardEnhanced> {
  String _currentRoute = 'browse';
  bool _isSidebarCollapsed = false;

  List<Donation> _availableDonations = [];
  List<Donation> _filteredDonations = []; // Filtered/searched results
  List<dynamic> _myRequests = [];
  bool _isLoading = false;
  String _selectedCategory = 'all';
  List<String> _selectedCategories = []; // Multiple category selection
  String _searchQuery = ''; // Search query
  int _previousApprovedCount = 0; // Track approved requests for celebrations

  List<Map<String, dynamic>> _getCategories(AppLocalizations l10n) {
    return [
      {'value': 'all', 'label': l10n.all, 'icon': Icons.apps},
      {'value': 'food', 'label': l10n.food, 'icon': Icons.restaurant},
      {'value': 'clothes', 'label': l10n.clothes, 'icon': Icons.checkroom},
      {'value': 'books', 'label': l10n.books, 'icon': Icons.menu_book},
      {
        'value': 'electronics',
        'label': l10n.electronics,
        'icon': Icons.devices
      },
      {'value': 'other', 'label': l10n.other, 'icon': Icons.category},
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadAvailableDonations(),
      _loadMyRequests(),
    ]);
  }

  Future<void> _loadAvailableDonations() async {
    setState(() => _isLoading = true);

    final response = await ApiService.getDonations(
      category: _selectedCategory == 'all' ? null : _selectedCategory,
      available: true,
    );

    if (response.success && response.data != null && mounted) {
      setState(() {
        _availableDonations = response.data!.items;
        _applyFiltersAndSearch(); // Apply filters after loading
      });
    }

    setState(() => _isLoading = false);
  }

  void _applyFiltersAndSearch() {
    var results = List<Donation>.from(_availableDonations);

    // Apply category filter
    if (_selectedCategories.isNotEmpty) {
      results = results
          .where((donation) => _selectedCategories.contains(donation.category))
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      results = results.where((donation) {
        return donation.title.toLowerCase().contains(query) ||
            donation.description.toLowerCase().contains(query) ||
            donation.category.toLowerCase().contains(query) ||
            donation.location.toLowerCase().contains(query);
      }).toList();
    }

    setState(() {
      _filteredDonations = results;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFiltersAndSearch();
  }

  void _onCategoryFilterChanged(List<String> categories) {
    setState(() {
      _selectedCategories = categories;
    });
    _applyFiltersAndSearch();
  }

  Future<void> _loadMyRequests() async {
    final response = await ApiService.getMyRequests();
    if (response.success && mounted) {
      final newRequests = response.data ?? [];
      final newApprovedCount =
          newRequests.where((r) => r.status == 'approved').length;

      // Check for new approvals and celebrate
      if (_previousApprovedCount > 0 &&
          newApprovedCount > _previousApprovedCount) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            GBConfetti.show(
              context,
              particleCount: 50,
              duration: const Duration(seconds: 2),
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.celebration, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '🎉 Great news! Your request has been approved!',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                backgroundColor: DesignSystem.success,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        });
      }

      setState(() {
        _myRequests = newRequests;
        _previousApprovedCount = newApprovedCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: DesignSystem.getBackgroundColor(context),
      body: isDesktop
          ? Row(
              children: [
                // Sidebar Navigation
                WebSidebarNav(
                  currentRoute: _currentRoute,
                  items: [
                    WebNavItem(
                      route: 'browse',
                      label: l10n.browseDonations,
                      icon: Icons.search,
                      color: DesignSystem.secondaryGreen,
                      onTap: () => setState(() => _currentRoute = 'browse'),
                    ),
                    WebNavItem(
                      route: 'requests',
                      label: l10n.myRequests,
                      icon: Icons.inbox_outlined,
                      color: DesignSystem.accentPurple,
                      onTap: () => setState(() => _currentRoute = 'requests'),
                      badge: _myRequests.isNotEmpty
                          ? _myRequests.length.toString()
                          : null,
                    ),
                    WebNavItem(
                      route: 'overview',
                      label: l10n.overview,
                      icon: Icons.dashboard_outlined,
                      color: DesignSystem.primaryBlue,
                      onTap: () => setState(() => _currentRoute = 'overview'),
                    ),
                  ],
                  userSection: _buildUserSection(authProvider),
                  onLogout: () {
                    authProvider.logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  isCollapsed: _isSidebarCollapsed,
                  onCollapseChanged: (collapsed) {
                    setState(() => _isSidebarCollapsed = collapsed);
                  },
                ),
                // Main Content
                Expanded(
                  child: _buildMainContent(context, theme, isDark, isDesktop),
                ),
              ],
            )
          : Column(
              children: [
                Expanded(
                  child: _buildMainContent(context, theme, isDark, isDesktop),
                ),
                // Bottom Navigation for Mobile
                WebBottomNav(
                  currentRoute: _currentRoute,
                  items: [
                    WebNavItem(
                      route: 'browse',
                      label: l10n.browseDonations,
                      icon: Icons.search,
                      color: DesignSystem.secondaryGreen,
                      onTap: () => setState(() => _currentRoute = 'browse'),
                    ),
                    WebNavItem(
                      route: 'requests',
                      label: l10n.myRequests,
                      icon: Icons.inbox_outlined,
                      color: DesignSystem.accentPurple,
                      onTap: () => setState(() => _currentRoute = 'requests'),
                      badge: _myRequests.isNotEmpty
                          ? _myRequests.length.toString()
                          : null,
                    ),
                    WebNavItem(
                      route: 'more',
                      label: 'More',
                      icon: Icons.menu,
                      color: DesignSystem.neutral600,
                      onTap: () => _showMobileMenu(context),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildUserSection(AuthProvider authProvider) {
    final userName = authProvider.user?.name ?? 'Receiver';
    final userEmail = authProvider.user?.email ?? '';

    return Column(
      children: [
        CircleAvatar(
          radius: _isSidebarCollapsed ? 20 : 28,
          backgroundColor: DesignSystem.secondaryGreen.withOpacity(0.1),
          child: Text(
            userName.isNotEmpty ? userName[0].toUpperCase() : 'R',
            style: TextStyle(
              fontSize: _isSidebarCollapsed ? 18 : 24,
              fontWeight: FontWeight.bold,
              color: DesignSystem.secondaryGreen,
            ),
          ),
        ),
        if (!_isSidebarCollapsed) ...[
          const SizedBox(height: DesignSystem.spaceS),
          Text(
            userName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            userEmail,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  void _showMobileMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(DesignSystem.spaceL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.dashboard_outlined,
                  color: DesignSystem.primaryBlue),
              title: Text(l10n.overview),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentRoute = 'overview');
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: DesignSystem.error),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                authProvider.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    if (_currentRoute == 'browse') {
      return _buildBrowseTab(context, theme, isDark, isDesktop);
    } else if (_currentRoute == 'requests') {
      return _buildRequestsTab(context, theme, isDark, isDesktop);
    } else if (_currentRoute == 'overview') {
      return _buildOverviewContent(context, theme, isDark, isDesktop);
    }
    return _buildBrowseTab(context, theme, isDark, isDesktop);
  }

  Widget _buildOverviewContent(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: WebTheme.section(
          maxWidth: WebTheme.maxContentWidthLarge,
          child: Padding(
            padding: EdgeInsets.all(
                isDesktop ? DesignSystem.spaceXXXL : DesignSystem.spaceL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                _buildWelcomeSection(context, theme)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.2, end: 0),

                const SizedBox(height: DesignSystem.spaceXXL),

                // Stats Cards
                _buildStatsSection(context, theme, isDesktop)
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: DesignSystem.spaceXXL),

                // Quick Actions
                _buildQuickActions(context, theme, isDesktop)
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: DesignSystem.spaceXXL),

                // Progress Tracking
                _buildProgressTracking(context, theme, isDesktop)
                    .animate(delay: 600.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: DesignSystem.spaceXXL),

                // Recent Activity
                _buildRecentActivity(context, theme, isDesktop)
                    .animate(delay: 800.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrowseTab(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    final donationsToDisplay =
        _searchQuery.isEmpty && _selectedCategories.isEmpty
            ? _availableDonations
            : _filteredDonations;

    return RefreshIndicator(
      onRefresh: _loadAvailableDonations,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: WebTheme.section(
          maxWidth: WebTheme.maxContentWidthLarge,
          child: Padding(
            padding: EdgeInsets.all(
                isDesktop ? DesignSystem.spaceXXXL : DesignSystem.spaceL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Title
                Text(
                  AppLocalizations.of(context)!.browseDonations,
                  style: DesignSystem.displaySmall(context).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: -0.2, end: 0),

                const SizedBox(height: DesignSystem.spaceXL),

                // Category Filter with animation
                _buildCategoryFilter(context, theme)
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: DesignSystem.spaceL),

                // Result count
                if (_searchQuery.isNotEmpty || _selectedCategories.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: DesignSystem.spaceM),
                    child: Row(
                      children: [
                        Text(
                          'Found ${donationsToDisplay.length} donation${donationsToDisplay.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: DesignSystem.neutral600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: DesignSystem.spaceS),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _selectedCategories = [];
                            });
                            _applyFiltersAndSearch();
                          },
                          child: Text(
                            'Clear filters',
                            style: TextStyle(
                              fontSize: 14,
                              color: DesignSystem.secondaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 300.ms).fadeIn(duration: 600.ms),

                // Available Donations with staggered animation
                _buildAvailableDonations(context, theme, isDark, isDesktop)
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.1, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.user?.name ?? 'Receiver';
    final now = DateTime.now();
    final hour = now.hour;
    String greeting = l10n.goodMorning;
    if (hour >= 12 && hour < 17) {
      greeting = l10n.goodAfternoon;
    } else if (hour >= 17) {
      greeting = l10n.goodEvening;
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.secondaryColor, Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
            child: const Icon(
              Icons.search,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: AppTheme.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $userName!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  l10n.discoverItems,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
      BuildContext context, ThemeData theme, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;
    final availableCount = _availableDonations.length;
    final requestsCount = _myRequests.length;
    final pendingCount = _myRequests.where((r) => r.status == 'pending').length;
    final approvedCount =
        _myRequests.where((r) => r.status == 'approved').length;

    // Calculate trends (mock data - replace with real data)
    final availableTrend = availableCount > 10 ? 8.5 : 0.0;
    final requestsTrend = requestsCount > 3 ? 15.2 : 0.0;
    final approvalRate =
        requestsCount > 0 ? (approvedCount / requestsCount * 100) : 0.0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : 2,
      crossAxisSpacing: DesignSystem.spaceL,
      mainAxisSpacing: DesignSystem.spaceL,
      childAspectRatio: 1.2,
      children: [
        GBStatCard(
          title: l10n.availableItems,
          value: availableCount.toString(),
          icon: Icons.inventory_2,
          color: DesignSystem.secondaryGreen,
          trend: availableTrend,
          subtitle: 'In your area',
          isLoading: _isLoading,
        ),
        GBStatCard(
          title: l10n.myRequests,
          value: requestsCount.toString(),
          icon: Icons.inbox_outlined,
          color: DesignSystem.primaryBlue,
          trend: requestsTrend,
          subtitle: 'Total requests',
          isLoading: _isLoading,
        ),
        GBStatCard(
          title: l10n.pending,
          value: pendingCount.toString(),
          icon: Icons.hourglass_empty,
          color: DesignSystem.warning,
          subtitle: 'Awaiting approval',
          isLoading: _isLoading,
        ),
        GBStatCard(
          title: l10n.approved,
          value: approvedCount.toString(),
          icon: Icons.check_circle_outline,
          color: DesignSystem.success,
          subtitle: '${approvalRate.toStringAsFixed(0)}% approval rate',
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildQuickActions(
      BuildContext context, ThemeData theme, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacingL),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isDesktop ? 4 : 2,
          crossAxisSpacing: DesignSystem.spaceL,
          mainAxisSpacing: DesignSystem.spaceL,
          childAspectRatio: 1.1,
          children: [
            GBQuickActionCard(
              title: l10n.browseDonations,
              description: 'Find items you need',
              icon: Icons.search,
              color: DesignSystem.primaryBlue,
              onTap: () => setState(() => _currentRoute = 'browse'),
            ),
            GBQuickActionCard(
              title: l10n.myRequests,
              description: 'View request status',
              icon: Icons.inbox_outlined,
              color: DesignSystem.secondaryGreen,
              onTap: () => setState(() => _currentRoute = 'requests'),
            ),
            GBQuickActionCard(
              title: l10n.message,
              description: 'Contact donors',
              icon: Icons.message_outlined,
              color: DesignSystem.accentPink,
              onTap: () {
                // Navigate to messages
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MessagesScreenEnhanced(),
                  ),
                );
              },
            ),
            GBQuickActionCard(
              title: 'Categories',
              description: 'Filter by category',
              icon: Icons.category,
              color: DesignSystem.accentCyan,
              onTap: () => setState(() => _currentRoute = 'browse'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(
      BuildContext context, ThemeData theme, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;

    // Sample activity data - replace with real data from API
    final activities = [
      {
        'title': 'Request approved',
        'description': 'Sarah approved your request for winter clothes',
        'time': '10 min ago',
        'icon': Icons.check_circle,
        'color': DesignSystem.success,
      },
      {
        'title': 'New donation available',
        'description': 'Food items posted in your area',
        'time': '1 hour ago',
        'icon': Icons.inventory_2,
        'color': DesignSystem.secondaryGreen,
      },
      {
        'title': 'Message from donor',
        'description': 'Mike sent you pickup instructions',
        'time': '3 hours ago',
        'icon': Icons.message,
        'color': DesignSystem.accentPink,
      },
      {
        'title': 'Request pending',
        'description': 'Your book request is awaiting approval',
        'time': '1 day ago',
        'icon': Icons.hourglass_empty,
        'color': DesignSystem.warning,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Full activity log coming soon')),
                );
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(l10n.viewAll),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.secondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingL),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            border: Border.all(color: AppTheme.borderColor),
          ),
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            children: activities
                .asMap()
                .entries
                .map(
                  (entry) => GBActivityItem(
                    title: entry.value['title'] as String,
                    description: entry.value['description'] as String,
                    time: entry.value['time'] as String,
                    icon: entry.value['icon'] as IconData,
                    color: entry.value['color'] as Color,
                    isLast: entry.key == activities.length - 1,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final categories = _getCategories(l10n);

    // Build filter options for GBFilterChips
    final filterOptions = categories
        .where((cat) => cat['value'] != 'all')
        .map((cat) => GBFilterOption<String>(
              value: cat['value'] as String,
              label: cat['label'] as String,
              icon: cat['icon'] as IconData,
            ))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        GBSearchBar<Donation>(
          hint: 'Search donations by title, description, or location...',
          onSearch: (query) => _onSearchChanged(query),
          onChanged: (query) => _onSearchChanged(query),
        ),

        const SizedBox(height: AppTheme.spacingL),

        // Filter Chips
        GBFilterChips<String>(
          label: l10n.donationCategories,
          options: filterOptions,
          selectedValues: _selectedCategories,
          onChanged: _onCategoryFilterChanged,
          multiSelect: true,
          scrollable: true,
        ),
      ],
    );
  }

  Widget _buildProgressTracking(
      BuildContext context, ThemeData theme, bool isDesktop) {
    final approvedRequests =
        _myRequests.where((r) => r.status == 'approved').length;
    final totalRequests = _myRequests.length;
    final requestGoal = 5;

    // Mock profile completion - replace with actual data
    final profileCompletion = 0.8; // 80%

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Progress',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacingL),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            border: Border.all(color: AppTheme.borderColor),
          ),
          padding: const EdgeInsets.all(AppTheme.spacingXL),
          child: isDesktop
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GBProgressRing(
                      progress: totalRequests > 0
                          ? approvedRequests / requestGoal
                          : 0.0,
                      label: 'Requests Filled',
                      color: DesignSystem.secondaryGreen,
                      size: 140,
                    ),
                    const SizedBox(width: AppTheme.spacingXL),
                    GBProgressRing(
                      progress: profileCompletion,
                      label: 'Profile Complete',
                      color: DesignSystem.primaryBlue,
                      size: 140,
                    ),
                  ],
                )
              : Column(
                  children: [
                    GBProgressRing(
                      progress: totalRequests > 0
                          ? approvedRequests / requestGoal
                          : 0.0,
                      label: 'Requests Filled',
                      color: DesignSystem.secondaryGreen,
                      size: 140,
                    ),
                    const SizedBox(height: AppTheme.spacingXL),
                    GBProgressRing(
                      progress: profileCompletion,
                      label: 'Profile Complete',
                      color: DesignSystem.primaryBlue,
                      size: 140,
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildAvailableDonations(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    // Use filtered donations if search/filter is active, otherwise use all
    final donationsToShow =
        _searchQuery.isNotEmpty || _selectedCategories.isNotEmpty
            ? _filteredDonations
            : _availableDonations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Available Donations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            Text(
              '${donationsToShow.length} items',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingL),
        if (_isLoading)
          Column(
            children: List.generate(
              3,
              (index) => const Padding(
                padding: EdgeInsets.only(bottom: AppTheme.spacingL),
                child: GBSkeletonCard(),
              ),
            ),
          )
        else if (donationsToShow.isEmpty)
          _buildEmptyState()
        else
          ...donationsToShow.map(
            (donation) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingL),
              child: _buildDonationCard(donation),
            ),
          ),
      ],
    );
  }

  Widget _buildDonationCard(Donation donation) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Icon(
                  _getCategoryIcon(donation.category),
                  color: AppTheme.secondaryColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donation.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      donation.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingS,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusS),
                          ),
                          child: Text(
                            donation.category.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.secondaryColor,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            donation.location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          Row(
            children: [
              Expanded(
                child: Text(
                  'By ${donation.donorName}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ),
              GBOutlineButton(
                text: l10n.message,
                size: GBButtonSize.small,
                onPressed: () => _contactDonor(donation),
                leftIcon: const Icon(Icons.message_outlined, size: 16),
              ),
              const SizedBox(width: AppTheme.spacingS),
              GBSecondaryButton(
                text: l10n.request,
                size: GBButtonSize.small,
                onPressed: () => _requestDonation(donation),
                leftIcon: const Icon(Icons.send, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsTab(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;
    return RefreshIndicator(
      onRefresh: _loadMyRequests,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 1400 : double.infinity,
            ),
            child: Padding(
              padding: EdgeInsets.all(
                  isDesktop ? AppTheme.spacingXL : AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.myRequests,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  if (_myRequests.isEmpty)
                    _buildEmptyRequestsState()
                  else
                    ..._myRequests.map(
                      (request) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppTheme.spacingL),
                        child: _buildRequestCard(request),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(dynamic request) {
    final statusColor = _getStatusColor(request.status);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Request #${request.id}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Text(
                  _getStatusLabel(request.status),
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            request.message ?? 'No message provided',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              const Icon(Icons.person_outline,
                  size: 16, color: AppTheme.textSecondaryColor),
              const SizedBox(width: AppTheme.spacingXS),
              Text(
                'Donor: ${request.donorName}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXXL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.search_off,
                size: 60,
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
            const Text(
              'No donations available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            const Text(
              'Check back later for new donations',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyRequestsState() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXXL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.inbox_outlined,
                size: 60,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
            const Text(
              'No requests yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            const Text(
              'Browse donations and request items you need',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _contactDonor(Donation donation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreenEnhanced(
          otherUserId: donation.donorId.toString(),
          otherUserName: donation.donorName,
          donationId: donation.id.toString(),
        ),
      ),
    );
  }

  Future<void> _requestDonation(Donation donation) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _RequestDialog(donation: donation),
    );

    if (result != null) {
      final response = await ApiService.createRequest(
        donationId: donation.id.toString(),
        message: result,
      );

      if (response.success && mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(child: Text(l10n.requestSentSuccess)),
              ],
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
        _loadMyRequests();
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppTheme.warningColor;
      case 'approved':
        return AppTheme.successColor;
      case 'declined':
        return AppTheme.errorColor;
      case 'completed':
        return AppTheme.primaryColor;
      case 'cancelled':
        return AppTheme.textSecondaryColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'declined':
        return 'Declined';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'clothes':
        return Icons.checkroom;
      case 'books':
        return Icons.menu_book;
      case 'electronics':
        return Icons.devices;
      default:
        return Icons.category;
    }
  }
}

class _RequestDialog extends StatefulWidget {
  final Donation donation;

  const _RequestDialog({required this.donation});

  @override
  State<_RequestDialog> createState() => _RequestDialogState();
}

class _RequestDialogState extends State<_RequestDialog> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      title: Text(l10n.requestDonation),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requesting: ${widget.donation.title}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          TextField(
            controller: _messageController,
            decoration: InputDecoration(
              labelText: l10n.message,
              hintText: 'Tell the donor why you need this...',
              border: const OutlineInputBorder(),
            ),
            maxLines: 4,
            maxLength: 500,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, _messageController.text.trim());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.secondaryColor,
          ),
          child: Text(l10n.sendRequest),
        ),
      ],
    );
  }
}
