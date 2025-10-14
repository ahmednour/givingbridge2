import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_button.dart';
import '../models/user.dart';
import '../l10n/app_localizations.dart';
import 'my_donations_screen.dart';
import 'browse_donations_screen.dart';
import 'my_requests_screen.dart';
import 'incoming_requests_screen.dart';
import 'messages_screen_enhanced.dart';
import 'login_screen.dart';
import 'donor_dashboard_enhanced.dart';
import 'receiver_dashboard_enhanced.dart';
import 'admin_dashboard_enhanced.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _onNavigationChanged(int index) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user!;
    final l10n = AppLocalizations.of(context)!;
    final menuItems = _getMenuItems(user.role, l10n);
    final selectedItem = menuItems[index];

    // Handle navigation based on menu item
    if (selectedItem.title == l10n.myDonations) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyDonationsScreen()),
      );
    } else if (selectedItem.title == l10n.browseDonations) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BrowseDonationsScreen()),
      );
    } else if (selectedItem.title == l10n.myRequests) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyRequestsScreen()),
      );
    } else if (selectedItem.title == l10n.browseRequests) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const IncomingRequestsScreen()),
      );
    } else if (selectedItem.title == l10n.messages) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MessagesScreenEnhanced()),
      );
    } else if (selectedItem.title == l10n.users ||
        selectedItem.title == l10n.donations ||
        selectedItem.title == l10n.requests ||
        selectedItem.title == l10n.analytics ||
        selectedItem.title == l10n.settings) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboardEnhanced()),
      );
    } else {
      // For dashboard and other items, just update the selected index
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated || authProvider.user == null) {
          return const LoginScreen();
        }

        final user = authProvider.user!;

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: Row(
            children: [
              // Sidebar
              Container(
                width: 280,
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceColor,
                  border: Border(
                    right: BorderSide(color: AppTheme.borderColor),
                  ),
                ),
                child: _buildSidebar(user),
              ),
              // Main content
              Expanded(
                child: Column(
                  children: [
                    _buildHeader(user),
                    Expanded(
                      child: _buildMainContent(user),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebar(User user) {
    final l10n = AppLocalizations.of(context)!;
    final menuItems = _getMenuItems(user.role, l10n);

    return Column(
      children: [
        // Logo and brand
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Text(
                l10n.appTitle,
                style: AppTheme.headingSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        const Divider(color: AppTheme.borderColor, height: 1),

        // Navigation menu
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              final isSelected = _selectedIndex == index;

              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingXS,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _onNavigationChanged(index),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.textSecondaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: AppTheme.spacingM),
                          Text(
                            item.title,
                            style: AppTheme.bodyMedium.copyWith(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : AppTheme.textPrimaryColor,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const Divider(color: AppTheme.borderColor, height: 1),

        // User profile section
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user.role.toUpperCase(),
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingM),
              AppButton(
                text: l10n.logout,
                onPressed: _handleLogout,
                variant: ButtonVariant.outline,
                size: ButtonSize.small,
                width: double.infinity,
                leftIcon: const Icon(
                  Icons.logout,
                  size: 16,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(User user) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXL),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _getPageTitle(user.role),
              style: AppTheme.headingMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getRoleIcon(user.role),
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  '${user.role.toUpperCase()} DASHBOARD',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(User user) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      child: _getContentForRole(user),
    );
  }

  Widget _getContentForRole(User user) {
    switch (user.role) {
      case 'donor':
        return _buildDonorContent(user);
      case 'receiver':
        return _buildReceiverContent(user);
      case 'admin':
        return _buildAdminContent(user);
      default:
        return _buildDefaultContent(user);
    }
  }

  Widget _buildDonorContent(User user) {
    return const DonorDashboardEnhanced();
  }

  Widget _buildReceiverContent(User user) {
    return const ReceiverDashboardEnhanced();
  }

  Widget _buildAdminContent(User user) {
    return const AdminDashboardEnhanced();
  }

  Widget _buildDefaultContent(User user) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Text(
        l10n.welcomeUser(user.name),
        style: AppTheme.headingLarge,
        textAlign: TextAlign.center,
      ),
    );
  }

  List<MenuItem> _getMenuItems(String role, AppLocalizations l10n) {
    switch (role) {
      case 'donor':
        return [
          MenuItem(l10n.dashboard, Icons.dashboard),
          MenuItem(l10n.myDonations, Icons.volunteer_activism),
          MenuItem(l10n.browseRequests, Icons.list),
          MenuItem(l10n.messages, Icons.message),
          MenuItem(l10n.profile, Icons.person),
        ];
      case 'receiver':
        return [
          MenuItem(l10n.dashboard, Icons.dashboard),
          MenuItem(l10n.browseDonations, Icons.search),
          MenuItem(l10n.myRequests, Icons.inbox),
          MenuItem(l10n.messages, Icons.message),
          MenuItem(l10n.profile, Icons.person),
        ];
      case 'admin':
        return [
          MenuItem(l10n.dashboard, Icons.dashboard),
          MenuItem(l10n.users, Icons.people),
          MenuItem(l10n.donations, Icons.volunteer_activism),
          MenuItem(l10n.requests, Icons.inbox),
          MenuItem(l10n.analytics, Icons.analytics),
          MenuItem(l10n.settings, Icons.settings),
        ];
      default:
        return [
          MenuItem(l10n.dashboard, Icons.dashboard),
          MenuItem(l10n.profile, Icons.person),
        ];
    }
  }

  String _getPageTitle(String role) {
    switch (role) {
      case 'donor':
        return 'Donor Dashboard';
      case 'receiver':
        return 'Receiver Dashboard';
      case 'admin':
        return 'Admin Panel';
      default:
        return 'Dashboard';
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'donor':
        return Icons.volunteer_activism;
      case 'receiver':
        return Icons.person_outline;
      case 'admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }
}

class MenuItem {
  final String title;
  final IconData icon;

  MenuItem(this.title, this.icon);
}
