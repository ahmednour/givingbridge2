import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/utils/responsive_utils.dart';
import '../widgets/common/mobile_navigation.dart';
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
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated || authProvider.user == null) {
          return const LoginScreen();
        }

        final user = authProvider.user!;

        // Use responsive layout
        return ResponsiveLayoutBuilder(
          builder: (context, screenSize) {
            if (ResponsiveUtils.isMobile(context)) {
              return _buildMobileLayout(user);
            } else {
              return _getContentForRole(user);
            }
          },
        );
      },
    );
  }

  Widget _buildMobileLayout(user) {
    final navItems = _getNavigationItems(user);
    
    return Scaffold(
      key: _scaffoldKey,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _getContentForRole(user),
          // Add other screens based on navigation items
          ...navItems.skip(1).map((item) => _getScreenForRoute(item.route ?? '/')),
        ],
      ),
      bottomNavigationBar: MobileBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: navItems.map((item) => MobileNavItem(
          icon: item.icon,
          activeIcon: item.icon, // You can customize active icons
          label: item.title,
        )).toList(),
      ),
      drawer: ResponsiveUtils.isMobile(context) 
          ? MobileDrawer(
              items: _getDrawerItems(user),
              currentRoute: '/',
            )
          : null,
    );
  }

  Widget _getContentForRole(user) {
    switch (user.role) {
      case 'donor':
        return const DonorDashboardEnhanced();
      case 'receiver':
        return const ReceiverDashboardEnhanced();
      case 'admin':
        return const AdminDashboardEnhanced();
      default:
        // Fallback to donor dashboard for unknown roles
        return const DonorDashboardEnhanced();
    }
  }

  List<MobileDrawerItem> _getNavigationItems(user) {
    final baseItems = [
      MobileDrawerItem(
        icon: Icons.dashboard,
        title: 'Dashboard',
        route: '/',
        onTap: () => setState(() => _currentIndex = 0),
      ),
    ];

    switch (user.role) {
      case 'donor':
        return [
          ...baseItems,
          MobileDrawerItem(
            icon: Icons.volunteer_activism,
            title: 'My Donations',
            route: '/my-donations',
            onTap: () => Navigator.pushNamed(context, '/my-donations'),
          ),
          MobileDrawerItem(
            icon: Icons.search,
            title: 'Browse Requests',
            route: '/browse-requests',
            onTap: () => Navigator.pushNamed(context, '/browse-requests'),
          ),
          MobileDrawerItem(
            icon: Icons.add_circle,
            title: 'Create Donation',
            route: '/create-donation',
            onTap: () => Navigator.pushNamed(context, '/create-donation'),
          ),
        ];
      case 'receiver':
        return [
          ...baseItems,
          MobileDrawerItem(
            icon: Icons.inbox,
            title: 'My Requests',
            route: '/my-requests',
            onTap: () => Navigator.pushNamed(context, '/my-requests'),
          ),
          MobileDrawerItem(
            icon: Icons.search,
            title: 'Browse Donations',
            route: '/browse-donations',
            onTap: () => Navigator.pushNamed(context, '/browse-donations'),
          ),
          MobileDrawerItem(
            icon: Icons.add_circle,
            title: 'Create Request',
            route: '/create-request',
            onTap: () => Navigator.pushNamed(context, '/create-request'),
          ),
        ];
      case 'admin':
        return [
          ...baseItems,
          MobileDrawerItem(
            icon: Icons.analytics,
            title: 'Analytics',
            route: '/analytics',
            onTap: () => Navigator.pushNamed(context, '/analytics'),
          ),
          MobileDrawerItem(
            icon: Icons.people,
            title: 'Users',
            route: '/admin/users',
            onTap: () => Navigator.pushNamed(context, '/admin/users'),
          ),
          MobileDrawerItem(
            icon: Icons.report,
            title: 'Reports',
            route: '/admin/reports',
            onTap: () => Navigator.pushNamed(context, '/admin/reports'),
          ),
        ];
      default:
        return baseItems;
    }
  }

  List<MobileDrawerItem> _getDrawerItems(user) {
    return [
      MobileDrawerItem(
        icon: Icons.person,
        title: 'Profile',
        subtitle: 'Manage your account',
        onTap: () => Navigator.pushNamed(context, '/profile'),
      ),
      MobileDrawerItem(
        icon: Icons.message,
        title: 'Messages',
        subtitle: 'Chat with users',
        onTap: () => Navigator.pushNamed(context, '/messages'),
      ),
      MobileDrawerItem(
        icon: Icons.notifications,
        title: 'Notifications',
        subtitle: 'Manage alerts',
        onTap: () => Navigator.pushNamed(context, '/notifications'),
      ),
      MobileDrawerItem(
        icon: Icons.help,
        title: 'Help & Support',
        subtitle: 'Get assistance',
        onTap: () => Navigator.pushNamed(context, '/help'),
      ),
    ];
  }

  Widget _getScreenForRoute(String route) {
    // Return placeholder widgets for now
    // In a real app, you'd return the actual screens
    return Center(
      child: Text('Screen for route: $route'),
    );
  }
}
