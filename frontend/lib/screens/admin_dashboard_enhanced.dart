import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/theme/design_system.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';

class AdminDashboardEnhanced extends StatefulWidget {
  const AdminDashboardEnhanced({Key? key}) : super(key: key);

  @override
  State<AdminDashboardEnhanced> createState() => _AdminDashboardEnhancedState();
}

class _AdminDashboardEnhancedState extends State<AdminDashboardEnhanced> {
  String _currentRoute = 'overview';

  
  final Map<String, dynamic> _stats = {
    'totalUsers': 1250,
    'totalDonations': 3420,
    'totalRequests': 890,
    'pendingRequests': 45,
    'activeUsers': 234,
    'monthlyGrowth': 12.5,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Directionality(
      textDirection: localeProvider.textDirection,
      child: Scaffold(
        backgroundColor: DesignSystem.getBackgroundColor(context),
        body: Row(
          children: [
            // Sidebar
            _buildSidebar(context, l10n),
            
            // Main Content
            Expanded(
              child: _buildMainContent(context, l10n, authProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, AppLocalizations l10n) {
    final menuItems = [
      {'route': 'overview', 'label': 'Overview', 'icon': Icons.dashboard},
      {'route': 'users', 'label': 'Users', 'icon': Icons.people},
      {'route': 'requests', 'label': 'Requests', 'icon': Icons.assignment},
      {'route': 'donations', 'label': 'Donations', 'icon': Icons.volunteer_activism},
      {'route': 'analytics', 'label': 'Analytics', 'icon': Icons.analytics},
      {'route': 'settings', 'label': 'Settings', 'icon': Icons.settings},
    ];

    return Container(
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
          // Header
          Container(
            padding: const EdgeInsets.all(DesignSystem.spaceL),
            child: Row(
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
                Text(
                  'Admin Panel',
                  style: DesignSystem.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Menu Items
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isActive = _currentRoute == item['route'];
                
                return _buildMenuItem(item, isActive, index);
              },
            ),
          ),
        ],
      ),
    );
  } 
 Widget _buildMenuItem(Map<String, dynamic> item, bool isActive, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: DesignSystem.spaceM,
        vertical: DesignSystem.spaceXS,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _currentRoute = item['route'] as String;
            });
          },
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSystem.spaceM,
              vertical: DesignSystem.spaceS,
            ),
            decoration: BoxDecoration(
              color: isActive ? DesignSystem.primaryBlue.withOpacity(0.1) : null,
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              border: isActive
                  ? Border.all(color: DesignSystem.primaryBlue.withOpacity(0.3))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  item['icon'] as IconData,
                  color: isActive
                      ? DesignSystem.primaryBlue
                      : DesignSystem.getTextColor(context).withOpacity(0.7),
                  size: 20,
                ),
                const SizedBox(width: DesignSystem.spaceM),
                Text(
                  item['label'] as String,
                  style: DesignSystem.bodyMedium(context).copyWith(
                    color: isActive
                        ? DesignSystem.primaryBlue
                        : DesignSystem.getTextColor(context),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
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
  }

  Widget _buildMainContent(BuildContext context, AppLocalizations l10n, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context, l10n, authProvider),
          
          const SizedBox(height: DesignSystem.spaceL),
          
          // Content based on current route
          Expanded(
            child: _buildRouteContent(context, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n, AuthProvider authProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getPageTitle(_currentRoute),
              style: DesignSystem.headlineMedium(context).copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: DesignSystem.spaceXS),
            Text(
              _getPageSubtitle(_currentRoute),
              style: DesignSystem.bodyMedium(context).copyWith(
                color: DesignSystem.getTextColor(context).withOpacity(0.7),
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Language Toggle
            Container(
              decoration: BoxDecoration(
                color: DesignSystem.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                border: Border.all(color: DesignSystem.getBorderColor(context)),
              ),
              child: Row(
                children: [
                  _buildLanguageButton('en', 'EN'),
                  _buildLanguageButton('ar', 'ع'),
                ],
              ),
            ),
            
            const SizedBox(width: DesignSystem.spaceM),
            
            // Profile Menu
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignSystem.spaceM,
                vertical: DesignSystem.spaceS,
              ),
              decoration: BoxDecoration(
                color: DesignSystem.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                border: Border.all(color: DesignSystem.getBorderColor(context)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: DesignSystem.primaryBlue,
                    child: Text(
                      'A',
                      style: DesignSystem.bodySmall(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: DesignSystem.spaceS),
                  Text(
                    'Admin',
                    style: DesignSystem.bodyMedium(context).copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: DesignSystem.spaceS),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: DesignSystem.getTextColor(context).withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageButton(String locale, String label) {
    final localeProvider = Provider.of<LocaleProvider>(context);
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: DesignSystem.spaceM,
            mainAxisSpacing: DesignSystem.spaceM,
            childAspectRatio: 2.5,
            children: [
              _buildStatCard(
                'Total Users',
                _stats['totalUsers'].toString(),
                Icons.people,
                DesignSystem.primaryBlue,
                0,
              ),
              _buildStatCard(
                'Total Donations',
                _stats['totalDonations'].toString(),
                Icons.volunteer_activism,
                DesignSystem.successGreen,
                1,
              ),
              _buildStatCard(
                'Pending Requests',
                _stats['pendingRequests'].toString(),
                Icons.pending_actions,
                DesignSystem.warningOrange,
                2,
              ),
            ],
          ),
          
          const SizedBox(height: DesignSystem.spaceXL),
          
          // Recent Activity
          Text(
            'Recent Activity',
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
                _buildActivityItem(
                  'New donation request submitted',
                  'John Doe requested help for medical expenses',
                  '2 minutes ago',
                  Icons.assignment_add,
                  DesignSystem.primaryBlue,
                ),
                _buildActivityItem(
                  'Donation completed',
                  'Sarah donated \$500 to help with education',
                  '15 minutes ago',
                  Icons.check_circle,
                  DesignSystem.successGreen,
                ),
                _buildActivityItem(
                  'New user registered',
                  'Ahmed joined as a donor',
                  '1 hour ago',
                  Icons.person_add,
                  DesignSystem.infoBlue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, int index) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spaceL),
      decoration: BoxDecoration(
        color: DesignSystem.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(DesignSystem.radiusL),
        border: Border.all(color: DesignSystem.getBorderColor(context)),
      ),
      child: Row(
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
          const SizedBox(width: DesignSystem.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: DesignSystem.headlineMedium(context).copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: DesignSystem.bodySmall(context).copyWith(
                    color: DesignSystem.getTextColor(context).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 200 * index))
        .slideY(begin: 0.3, duration: 400.ms)
        .fadeIn();
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

  // Placeholder content for other routes
  Widget _buildUsersContent(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people,
            size: 64,
            color: DesignSystem.getTextColor(context).withOpacity(0.3),
          ),
          const SizedBox(height: DesignSystem.spaceM),
          Text(
            'Users Management',
            style: DesignSystem.headlineSmall(context).copyWith(
              color: DesignSystem.getTextColor(context).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: DesignSystem.spaceS),
          Text(
            'Coming soon...',
            style: DesignSystem.bodyMedium(context).copyWith(
              color: DesignSystem.getTextColor(context).withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsContent(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment,
            size: 64,
            color: DesignSystem.getTextColor(context).withOpacity(0.3),
          ),
          const SizedBox(height: DesignSystem.spaceM),
          Text(
            'Requests Management',
            style: DesignSystem.headlineSmall(context).copyWith(
              color: DesignSystem.getTextColor(context).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: DesignSystem.spaceS),
          Text(
            'Coming soon...',
            style: DesignSystem.bodyMedium(context).copyWith(
              color: DesignSystem.getTextColor(context).withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationsContent(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.volunteer_activism,
            size: 64,
            color: DesignSystem.getTextColor(context).withOpacity(0.3),
          ),
          const SizedBox(height: DesignSystem.spaceM),
          Text(
            'Donations Management',
            style: DesignSystem.headlineSmall(context).copyWith(
              color: DesignSystem.getTextColor(context).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: DesignSystem.spaceS),
          Text(
            'Coming soon...',
            style: DesignSystem.bodyMedium(context).copyWith(
              color: DesignSystem.getTextColor(context).withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics,
            size: 64,
            color: DesignSystem.getTextColor(context).withOpacity(0.3),
          ),
          const SizedBox(height: DesignSystem.spaceM),
          Text(
            'Analytics Dashboard',
            style: DesignSystem.headlineSmall(context).copyWith(
              color: DesignSystem.getTextColor(context).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: DesignSystem.spaceS),
          Text(
            'Coming soon...',
            style: DesignSystem.bodyMedium(context).copyWith(
              color: DesignSystem.getTextColor(context).withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings,
            size: 64,
            color: DesignSystem.getTextColor(context).withOpacity(0.3),
          ),
          const SizedBox(height: DesignSystem.spaceM),
          Text(
            'System Settings',
            style: DesignSystem.headlineSmall(context).copyWith(
              color: DesignSystem.getTextColor(context).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: DesignSystem.spaceS),
          Text(
            'Coming soon...',
            style: DesignSystem.bodyMedium(context).copyWith(
              color: DesignSystem.getTextColor(context).withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle(String route) {
    switch (route) {
      case 'overview':
        return 'Dashboard Overview';
      case 'users':
        return 'User Management';
      case 'requests':
        return 'Request Management';
      case 'donations':
        return 'Donation Management';
      case 'analytics':
        return 'Analytics';
      case 'settings':
        return 'Settings';
      default:
        return 'Dashboard';
    }
  }

  String _getPageSubtitle(String route) {
    switch (route) {
      case 'overview':
        return 'Monitor your platform performance and activity';
      case 'users':
        return 'Manage registered users and their permissions';
      case 'requests':
        return 'Review and manage donation requests';
      case 'donations':
        return 'Track and manage all donations';
      case 'analytics':
        return 'View detailed analytics and reports';
      case 'settings':
        return 'Configure system settings and preferences';
      default:
        return 'Welcome to the admin dashboard';
    }
  }
}