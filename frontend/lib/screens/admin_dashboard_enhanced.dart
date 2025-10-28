import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/design_system.dart';
import '../widgets/common/gb_dashboard_components.dart';
import '../widgets/common/gb_confetti.dart';
import '../widgets/common/gb_search_bar.dart';
import '../widgets/common/gb_filter_chips.dart';
import '../widgets/common/gb_line_chart.dart';
import '../widgets/common/gb_bar_chart.dart';
import '../widgets/common/gb_pie_chart.dart';
import '../widgets/common/web_sidebar_nav.dart';
import '../providers/auth_provider.dart';
import '../providers/analytics_provider.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../models/donation.dart';
import '../l10n/app_localizations.dart';
import 'admin_reports_screen.dart';
import 'activity_log_screen.dart';
import 'analytics_dashboard_enhanced.dart';

class AdminDashboardEnhanced extends StatefulWidget {
  const AdminDashboardEnhanced({Key? key}) : super(key: key);

  @override
  State<AdminDashboardEnhanced> createState() => _AdminDashboardEnhancedState();
}

class _AdminDashboardEnhancedState extends State<AdminDashboardEnhanced> {
  String _currentRoute = 'overview';
  bool _isSidebarCollapsed = false;

  List<User> _users = [];
  List<User> _filteredUsers = []; // Filtered/searched users
  List<Donation> _donations = [];
  List<Donation> _filteredDonations = []; // Filtered/searched donations
  List<dynamic> _requests = [];

  Map<String, int> _donationStats = {};
  Map<String, int> _requestStats = {};

  int _previousUserCount = 0; // Track platform growth milestones

  // Search and filter state
  String _userSearchQuery = '';
  List<String> _selectedUserRoles = [];
  String _donationSearchQuery = '';
  List<String> _selectedDonationStatuses = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadUsers(),
      _loadDonations(),
      _loadRequests(),
      _loadStats(),
    ]);
  }

  Future<void> _loadUsers() async {
    final response = await ApiService.getAllUsers();
    if (response.success && mounted) {
      final newUsers = response.data ?? [];
      final newUserCount = newUsers.length;

      // Check for platform milestones (50, 100, 500, 1000 users)
      if (_previousUserCount > 0 && newUserCount > _previousUserCount) {
        _checkPlatformMilestones(newUserCount);
      }

      setState(() {
        _users = newUsers;
        _previousUserCount = newUserCount;
      });

      // Apply filters after loading
      _applyUserFilters();
    }
  }

  void _applyUserFilters() {
    var results = List<User>.from(_users);

    // Apply role filter
    if (_selectedUserRoles.isNotEmpty) {
      results = results
          .where((user) => _selectedUserRoles.contains(user.role))
          .toList();
    }

    // Apply search filter
    if (_userSearchQuery.isNotEmpty) {
      final query = _userSearchQuery.toLowerCase();
      results = results.where((user) {
        return user.name.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query) ||
            user.role.toLowerCase().contains(query);
      }).toList();
    }

    setState(() {
      _filteredUsers = results;
    });
  }

  void _onUserSearchChanged(String query) {
    setState(() {
      _userSearchQuery = query;
    });
    _applyUserFilters();
  }

  void _onUserRoleFilterChanged(List<String> roles) {
    setState(() {
      _selectedUserRoles = roles;
    });
    _applyUserFilters();
  }

  void _checkPlatformMilestones(int count) {
    final milestones = [50, 100, 250, 500, 1000];

    for (final milestone in milestones) {
      if (count == milestone && _previousUserCount < milestone) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            GBConfetti.show(
              context,
              particleCount: milestone >= 500 ? 100 : 75,
              duration: const Duration(seconds: 4),
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '🎉 Platform Milestone! $milestone users joined GivingBridge!',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                backgroundColor: DesignSystem.warning,
                duration: const Duration(seconds: 5),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        });
        break;
      }
    }
  }

  Future<void> _loadDonations() async {
    final response = await ApiService.getDonations();
    if (response.success && response.data != null && mounted) {
      setState(() {
        _donations = response.data!.items;
      });

      // Apply filters after loading
      _applyDonationFilters();
    }
  }

  void _applyDonationFilters() {
    var results = List<Donation>.from(_donations);

    // Apply status filter
    if (_selectedDonationStatuses.isNotEmpty) {
      results = results
          .where(
              (donation) => _selectedDonationStatuses.contains(donation.status))
          .toList();
    }

    // Apply search filter
    if (_donationSearchQuery.isNotEmpty) {
      final query = _donationSearchQuery.toLowerCase();
      results = results.where((donation) {
        return donation.title.toLowerCase().contains(query) ||
            donation.description.toLowerCase().contains(query) ||
            donation.category.toLowerCase().contains(query);
      }).toList();
    }

    setState(() {
      _filteredDonations = results;
    });
  }

  void _onDonationSearchChanged(String query) {
    setState(() {
      _donationSearchQuery = query;
    });
    _applyDonationFilters();
  }

  void _onDonationStatusFilterChanged(List<String> statuses) {
    setState(() {
      _selectedDonationStatuses = statuses;
    });
    _applyDonationFilters();
  }

  Future<void> _loadRequests() async {
    final response = await ApiService.getRequests();
    if (response.success && response.data != null && mounted) {
      setState(() {
        _requests = response.data!.items;
      });
    }
  }

  Future<void> _loadStats() async {
    // Calculate donation stats
    final donationResponse = await ApiService.getDonations();
    if (donationResponse.success && donationResponse.data != null) {
      final donations = donationResponse.data!.items;
      setState(() {
        _donationStats = {
          'total': donations.length,
          'available': donations.where((d) => d.isAvailable).length,
          'food': donations.where((d) => d.category == 'food').length,
          'clothes': donations.where((d) => d.category == 'clothes').length,
          'books': donations.where((d) => d.category == 'books').length,
          'electronics':
              donations.where((d) => d.category == 'electronics').length,
        };
      });
    }

    // Calculate request stats
    final requestResponse = await ApiService.getRequests();
    if (requestResponse.success && requestResponse.data != null) {
      final requests = requestResponse.data!.items;
      setState(() {
        _requestStats = {
          'total': requests.length,
          'pending': requests.where((r) => r.status == 'pending').length,
          'approved': requests.where((r) => r.status == 'approved').length,
          'declined': requests.where((r) => r.status == 'declined').length,
          'completed': requests.where((r) => r.status == 'completed').length,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
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
                      route: 'overview',
                      label: l10n.overview,
                      icon: Icons.dashboard_outlined,
                      color: DesignSystem.accentAmber,
                      onTap: () => setState(() => _currentRoute = 'overview'),
                    ),
                    WebNavItem(
                      route: 'users',
                      label: 'Users',
                      icon: Icons.people_outline,
                      color: DesignSystem.primaryBlue,
                      onTap: () => setState(() => _currentRoute = 'users'),
                      badge:
                          _users.isNotEmpty ? _users.length.toString() : null,
                    ),
                    WebNavItem(
                      route: 'donations',
                      label: 'Donations',
                      icon: Icons.volunteer_activism,
                      color: DesignSystem.accentPink,
                      onTap: () => setState(() => _currentRoute = 'donations'),
                      badge: _donations.isNotEmpty
                          ? _donations.length.toString()
                          : null,
                    ),
                    WebNavItem(
                      route: 'requests',
                      label: 'Requests',
                      icon: Icons.inbox_outlined,
                      color: DesignSystem.accentPurple,
                      onTap: () => setState(() => _currentRoute = 'requests'),
                      badge: _requests.isNotEmpty
                          ? _requests.length.toString()
                          : null,
                    ),
                    WebNavItem(
                      route: 'analytics',
                      label: 'Analytics',
                      icon: Icons.analytics_outlined,
                      color: DesignSystem.secondaryGreen,
                      onTap: () => setState(() => _currentRoute = 'analytics'),
                    ),
                    WebNavItem(
                      route: 'reports',
                      label: 'Reports',
                      icon: Icons.report_outlined,
                      color: DesignSystem.warning,
                      onTap: () => setState(() => _currentRoute = 'reports'),
                    ),
                    WebNavItem(
                      route: 'activity',
                      label: 'Activity Logs',
                      icon: Icons.history,
                      color: DesignSystem.info,
                      onTap: () => setState(() => _currentRoute = 'activity'),
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
                  child: _buildMainContent(context, theme, isDesktop),
                ),
              ],
            )
          : Column(
              children: [
                Expanded(
                  child: _buildMainContent(context, theme, isDesktop),
                ),
                // Bottom Navigation for Mobile
                WebBottomNav(
                  currentRoute: _currentRoute,
                  items: [
                    WebNavItem(
                      route: 'overview',
                      label: l10n.overview,
                      icon: Icons.dashboard_outlined,
                      color: DesignSystem.accentAmber,
                      onTap: () => setState(() => _currentRoute = 'overview'),
                    ),
                    WebNavItem(
                      route: 'users',
                      label: 'Users',
                      icon: Icons.people_outline,
                      color: DesignSystem.primaryBlue,
                      onTap: () => setState(() => _currentRoute = 'users'),
                      badge:
                          _users.isNotEmpty ? _users.length.toString() : null,
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
    final userName = authProvider.user?.name ?? 'Admin';
    final userEmail = authProvider.user?.email ?? '';

    return Column(
      children: [
        CircleAvatar(
          radius: _isSidebarCollapsed ? 20 : 28,
          backgroundColor: DesignSystem.accentAmber.withOpacity(0.1),
          child: Text(
            userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
            style: TextStyle(
              fontSize: _isSidebarCollapsed ? 18 : 24,
              fontWeight: FontWeight.bold,
              color: DesignSystem.accentAmber,
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
              leading: Icon(Icons.volunteer_activism,
                  color: DesignSystem.accentPink),
              title: Text('Donations'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentRoute = 'donations');
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.inbox_outlined, color: DesignSystem.accentPurple),
              title: Text('Requests'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentRoute = 'requests');
              },
            ),
            ListTile(
              leading: Icon(Icons.analytics_outlined,
                  color: DesignSystem.secondaryGreen),
              title: Text('Analytics'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentRoute = 'analytics');
              },
            ),
            ListTile(
              leading: Icon(Icons.report_outlined, color: DesignSystem.warning),
              title: Text('Reports'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentRoute = 'reports');
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: DesignSystem.info),
              title: Text('Activity Logs'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentRoute = 'activity');
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
      BuildContext context, ThemeData theme, bool isDesktop) {
    if (_currentRoute == 'overview') {
      return _buildOverviewTab(context, theme, isDesktop);
    } else if (_currentRoute == 'users') {
      return _buildUsersTab(context, theme, isDesktop);
    } else if (_currentRoute == 'donations') {
      return _buildDonationsTab(context, theme, isDesktop);
    } else if (_currentRoute == 'requests') {
      return _buildRequestsTab(context, theme, isDesktop);
    } else if (_currentRoute == 'analytics') {
      return _buildAnalyticsTab(context, theme, isDesktop);
    } else if (_currentRoute == 'reports') {
      return const AdminReportsScreen();
    } else if (_currentRoute == 'activity') {
      return const ActivityLogScreen();
    }
    return _buildOverviewTab(context, theme, isDesktop);
  }

  Widget _buildOverviewTab(
      BuildContext context, ThemeData theme, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.user?.name ?? 'Admin';

    return RefreshIndicator(
      onRefresh: _loadAllData,
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
                  // Welcome Section
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingXL),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.warningColor, Color(0xFFF59E0B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.warningColor.withOpacity(0.3),
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
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusL),
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings,
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
                                l10n.welcomeAdmin(userName),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingXS),
                              Text(
                                l10n.manageOversee,
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
                  ),

                  const SizedBox(height: AppTheme.spacingXL),

                  // Platform Stats
                  Text(
                    l10n.platformStatistics,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),

                  _buildStatsSection(context, l10n, isDesktop),

                  const SizedBox(height: AppTheme.spacingXL),

                  // Quick Actions
                  _buildQuickActions(context, l10n, isDesktop),

                  const SizedBox(height: AppTheme.spacingXL),

                  // Recent Activity
                  _buildRecentActivity(context, l10n, isDesktop),

                  const SizedBox(height: AppTheme.spacingXL),

                  // Progress Tracking
                  _buildProgressTracking(context, l10n, isDesktop),

                  const SizedBox(height: AppTheme.spacingXL),

                  // Donation Stats
                  Text(
                    l10n.donationCategories,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),

                  _buildCategoryStats(),

                  const SizedBox(height: AppTheme.spacingXL),

                  // Request Status
                  Text(
                    l10n.requestStatus,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),

                  _buildRequestStats(),

                  const SizedBox(height: AppTheme.spacingXL),

                  // User Distribution
                  const Text(
                    'User Distribution',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),

                  _buildUserDistribution(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(
      BuildContext context, AppLocalizations l10n, bool isDesktop) {
    final totalUsers = _users.length;
    final totalDonations = _donationStats['total'] ?? 0;
    final totalRequests = _requestStats['total'] ?? 0;
    final activeItems = _donationStats['available'] ?? 0;

    // Calculate trends
    final usersTrend = totalUsers > 20 ? 12.3 : 0.0;
    final donationsTrend = totalDonations > 15 ? 18.7 : 0.0;
    final requestsTrend = totalRequests > 10 ? 25.4 : 0.0;
    final activeRate =
        totalDonations > 0 ? (activeItems / totalDonations * 100) : 0.0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : 2,
      crossAxisSpacing: DesignSystem.spaceL,
      mainAxisSpacing: DesignSystem.spaceL,
      childAspectRatio: 1.2,
      children: [
        GBStatCard(
          title: l10n.totalUsers,
          value: totalUsers.toString(),
          icon: Icons.people,
          color: DesignSystem.primaryBlue,
          trend: usersTrend,
          subtitle: 'Active platform users',
          isLoading: false,
        ),
        GBStatCard(
          title: l10n.totalDonations,
          value: totalDonations.toString(),
          icon: Icons.volunteer_activism,
          color: DesignSystem.secondaryGreen,
          trend: donationsTrend,
          subtitle: 'Total donations',
          isLoading: false,
        ),
        GBStatCard(
          title: l10n.totalRequests,
          value: totalRequests.toString(),
          icon: Icons.inbox,
          color: DesignSystem.warning,
          trend: requestsTrend,
          subtitle: 'All requests',
          isLoading: false,
        ),
        GBStatCard(
          title: l10n.activeItems,
          value: activeItems.toString(),
          icon: Icons.check_circle,
          color: DesignSystem.success,
          subtitle: '${activeRate.toStringAsFixed(0)}% available',
          isLoading: false,
        ),
      ],
    );
  }

  Widget _buildQuickActions(
      BuildContext context, AppLocalizations l10n, bool isDesktop) {
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
          crossAxisCount: isDesktop ? 3 : 2,
          crossAxisSpacing: DesignSystem.spaceL,
          mainAxisSpacing: DesignSystem.spaceL,
          childAspectRatio: 1.1,
          children: [
            GBQuickActionCard(
              title: l10n.users,
              description: 'Manage all users',
              icon: Icons.people_outline,
              color: DesignSystem.primaryBlue,
              onTap: () => setState(() => _currentRoute = 'users'),
            ),
            GBQuickActionCard(
              title: l10n.donations,
              description: 'View all donations',
              icon: Icons.volunteer_activism,
              color: DesignSystem.secondaryGreen,
              onTap: () => setState(() => _currentRoute = 'donations'),
            ),
            GBQuickActionCard(
              title: l10n.requests,
              description: 'Manage requests',
              icon: Icons.inbox_outlined,
              color: DesignSystem.warning,
              onTap: () => setState(() => _currentRoute = 'requests'),
            ),
            GBQuickActionCard(
              title: 'Reports',
              description: 'Manage user reports',
              icon: Icons.flag_outlined,
              color: DesignSystem.accentPink,
              onTap: () => setState(() => _currentRoute = 'reports'),
            ),
            if (isDesktop) ...[
              GBQuickActionCard(
                title: 'Activity',
                description: 'View activity logs',
                icon: Icons.history,
                color: DesignSystem.info,
                onTap: () => setState(() => _currentRoute = 'activity'),
              ),
              GBQuickActionCard(
                title: 'Analytics',
                description: 'View statistics',
                icon: Icons.analytics_outlined,
                color: DesignSystem.accentPink,
                onTap: () => setState(() => _currentRoute = 'overview'),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(
      BuildContext context, AppLocalizations l10n, bool isDesktop) {
    // Sample activity data - replace with real data from API
    final activities = [
      {
        'title': 'New user registered',
        'description': 'Emily Johnson joined as a donor',
        'time': '5 min ago',
        'icon': Icons.person_add,
        'color': DesignSystem.primaryBlue,
      },
      {
        'title': 'Donation created',
        'description': 'John posted electronics in New York',
        'time': '30 min ago',
        'icon': Icons.volunteer_activism,
        'color': DesignSystem.secondaryGreen,
      },
      {
        'title': 'Request flagged',
        'description': 'Request #1234 needs admin review',
        'time': '2 hours ago',
        'icon': Icons.flag,
        'color': DesignSystem.warning,
      },
      {
        'title': 'Transaction complete',
        'description': 'Donation #567 marked as delivered',
        'time': '1 day ago',
        'icon': Icons.check_circle,
        'color': DesignSystem.success,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Platform Activity',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            TextButton.icon(
              onPressed: () => setState(() => _currentRoute = 'activity'),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(l10n.viewAll),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.warningColor,
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

  Widget _buildProgressTracking(
      BuildContext context, AppLocalizations l10n, bool isDesktop) {
    final totalUsers = _users.length;
    final userGoal = 100; // Platform goal for 100 users
// Platform goal for 200 donations

    final platformGrowth = totalUsers / userGoal;
    final userSatisfaction = 0.90; // 90% mock satisfaction

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Platform Health',
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
                      progress: platformGrowth > 1.0 ? 1.0 : platformGrowth,
                      label: 'Platform Growth',
                      color: DesignSystem.warning,
                      size: 140,
                    ),
                    const SizedBox(width: AppTheme.spacingXL),
                    GBProgressRing(
                      progress: userSatisfaction,
                      label: 'User Satisfaction',
                      color: DesignSystem.success,
                      size: 140,
                    ),
                  ],
                )
              : Column(
                  children: [
                    GBProgressRing(
                      progress: platformGrowth > 1.0 ? 1.0 : platformGrowth,
                      label: 'Platform Growth',
                      color: DesignSystem.warning,
                      size: 140,
                    ),
                    const SizedBox(height: AppTheme.spacingXL),
                    GBProgressRing(
                      progress: userSatisfaction,
                      label: 'User Satisfaction',
                      color: DesignSystem.success,
                      size: 140,
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryStats() {
    final categories = [
      {
        'name': 'Food',
        'value': _donationStats['food'] ?? 0,
        'icon': Icons.restaurant,
        'color': AppTheme.primaryColor
      },
      {
        'name': 'Clothes',
        'value': _donationStats['clothes'] ?? 0,
        'icon': Icons.checkroom,
        'color': AppTheme.secondaryColor
      },
      {
        'name': 'Books',
        'value': _donationStats['books'] ?? 0,
        'icon': Icons.menu_book,
        'color': AppTheme.warningColor
      },
      {
        'name': 'Electronics',
        'value': _donationStats['electronics'] ?? 0,
        'icon': Icons.devices,
        'color': AppTheme.errorColor
      },
    ];

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: categories.map((cat) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (cat['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: Icon(cat['icon'] as IconData,
                      color: cat['color'] as Color, size: 20),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Text(
                    cat['name'] as String,
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
                    color: (cat['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Text(
                    cat['value'].toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: cat['color'] as Color,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRequestStats() {
    final statuses = [
      {
        'name': 'Pending',
        'value': _requestStats['pending'] ?? 0,
        'color': AppTheme.warningColor
      },
      {
        'name': 'Approved',
        'value': _requestStats['approved'] ?? 0,
        'color': AppTheme.successColor
      },
      {
        'name': 'Declined',
        'value': _requestStats['declined'] ?? 0,
        'color': AppTheme.errorColor
      },
      {
        'name': 'Completed',
        'value': _requestStats['completed'] ?? 0,
        'color': AppTheme.primaryColor
      },
    ];

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: statuses.map((status) {
          final total = _requestStats['total'] ?? 1;
          final percentage = total > 0
              ? ((status['value'] as int) / total * 100).toStringAsFixed(1)
              : '0.0';

          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      status['name'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    Text(
                      '${status['value']} ($percentage%)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: status['color'] as Color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingXS),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  child: LinearProgressIndicator(
                    value: total > 0 ? (status['value'] as int) / total : 0,
                    backgroundColor: AppTheme.surfaceColor,
                    color: status['color'] as Color,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUserDistribution() {
    final donors = _users.where((u) => u.role == 'donor').length;
    final receivers = _users.where((u) => u.role == 'receiver').length;
    final admins = _users.where((u) => u.role == 'admin').length;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildUserRole('Donors', donors, AppTheme.primaryColor),
          ),
          Container(width: 1, height: 60, color: AppTheme.borderColor),
          Expanded(
            child:
                _buildUserRole('Receivers', receivers, AppTheme.secondaryColor),
          ),
          Container(width: 1, height: 60, color: AppTheme.borderColor),
          Expanded(
            child: _buildUserRole('Admins', admins, AppTheme.warningColor),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRole(String role, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: AppTheme.spacingXS),
        Text(
          role,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildUsersTab(BuildContext context, ThemeData theme, bool isDesktop) {
    // Determine which list to display
    final usersToDisplay =
        _userSearchQuery.isEmpty && _selectedUserRoles.isEmpty
            ? _users
            : _filteredUsers;

    return RefreshIndicator(
      onRefresh: _loadUsers,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'All Users',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      Text(
                        '${_users.length} users',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingL),

                  // Search and Filter Section
                  if (_users.isNotEmpty) ...[
                    GBSearchBar<User>(
                      hint: 'Search users by name, email, or role...',
                      onSearch: (query) => _onUserSearchChanged(query),
                      onChanged: (query) => _onUserSearchChanged(query),
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                    GBFilterChips<String>(
                      label: 'User Role',
                      options: [
                        GBFilterOption<String>(
                          value: 'donor',
                          label: 'Donors',
                          icon: Icons.volunteer_activism,
                          color: DesignSystem.primaryBlue,
                        ),
                        GBFilterOption<String>(
                          value: 'receiver',
                          label: 'Receivers',
                          icon: Icons.volunteer_activism_outlined,
                          color: DesignSystem.secondaryGreen,
                        ),
                        GBFilterOption<String>(
                          value: 'admin',
                          label: 'Admins',
                          icon: Icons.admin_panel_settings,
                          color: DesignSystem.warning,
                        ),
                      ],
                      selectedValues: _selectedUserRoles,
                      onChanged: _onUserRoleFilterChanged,
                      multiSelect: true,
                      scrollable: true,
                    ),
                    const SizedBox(height: AppTheme.spacingL),

                    // Result count
                    if (_userSearchQuery.isNotEmpty ||
                        _selectedUserRoles.isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppTheme.spacingM),
                        child: Row(
                          children: [
                            Text(
                              'Found ${usersToDisplay.length} user${usersToDisplay.length == 1 ? '' : 's'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: DesignSystem.neutral600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingS),
                            if (_userSearchQuery.isNotEmpty ||
                                _selectedUserRoles.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _userSearchQuery = '';
                                    _selectedUserRoles = [];
                                  });
                                  _applyUserFilters();
                                },
                                child: Text(
                                  'Clear filters',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: DesignSystem.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],

                  if (usersToDisplay.isEmpty &&
                      (_userSearchQuery.isNotEmpty ||
                          _selectedUserRoles.isNotEmpty))
                    _buildNoUsersResultState()
                  else
                    ...usersToDisplay.map((user) => _buildUserCard(user)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(User user) {
    Color roleColor;
    switch (user.role) {
      case 'donor':
        roleColor = AppTheme.primaryColor;
        break;
      case 'receiver':
        roleColor = AppTheme.secondaryColor;
        break;
      case 'admin':
        roleColor = AppTheme.warningColor;
        break;
      default:
        roleColor = AppTheme.textSecondaryColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Icon(Icons.person, color: roleColor, size: 24),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingXS,
            ),
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
            child: Text(
              user.role.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: roleColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoUsersResultState() {
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
                color: DesignSystem.neutral100,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.search_off,
                size: 60,
                color: DesignSystem.neutral400,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
            Text(
              'No users found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: DesignSystem.neutral900,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: DesignSystem.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXL),
            TextButton(
              onPressed: () {
                setState(() {
                  _userSearchQuery = '';
                  _selectedUserRoles = [];
                });
                _applyUserFilters();
              },
              child: Text(
                'Clear all filters',
                style: TextStyle(
                  fontSize: 16,
                  color: DesignSystem.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationsTab(
      BuildContext context, ThemeData theme, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;

    // Determine which list to display
    final donationsToDisplay =
        _donationSearchQuery.isEmpty && _selectedDonationStatuses.isEmpty
            ? _donations
            : _filteredDonations;

    return RefreshIndicator(
      onRefresh: _loadDonations,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'All Donations',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      Text(
                        '${_donations.length} donations',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingL),

                  // Search and Filter Section
                  if (_donations.isNotEmpty) ...[
                    GBSearchBar<Donation>(
                      hint:
                          'Search donations by title, description, or category...',
                      onSearch: (query) => _onDonationSearchChanged(query),
                      onChanged: (query) => _onDonationSearchChanged(query),
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                    GBFilterChips<String>(
                      label: 'Status',
                      options: [
                        GBFilterOption<String>(
                          value: 'available',
                          label: 'Available',
                          icon: Icons.check_circle_outline,
                          color: DesignSystem.success,
                        ),
                        GBFilterOption<String>(
                          value: 'pending',
                          label: 'Pending',
                          icon: Icons.pending_outlined,
                          color: DesignSystem.warning,
                        ),
                        GBFilterOption<String>(
                          value: 'completed',
                          label: 'Completed',
                          icon: Icons.done_all,
                          color: DesignSystem.primaryBlue,
                        ),
                      ],
                      selectedValues: _selectedDonationStatuses,
                      onChanged: _onDonationStatusFilterChanged,
                      multiSelect: true,
                      scrollable: true,
                    ),
                    const SizedBox(height: AppTheme.spacingL),

                    // Result count
                    if (_donationSearchQuery.isNotEmpty ||
                        _selectedDonationStatuses.isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppTheme.spacingM),
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
                            const SizedBox(width: AppTheme.spacingS),
                            if (_donationSearchQuery.isNotEmpty ||
                                _selectedDonationStatuses.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _donationSearchQuery = '';
                                    _selectedDonationStatuses = [];
                                  });
                                  _applyDonationFilters();
                                },
                                child: Text(
                                  'Clear filters',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: DesignSystem.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],

                  if (_donations.isEmpty)
                    Center(child: Text(l10n.noDonations))
                  else if (donationsToDisplay.isEmpty &&
                      (_donationSearchQuery.isNotEmpty ||
                          _selectedDonationStatuses.isNotEmpty))
                    _buildNoDonationsResultState()
                  else
                    ...donationsToDisplay
                        .map((donation) => _buildDonationCardAdmin(donation)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoDonationsResultState() {
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
                color: DesignSystem.neutral100,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.search_off,
                size: 60,
                color: DesignSystem.neutral400,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
            Text(
              'No donations found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: DesignSystem.neutral900,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: DesignSystem.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXL),
            TextButton(
              onPressed: () {
                setState(() {
                  _donationSearchQuery = '';
                  _selectedDonationStatuses = [];
                });
                _applyDonationFilters();
              },
              child: Text(
                'Clear all filters',
                style: TextStyle(
                  fontSize: 16,
                  color: DesignSystem.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationCardAdmin(Donation donation) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Icon(_getCategoryIcon(donation.category),
                    color: AppTheme.secondaryColor, size: 24),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donation.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      'By ${donation.donorName}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: donation.isAvailable
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Text(
                  donation.isAvailable ? 'AVAILABLE' : 'UNAVAILABLE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: donation.isAvailable
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsTab(
      BuildContext context, ThemeData theme, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;
    return RefreshIndicator(
      onRefresh: _loadRequests,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'All Requests',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      Text(
                        '${_requests.length} requests',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  if (_requests.isEmpty)
                    Center(child: Text(l10n.noRequests))
                  else
                    ..._requests
                        .map((request) => _buildRequestCardAdmin(request)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCardAdmin(dynamic request) {
    final statusColor = _getStatusColor(request.status);

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Request #${request.id}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
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
                  request.status.toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 16, color: AppTheme.textSecondaryColor),
                    const SizedBox(width: AppTheme.spacingXS),
                    Expanded(
                      child: Text(
                        'From: ${request.receiverName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.volunteer_activism,
                        size: 16, color: AppTheme.textSecondaryColor),
                    const SizedBox(width: AppTheme.spacingXS),
                    Expanded(
                      child: Text(
                        'To: ${request.donorName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
      default:
        return AppTheme.textSecondaryColor;
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

  // Analytics Tab - Enhanced Version
  Widget _buildAnalyticsTab(
      BuildContext context, ThemeData theme, bool isDesktop) {
    return const AnalyticsDashboardEnhanced();
  }

  Widget _buildAnalyticsMetrics(
      bool isDesktop, AnalyticsProvider analyticsProvider) {
    final overview = analyticsProvider.overview;

    final totalDonations = overview?.donations.total ?? 0;
    final totalRequests = overview?.requests.total ?? 0;
    final totalUsers = overview?.users.total ?? 0;
    final activeDonations = overview?.donations.available ?? 0;

    final metrics = [
      {
        'title': 'Total Donations',
        'value': totalDonations.toString(),
        'icon': Icons.volunteer_activism,
        'color': DesignSystem.primaryBlue,
        'change': '+12%',
      },
      {
        'title': 'Total Requests',
        'value': totalRequests.toString(),
        'icon': Icons.request_page,
        'color': DesignSystem.secondaryGreen,
        'change': '+8%',
      },
      {
        'title': 'Active Users',
        'value': totalUsers.toString(),
        'icon': Icons.people,
        'color': DesignSystem.accentPurple,
        'change': '+15%',
      },
      {
        'title': 'Active Donations',
        'value': activeDonations.toString(),
        'icon': Icons.trending_up,
        'color': DesignSystem.success,
        'change': '+5%',
      },
    ];

    if (isDesktop) {
      return Row(
        children: metrics
            .map((metric) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: AppTheme.spacingM),
                    child: _buildMetricCard(metric),
                  ),
                ))
            .toList(),
      );
    } else {
      return Column(
        children: metrics
            .map((metric) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                  child: _buildMetricCard(metric),
                ))
            .toList(),
      );
    }
  }

  Widget _buildMetricCard(Map<String, dynamic> metric) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.shadowMD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (metric['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Icon(
                  metric['icon'] as IconData,
                  color: metric['color'] as Color,
                  size: 24,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: DesignSystem.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Text(
                  metric['change'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DesignSystem.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            metric['value'] as String,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            metric['title'] as String,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationTrendsChart(AnalyticsProvider analyticsProvider) {
    // Use real data from analytics provider
    final points = analyticsProvider.donationTrends.map((trend) {
      return GBChartPoint(
        x: DateTime.parse(trend.date).millisecondsSinceEpoch.toDouble(),
        y: trend.count.toDouble(),
      );
    }).toList();

    // Generate xLabels from dates
    final xLabels = analyticsProvider.donationTrends
        .map((trend) => _formatDateLabel(trend.date))
        .toList();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.shadowMD,
      ),
      child: GBLineChart(
        data: [
          GBLineChartData.donationTrend(points: points),
        ],
        xLabels: xLabels,
        yAxisTitle: 'Donations',
        xAxisTitle: 'Date',
        height: 300,
      ),
    );
  }

  Widget _buildCategoryDistributionChart(AnalyticsProvider analyticsProvider) {
    // Use real data from analytics provider
    final colors = [
      DesignSystem.primaryBlue,
      DesignSystem.secondaryGreen,
      DesignSystem.accentPurple,
      DesignSystem.accentPink,
      DesignSystem.warning,
    ];

    final barData =
        analyticsProvider.categoryDistribution.asMap().entries.map((entry) {
      return GBBarChartData.category(
        name: entry.value.category,
        count: entry.value.count.toDouble(),
        color: colors[entry.key % colors.length],
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.shadowMD,
      ),
      child: GBBarChart(
        data: barData.isEmpty
            ? [
                GBBarChartData.category(
                  name: 'No Data',
                  count: 0,
                  color: DesignSystem.neutral300,
                )
              ]
            : barData,
        title: 'Donations by Category',
        height: 300,
      ),
    );
  }

  Widget _buildStatusDistributionChart(AnalyticsProvider analyticsProvider) {
    // Use real data from analytics provider
    final pieData = analyticsProvider.statusDistribution.map((statusDist) {
      return GBPieChartData.status(
        status: statusDist.status,
        count: statusDist.count.toDouble(),
      );
    }).toList();

    final totalDonations = analyticsProvider.overview?.donations.total ?? 0;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.shadowMD,
      ),
      child: GBPieChart(
        data: pieData.isEmpty
            ? [
                GBPieChartData.status(
                  status: 'No Data',
                  count: 1,
                )
              ]
            : pieData,
        title: 'Status Distribution',
        isDonut: true,
        centerLabel: totalDonations.toString(),
        size: 220,
      ),
    );
  }

  Widget _buildUserGrowthChart(AnalyticsProvider analyticsProvider) {
    // Use real data from analytics provider
    final points = analyticsProvider.userGrowth.map((growth) {
      return GBChartPoint(
        x: DateTime.parse(growth.date).millisecondsSinceEpoch.toDouble(),
        y: growth.count.toDouble(),
      );
    }).toList();

    // Generate xLabels from dates
    final xLabels = analyticsProvider.userGrowth
        .map((growth) => _formatDateLabel(growth.date))
        .toList();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.shadowMD,
      ),
      child: GBLineChart(
        data: [
          GBLineChartData.userGrowth(points: points),
        ],
        xLabels: xLabels,
        yAxisTitle: 'Users',
        xAxisTitle: 'Date',
        height: 300,
      ),
    );
  }

  String _formatDateLabel(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.month}/${date.day}';
    } catch (e) {
      return dateStr;
    }
  }
}
