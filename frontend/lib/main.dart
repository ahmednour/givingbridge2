import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/donation_provider.dart';
import 'providers/request_provider.dart';
import 'providers/message_provider.dart';
import 'providers/notification_provider.dart';
import 'services/navigation_service.dart';
import 'services/error_handler.dart';
import 'services/network_status_service.dart';
import 'services/socket_service.dart';
import 'core/routing/app_router.dart';
import 'screens/dashboard_screen.dart';
import 'screens/landing_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize global error handler
  GlobalErrorHandler.initialize();

  runApp(const GivingBridgeApp());
}

class GivingBridgeApp extends StatelessWidget {
  const GivingBridgeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DonationProvider()),
        ChangeNotifierProvider(create: (_) => RequestProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(
            create: (_) => NetworkStatusService()..initialize()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Giving Bridge',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            navigatorKey: NavigationService.navigatorKey,
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: '/',
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _socketInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize auth state when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while checking auth state
        if (authProvider.isLoading) {
          return const LoadingScreen();
        }

        // Initialize socket service and set authenticated user ID when user is authenticated
        if (authProvider.isAuthenticated && !_socketInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeServices(context, authProvider);
          });
        }

        // Show appropriate screen based on auth state
        return authProvider.isAuthenticated
            ? const DashboardScreen()
            : const LandingScreen();
      },
    );
  }

  Future<void> _initializeServices(
      BuildContext context, AuthProvider authProvider) async {
    try {
      // Set authenticated user ID in message provider
      final messageProvider =
          Provider.of<MessageProvider>(context, listen: false);
      if (authProvider.user?.id != null) {
        messageProvider
            .setAuthenticatedUserId(authProvider.user!.id.toString());
      }

      // Initialize socket service
      final socketService = SocketService();
      await socketService.connect();



      setState(() {
        _socketInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusXL),
              ),
              child: const Icon(
                Icons.favorite,
                color: AppTheme.primaryColor,
                size: 40,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
            Text(
              'Giving Bridge',
              style: AppTheme.headingLarge.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Connecting Hearts, Sharing Hope',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
