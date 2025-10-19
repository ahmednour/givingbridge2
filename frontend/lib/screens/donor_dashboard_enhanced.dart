import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/design_system.dart';
import '../widgets/common/gb_button.dart';
import '../widgets/common/gb_dashboard_components.dart';
import '../widgets/common/gb_confetti.dart';
import '../widgets/common/gb_empty_state.dart';
import '../widgets/common/gb_search_bar.dart';
import '../widgets/common/gb_filter_chips.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/donation.dart';
import 'create_donation_screen_enhanced.dart';
import 'donor_browse_requests_screen.dart';
import 'donor_impact_screen.dart';
import '../l10n/app_localizations.dart';

class DonorDashboardEnhanced extends StatefulWidget {
  const DonorDashboardEnhanced({Key? key}) : super(key: key);

  @override
  State<DonorDashboardEnhanced> createState() => _DonorDashboardEnhancedState();
}

class _DonorDashboardEnhancedState extends State<DonorDashboardEnhanced>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Donation> _donations = [];
  List<Donation> _filteredDonations = []; // Filtered/searched donations
  bool _isLoading = false;
  int _previousDonationCount =
      0; // Track previous count for milestone detection
  String _searchQuery = ''; // Search query
  List<String> _selectedStatuses = []; // Status filter

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserDonations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDonations() async {
    setState(() => _isLoading = true);

    final response = await ApiService.getMyDonations();
    if (response.success && mounted) {
      final newDonations = response.data ?? [];
      final newCount = newDonations.length;

      // Check for milestones (10th, 20th, 50th, 100th donation)
      if (_previousDonationCount > 0 && newCount > _previousDonationCount) {
        _checkMilestones(newCount);
      }

      setState(() {
        _donations = newDonations;
        _previousDonationCount = newCount;
      });

      // Apply filters after loading
      _applyFiltersAndSearch();
    }

    setState(() => _isLoading = false);
  }

  void _applyFiltersAndSearch() {
    var results = List<Donation>.from(_donations);

    // Apply status filter
    if (_selectedStatuses.isNotEmpty) {
      results = results
          .where((donation) => _selectedStatuses.contains(donation.status))
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

  void _onStatusFilterChanged(List<String> statuses) {
    setState(() {
      _selectedStatuses = statuses;
    });
    _applyFiltersAndSearch();
  }

  void _checkMilestones(int count) {
    // Milestone thresholds
    final milestones = [10, 20, 50, 100, 200, 500];

    for (final milestone in milestones) {
      if (count == milestone && _previousDonationCount < milestone) {
        // Trigger confetti celebration
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            GBConfetti.show(
              context,
              particleCount: milestone >= 100 ? 100 : 50,
              duration: const Duration(seconds: 3),
            );

            // Show congratulations message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.celebration, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '🎉 Congratulations! You\'ve reached $milestone donations!',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                backgroundColor: DesignSystem.success,
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        });
        break; // Only celebrate one milestone at a time
      }
    }
  }

  Future<void> _navigateToCreateDonation({Donation? donation}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateDonationScreenEnhanced(donation: donation),
      ),
    );

    if (result == true) {
      _loadUserDonations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    return Scaffold(
      backgroundColor: DesignSystem.getBackgroundColor(context),
      body: Column(
        children: [
          // Modern Tab Bar
          Container(
            decoration: BoxDecoration(
              color: DesignSystem.getSurfaceColor(context),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.textSecondaryColor,
              indicatorColor: AppTheme.primaryColor,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(text: l10n.overview),
                Tab(text: l10n.myDonations),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(context, theme, isDark, isDesktop),
                _buildDonationsTab(context, theme, isDark, isDesktop),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: isDesktop
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _navigateToCreateDonation(),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add),
              label: Text(l10n.createDonation,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
    );
  }

  Widget _buildOverviewTab(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    return RefreshIndicator(
      onRefresh: _loadUserDonations,
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
                  _buildWelcomeSection(context, theme),

                  const SizedBox(height: AppTheme.spacingXL),

                  // Stats Cards
                  _buildStatsSection(context, theme, isDesktop),

                  const SizedBox(height: AppTheme.spacingXL),

                  // Recent Activity
                  _buildRecentActivity(context, theme, isDark),

                  const SizedBox(height: AppTheme.spacingXL),

                  // Progress Tracking
                  _buildProgressTracking(context, theme, isDesktop),

                  const SizedBox(height: AppTheme.spacingXL),

                  // Quick Actions
                  _buildQuickActions(context, theme, isDesktop),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.user?.name ?? 'Donor';
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
          colors: [AppTheme.primaryColor, Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                ),
                child: const Icon(
                  Icons.volunteer_activism,
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
                      l10n.thankYouDifference,
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
        ],
      ),
    );
  }

  Widget _buildStatsSection(
      BuildContext context, ThemeData theme, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;
    final totalDonations = _donations.length;
    final activeDonations =
        _donations.where((d) => d.status == 'available').length;
    final completedDonations =
        _donations.where((d) => d.status == 'completed').length;
    final impactScore = totalDonations * 10;

    // Calculate trends (mock data - replace with real data from previous period)
    final totalTrend = totalDonations > 10 ? 12.5 : 0.0;
    final activeTrend = activeDonations > 5 ? 8.3 : 0.0;
    final completedTrend = completedDonations > 0 ? 15.7 : 0.0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : 2,
      crossAxisSpacing: DesignSystem.spaceL,
      mainAxisSpacing: DesignSystem.spaceL,
      childAspectRatio: 1.2,
      children: [
        GBStatCard(
          title: l10n.totalDonations,
          value: totalDonations.toString(),
          icon: Icons.volunteer_activism,
          color: DesignSystem.primaryBlue,
          trend: totalTrend,
          subtitle:
              '+${(totalTrend * totalDonations / 100).toInt()} this month',
          isLoading: _isLoading,
        ),
        GBStatCard(
          title: l10n.active,
          value: activeDonations.toString(),
          icon: Icons.check_circle_outline,
          color: DesignSystem.success,
          trend: activeTrend,
          subtitle: 'Available now',
          isLoading: _isLoading,
        ),
        GBStatCard(
          title: l10n.completed,
          value: completedDonations.toString(),
          icon: Icons.handshake_outlined,
          color: DesignSystem.accentPurple,
          trend: completedTrend,
          subtitle: 'All time',
          isLoading: _isLoading,
        ),
        GBStatCard(
          title: l10n.impactScore,
          value: impactScore.toString(),
          icon: Icons.trending_up,
          color: DesignSystem.accentAmber,
          subtitle: 'Top 10%',
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildRecentActivity(
      BuildContext context, ThemeData theme, bool isDark) {
    final l10n = AppLocalizations.of(context)!;

    // Sample activity data - replace with real data from API
    final activities = [
      {
        'title': 'New request received',
        'description': 'John requested your winter jacket',
        'time': '5 min ago',
        'icon': Icons.inbox,
        'color': DesignSystem.primaryBlue,
      },
      {
        'title': 'Donation marked complete',
        'description': 'Your book donation was successfully delivered',
        'time': '2 hours ago',
        'icon': Icons.check_circle,
        'color': DesignSystem.success,
      },
      {
        'title': 'Item viewed',
        'description': '12 people viewed your laptop donation',
        'time': '1 day ago',
        'icon': Icons.visibility,
        'color': DesignSystem.accentPurple,
      },
      {
        'title': 'Message received',
        'description': 'Sarah sent you a thank you message',
        'time': '2 days ago',
        'icon': Icons.message,
        'color': DesignSystem.accentPink,
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
                foregroundColor: AppTheme.primaryColor,
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

  Widget _buildQuickActions(
      BuildContext context, ThemeData theme, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: DesignSystem.titleLarge(context).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: DesignSystem.spaceL),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isDesktop ? 4 : 2,
          crossAxisSpacing: DesignSystem.spaceL,
          mainAxisSpacing: DesignSystem.spaceL,
          childAspectRatio: 1.0,
          children: [
            GBQuickActionCard(
              title: l10n.createDonation,
              description: l10n.shareItemsNeed,
              icon: Icons.add_circle_outline,
              color: DesignSystem.primaryBlue,
              onTap: () => _navigateToCreateDonation(),
            ),
            GBQuickActionCard(
              title: l10n.browseRequests,
              description: l10n.seeWhatPeopleNeed,
              icon: Icons.search,
              color: DesignSystem.accentPurple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DonorBrowseRequestsScreen(),
                  ),
                );
              },
            ),
            GBQuickActionCard(
              title: l10n.viewImpact,
              description: l10n.seeContributionStats,
              icon: Icons.analytics_outlined,
              color: DesignSystem.accentAmber,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DonorImpactScreen(),
                  ),
                );
              },
            ),
            GBQuickActionCard(
              title: l10n.messages,
              description: 'Chat with recipients',
              icon: Icons.message_outlined,
              color: DesignSystem.accentPink,
              onTap: () {
                // Navigate to messages
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressTracking(
      BuildContext context, ThemeData theme, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;
    final totalDonations = _donations.length;
    final monthlyGoal = 10;
    final impactScore = totalDonations * 10;
    final impactGoal = 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goal Tracking',
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
                      progress: totalDonations / monthlyGoal,
                      label: 'Monthly Goal',
                      color: DesignSystem.primaryBlue,
                      size: 140,
                    ),
                    const SizedBox(width: AppTheme.spacingXL),
                    GBProgressRing(
                      progress: impactScore / impactGoal,
                      label: 'Impact Score',
                      color: DesignSystem.accentAmber,
                      size: 140,
                    ),
                  ],
                )
              : Column(
                  children: [
                    GBProgressRing(
                      progress: totalDonations / monthlyGoal,
                      label: 'Monthly Goal',
                      color: DesignSystem.primaryBlue,
                      size: 140,
                    ),
                    const SizedBox(height: AppTheme.spacingXL),
                    GBProgressRing(
                      progress: impactScore / impactGoal,
                      label: 'Impact Score',
                      color: DesignSystem.accentAmber,
                      size: 140,
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildDonationsTab(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;

    // Determine which list to display
    final donationsToDisplay = _searchQuery.isEmpty && _selectedStatuses.isEmpty
        ? _donations
        : _filteredDonations;

    return RefreshIndicator(
      onRefresh: _loadUserDonations,
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
                      Text(
                        l10n.myDonations,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      GBPrimaryButton(
                        text: l10n.newButton,
                        size: isDesktop
                            ? GBButtonSize.medium
                            : GBButtonSize.small,
                        leftIcon: const Icon(Icons.add, size: 18),
                        onPressed: () => _navigateToCreateDonation(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingL),

                  // Search and Filter Section
                  if (_donations.isNotEmpty && !_isLoading) ...[
                    GBSearchBar<Donation>(
                      hint:
                          'Search donations by title, description, or category...',
                      onSearch: (query) => _onSearchChanged(query),
                      onChanged: (query) => _onSearchChanged(query),
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
                      selectedValues: _selectedStatuses,
                      onChanged: _onStatusFilterChanged,
                      multiSelect: true,
                      scrollable: true,
                    ),
                    const SizedBox(height: AppTheme.spacingL),

                    // Result count
                    if (_searchQuery.isNotEmpty || _selectedStatuses.isNotEmpty)
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
                            if (_searchQuery.isNotEmpty ||
                                _selectedStatuses.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _selectedStatuses = [];
                                  });
                                  _applyFiltersAndSearch();
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
                  else if (_donations.isEmpty)
                    _buildEmptyState()
                  else if (donationsToDisplay.isEmpty)
                    _buildNoResultsState()
                  else
                    ...donationsToDisplay.map(
                      (donation) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppTheme.spacingL),
                        child: _buildDonationCard(donation),
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

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
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
                Icons.inventory_2_outlined,
                size: 60,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
            Text(
              l10n.noDonationsYet,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              l10n.startMakingDifference,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXL),
            GBPrimaryButton(
              text: l10n.createFirstDonation,
              leftIcon: const Icon(Icons.add, size: 20),
              onPressed: () => _navigateToCreateDonation(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
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
                  _searchQuery = '';
                  _selectedStatuses = [];
                });
                _applyFiltersAndSearch();
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

  Widget _buildDonationCard(Donation donation, {bool compact = false}) {
    final statusColor = _getStatusColor(donation.status);

    return Container(
      padding: EdgeInsets.all(compact ? AppTheme.spacingM : AppTheme.spacingL),
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
              // Icon
              Container(
                width: compact ? 50 : 60,
                height: compact ? 50 : 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Icon(
                  _getCategoryIcon(donation.category),
                  color: AppTheme.primaryColor,
                  size: compact ? 24 : 30,
                ),
              ),

              const SizedBox(width: AppTheme.spacingM),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donation.title,
                      style: TextStyle(
                        fontSize: compact ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!compact) ...[
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
                    ],
                    const SizedBox(height: AppTheme.spacingS),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingS,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusS),
                          ),
                          child: Text(
                            donation.category.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingS,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusS),
                          ),
                          child: Text(
                            _getStatusLabel(donation.status).toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              if (!compact)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppTheme.textSecondaryColor,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  itemBuilder: (menuContext) {
                    final l10n = AppLocalizations.of(menuContext)!;
                    return [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.edit),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete,
                                size: 18, color: AppTheme.errorColor),
                            const SizedBox(width: 8),
                            Text(l10n.delete,
                                style: const TextStyle(
                                    color: AppTheme.errorColor)),
                          ],
                        ),
                      ),
                    ];
                  },
                  onSelected: (value) {
                    if (value == 'edit') {
                      _navigateToCreateDonation(donation: donation);
                    } else if (value == 'delete') {
                      _deleteDonation(donation.id);
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDonation(int donationId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final dialogL10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
          ),
          title: Text(dialogL10n.deleteDonation),
          content: Text(dialogL10n.deleteDonationConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(dialogL10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
              child: Text(dialogL10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final response = await ApiService.deleteDonation(donationId.toString());

      if (response.success) {
        _loadUserDonations();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.donationDeletedSuccess),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return AppTheme.successColor;
      case 'pending':
        return AppTheme.warningColor;
      case 'completed':
        return AppTheme.primaryColor;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return 'Available';
      case 'pending':
        return 'Pending';
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
