import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/route_constants.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/browse_donations_screen.dart';
import '../screens/create_donation_screen_enhanced.dart';
import '../screens/my_donations_screen.dart';
import '../screens/my_requests_screen.dart';
import '../screens/incoming_requests_screen.dart';
import '../screens/messages_screen_enhanced.dart';
import '../screens/chat_screen_enhanced.dart';
import '../screens/admin_dashboard_enhanced.dart';
import '../screens/donor_dashboard_enhanced.dart';
import '../screens/receiver_dashboard_enhanced.dart';
import '../screens/notifications_screen.dart';
import '../screens/landing_screen.dart';

/// Navigation service for managing app routing
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Get current context
  static BuildContext? get currentContext => navigatorKey.currentContext;

  /// Navigate to a route
  static Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  /// Navigate and replace current route
  static Future<dynamic> navigateAndReplace(String routeName,
      {Object? arguments}) {
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  /// Navigate and clear stack
  static Future<dynamic> navigateAndClearStack(String routeName,
      {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Go back
  static void goBack([dynamic result]) {
    navigatorKey.currentState!.pop(result);
  }

  /// Check if can go back
  static bool canGoBack() {
    return navigatorKey.currentState!.canPop();
  }

  /// Pop until route
  static void popUntil(String routeName) {
    navigatorKey.currentState!.popUntil(ModalRoute.withName(routeName));
  }

  /// Show dialog
  static Future<dynamic> showDialog(Widget dialog) {
    return showGeneralDialog(
      context: currentContext!,
      pageBuilder: (context, animation, secondaryAnimation) => dialog,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  /// Show bottom sheet
  static Future<dynamic> showBottomSheet(Widget bottomSheet) {
    return showModalBottomSheet(
      context: currentContext!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => bottomSheet,
    );
  }

  /// Navigate to login
  static Future<dynamic> navigateToLogin() {
    return navigateAndClearStack(RouteConstants.login);
  }

  /// Navigate to register
  static Future<dynamic> navigateToRegister() {
    return navigateTo(RouteConstants.register);
  }

  /// Navigate to dashboard based on user role
  static Future<dynamic> navigateToDashboard() {
    return navigateAndClearStack(RouteConstants.dashboard);
  }

  /// Navigate to profile
  static Future<dynamic> navigateToProfile() {
    return navigateTo(RouteConstants.profile);
  }

  /// Navigate to browse donations
  static Future<dynamic> navigateToBrowseDonations() {
    return navigateTo(RouteConstants.browseDonations);
  }

  /// Navigate to create donation
  static Future<dynamic> navigateToCreateDonation() {
    return navigateTo(RouteConstants.createDonation);
  }

  /// Navigate to my donations
  static Future<dynamic> navigateToMyDonations() {
    return navigateTo(RouteConstants.myDonations);
  }

  /// Navigate to my requests
  static Future<dynamic> navigateToMyRequests() {
    return navigateTo(RouteConstants.myRequests);
  }

  /// Navigate to incoming requests
  static Future<dynamic> navigateToIncomingRequests() {
    return navigateTo(RouteConstants.incomingRequests);
  }

  /// Navigate to messages
  static Future<dynamic> navigateToMessages() {
    return navigateTo(RouteConstants.messages);
  }

  /// Navigate to chat
  static Future<dynamic> navigateToChat({required String userId}) {
    return navigateTo(RouteConstants.chat, arguments: {'userId': userId});
  }

  /// Navigate to admin dashboard
  static Future<dynamic> navigateToAdminDashboard() {
    return navigateTo(RouteConstants.adminDashboard);
  }

  /// Navigate to donor dashboard
  static Future<dynamic> navigateToDonorDashboard() {
    return navigateTo(RouteConstants.donorDashboard);
  }

  /// Navigate to receiver dashboard
  static Future<dynamic> navigateToReceiverDashboard() {
    return navigateTo(RouteConstants.receiverDashboard);
  }

  /// Navigate to notifications
  static Future<dynamic> navigateToNotifications() {
    return navigateTo(RouteConstants.notifications);
  }

  /// Navigate to landing page
  static Future<dynamic> navigateToLanding() {
    return navigateAndClearStack(RouteConstants.home);
  }
}

/// Route generator for the app
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.home:
        return MaterialPageRoute(builder: (_) => const LandingScreen());

      case RouteConstants.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case RouteConstants.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case RouteConstants.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case RouteConstants.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case RouteConstants.browseDonations:
        return MaterialPageRoute(builder: (_) => const BrowseDonationsScreen());

      case RouteConstants.createDonation:
        return MaterialPageRoute(
            builder: (_) => const CreateDonationScreenEnhanced());

      case RouteConstants.myDonations:
        return MaterialPageRoute(builder: (_) => const MyDonationsScreen());

      case RouteConstants.myRequests:
        return MaterialPageRoute(builder: (_) => const MyRequestsScreen());

      case RouteConstants.incomingRequests:
        return MaterialPageRoute(
            builder: (_) => const IncomingRequestsScreen());

      case RouteConstants.messages:
        return MaterialPageRoute(
            builder: (_) => const MessagesScreenEnhanced());

      case RouteConstants.chat:
        final args = settings.arguments as Map<String, dynamic>?;
        final otherUserId = args?['otherUserId'] as String? ?? '';
        final otherUserName = args?['otherUserName'] as String? ?? '';
        final conversationId = args?['conversationId'] as String?;
        final donationId = args?['donationId'] as String?;
        final requestId = args?['requestId'] as String?;
        return MaterialPageRoute(
          builder: (_) => ChatScreenEnhanced(
            otherUserId: otherUserId,
            otherUserName: otherUserName,
            conversationId: conversationId,
            donationId: donationId,
            requestId: requestId,
          ),
        );

      case RouteConstants.adminDashboard:
        return MaterialPageRoute(
            builder: (_) => const AdminDashboardEnhanced());

      case RouteConstants.donorDashboard:
        return MaterialPageRoute(
            builder: (_) => const DonorDashboardEnhanced());

      case RouteConstants.receiverDashboard:
        return MaterialPageRoute(
            builder: (_) => const ReceiverDashboardEnhanced());

      case RouteConstants.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text(
                  'No route defined for ${settings.name}'), // Error fallback, not user-facing
            ),
          ),
        );
    }
  }
}

/// Route guard for authentication
class AuthGuard {
  /// Check if user is authenticated
  static bool isAuthenticated(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAuthenticated;
  }

  /// Check if user has required role
  static bool hasRole(BuildContext context, String requiredRole) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.user?.role == requiredRole;
  }

  /// Check if user is admin
  static bool isAdmin(BuildContext context) {
    return hasRole(context, 'admin');
  }

  /// Check if user is donor
  static bool isDonor(BuildContext context) {
    return hasRole(context, 'donor');
  }

  /// Check if user is receiver
  static bool isReceiver(BuildContext context) {
    return hasRole(context, 'receiver');
  }

  /// Redirect to login if not authenticated
  static void requireAuth(BuildContext context) {
    if (!isAuthenticated(context)) {
      NavigationService.navigateToLogin();
    }
  }

  /// Redirect to appropriate dashboard based on role
  static void redirectToDashboard(BuildContext context) {
    if (!isAuthenticated(context)) {
      NavigationService.navigateToLogin();
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userRole = authProvider.user?.role;

    switch (userRole) {
      case 'admin':
        NavigationService.navigateToAdminDashboard();
        break;
      case 'donor':
        NavigationService.navigateToDonorDashboard();
        break;
      case 'receiver':
        NavigationService.navigateToReceiverDashboard();
        break;
      default:
        NavigationService.navigateToDashboard();
    }
  }
}
