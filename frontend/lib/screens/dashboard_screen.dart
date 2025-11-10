import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../core/utils/responsive_utils.dart';
import '../widgets/common/mobile_navigation.dart';
import '../widgets/rtl/directional_app_bar.dart';
import '../widgets/rtl/directional_drawer.dart';
import '../widgets/rtl/directional_bottom_navigation.dart';
import '../widgets/language_selector.dart';
import '../l10n/app_localizations.dart';
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
    return Consumer2<AuthProvider, LocaleProvider>(
      builder: (context, authProvider, localeProvider, child) {
        // Show loading state
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check authentication
        if (!authProvider.isAuthenticated || authProvider.user == null) {
          return const LoginScreen();
        }

        final user = authProvider.user!;
        final l10n = AppLocalizations.of(context)!;

        // Wrap with RTL directionality
        return Directionality(
          textDirection: localeProvider.textDirection,
          child: ResponsiveLayoutBuilder(
            builder: (context, screenSize) {
              if (ResponsiveUtils.isMobile(context)) {
                return _buildMobileLayout(user, l10n, localeProvider);
              } else {
                return _buildDesktopLayout(user, l10n, localeProvider);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(
      user, AppLocalizations l10n, LocaleProvider localeProvider) {
    final navItems = _getNavigationItems(user, l10n);

    return Scaffold(
      key: _scaffoldKey,
      appBar: DirectionalAppBar(
        title: Text(l10n.appTitle),
        centerTitle: localeProvider.isRTL,
        actions: [
          const LanguageToggleButton(),
          IconButton(
            icon: Icon(localeProvider.getDirectionalIcon(
              start: Icons.more_vert,
              end: Icons.more_vert,
            )),
            onPressed: () => _showLanguageSelector(context),
            tooltip: l10n.selectLanguage,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _getContentForRole(user),
          // Add other screens based on navigation items
          ...navItems
              .skip(1)
              .map((item) => _getScreenForRoute(item.route ?? '/')),
        ],
      ),
      bottomNavigationBar: _buildRTLBottomNavigation(navItems, localeProvider),
      drawer: ResponsiveUtils.isMobile(context)
          ? DirectionalDrawer(
              child: _buildRTLDrawerContent(user, l10n, localeProvider),
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

  List<MobileDrawerItem> _getNavigationItems(user, AppLocalizations l10n) {
    final baseItems = [
      MobileDrawerItem(
        icon: Icons.dashboard,
        title: l10n.dashboard,
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
            title: l10n.myDonations,
            route: '/my-donations',
            onTap: () => Navigator.pushNamed(context, '/my-donations'),
          ),
          MobileDrawerItem(
            icon: Icons.search,
            title: l10n.browseRequests,
            route: '/browse-requests',
            onTap: () => Navigator.pushNamed(context, '/browse-requests'),
          ),
          MobileDrawerItem(
            icon: Icons.add_circle,
            title: l10n.createDonation,
            route: '/create-donation',
            onTap: () => Navigator.pushNamed(context, '/create-donation'),
          ),
        ];
      case 'receiver':
        return [
          ...baseItems,
          MobileDrawerItem(
            icon: Icons.inbox,
            title: l10n.myRequests,
            route: '/my-requests',
            onTap: () => Navigator.pushNamed(context, '/my-requests'),
          ),
          MobileDrawerItem(
            icon: Icons.search,
            title: l10n.browseDonations,
            route: '/browse-donations',
            onTap: () => Navigator.pushNamed(context, '/browse-donations'),
          ),
          MobileDrawerItem(
            icon: Icons.add_circle,
            title: l10n.createRequest,
            route: '/create-request',
            onTap: () => Navigator.pushNamed(context, '/create-request'),
          ),
        ];
      case 'admin':
        return [
          ...baseItems,
          MobileDrawerItem(
            icon: Icons.analytics,
            title: l10n.analytics,
            route: '/analytics',
            onTap: () => Navigator.pushNamed(context, '/analytics'),
          ),
          MobileDrawerItem(
            icon: Icons.people,
            title: l10n.users,
            route: '/admin/users',
            onTap: () => Navigator.pushNamed(context, '/admin/users'),
          ),
          MobileDrawerItem(
            icon: Icons.report,
            title: l10n.reports,
            route: '/admin/reports',
            onTap: () => Navigator.pushNamed(context, '/admin/reports'),
          ),
        ];
      default:
        return baseItems;
    }
  }

  List<MobileDrawerItem> _getDrawerItems(user, AppLocalizations l10n) {
    return [
      MobileDrawerItem(
        icon: Icons.person,
        title: l10n.profile,
        subtitle: l10n.manageAccount,
        onTap: () => Navigator.pushNamed(context, '/profile'),
      ),
      MobileDrawerItem(
        icon: Icons.message,
        title: l10n.messages,
        subtitle: l10n.chatWithUsers,
        onTap: () => Navigator.pushNamed(context, '/messages'),
      ),
      MobileDrawerItem(
        icon: Icons.notifications,
        title: l10n.notifications,
        subtitle: l10n.manageAlerts,
        onTap: () => Navigator.pushNamed(context, '/notifications'),
      ),
      MobileDrawerItem(
        icon: Icons.help,
        title: l10n.helpSupport,
        subtitle: l10n.getAssistance,
        onTap: () => Navigator.pushNamed(context, '/help'),
      ),
    ];
  }

  Widget _getScreenForRoute(String route) {
    // Return placeholder widgets for now
    // In a real app, you'd return the actual screens
    return Center(
      child: Text(AppLocalizations.of(context)!.screenForRoute(route)),
    );
  }

  Widget _buildDesktopLayout(
      user, AppLocalizations l10n, LocaleProvider localeProvider) {
    return Scaffold(
      appBar: DirectionalAppBar(
        title: Text(l10n.appTitle),
        centerTitle: localeProvider.isRTL,
        actions: [
          const LanguageToggleButton(),
          IconButton(
            icon: Icon(localeProvider.getDirectionalIcon(
              start: Icons.more_vert,
              end: Icons.more_vert,
            )),
            onPressed: () => _showLanguageSelector(context),
            tooltip: l10n.selectLanguage,
          ),
        ],
      ),
      body: _getContentForRole(user),
      drawer: DirectionalDrawer(
        child: _buildRTLDrawerContent(user, l10n, localeProvider),
      ),
    );
  }

  Widget _buildRTLBottomNavigation(
      List<MobileDrawerItem> navItems, LocaleProvider localeProvider) {
    final bottomNavItems = navItems
        .take(4)
        .map((item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              label: item.title,
            ))
        .toList();

    return DirectionalBottomNavigationBar(
      items: bottomNavItems,
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
    );
  }

  Widget _buildRTLDrawerContent(
      user, AppLocalizations l10n, LocaleProvider localeProvider) {
    final drawerItems = _getDrawerItems(user, l10n);

    return Column(
      children: [
        DirectionalDrawerHeader(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8)
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: localeProvider.isRTL
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                user.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user.email,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: drawerItems
                .map((item) => DirectionalDrawerItem(
                      leading: Icon(item.icon),
                      title: Text(item.title),
                      subtitle:
                          item.subtitle != null ? Text(item.subtitle!) : null,
                      onTap: item.onTap,
                    ))
                .toList(),
          ),
        ),
        const Divider(),
        DirectionalDrawerItem(
          leading: const Icon(Icons.logout),
          title: Text(l10n.logout),
          onTap: () {
            Navigator.pop(context);
            Provider.of<AuthProvider>(context, listen: false).logout();
          },
        ),
      ],
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const LanguageSelector(showAsButton: false),
    );
  }
}
