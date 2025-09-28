import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../widgets/custom_navigation.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'donor_dashboard.dart';
import 'receiver_dashboard.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late List<NavigationItem> _navigationItems;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _initializeNavigation();
  }

  void _initializeNavigation() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userRole = authProvider.userRole;

    if (userRole == UserRole.donor) {
      _navigationItems = [
        NavigationItem(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard,
          route: '/donor-dashboard',
        ),
        NavigationItem(
          label: 'Browse',
          icon: Icons.search_outlined,
          activeIcon: Icons.search,
          route: '/browse',
        ),
        NavigationItem(
          label: 'Notifications',
          icon: Icons.notifications_outlined,
          activeIcon: Icons.notifications,
          route: '/notifications',
        ),
        NavigationItem(
          label: 'Profile',
          icon: Icons.person_outlined,
          activeIcon: Icons.person,
          route: '/profile',
        ),
      ];

      _screens = [
        const DonorDashboard(),
        const _BrowseScreen(),
        const NotificationsScreen(),
        const ProfileScreen(),
      ];
    } else {
      _navigationItems = [
        NavigationItem(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard,
          route: '/receiver-dashboard',
        ),
        NavigationItem(
          label: 'Browse',
          icon: Icons.inventory_outlined,
          activeIcon: Icons.inventory,
          route: '/browse',
        ),
        NavigationItem(
          label: 'Notifications',
          icon: Icons.notifications_outlined,
          activeIcon: Icons.notifications,
          route: '/notifications',
        ),
        NavigationItem(
          label: 'Profile',
          icon: Icons.person_outlined,
          activeIcon: Icons.person,
          route: '/profile',
        ),
      ];

      _screens = [
        const ReceiverDashboard(),
        const _BrowseScreen(),
        const NotificationsScreen(),
        const ProfileScreen(),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    return Scaffold(
      body: Row(
        children: [
          // Side navigation for desktop
          if (isDesktop)
            CustomSideNavigation(
              items: _navigationItems,
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),

          // Main content
          Expanded(
            child: Column(
              children: [
                // App bar
                _buildAppBar(context),

                // Content
                Expanded(
                  child: _screens[_currentIndex],
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom navigation for mobile
      bottomNavigationBar: isDesktop
          ? null
          : CustomBottomNavigation(
              items: _navigationItems,
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing24,
        vertical: AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo (mobile only)
          if (MediaQuery.of(context).size.width <= 768) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),
          ],

          // Title
          Text(
            _getScreenTitle(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          // Theme toggle
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: themeProvider.toggleTheme,
            tooltip: 'Toggle theme',
          ),

          const SizedBox(width: AppTheme.spacing8),

          // User avatar
          GestureDetector(
            onTap: () => setState(() => _currentIndex = _screens.length - 1),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: authProvider.user?.avatarUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        authProvider.user!.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            color: AppTheme.primaryColor,
                            size: 24,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.person,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _getScreenTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Browse Donations';
      case 2:
        return 'Notifications';
      case 3:
        return 'Profile';
      default:
        return 'Giving Bridge';
    }
  }
}

class _BrowseScreen extends StatelessWidget {
  const _BrowseScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            'Browse Feature',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            'Coming Soon!',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.brightness == Brightness.dark
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
