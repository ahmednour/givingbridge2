import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_button.dart';
import '../models/user.dart';
import 'create_donation_screen.dart';
import 'my_donations_screen.dart';
import 'browse_donations_screen.dart';
import 'my_requests_screen.dart';
import 'incoming_requests_screen.dart';
import 'messages_screen.dart';
import 'admin_panel.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _onNavigationChanged(int index) {
    print('🔥 Navigation clicked: index $index');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user!;
    final menuItems = _getMenuItems(user.role);
    final selectedItem = menuItems[index];
    print('🔥 Selected item: ${selectedItem.title}');

    // Handle navigation based on menu item
    switch (selectedItem.title) {
      case 'My Donations':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyDonationsScreen()),
        );
        break;
      case 'Browse Donations':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const BrowseDonationsScreen()),
        );
        break;
      case 'My Requests':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyRequestsScreen()),
        );
        break;
      case 'Browse Requests':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const IncomingRequestsScreen()),
        );
        break;
      case 'Messages':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MessagesScreen()),
        );
        break;
      case 'Users':
      case 'Donations':
      case 'Requests':
      case 'Analytics':
      case 'Settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
        );
        break;
      default:
        // For dashboard and other items, just update the selected index
        setState(() {
          _selectedIndex = index;
        });
        break;
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
    final menuItems = _getMenuItems(user.role);

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
                'Giving Bridge',
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
                text: 'Sign Out',
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.volunteer_activism,
            size: 80,
            color: AppTheme.primaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'Welcome, ${user.name}!',
            style: AppTheme.headingLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Your generosity makes a difference. Start by creating a donation or browse requests from receivers.',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXL),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppButton(
                text: 'Create Donation',
                onPressed: () {
                  print('🔥 Create Donation button clicked!');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateDonationScreen()),
                  );
                },
                leftIcon: const Icon(Icons.add, size: 18, color: Colors.white),
              ),
              const SizedBox(width: AppTheme.spacingM),
              AppButton(
                text: 'View Requests',
                onPressed: () {},
                variant: ButtonVariant.outline,
                leftIcon: const Icon(Icons.list, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiverContent(User user) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 80,
            color: AppTheme.secondaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'Welcome, ${user.name}!',
            style: AppTheme.headingLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Browse available donations and make requests for items you need.',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXL),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppButton(
                text: 'Browse Donations',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BrowseDonationsScreen()),
                  );
                },
                variant: ButtonVariant.secondary,
                leftIcon:
                    const Icon(Icons.search, size: 18, color: Colors.white),
              ),
              const SizedBox(width: AppTheme.spacingM),
              AppButton(
                text: 'My Requests',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyRequestsScreen()),
                  );
                },
                variant: ButtonVariant.outline,
                leftIcon: const Icon(Icons.inbox, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminContent(User user) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.admin_panel_settings,
            size: 80,
            color: AppTheme.warningColor.withOpacity(0.3),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'Admin Dashboard',
            style: AppTheme.headingLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Manage users, monitor donations, and oversee platform activities.',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXL),
          Wrap(
            spacing: AppTheme.spacingM,
            runSpacing: AppTheme.spacingM,
            children: [
              AppButton(
                text: 'Manage Users',
                onPressed: () {},
                variant: ButtonVariant.secondary,
                leftIcon:
                    const Icon(Icons.people, size: 18, color: Colors.white),
              ),
              AppButton(
                text: 'View Analytics',
                onPressed: () {},
                variant: ButtonVariant.outline,
                leftIcon: const Icon(Icons.analytics, size: 18),
              ),
              AppButton(
                text: 'Platform Settings',
                onPressed: () {},
                variant: ButtonVariant.outline,
                leftIcon: const Icon(Icons.settings, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultContent(User user) {
    return Center(
      child: Text(
        'Welcome to Giving Bridge, ${user.name}!',
        style: AppTheme.headingLarge,
        textAlign: TextAlign.center,
      ),
    );
  }

  List<MenuItem> _getMenuItems(String role) {
    switch (role) {
      case 'donor':
        return [
          MenuItem('Dashboard', Icons.dashboard),
          MenuItem('My Donations', Icons.volunteer_activism),
          MenuItem('Browse Requests', Icons.list),
          MenuItem('Messages', Icons.message),
          MenuItem('Profile', Icons.person),
        ];
      case 'receiver':
        return [
          MenuItem('Dashboard', Icons.dashboard),
          MenuItem('Browse Donations', Icons.search),
          MenuItem('My Requests', Icons.inbox),
          MenuItem('Messages', Icons.message),
          MenuItem('Profile', Icons.person),
        ];
      case 'admin':
        return [
          MenuItem('Dashboard', Icons.dashboard),
          MenuItem('Users', Icons.people),
          MenuItem('Donations', Icons.volunteer_activism),
          MenuItem('Requests', Icons.inbox),
          MenuItem('Analytics', Icons.analytics),
          MenuItem('Settings', Icons.settings),
        ];
      default:
        return [
          MenuItem('Dashboard', Icons.dashboard),
          MenuItem('Profile', Icons.person),
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
