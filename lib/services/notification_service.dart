import 'dart:io';
import 'dart:convert';
import 'dart:async' show unawaited;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/notification_model.dart';
import '../config/firebase_config.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Initialize notification service
  static Future<void> initialize() async {
    try {
      // Initialize timezone
      tz_data.initializeTimeZones();

      // Android settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS settings
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Initialization settings
      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize local notifications
      await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTap,
        onDidReceiveBackgroundNotificationResponse:
            _onBackgroundNotificationTap,
      );

      // Create notification channel for Android
      if (Platform.isAndroid) {
        await _createNotificationChannel();
      }

      // Request permissions (skip for web)
      if (!kIsWeb) {
        await _requestPermissions();
      }

      // Get FCM token
      await _getFCMToken();

      // Setup message handlers
      _setupMessageHandlers();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  // Create notification channel for Android
  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important job notifications.',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ledColor: Colors.blue,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Request permissions
  static Future<void> _requestPermissions() async {
    try {
      // Request iOS permissions
      if (Platform.isIOS) {
        await _requestIosPermissions();
      }

      // Request Android 13+ permission
      if (Platform.isAndroid) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      }
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
    }
  }

  // iOS permissions method
  static Future<void> _requestIosPermissions() async {
    try {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } catch (e) {
      debugPrint('Error requesting iOS permissions: $e');
    }
  }

  // Get FCM token
  static Future<String?> _getFCMToken() async {
    try {
      String? token = await _messaging.getToken();
      debugPrint('FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  // Setup message handlers
  static void _setupMessageHandlers() {
    // Handle foreground messages - FIXED: Using lambda to handle async function
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle when app is opened from terminated state
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        _handleInitialMessage(message);
      }
    });

    // Handle when app is in background and opened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageOpenedApp(message);
    });
  }

  // Background handler for Firebase
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    debugPrint('Handling background message: ${message.messageId}');
    await handleBackgroundMessage(message);
  }

  // Handle notification tap
  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    _handleNavigation(response.payload);
  }

  // Handle background notification tap
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTap(NotificationResponse response) {
    debugPrint('Background notification tapped: ${response.payload}');
  }

  // PUBLIC METHOD: Handle foreground message (called from main.dart)
  static void handleForegroundMessage(RemoteMessage message) {
    debugPrint('Handling foreground message: ${message.messageId}');

    final notification = message.notification;
    if (notification != null) {
      // Show local notification
      unawaited(showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: notification.title ?? 'JobConnect',
        body: notification.body ?? '',
        payload: message.data.toString(),
      ));

      debugPrint('Foreground notification: ${notification.title}');
    }

    // Save to Firestore
    unawaited(_saveNotificationToFirestore(message));
  }

  // PUBLIC METHOD: Handle background message (called from main.dart)
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Handling background message: ${message.messageId}');

    final notification = message.notification;
    if (notification != null) {
      debugPrint('Background notification: ${notification.title}');

      // Save locally for background
      await _saveNotificationLocally(message);
    }
  }

  // Handle foreground message (internal)
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message received: ${message.messageId}');

    final notification = message.notification;
    if (notification != null) {
      await showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: notification.title ?? 'JobConnect',
        body: notification.body ?? '',
        payload: message.data.toString(),
      );
    }

    await _saveNotificationToFirestore(message);
  }

  // Handle initial message
  static Future<void> _handleInitialMessage(RemoteMessage message) async {
    debugPrint('Initial message: ${message.messageId}');
    _handleNavigation(message.data.toString());
    await handleBackgroundMessage(message);
  }

  // Handle message opened app
  static Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    debugPrint('Message opened app: ${message.messageId}');
    _handleNavigation(message.data.toString());
    await handleBackgroundMessage(message);
  }

  // Handle navigation
  static void _handleNavigation(String? payload) {
    debugPrint('Navigate with payload: $payload');
    // TODO: Implement navigation logic
  }

  // Save notification to Firestore
  static Future<void> _saveNotificationToFirestore(
      RemoteMessage message) async {
    try {
      final notification = message.notification;
      if (notification == null) return;

      final userId = message.data['userId'];
      if (userId == null) return;

      final notificationModel = NotificationModel(
        id: FirebaseConfig.notificationsCollection.doc().id,
        userId: userId,
        type: _parseNotificationType(message.data['type']),
        title: notification.title ?? 'JobConnect',
        body: notification.body ?? '',
        data: message.data,
        createdAt: DateTime.now(),
        platform: kIsWeb ? 'web' : Platform.operatingSystem,
      );

      await FirebaseConfig.notificationsCollection
          .doc(notificationModel.id)
          .set(notificationModel.toFirestore());
    } catch (e) {
      debugPrint('Error saving notification to Firestore: $e');
    }
  }

  // Save notification locally (for background)
  static Future<void> _saveNotificationLocally(RemoteMessage message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications =
          prefs.getStringList('background_notifications') ?? [];

      notifications.add(json.encode({
        'messageId': message.messageId,
        'title': message.notification?.title,
        'body': message.notification?.body,
        'data': message.data,
        'timestamp': DateTime.now().toIso8601String(),
      }));

      // Keep only last 50 notifications
      if (notifications.length > 50) {
        notifications.removeRange(0, notifications.length - 50);
      }

      await prefs.setStringList('background_notifications', notifications);
    } catch (e) {
      debugPrint('Error saving notification locally: $e');
    }
  }

  // Parse notification type
  static NotificationType _parseNotificationType(String? type) {
    if (type == null) return NotificationType.system;
    switch (type) {
      case 'jobMatch':
        return NotificationType.jobMatch;
      case 'applicationUpdate':
        return NotificationType.applicationUpdate;
      case 'interviewSchedule':
        return NotificationType.interviewSchedule;
      case 'message':
        return NotificationType.message;
      case 'jobAlert':
        return NotificationType.jobAlert;
      case 'resumeFeedback':
        return NotificationType.resumeFeedback;
      case 'offer':
        return NotificationType.offer;
      case 'reminder':
        return NotificationType.reminder;
      default:
        return NotificationType.system;
    }
  }

  // Show local notification
  static Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      // Get platform-specific notification details
      final NotificationDetails details =
          await _getPlatformNotificationDetails();

      await _localNotifications.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }

  // Schedule notification
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    try {
      final NotificationDetails details =
          await _getPlatformNotificationDetails();

      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  // Show periodic notification
  // In the periodicallyShow method, add the missing parameter:
  static Future<void> showPeriodicNotification({
    required int id,
    required String title,
    required String body,
    required RepeatInterval interval,
    String? payload,
  }) async {
    try {
      final NotificationDetails details =
          await _getPlatformNotificationDetails();

      await _localNotifications.periodicallyShow(
        id,
        title,
        body,
        interval,
        details,
        payload: payload,
        androidScheduleMode:
            AndroidScheduleMode.inexact, // FIXED: Add this parameter
      );
    } catch (e) {
      debugPrint('Error showing periodic notification: $e');
    }
  }

  // Get platform-specific notification details safely
  static Future<NotificationDetails> _getPlatformNotificationDetails() async {
    // Android details
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'Important job notifications',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      enableLights: true,
      ledColor: Colors.blue,
    );

    // iOS details
    final DarwinNotificationDetails iosDetails =
        const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  // Cancel notification
  static Future<void> cancelNotification(int id) async {
    try {
      await _localNotifications.cancel(id);
    } catch (e) {
      debugPrint('Error canceling notification: $e');
    }
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
    } catch (e) {
      debugPrint('Error canceling all notifications: $e');
    }
  }

  // Get pending notifications
  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    try {
      return await _localNotifications.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Error getting pending notifications: $e');
      return [];
    }
  }

  // Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    try {
      if (Platform.isAndroid) {
        final android =
            _localNotifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        return await android?.areNotificationsEnabled() ?? false;
      }
      return true;
    } catch (e) {
      debugPrint('Error checking notifications enabled: $e');
      return false;
    }
  }

  // Get notifications stream
  static Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return FirebaseConfig.notificationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    });
  }

  // Mark as read
  static Future<void> markAsRead(String notificationId) async {
    try {
      await FirebaseConfig.notificationsCollection.doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  // Mark all as read
  static Future<void> markAllAsRead(String userId) async {
    try {
      final WriteBatch batch = FirebaseFirestore.instance.batch();
      final QuerySnapshot snapshot = await FirebaseConfig
          .notificationsCollection
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  // Delete notification
  static Future<void> deleteNotification(String notificationId) async {
    try {
      await FirebaseConfig.notificationsCollection.doc(notificationId).delete();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  // Clear all notifications
  static Future<void> clearAllNotifications(String userId) async {
    try {
      final WriteBatch batch = FirebaseFirestore.instance.batch();
      final QuerySnapshot snapshot = await FirebaseConfig
          .notificationsCollection
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error clearing all notifications: $e');
    }
  }

  // Get background notifications from local storage
  static Future<List<Map<String, dynamic>>> getBackgroundNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications =
          prefs.getStringList('background_notifications') ?? [];

      return notifications
          .map((item) => json.decode(item) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('Error getting background notifications: $e');
      return [];
    }
  }

  // Clear background notifications
  static Future<void> clearBackgroundNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('background_notifications');
    } catch (e) {
      debugPrint('Error clearing background notifications: $e');
    }
  }
}

// Top-level background handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Top-level background handler: ${message.messageId}');
  await NotificationService.handleBackgroundMessage(message);
}
