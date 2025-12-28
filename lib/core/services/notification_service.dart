import 'package:flutter/foundation.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

/// Service for handling push notifications using Firebase Messaging.
/// Note: Firebase configuration required for production use.
class NotificationService {
  // static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static bool _initialized = false;

  /// Initialize the notification service
  static Future<void> init() async {
    if (_initialized) return;

    try {
      // Request permission for iOS and web
      // await _requestPermission();

      // Get FCM token
      // await _getToken();

      // Handle foreground messages
      // _setupForegroundHandler();

      // Handle background messages
      // FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      _initialized = true;
      debugPrint('NotificationService initialized');
    } catch (e) {
      debugPrint('Failed to initialize NotificationService: $e');
    }
  }

  /// Request notification permissions
  static Future<bool> requestPermission() async {
    try {
      // final settings = await _messaging.requestPermission(
      //   alert: true,
      //   announcement: false,
      //   badge: true,
      //   carPlay: false,
      //   criticalAlert: false,
      //   provisional: false,
      //   sound: true,
      // );

      // return settings.authorizationStatus == AuthorizationStatus.authorized ||
      //     settings.authorizationStatus == AuthorizationStatus.provisional;
      return true;
    } catch (e) {
      debugPrint('Failed to request permission: $e');
      return false;
    }
  }

  /// Get FCM token
  static Future<String?> getToken() async {
    try {
      // final token = await _messaging.getToken();
      // debugPrint('FCM Token: $token');
      // return token;
      return 'mock_fcm_token_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
      return null;
    }
  }

  /// Subscribe to a topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      // await _messaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Failed to subscribe to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      // await _messaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Failed to unsubscribe from topic: $e');
    }
  }

  /// Schedule a local notification (mock implementation)
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // In production, use flutter_local_notifications package
    debugPrint('Scheduled notification: $title at $scheduledTime');
  }

  /// Cancel all scheduled notifications
  static Future<void> cancelAllNotifications() async {
    // In production, cancel via flutter_local_notifications
    debugPrint('Cancelled all notifications');
  }

  /// Schedule daily reminder
  static Future<void> scheduleDailyReminder() async {
    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      19, // 7 PM
      0,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await scheduleNotification(
      title: 'New surveys waiting!',
      body: 'Complete surveys and earn coins today!',
      scheduledTime: scheduledTime,
    );
  }

  /// Schedule streak reminder
  static Future<void> scheduleStreakReminder(int currentStreak) async {
    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      20, // 8 PM
      0,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await scheduleNotification(
      title: 'Keep your streak alive!',
      body: 'You have a $currentStreak day streak. Complete a survey to maintain it!',
      scheduledTime: scheduledTime,
    );
  }
}

// Handle background messages (top-level function required)
// @pragma('vm:entry-point')
// Future<void> _handleBackgroundMessage(RemoteMessage message) async {
//   debugPrint('Handling background message: ${message.messageId}');
// }
