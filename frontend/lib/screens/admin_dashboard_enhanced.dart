import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../models/donation.dart';
import '../l10n/app_localizations.dart';

class AdminDashboardEnhanced extends StatefulWidget {
  const AdminDashboardEnhanced({Key? key}) : super(key: key);

  @override
  State<AdminDashboardEnhanced> createState() => _AdminDashboardEnhancedState();
}

class _AdminDashboardEnhancedState extends State<AdminDashboardEnhanced>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<User> _users = [];
  List<Donation> _donations = [];
  List<dynamic> _requests = [];

  Map<String, int> _donationStats = {};
  Map<String, int> _requestStats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      setState(() {
        _users = response.data ?? [];
      });
    }
  }

  Future<void> _loadDonations() async {
    final response = await ApiService.getDonations();
    if (response.success && mounted) {
      setState(() {
        _donations = response.data ?? [];
      });
    }
  }

  Future<void> _loadRequests() async {
    final response = await ApiService.getRequests();
    if (response.success && mounted) {
      setState(() {
        _requests = response.data ?? [];
      });
    }
  }

  Future<void> _loadStats() async {
    // Calculate donation stats
    final donationResponse = await ApiService.getDonations();
    if (donationResponse.success) {
      final donations = donationResponse.data ?? [];
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
    if (requestResponse.success) {
      final requests = requestResponse.data ?? [];
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
              labelColor: AppTheme.warningColor,
              unselectedLabelColor: AppTheme.textSecondaryColor,
              indicatorColor: AppTheme.warningColor,
              indicatorWeight: 3,
              isScrollable: true,
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
                Tab(text: l10n.users),
                Tab(text: l10n.donations),
                Tab(text: l10n.requests),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(context, isDesktop),
                _buildUsersTab(context, isDesktop),
                _buildDonationsTab(context, isDesktop),
                _buildRequestsTab(context, isDesktop),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, bool isDesktop) {
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

                  if (isDesktop)
                    Row(
                      children: [
                        Expanded(
                            child: _buildStatCard(
                                l10n.totalUsers,
                                _users.length.toString(),
                                Icons.people,
                                AppTheme.primaryColor)),
                        const SizedBox(width: AppTheme.spacingL),
                        Expanded(
                            child: _buildStatCard(
                                l10n.totalDonations,
                                _donationStats['total']?.toString() ?? '0',
                                Icons.volunteer_activism,
                                AppTheme.secondaryColor)),
                        const SizedBox(width: AppTheme.spacingL),
                        Expanded(
                            child: _buildStatCard(
                                l10n.totalRequests,
                                _requestStats['total']?.toString() ?? '0',
                                Icons.inbox,
                                AppTheme.warningColor)),
                        const SizedBox(width: AppTheme.spacingL),
                        Expanded(
                            child: _buildStatCard(
                                l10n.activeItems,
                                _donationStats['available']?.toString() ?? '0',
                                Icons.check_circle,
                                AppTheme.successColor)),
                      ],
                    )
                  else
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: AppTheme.spacingM,
                      mainAxisSpacing: AppTheme.spacingM,
                      childAspectRatio: 1.3,
                      children: [
                        _buildStatCard(
                            l10n.totalUsers,
                            _users.length.toString(),
                            Icons.people,
                            AppTheme.primaryColor),
                        _buildStatCard(
                            l10n.totalDonations,
                            _donationStats['total']?.toString() ?? '0',
                            Icons.volunteer_activism,
                            AppTheme.secondaryColor),
                        _buildStatCard(
                            l10n.totalRequests,
                            _requestStats['total']?.toString() ?? '0',
                            Icons.inbox,
                            AppTheme.warningColor),
                        _buildStatCard(
                            l10n.activeItems,
                            _donationStats['available']?.toString() ?? '0',
                            Icons.check_circle,
                            AppTheme.successColor),
                      ],
                    ),

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

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
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
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            title,
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

  Widget _buildUsersTab(BuildContext context, bool isDesktop) {
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
                  ..._users.map((user) => _buildUserCard(user)),
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

  Widget _buildDonationsTab(BuildContext context, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;
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
                  if (_donations.isEmpty)
                    Center(child: Text(l10n.noDonations))
                  else
                    ..._donations
                        .map((donation) => _buildDonationCardAdmin(donation)),
                ],
              ),
            ),
          ),
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

  Widget _buildRequestsTab(BuildContext context, bool isDesktop) {
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
}
