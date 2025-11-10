import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/landing_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/register_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );
      
      case '/landing':
        return MaterialPageRoute(
          builder: (_) => const LandingScreen(),
          settings: settings,
        );
      
      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      
      case '/register':
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );
      
      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      
      // Placeholder routes for navigation items
      case '/my-donations':
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text(AppLocalizations.of(context)!.myDonationsComingSoon)),
          ),
          settings: settings,
        );
      
      case '/browse-donations':
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text(AppLocalizations.of(context)!.browseDonationsComingSoon)),
          ),
          settings: settings,
        );
      
      case '/my-requests':
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text(AppLocalizations.of(context)!.myRequestsComingSoon)),
          ),
          settings: settings,
        );
      
      case '/browse-requests':
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text(AppLocalizations.of(context)!.browseRequestsComingSoon)),
          ),
          settings: settings,
        );
      
      case '/create-donation':
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text(AppLocalizations.of(context)!.createDonationComingSoon)),
          ),
          settings: settings,
        );
      
      case '/create-request':
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text(AppLocalizations.of(context)!.createRequestComingSoon)),
          ),
          settings: settings,
        );
      
      case '/profile':
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text(AppLocalizations.of(context)!.profileComingSoon)),
          ),
          settings: settings,
        );
      
      case '/messages':
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text(AppLocalizations.of(context)!.messagesComingSoon)),
          ),
          settings: settings,
        );
      
      case '/notifications':
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text(AppLocalizations.of(context)!.notificationsComingSoon)),
          ),
          settings: settings,
        );
      
      case '/help':
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text(AppLocalizations.of(context)!.helpSupportComingSoon)),
          ),
          settings: settings,
        );
      
      case '/analytics':
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text(AppLocalizations.of(context)!.analyticsComingSoon)),
          ),
          settings: settings,
        );
      
      case '/admin/users':
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text(AppLocalizations.of(context)!.userManagementComingSoon)),
          ),
          settings: settings,
        );
      
      case '/admin/reports':
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text(AppLocalizations.of(context)!.reportsComingSoon)),
          ),
          settings: settings,
        );
      
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context)!.pageNotFound)),
            body: Center(
              child: Text(AppLocalizations.of(context)!.noRouteDefinedForPath),
            ),
          ),
          settings: settings,
        );
    }
  }
}