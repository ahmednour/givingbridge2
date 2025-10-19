import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../widgets/common/gb_button.dart';
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
  bool _isLoading = false;

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
      setState(() {
        _donations = response.data ?? [];
      });
    }

    setState(() => _isLoading = false);
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
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Modern Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
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
    final stats = [
      {
        'title': l10n.totalDonations,
        'value': _donations.length.toString(),
        'icon': Icons.volunteer_activism,
        'color': AppTheme.primaryColor,
        'bgColor': AppTheme.primaryColor.withOpacity(0.1),
      },
      {
        'title': l10n.active,
        'value':
            _donations.where((d) => d.status == 'available').length.toString(),
        'icon': Icons.check_circle_outline,
        'color': AppTheme.successColor,
        'bgColor': AppTheme.successColor.withOpacity(0.1),
      },
      {
        'title': l10n.completed,
        'value':
            _donations.where((d) => d.status == 'completed').length.toString(),
        'icon': Icons.handshake_outlined,
        'color': const Color(0xFF8B5CF6),
        'bgColor': const Color(0xFF8B5CF6).withOpacity(0.1),
      },
      {
        'title': l10n.impactScore,
        'value': (_donations.length * 10).toString(),
        'icon': Icons.trending_up,
        'color': AppTheme.warningColor,
        'bgColor': AppTheme.warningColor.withOpacity(0.1),
      },
    ];

    if (isDesktop) {
      return Row(
        children: stats.map((stat) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: AppTheme.spacingL),
              child: _buildStatCard(stat),
            ),
          );
        }).toList(),
      );
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppTheme.spacingM,
          mainAxisSpacing: AppTheme.spacingM,
          childAspectRatio: 1.3,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) => _buildStatCard(stats[index]),
      );
    }
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: stat['bgColor'],
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Icon(
                  stat['icon'],
                  color: stat['color'],
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            stat['value'],
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            stat['title'],
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(
      BuildContext context, ThemeData theme, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.recentDonations,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            TextButton.icon(
              onPressed: () => _tabController.animateTo(1),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(l10n.viewAll),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingL),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_donations.isEmpty)
          _buildEmptyState()
        else
          ..._donations.take(3).map(
                (donation) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                  child: _buildDonationCard(donation, compact: true),
                ),
              ),
      ],
    );
  }

  Widget _buildQuickActions(
      BuildContext context, ThemeData theme, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;
    final actions = [
      {
        'title': l10n.createDonation,
        'description': l10n.shareItemsNeed,
        'icon': Icons.add_circle_outline,
        'color': AppTheme.primaryColor,
        'onTap': () => _navigateToCreateDonation(),
      },
      {
        'title': l10n.browseRequests,
        'description': l10n.seeWhatPeopleNeed,
        'icon': Icons.search,
        'color': const Color(0xFF8B5CF6),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DonorBrowseRequestsScreen(),
            ),
          );
        },
      },
      {
        'title': l10n.viewImpact,
        'description': l10n.seeContributionStats,
        'icon': Icons.analytics_outlined,
        'color': AppTheme.warningColor,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DonorImpactScreen(),
            ),
          );
        },
      },
    ];

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
        if (isDesktop)
          Row(
            children: actions.map((action) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppTheme.spacingL),
                  child: _buildActionCard(action),
                ),
              );
            }).toList(),
          )
        else
          ...actions.map(
            (action) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
              child: _buildActionCard(action),
            ),
          ),
      ],
    );
  }

  Widget _buildActionCard(Map<String, dynamic> action) {
    return InkWell(
      onTap: action['onTap'],
      borderRadius: BorderRadius.circular(AppTheme.radiusL),
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (action['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Icon(
                action['icon'],
                color: action['color'],
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spacingL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    action['description'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.textSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationsTab(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;
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
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_donations.isEmpty)
                    _buildEmptyState()
                  else
                    ..._donations.map(
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
