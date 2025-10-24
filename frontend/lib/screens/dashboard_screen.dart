import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
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
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated || authProvider.user == null) {
          return const LoginScreen();
        }

        final user = authProvider.user!;

        // Route to appropriate enhanced dashboard based on role
        return _getContentForRole(user);
      },
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
}
