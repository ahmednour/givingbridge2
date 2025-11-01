import 'package:flutter/material.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/landing_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/login_screen.dart';

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
      
      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      
      // Placeholder routes for navigation items
      case '/my-donations':
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('My Donations - Coming Soon')),
          ),
          settings: settings,
        );
      
      case '/browse-donations':
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Browse Donations - Coming Soon')),
          ),
          settings: settings,
        );
      
      case '/my-requests':
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('My Requests - Coming Soon')),
          ),
          settings: settings,
        );
      
      case '/browse-requests':
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Browse Requests - Coming Soon')),
          ),
          settings: settings,
        );
      
      case '/create-donation':
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Create Donation - Coming Soon')),
          ),
          settings: settings,
        );
      
      case '/create-request':
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Create Request - Coming Soon')),
          ),
          settings: settings,
        );
      
      case '/profile':
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Profile - Coming Soon')),
          ),
          settings: settings,
        );
      
      case '/messages':
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Messages - Coming Soon')),
          ),
          settings: settings,
        );
      
      case '/notifications':
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Notifications - Coming Soon')),
          ),
          settings: settings,
        );
      
      case '/help':
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Help & Support - Coming Soon')),
          ),
          settings: settings,
        );
      
      case '/analytics':
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Analytics - Coming Soon')),
          ),
          settings: settings,
        );
      
      case '/admin/users':
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('User Management - Coming Soon')),
          ),
          settings: settings,
        );
      
      case '/admin/reports':
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Reports - Coming Soon')),
          ),
          settings: settings,
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: const Center(
              child: Text('No route defined for this path'),
            ),
          ),
          settings: settings,
        );
    }
  }
}