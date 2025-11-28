import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme/design_system.dart';
import '../widgets/common/gb_dashboard_components.dart';
import '../widgets/common/gb_empty_state.dart';
import '../widgets/common/gb_button.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../models/donation.dart';
import 'admin_pending_donations_screen.dart';

class AdminDashboardEnhanced extends StatefulWidget {
  const AdminDashboardEnhanced({Key? key}) : super(key: key);

  @override
  State<AdminDashboardEnhanced> createState() => _AdminDashboardEnhancedState();
}

class _AdminDashboardEnhancedState extends State<AdminDashboardEnhanced> {
  String _currentRoute = 'overview';
  
  // Real data state
  List<User> _users = [];
  List<Donation> _donations = [];
  List<DonationRequest> _requests = [];
  bool _isLoading = false;
  
  // Search and filter state
  String _userSearchQuery = '';
  String _donationSearchQuery = '';
  String _selectedUserRole = 'all';
  String _selectedDonationCategory = 'all';
  
  // Stats
  Map<String, dynamic> _stats = {
    'totalUsers': 0,
    'totalDonations': 0,
    'totalRequests': 0,
    'pendingRequests': 0,
    'pendingDonations': 0,
    'activeUsers': 0,
    'monthlyGrowth': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadPendingDonationsCount();
  }

  Future<void> _loadPendingDonationsCount() async {
    final response = await ApiService.getPendingDonationsCount();
    if (response.success && mounted) {
      setState(() {
        _stats['pendingDonations'] = response.data ?? 0;
      });
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    await Future.wait([
      _loadUsers(),
      _loadDonations(),
      _loadRequests(),
    ]);
    
    _calculateStats();
    
    setState(() => _isLoading = false);
  }

  Future<void> _loadUsers() async {
    final response = await ApiService.getAllUsers();
    if (response.success && mounted) {
      setState(() {
        final data = response.data as Map<String, dynamic>;
        final usersList = data['users'] as List<dynamic>;
        _users = usersList.map((json) => User.fromJson(json)).toList();
      });
    }
  }

  Future<void> _loadDonations() async {
    final response = await ApiService.getDonations(limit: 100);
    if (response.success && mounted) {
      setState(() {
        _donations = response.data?.items ?? [];
      });
    }
  }

  Future<void> _loadRequests() async {
    final response = await ApiService.getAllRequests();
    if (response.success && mounted) {
      setState(() {
        final data = response.data as Map<String, dynamic>;
        _requests = (data['requests'] as List<dynamic>)
            .map((json) => DonationRequest.fromJson(json as Map<String, dynamic>))
            .toList();
      });
    }
  }

  void _calculateStats() {
    final donors = _users.where((u) => u.role == 'donor').length;
    final receivers = _users.where((u) => u.role == 'receiver').length;
    final pendingReqs = _requests.where((r) => r.status == 'pending').length;
    
    setState(() {
      _stats = {
        'totalUsers': _users.length,
        'totalDonations': _donations.length,
        'totalRequests': _requests.length,
        'pendingRequests': pendingReqs,
        'donors': donors,
        'receivers': receivers,
        'admins': _users.where((u) => u.role == 'admin').length,
        'availableDonations': _donations.where((d) => d.isAvailable).length,
        'claimedDonations': _donations.where((d) => !d.isAvailable).length,
        'approvedRequests': _requests.where((r) => r.status == 'approved').length,
      };
    });
  }

  Future<void> _handleLogout(BuildContext context, AuthProvider authProvider) async {
    final l10n = AppLocalizations.of(context)!;
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: DesignSystem.error,
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await authProvider.logout();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    
    return Directionality(
      textDirection: localeProvider.textDirection,
      child: Scaffold(
        backgroundColor: DesignSystem.getBackgroundColor(context),
        body: isDesktop ? _buildDesktopLayout(context, l10n, authProvider) : _buildMobileLayout(context, l10n, authProvider),
        bottomNavigationBar: !isDesktop ? _buildMobileBottomNav(context, l10n) : null,
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AppLocalizations l10n, AuthProvider authProvider) {
    return Row(
      children: [
        // Desktop Sidebar (without collapse functionality)
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: DesignSystem.getSurfaceColor(context),
            border: Border(
              right: BorderSide(
                color: DesignSystem.getBorderColor(context),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Header with Language Toggle
              Container(
                padding: const EdgeInsets.all(DesignSystem.spaceL),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: DesignSystem.primaryBlue,
                            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: DesignSystem.spaceM),
                        Expanded(
                          child: Text(
                            l10n.admin,
                            style: DesignSystem.headlineSmall(context).copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignSystem.spaceM),
                    // Language Toggle in Sidebar
                    _buildLanguageToggle(context),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // User Section
              Padding(
                padding: const EdgeInsets.all(DesignSystem.spaceM),
                child: _buildUserSection(context, l10n, authProvider),
              ),
              
              const Divider(height: 1),
              
              // Navigation Items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: DesignSystem.spaceM),
                  itemCount: _getNavItems(l10n).length,
                  itemBuilder: (context, index) {
                    final item = _getNavItems(l10n)[index];
                    final isActive = _currentRoute == item['route'];
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignSystem.spaceM,
                        vertical: DesignSystem.spaceXS,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: item['onTap'] as VoidCallback,
                          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                          child: Container(
                            padding: const EdgeInsets.all(DesignSystem.spaceM),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? (item['color'] as Color).withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                              border: isActive
                                  ? Border.all(color: (item['color'] as Color).withOpacity(0.3))
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  item['icon'] as IconData,
                                  color: isActive
                                      ? item['color'] as Color
                                      : DesignSystem.getTextColor(context).withOpacity(0.7),
                                  size: 20,
                                ),
                                const SizedBox(width: DesignSystem.spaceM),
                                Expanded(
                                  child: Text(
                                    item['label'] as String,
                                    style: DesignSystem.bodyMedium(context).copyWith(
                                      color: isActive
                                          ? item['color'] as Color
                                          : DesignSystem.getTextColor(context),
                                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ).animate(delay: Duration(milliseconds: 100 * index))
                        .slideX(begin: -0.3, duration: 300.ms)
                        .fadeIn();
                  },
                ),
              ),
              
              // Logout Button
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(DesignSystem.spaceM),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _handleLogout(context, authProvider),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                    child: Container(
                      padding: const EdgeInsets.all(DesignSystem.spaceM),
                      decoration: BoxDecoration(
                        color: DesignSystem.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                        border: Border.all(
                          color: DesignSystem.error.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout,
                            color: DesignSystem.error,
                            size: 20,
                          ),
                          const SizedBox(width: DesignSystem.spaceM),
                          Expanded(
                            child: Text(
                              l10n.logout,
                              style: DesignSystem.bodyMedium(context).copyWith(
                                color: DesignSystem.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Main Content
        Expanded(
          child: _buildMainContent(context, l10n),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, AppLocalizations l10n, AuthProvider authProvider) {
    return Column(
      children: [
        // Mobile App Bar
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + DesignSystem.spaceM,
            left: DesignSystem.spaceL,
            right: DesignSystem.spaceL,
            bottom: DesignSystem.spaceM,
          ),
          decoration: BoxDecoration(
            color: DesignSystem.getSurfaceColor(context),
            border: Border(
              bottom: BorderSide(
                color: DesignSystem.getBorderColor(context),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Admin Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DesignSystem.primaryBlue,
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: DesignSystem.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.admin,
                      style: DesignSystem.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'admin@givingbridge.com',
                      style: DesignSystem.bodySmall(context).copyWith(
                        color: DesignSystem.getTextColor(context).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Language Toggle
              _buildLanguageToggle(context),
              const SizedBox(width: DesignSystem.spaceS),
              // Logout Button
              IconButton(
                icon: Icon(
                  Icons.logout,
                  color: DesignSystem.error,
                ),
                onPressed: () => _handleLogout(context, authProvider),
                tooltip: l10n.logout,
              ),
            ],
          ),
        ),
        // Main Content
        Expanded(
          child: _buildMainContent(context, l10n),
        ),
      ],
    );
  }



  Widget _buildMobileBottomNav(BuildContext context, AppLocalizations l10n) {
    final navItems = _getNavItems(l10n);
    
    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.getSurfaceColor(context),
        border: Border(
          top: BorderSide(
            color: DesignSystem.getBorderColor(context),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: DesignSystem.spaceS),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navItems.take(5).map((item) {
              final isActive = _currentRoute == item['route'];
              return GestureDetector(
                onTap: item['onTap'] as VoidCallback,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignSystem.spaceS,
                    vertical: DesignSystem.spaceXS,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        color: isActive
                            ? item['color'] as Color
                            : DesignSystem.getTextColor(context).withOpacity(0.6),
                        size: 20,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['label'] as String,
                        style: DesignSystem.bodySmall(context).copyWith(
                          color: isActive
                              ? item['color'] as Color
                              : DesignSystem.getTextColor(context).withOpacity(0.6),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getNavItems(AppLocalizations l10n) {
    return [
      {
        'route': 'overview',
        'label': l10n.overview,
        'icon': Icons.dashboard,
        'color': DesignSystem.primaryBlue,
        'onTap': () => setState(() => _currentRoute = 'overview'),
      },
      {
        'route': 'users',
        'label': l10n.users,
        'icon': Icons.people,
        'color': DesignSystem.success,
        'onTap': () => setState(() => _currentRoute = 'users'),
      },
      {
        'route': 'requests',
        'label': l10n.requests,
        'icon': Icons.assignment,
        'color': DesignSystem.warning,
        'onTap': () => setState(() => _currentRoute = 'requests'),
      },
      {
        'route': 'donations',
        'label': l10n.donations,
        'icon': Icons.volunteer_activism,
        'color': DesignSystem.accentPink,
        'onTap': () => setState(() => _currentRoute = 'donations'),
      },
      {
        'route': 'pending_donations',
        'label': l10n.pendingDonations,
        'icon': Icons.pending_actions,
        'color': Colors.orange,
        'badge': _stats['pendingDonations'] ?? 0,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminPendingDonationsScreen(),
            ),
          ).then((_) => _loadPendingDonationsCount());
        },
      },
      {
        'route': 'analytics',
        'label': l10n.analytics,
        'icon': Icons.analytics,
        'color': DesignSystem.accentPurple,
        'onTap': () => setState(() => _currentRoute = 'analytics'),
      },
      {
        'route': 'settings',
        'label': l10n.settings,
        'icon': Icons.settings,
        'color': DesignSystem.neutral600,
        'onTap': () => setState(() => _currentRoute = 'settings'),
      },
    ];
  }

  Widget _buildUserSection(BuildContext context, AppLocalizations l10n, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spaceM),
      decoration: BoxDecoration(
        color: DesignSystem.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: DesignSystem.primaryBlue,
            child: Text(
              'A',
              style: DesignSystem.bodyMedium(context).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: DesignSystem.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.admin,
                  style: DesignSystem.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'admin@givingbridge.com',
                  style: DesignSystem.bodySmall(context).copyWith(
                    color: DesignSystem.getTextColor(context).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    
    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(color: DesignSystem.getBorderColor(context)),
      ),
      child: Row(
        children: [
          _buildLanguageButton('en', 'EN', localeProvider),
          _buildLanguageButton('ar', 'ع', localeProvider),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(String locale, String label, LocaleProvider localeProvider) {
    final isActive = localeProvider.locale.languageCode == locale;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => localeProvider.setLocale(Locale(locale)),
        borderRadius: BorderRadius.circular(DesignSystem.radiusS),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSystem.spaceM,
            vertical: DesignSystem.spaceS,
          ),
          decoration: BoxDecoration(
            color: isActive ? DesignSystem.primaryBlue : null,
            borderRadius: BorderRadius.circular(DesignSystem.radiusS),
          ),
          child: Text(
            label,
            style: DesignSystem.bodySmall(context).copyWith(
              color: isActive ? Colors.white : DesignSystem.getTextColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spaceL),
      child: _buildRouteContent(context, l10n),
    );
  }

  Widget _buildRouteContent(BuildContext context, AppLocalizations l10n) {
    switch (_currentRoute) {
      case 'overview':
        return _buildOverviewContent(context, l10n);
      case 'users':
        return _buildUsersContent(context, l10n);
      case 'requests':
        return _buildRequestsContent(context, l10n);
      case 'donations':
        return _buildDonationsContent(context, l10n);
      case 'analytics':
        return _buildAnalyticsContent(context, l10n);
      case 'settings':
        return _buildSettingsContent(context, l10n);
      default:
        return _buildOverviewContent(context, l10n);
    }
  }

  Widget _buildOverviewContent(BuildContext context, AppLocalizations l10n) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final crossAxisCount = isDesktop ? 3 : 2;
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards using real data
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: DesignSystem.spaceM,
            mainAxisSpacing: DesignSystem.spaceM,
            childAspectRatio: isDesktop ? 2.5 : 1.8,
            children: [
              GBStatCard(
                title: l10n.totalUsers,
                value: _stats['totalUsers'].toString(),
                icon: Icons.people,
                color: DesignSystem.primaryBlue,
                isLoading: _isLoading,
              ).animate(delay: 100.ms).slideY(begin: 0.3, duration: 400.ms).fadeIn(),
              
              GBStatCard(
                title: l10n.totalDonations,
                value: _stats['totalDonations'].toString(),
                icon: Icons.volunteer_activism,
                color: DesignSystem.success,
                isLoading: _isLoading,
              ).animate(delay: 200.ms).slideY(begin: 0.3, duration: 400.ms).fadeIn(),
              
              GBStatCard(
                title: l10n.pendingRequests,
                value: _stats['pendingRequests'].toString(),
                icon: Icons.pending_actions,
                color: DesignSystem.warning,
                isLoading: _isLoading,
              ).animate(delay: 300.ms).slideY(begin: 0.3, duration: 400.ms).fadeIn(),
            ],
          ),
          
          const SizedBox(height: DesignSystem.spaceXL),
          
          // Recent Activity Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.recentActivity,
                style: DesignSystem.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              GBButton(
                text: l10n.refresh,
                onPressed: _loadData,
                variant: GBButtonVariant.secondary,
                size: GBButtonSize.small,
              ),
            ],
          ),
          
          const SizedBox(height: DesignSystem.spaceM),
          
          // Activity List - Real Data
          Container(
            decoration: BoxDecoration(
              color: DesignSystem.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(DesignSystem.radiusL),
              border: Border.all(color: DesignSystem.getBorderColor(context)),
            ),
            child: Column(
              children: _buildRecentActivityItems(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spaceL),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: DesignSystem.getBorderColor(context),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: DesignSystem.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DesignSystem.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DesignSystem.spaceXS),
                Text(
                  subtitle,
                  style: DesignSystem.bodySmall(context).copyWith(
                    color: DesignSystem.getTextColor(context).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: DesignSystem.bodySmall(context).copyWith(
              color: DesignSystem.getTextColor(context).withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  // Users Management Page
  Widget _buildUsersContent(BuildContext context, AppLocalizations l10n) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignSystem.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Title
          Text(
            l10n.users,
            style: DesignSystem.headlineMedium(context).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DesignSystem.spaceXS),
          Text(
            l10n.usersSubtitle,
            style: DesignSystem.bodyMedium(context).copyWith(
              color: DesignSystem.getTextColor(context).withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: DesignSystem.spaceXL),
          
          // User Stats - Real Data
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isDesktop ? 4 : 2,
            crossAxisSpacing: DesignSystem.spaceM,
            mainAxisSpacing: DesignSystem.spaceM,
            childAspectRatio: isDesktop ? 2 : 1.5,
            children: [
              GBStatCard(
                title: l10n.totalUsersLabel,
                value: _stats['totalUsers'].toString(),
                icon: Icons.people,
                color: DesignSystem.primaryBlue,
              ),
              GBStatCard(
                title: l10n.donors,
                value: (_stats['donors'] ?? 0).toString(),
                icon: Icons.volunteer_activism,
                color: DesignSystem.accentPink,
              ),
              GBStatCard(
                title: l10n.receivers,
                value: (_stats['receivers'] ?? 0).toString(),
                icon: Icons.inbox,
                color: DesignSystem.secondaryGreen,
              ),
              GBStatCard(
                title: l10n.admin,
                value: (_stats['admins'] ?? 0).toString(),
                icon: Icons.admin_panel_settings,
                color: DesignSystem.warning,
              ),
            ],
          ),
          
          const SizedBox(height: DesignSystem.spaceXL),
          
          // Search and Filter Section
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  onChanged: (value) => setState(() => _userSearchQuery = value),
                  decoration: InputDecoration(
                    hintText: '${l10n.search} ${l10n.users.toLowerCase()}...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: DesignSystem.spaceM,
                      vertical: DesignSystem.spaceS,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DesignSystem.spaceM),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedUserRole,
                  decoration: InputDecoration(
                    labelText: l10n.role,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: DesignSystem.spaceM,
                      vertical: DesignSystem.spaceS,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(value: 'all', child: Text(l10n.all)),
                    DropdownMenuItem(value: 'donor', child: Text(l10n.donor)),
                    DropdownMenuItem(value: 'receiver', child: Text(l10n.receiver)),
                    DropdownMenuItem(value: 'admin', child: Text(l10n.admin)),
                  ],
                  onChanged: (value) => setState(() => _selectedUserRole = value ?? 'all'),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: DesignSystem.spaceL),
          
          // Users Table Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Users (${_getFilteredUsers().length})',
                style: DesignSystem.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              GBButton(
                text: l10n.refresh,
                onPressed: _loadUsers,
                variant: GBButtonVariant.secondary,
                size: GBButtonSize.small,
              ),
            ],
          ),
          
          const SizedBox(height: DesignSystem.spaceM),
          
          _getFilteredUsers().isEmpty
              ? GBEmptyState(
                  icon: Icons.people,
                  title: l10n.noUsersFound,
                  message: _userSearchQuery.isNotEmpty || _selectedUserRole != 'all'
                      ? l10n.noUsersMatchCriteria
                      : l10n.noUsersFoundInSystem,
                )
              : Container(
                  decoration: BoxDecoration(
                    color: DesignSystem.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                    border: Border.all(color: DesignSystem.getBorderColor(context)),
                  ),
                  child: Column(
                    children: _getFilteredUsers().take(20).map((user) {
                      final roleColor = _getRoleColor(user.role);
                      return _buildUserRow(
                        user.name,
                        user.email,
                        user.role.toUpperCase(),
                        'Active',
                        roleColor,
                      );
                    }).toList(),
                  ),
                ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'donor':
        return DesignSystem.accentPink;
      case 'receiver':
        return DesignSystem.secondaryGreen;
      case 'admin':
        return DesignSystem.primaryBlue;
      default:
        return DesignSystem.neutral600;
    }
  }

  List<User> _getFilteredUsers() {
    var filtered = _users;
    
    // Filter by role
    if (_selectedUserRole != 'all') {
      filtered = filtered.where((u) => u.role.toLowerCase() == _selectedUserRole.toLowerCase()).toList();
    }
    
    // Filter by search query
    if (_userSearchQuery.isNotEmpty) {
      final query = _userSearchQuery.toLowerCase();
      filtered = filtered.where((u) => 
        u.name.toLowerCase().contains(query) ||
        u.email.toLowerCase().contains(query)
      ).toList();
    }
    
    return filtered;
  }

  List<Donation> _getFilteredDonations() {
    var filtered = _donations;
    
    // Filter by category
    if (_selectedDonationCategory != 'all') {
      filtered = filtered.where((d) => d.category.toLowerCase() == _selectedDonationCategory.toLowerCase()).toList();
    }
    
    // Filter by search query
    if (_donationSearchQuery.isNotEmpty) {
      final query = _donationSearchQuery.toLowerCase();
      filtered = filtered.where((d) => 
        d.title.toLowerCase().contains(query) ||
        d.description.toLowerCase().contains(query) ||
        d.donorName.toLowerCase().contains(query)
      ).toList();
    }
    
    return filtered;
  }

  List<Widget> _buildRecentActivityItems() {
    List<Widget> activities = [];
    
    // Add recent users
    final recentUsers = _users.take(3).toList();
    final l10n = AppLocalizations.of(context)!;
    
    for (final user in recentUsers) {
      activities.add(_buildActivityItem(
        l10n.newUserRegisteredActivity,
        '${user.name} ${l10n.joinedAs} ${user.role}',
        _getTimeAgo(DateTime.tryParse(user.createdAt)),
        Icons.person_add,
        _getRoleColor(user.role),
      ));
    }
    
    // Add recent donations
    final recentDonations = _donations.take(2).toList();
    for (final donation in recentDonations) {
      activities.add(_buildActivityItem(
        l10n.newDonationPostedActivity,
        '${donation.donorName} ${l10n.donated} ${donation.title}',
        _getTimeAgo(DateTime.tryParse(donation.createdAt)),
        Icons.volunteer_activism,
        DesignSystem.accentPink,
      ));
    }
    
    // Add recent requests
    final recentRequests = _requests.take(2).toList();
    for (final request in recentRequests) {
      activities.add(_buildActivityItem(
        l10n.newRequestSubmittedActivity,
        '${request.receiverName} ${l10n.requestedHelp}',
        _getTimeAgo(DateTime.tryParse(request.createdAt)),
        Icons.assignment_add,
        DesignSystem.primaryBlue,
      ));
    }
    
    if (activities.isEmpty) {
      activities.add(
        Padding(
          padding: const EdgeInsets.all(DesignSystem.spaceXL),
          child: Center(
            child: Text(
              l10n.noRecentActivity,
              style: DesignSystem.bodyMedium(context).copyWith(
                color: DesignSystem.getTextColor(context).withOpacity(0.5),
              ),
            ),
          ),
        ),
      );
    }
    
    return activities.take(5).toList(); // Limit to 5 items
  }

  String _getTimeAgo(DateTime? dateTime) {
    final l10n = AppLocalizations.of(context)!;
    if (dateTime == null) return l10n.unknownTime;
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return l10n.justNowTime;
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${l10n.minutesAgo}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${l10n.hoursAgo}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${l10n.daysAgo}';
    } else {
      return '${(difference.inDays / 7).floor()} ${l10n.weeksAgo}';
    }
  }

  Widget _buildUserRow(String name, String email, String role, String status, Color roleColor) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spaceL),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: DesignSystem.getBorderColor(context),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: roleColor.withOpacity(0.1),
            child: Text(
              name[0],
              style: DesignSystem.bodyMedium(context).copyWith(
                color: roleColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: DesignSystem.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: DesignSystem.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  email,
                  style: DesignSystem.bodySmall(context).copyWith(
                    color: DesignSystem.getTextColor(context).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSystem.spaceM,
              vertical: DesignSystem.spaceXS,
            ),
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
            ),
            child: Text(
              role,
              style: DesignSystem.bodySmall(context).copyWith(
                color: roleColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: DesignSystem.spaceM),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSystem.spaceM,
              vertical: DesignSystem.spaceXS,
            ),
            decoration: BoxDecoration(
              color: status == 'Active' 
                  ? DesignSystem.success.withOpacity(0.1)
                  : DesignSystem.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
            ),
            child: Text(
              status,
              style: DesignSystem.bodySmall(context).copyWith(
                color: status == 'Active' ? DesignSystem.success : DesignSystem.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Requests Management Page
  Widget _buildRequestsContent(BuildContext context, AppLocalizations l10n) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final pendingRequests = _requests.where((r) => r.status == 'pending').toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignSystem.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Title
          Text(
            l10n.requests,
            style: DesignSystem.headlineMedium(context).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DesignSystem.spaceXS),
          Text(
            l10n.requestsSubtitle,
            style: DesignSystem.bodyMedium(context).copyWith(
              color: DesignSystem.getTextColor(context).withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: DesignSystem.spaceXL),
          
          // Request Stats - Real Data
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isDesktop ? 3 : 2,
            crossAxisSpacing: DesignSystem.spaceM,
            mainAxisSpacing: DesignSystem.spaceM,
            childAspectRatio: isDesktop ? 2.5 : 1.5,
            children: [
              GBStatCard(
                title: l10n.totalRequests,
                value: _stats['totalRequests'].toString(),
                icon: Icons.assignment,
                color: DesignSystem.primaryBlue,
              ),
              GBStatCard(
                title: 'Pending',
                value: _stats['pendingRequests'].toString(),
                icon: Icons.pending_actions,
                color: DesignSystem.warning,
              ),
              GBStatCard(
                title: 'Approved',
                value: (_stats['approvedRequests'] ?? 0).toString(),
                icon: Icons.check_circle,
                color: DesignSystem.success,
              ),
            ],
          ),
          
          const SizedBox(height: DesignSystem.spaceXL),
          
          // Pending Requests - Real Data
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l10n.pendingRequests} (${pendingRequests.length})',
                style: DesignSystem.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              GBButton(
                text: l10n.refresh,
                onPressed: _loadRequests,
                variant: GBButtonVariant.secondary,
                size: GBButtonSize.small,
              ),
            ],
          ),
          
          const SizedBox(height: DesignSystem.spaceM),
          
          pendingRequests.isEmpty
              ? GBEmptyState(
                  icon: Icons.assignment,
                  title: l10n.noPendingRequests,
                  message: l10n.noPendingRequestsMessage,
                )
              : Container(
                  decoration: BoxDecoration(
                    color: DesignSystem.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                    border: Border.all(color: DesignSystem.getBorderColor(context)),
                  ),
                  child: Column(
                    children: pendingRequests.take(10).map((request) {
                      return _buildRequestRow(
                        request.message ?? 'Request',
                        request.receiverName,
                        'Request',
                        request.status,
                      );
                    }).toList(),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildRequestRow(String title, String requester, String category, String status) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spaceL),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: DesignSystem.getBorderColor(context),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DesignSystem.accentPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
            ),
            child: Icon(
              Icons.assignment,
              color: DesignSystem.accentPurple,
              size: 20,
            ),
          ),
          const SizedBox(width: DesignSystem.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DesignSystem.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'By $requester • $category',
                  style: DesignSystem.bodySmall(context).copyWith(
                    color: DesignSystem.getTextColor(context).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          GBButton(
            text: 'Review',
            onPressed: () {},
            variant: GBButtonVariant.secondary,
            size: GBButtonSize.small,
          ),
        ],
      ),
    );
  }

  // Donations Management Page
  Widget _buildDonationsContent(BuildContext context, AppLocalizations l10n) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignSystem.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Title
          Text(
            l10n.donations,
            style: DesignSystem.headlineMedium(context).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DesignSystem.spaceXS),
          Text(
            l10n.donationsSubtitle,
            style: DesignSystem.bodyMedium(context).copyWith(
              color: DesignSystem.getTextColor(context).withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: DesignSystem.spaceXL),
          
          // Donation Stats - Real Data
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isDesktop ? 3 : 2,
            crossAxisSpacing: DesignSystem.spaceM,
            mainAxisSpacing: DesignSystem.spaceM,
            childAspectRatio: isDesktop ? 2.5 : 1.5,
            children: [
              GBStatCard(
                title: l10n.totalDonations,
                value: _stats['totalDonations'].toString(),
                icon: Icons.volunteer_activism,
                color: DesignSystem.accentPink,
              ),
              GBStatCard(
                title: 'Available',
                value: (_stats['availableDonations'] ?? 0).toString(),
                icon: Icons.check_circle,
                color: DesignSystem.success,
              ),
              GBStatCard(
                title: 'Claimed',
                value: (_stats['claimedDonations'] ?? 0).toString(),
                icon: Icons.done_all,
                color: DesignSystem.info,
              ),
            ],
          ),
          
          const SizedBox(height: DesignSystem.spaceXL),
          
          // Search and Filter Section
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  onChanged: (value) => setState(() => _donationSearchQuery = value),
                  decoration: InputDecoration(
                    hintText: '${l10n.search} ${l10n.donations.toLowerCase()}...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: DesignSystem.spaceM,
                      vertical: DesignSystem.spaceS,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DesignSystem.spaceM),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedDonationCategory,
                  decoration: InputDecoration(
                    labelText: l10n.category,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: DesignSystem.spaceM,
                      vertical: DesignSystem.spaceS,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(value: 'all', child: Text(l10n.all)),
                    DropdownMenuItem(value: 'food', child: Text(l10n.food)),
                    DropdownMenuItem(value: 'clothes', child: Text(l10n.clothes)),
                    DropdownMenuItem(value: 'books', child: Text(l10n.books)),
                    DropdownMenuItem(value: 'electronics', child: Text(l10n.electronics)),
                    DropdownMenuItem(value: 'furniture', child: Text(l10n.furniture)),
                    DropdownMenuItem(value: 'toys', child: Text(l10n.toys)),
                    DropdownMenuItem(value: 'other', child: Text(l10n.other)),
                  ],
                  onChanged: (value) => setState(() => _selectedDonationCategory = value ?? 'all'),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: DesignSystem.spaceL),
          
          // Donations Table Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Donations (${_getFilteredDonations().length})',
                style: DesignSystem.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              GBButton(
                text: l10n.refresh,
                onPressed: _loadDonations,
                variant: GBButtonVariant.secondary,
                size: GBButtonSize.small,
              ),
            ],
          ),
          
          const SizedBox(height: DesignSystem.spaceM),
          
          _getFilteredDonations().isEmpty
              ? GBEmptyState(
                  icon: Icons.volunteer_activism,
                  title: l10n.noDonations,
                  message: _donationSearchQuery.isNotEmpty || _selectedDonationCategory != 'all'
                      ? l10n.noDonationsMatchCriteria
                      : l10n.noDonationsFoundInSystem,
                )
              : Container(
                  decoration: BoxDecoration(
                    color: DesignSystem.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                    border: Border.all(color: DesignSystem.getBorderColor(context)),
                  ),
                  child: Column(
                    children: _getFilteredDonations().take(20).map((donation) {
                      return _buildDonationRow(
                        donation.title,
                        donation.donorName,
                        donation.category,
                        donation.isAvailable ? 'Available' : 'Claimed',
                      );
                    }).toList(),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildDonationRow(String title, String donor, String category, String status) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spaceL),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: DesignSystem.getBorderColor(context),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DesignSystem.accentPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
            ),
            child: Icon(
              Icons.volunteer_activism,
              color: DesignSystem.accentPink,
              size: 20,
            ),
          ),
          const SizedBox(width: DesignSystem.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DesignSystem.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'By $donor • $category',
                  style: DesignSystem.bodySmall(context).copyWith(
                    color: DesignSystem.getTextColor(context).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSystem.spaceM,
              vertical: DesignSystem.spaceXS,
            ),
            decoration: BoxDecoration(
              color: status == 'Available' 
                  ? DesignSystem.success.withOpacity(0.1)
                  : DesignSystem.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
            ),
            child: Text(
              status,
              style: DesignSystem.bodySmall(context).copyWith(
                color: status == 'Available' ? DesignSystem.success : DesignSystem.info,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Analytics Page
  Widget _buildAnalyticsContent(BuildContext context, AppLocalizations l10n) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Calculate analytics from real data
    final activeUsers = _users.length; // All users are considered active for now
    final successRate = _stats['totalRequests'] > 0 
        ? ((_stats['approvedRequests'] ?? 0) / _stats['totalRequests'] * 100).toStringAsFixed(1)
        : '0.0';
    final totalTransactions = _stats['totalRequests'] + _stats['totalDonations'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignSystem.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Title
          Text(
            l10n.analytics,
            style: DesignSystem.headlineMedium(context).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DesignSystem.spaceXS),
          Text(
            l10n.analyticsSubtitle,
            style: DesignSystem.bodyMedium(context).copyWith(
              color: DesignSystem.getTextColor(context).withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: DesignSystem.spaceXL),
          
          // Key Metrics - Real Data
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isDesktop ? 4 : 2,
            crossAxisSpacing: DesignSystem.spaceM,
            mainAxisSpacing: DesignSystem.spaceM,
            childAspectRatio: isDesktop ? 2 : 1.5,
            children: [
              GBStatCard(
                title: 'Donors',
                value: (_stats['donors'] ?? 0).toString(),
                icon: Icons.trending_up,
                color: DesignSystem.success,
              ),
              GBStatCard(
                title: l10n.activeUsers,
                value: activeUsers.toString(),
                icon: Icons.people_alt,
                color: DesignSystem.primaryBlue,
              ),
              GBStatCard(
                title: l10n.successRate,
                value: '$successRate%',
                icon: Icons.check_circle,
                color: DesignSystem.success,
              ),
              GBStatCard(
                title: 'Receivers',
                value: (_stats['receivers'] ?? 0).toString(),
                icon: Icons.inbox,
                color: DesignSystem.warning,
              ),
            ],
          ),
          
          const SizedBox(height: DesignSystem.spaceXL),
          
          // Platform Statistics - Real Data
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.platformStatistics,
                style: DesignSystem.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              GBButton(
                text: l10n.refresh,
                onPressed: _loadData,
                variant: GBButtonVariant.secondary,
                size: GBButtonSize.small,
              ),
            ],
          ),
          
          const SizedBox(height: DesignSystem.spaceM),
          
          Container(
            padding: const EdgeInsets.all(DesignSystem.spaceXL),
            decoration: BoxDecoration(
              color: DesignSystem.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(DesignSystem.radiusL),
              border: Border.all(color: DesignSystem.getBorderColor(context)),
            ),
            child: Column(
              children: [
                _buildStatRow(l10n.totalTransactions, totalTransactions.toString(), Icons.swap_horiz, DesignSystem.primaryBlue),
                const SizedBox(height: DesignSystem.spaceL),
                _buildStatRow(l10n.availableDonations, (_stats['availableDonations'] ?? 0).toString(), Icons.volunteer_activism, DesignSystem.success),
                const SizedBox(height: DesignSystem.spaceL),
                _buildStatRow(l10n.pendingRequests, _stats['pendingRequests'].toString(), Icons.pending_actions, DesignSystem.warning),
                const SizedBox(height: DesignSystem.spaceL),
                _buildStatRow(l10n.totalUsers, _stats['totalUsers'].toString(), Icons.people, DesignSystem.primaryBlue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: DesignSystem.spaceL),
        Expanded(
          child: Text(
            label,
            style: DesignSystem.bodyLarge(context).copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: DesignSystem.headlineSmall(context).copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  // Settings Page
  Widget _buildSettingsContent(BuildContext context, AppLocalizations l10n) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignSystem.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Title
          Text(
            l10n.settings,
            style: DesignSystem.headlineMedium(context).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DesignSystem.spaceXS),
          Text(
            l10n.settingsSubtitle,
            style: DesignSystem.bodyMedium(context).copyWith(
              color: DesignSystem.getTextColor(context).withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: DesignSystem.spaceXL),
          
          // Language Settings
          Text(
            l10n.language,
            style: DesignSystem.headlineSmall(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignSystem.spaceXS),
          Text(
            l10n.changeAppLanguage,
            style: DesignSystem.bodySmall(context).copyWith(
              color: DesignSystem.getTextColor(context).withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: DesignSystem.spaceM),
          
          Container(
            decoration: BoxDecoration(
              color: DesignSystem.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(DesignSystem.radiusL),
              border: Border.all(color: DesignSystem.getBorderColor(context)),
            ),
            child: Column(
              children: [
                _buildLanguageSettingRow(
                  l10n.english,
                  'en',
                  Icons.language,
                  localeProvider.locale.languageCode == 'en',
                  () {
                    localeProvider.setLocale(const Locale('en'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.languageChanged)),
                    );
                  },
                ),
                _buildLanguageSettingRow(
                  l10n.arabic,
                  'ar',
                  Icons.language,
                  localeProvider.locale.languageCode == 'ar',
                  () {
                    localeProvider.setLocale(const Locale('ar'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.languageChanged)),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: DesignSystem.spaceXL),
          
          // Notification Settings
          Text(
            l10n.notificationSettings,
            style: DesignSystem.headlineSmall(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignSystem.spaceXS),
          Text(
            l10n.manageYourNotifications,
            style: DesignSystem.bodySmall(context).copyWith(
              color: DesignSystem.getTextColor(context).withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: DesignSystem.spaceM),
          
          Container(
            decoration: BoxDecoration(
              color: DesignSystem.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(DesignSystem.radiusL),
              border: Border.all(color: DesignSystem.getBorderColor(context)),
            ),
            child: Column(
              children: [
                _buildToggleSettingRow(
                  l10n.pushNotifications,
                  l10n.receiveDonationNotifications,
                  Icons.notifications_active,
                  true,
                  (value) {},
                ),
                _buildToggleSettingRow(
                  l10n.emailNotifications,
                  l10n.receiveWeeklySummary,
                  Icons.email,
                  true,
                  (value) {},
                ),
                _buildToggleSettingRow(
                  l10n.systemUpdates,
                  l10n.notifyOnSystemUpdates,
                  Icons.system_update,
                  true,
                  (value) {},
                ),
              ],
            ),
          ),
          
          const SizedBox(height: DesignSystem.spaceXL),
          
          // Platform Information
          Text(
            l10n.platformInformation,
            style: DesignSystem.headlineSmall(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: DesignSystem.spaceM),
          
          Container(
            decoration: BoxDecoration(
              color: DesignSystem.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(DesignSystem.radiusL),
              border: Border.all(color: DesignSystem.getBorderColor(context)),
            ),
            child: Column(
              children: [
                _buildInfoRow(l10n.platformName, l10n.givingBridge, Icons.business),
                _buildInfoRow(l10n.version, '1.0.0', Icons.info),
                _buildInfoRow(l10n.supportEmail, 'support@givingbridge.com', Icons.email),
                _buildInfoRow(l10n.totalUsers, _stats['totalUsers'].toString(), Icons.people),
                _buildInfoRow(l10n.totalDonations, _stats['totalDonations'].toString(), Icons.volunteer_activism),
              ],
            ),
          ),
          
          const SizedBox(height: DesignSystem.spaceXL),
          
          // System Settings
          Text(
            l10n.systemSettings,
            style: DesignSystem.headlineSmall(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: DesignSystem.spaceM),
          
          Container(
            decoration: BoxDecoration(
              color: DesignSystem.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(DesignSystem.radiusL),
              border: Border.all(color: DesignSystem.getBorderColor(context)),
            ),
            child: Column(
              children: [
                _buildInfoRow(l10n.maxUploadSize, '10 MB', Icons.cloud_upload),
                _buildInfoRow(l10n.sessionTimeout, '30 minutes', Icons.timer),
                _buildInfoRow(l10n.apiVersion, 'v1.0', Icons.api),
                _buildInfoRow(l10n.databaseStatus, l10n.active, Icons.storage),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spaceL),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: DesignSystem.getBorderColor(context),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DesignSystem.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
            ),
            child: Icon(
              icon,
              color: DesignSystem.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: DesignSystem.spaceM),
          Expanded(
            child: Text(
              label,
              style: DesignSystem.bodyMedium(context).copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: DesignSystem.bodyMedium(context).copyWith(
              color: DesignSystem.getTextColor(context).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSettingRow(
    String label,
    String languageCode,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(DesignSystem.spaceL),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: DesignSystem.getBorderColor(context),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? DesignSystem.primaryBlue.withOpacity(0.1)
                      : DesignSystem.neutral200.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? DesignSystem.primaryBlue : DesignSystem.neutral600,
                  size: 20,
                ),
              ),
              const SizedBox(width: DesignSystem.spaceM),
              Expanded(
                child: Text(
                  label,
                  style: DesignSystem.bodyMedium(context).copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? DesignSystem.primaryBlue : null,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: DesignSystem.primaryBlue,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSettingRow(
    String label,
    String description,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spaceL),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: DesignSystem.getBorderColor(context),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DesignSystem.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
            ),
            child: Icon(
              icon,
              color: DesignSystem.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: DesignSystem.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: DesignSystem.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: DesignSystem.spaceXS),
                Text(
                  description,
                  style: DesignSystem.bodySmall(context).copyWith(
                    color: DesignSystem.getTextColor(context).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: DesignSystem.spaceM),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: DesignSystem.primaryBlue,
          ),
        ],
      ),
    );
  }

}
