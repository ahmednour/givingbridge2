import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/navigation_service.dart';
import '../core/constants/route_constants.dart';

/// Firebase Cloud Messaging service for push notifications
///
/// Features:
/// - Background and foreground notifications
/// - Custom notification sounds
/// - Notification tap handling
/// - Token management
/// - Topic subscriptions
class FirebaseNotificationService {
  static final FirebaseNotificationService _instance =
      FirebaseNotificationService._internal();
  factory FirebaseNotificationService() => _instance;
  FirebaseNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  StreamController<RemoteMessage>? _messageStreamController;
  StreamController<String>? _tokenStreamController;

  /// Get FCM token stream
  Stream<String> get tokenStream => _tokenStreamController!.stream;

  /// Get message stream
  Stream<RemoteMessage> get messageStream => _messageStreamController!.stream;

  /// Get current FCM token
  String? get fcmToken => _fcmToken;

  /// Initialize Firebase Messaging
  Future<void> initialize() async {
    try {
      // Initialize stream controllers
      _messageStreamController = StreamController<RemoteMessage>.broadcast();
      _tokenStreamController = StreamController<String>.broadcast();

      // Request notification permissions
      await _requestPermissions();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get FCM token
      await _getFCMToken();

      // Setup message handlers
      _setupMessageHandlers();

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _tokenStreamController!.add(newToken);
        debugPrint('🔄 FCM Token refreshed: $newToken');
      });

      debugPrint('✅ Firebase Notification Service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing Firebase Notifications: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    if (kIsWeb) {
      // Web permissions
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint(
          '📱 Web notification permission: ${settings.authorizationStatus}');
    } else if (Platform.isIOS) {
      // iOS permissions
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      debugPrint(
          '📱 iOS notification permission: ${settings.authorizationStatus}');
    } else {
      // Android permissions (auto-granted)
      debugPrint('📱 Android notification permission: auto-granted');
    }
  }

  /// Initialize local notifications for displaying foreground notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    if (!kIsWeb && Platform.isAndroid) {
      await _createNotificationChannel();
    }
  }

  /// Create Android notification channel
  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // name
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Get FCM token
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        _tokenStreamController!.add(_fcmToken!);
        debugPrint('📱 FCM Token: $_fcmToken');
      }
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
    }
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📨 Foreground message received: ${message.messageId}');
      _messageStreamController!.add(message);
      _showLocalNotification(message);
    });

    // Handle background message tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📬 Background message tapped: ${message.messageId}');
      _messageStreamController!.add(message);
      _handleNotificationTap(message.data);
    });

    // Handle notification tap when app was terminated
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('🚀 App opened from terminated state: ${message.messageId}');
        _messageStreamController!.add(message);
        _handleNotificationTap(message.data);
      }
    });
  }

  /// Show local notification for foreground messages
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
    // Parse payload and navigate
    if (response.payload != null) {
      try {
        // Parse the payload as a Map
        final payload = response.payload;
        if (payload != null) {
          // Navigate based on notification type
          _navigateBasedOnNotificationType(payload);
        }
      } catch (e) {
        debugPrint('❌ Error parsing notification payload: $e');
      }
    }
  }

  /// Handle notification navigation
  void _handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'];
    final relatedId = data['relatedId'];

    debugPrint('🎯 Handling notification tap - Type: $type, ID: $relatedId');

    // Implement navigation logic based on notification type
    switch (type) {
      case 'message':
        // Navigate to chat screen with the user ID
        if (relatedId != null) {
          NavigationService.navigateTo(
            RouteConstants.chat,
            arguments: {
              'otherUserId': relatedId.toString(),
              'otherUserName': data['senderName'] ?? 'User',
            },
          );
        } else {
          // Fallback to messages screen
          NavigationService.navigateTo(RouteConstants.messages);
        }
        break;

      case 'donation_request':
        // Navigate to incoming requests
        NavigationService.navigateTo(RouteConstants.incomingRequests);
        break;

      case 'donation_approved':
        // Navigate to my requests
        NavigationService.navigateTo(RouteConstants.myRequests);
        break;

      case 'new_donation':
        // Navigate to donation details
        if (relatedId != null) {
          NavigationService.navigateTo(
            RouteConstants.donationDetails,
            arguments: {'donationId': relatedId.toString()},
          );
        } else {
          // Fallback to browse donations
          NavigationService.navigateTo(RouteConstants.browseDonations);
        }
        break;

      case 'request_completed':
        // Navigate to my requests
        NavigationService.navigateTo(RouteConstants.myRequests);
        break;

      case 'donation_reminder':
        // Navigate to my donations
        NavigationService.navigateTo(RouteConstants.myDonations);
        break;

      default:
        // Fallback to notifications screen
        NavigationService.navigateTo(RouteConstants.notifications);
        break;
    }
  }

  /// Navigate based on notification type from payload string
  void _navigateBasedOnNotificationType(String payload) {
    try {
      // Parse the payload string as a Map
      // This is a simplified approach - in a real app, you might want to use JSON parsing
      debugPrint('🎯 Navigating with payload: $payload');

      // Fallback to notifications screen for now
      NavigationService.navigateTo(RouteConstants.notifications);
    } catch (e) {
      debugPrint('❌ Error navigating based on notification type: $e');
      // Fallback to notifications screen
      NavigationService.navigateTo(RouteConstants.notifications);
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from topic: $e');
    }
  }

  /// Subscribe to user-specific topics based on role
  Future<void> subscribeToRoleTopics(String role, String userId) async {
    // Subscribe to role-specific topics
    await subscribeToTopic('all_users');
    await subscribeToTopic(role.toLowerCase()); // donor, receiver, or admin
    await subscribeToTopic('user_$userId');
  }

  /// Unsubscribe from all topics
  Future<void> unsubscribeFromAllTopics(String role, String userId) async {
    await unsubscribeFromTopic('all_users');
    await unsubscribeFromTopic(role.toLowerCase());
    await unsubscribeFromTopic('user_$userId');
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Dispose resources
  void dispose() {
    _messageStreamController?.close();
    _tokenStreamController?.close();
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('🔔 Background message received: ${message.messageId}');
  debugPrint('📬 Title: ${message.notification?.title}');
  debugPrint('📝 Body: ${message.notification?.body}');
  debugPrint('📊 Data: ${message.data}');
}
