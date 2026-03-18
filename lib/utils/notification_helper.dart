import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Initialize local notifications
  static Future<void> initialize() async {
    try {
      // Initialize timezone data
      tz_data.initializeTimeZones();

      // Android initialization settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Initialization settings for both platforms
      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize notifications
      await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTap,
        onDidReceiveBackgroundNotificationResponse:
            _onBackgroundNotificationTap,
      );

      // Create notification channel for Android
      if (Platform.isAndroid) {
        await createNotificationChannel();
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  // Handle notification tap in foreground
  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }

  // Handle notification tap in background (requires @pragma for background execution)
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTap(NotificationResponse response) {
    debugPrint('Background notification tapped: ${response.payload}');
    // Handle background navigation
  }

  // Show local notification
  static Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      // Android notification details
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'job_channel',
        'Job Notifications',
        channelDescription: 'Notifications for job applications and updates',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
        enableVibration: true,
        playSound: true,
        showWhen: true,
        enableLights: true,
        ledColor: Colors.blue,
        ledOnMs: 1000,
        ledOffMs: 500,
      );

      // iOS notification details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Combined notification details
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

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
      // Android notification details
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'job_channel',
        'Job Notifications',
        channelDescription: 'Notifications for job applications and updates',
        importance: Importance.high,
        priority: Priority.high,
      );

      // iOS notification details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Combined notification details
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

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

  // Handle foreground message from Firebase
  static Future<void> handleForegroundMessage(RemoteMessage message) async {
    try {
      final notification = message.notification;
      if (notification != null) {
        await showLocalNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: notification.title ?? 'JobConnect',
          body: notification.body ?? '',
          payload: message.data.toString(),
        );
      }
    } catch (e) {
      debugPrint('Error handling foreground message: $e');
    }
  }

  // Handle background message from Firebase
  @pragma('vm:entry-point')
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Background message received: ${message.messageId}');
    // Handle background message - can show notification here
    final notification = message.notification;
    if (notification != null) {
      // You can show local notification here if needed
      debugPrint('Background notification: ${notification.title}');
    }
  }

  // Request notification permissions
  static Future<bool> requestPermissions() async {
    try {
      // For Android 13+
      final AndroidFlutterLocalNotificationsPlugin? android =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? androidGranted =
          await android?.requestNotificationsPermission();

      // For iOS
      final IOSFlutterLocalNotificationsPlugin? ios =
          _localNotifications.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      final bool? iosGranted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      if (Platform.isAndroid) {
        return androidGranted ?? false;
      } else if (Platform.isIOS) {
        return iosGranted ?? false;
      }

      return false;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }

  // Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    try {
      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? android =
            _localNotifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        final bool? enabled = await android?.areNotificationsEnabled();
        return enabled ?? false;
      } else if (Platform.isIOS) {
        // For iOS, we can't directly check, assume true if permissions were granted
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking notifications enabled: $e');
      return false;
    }
  }

  // Create notification channel (Android only)
  static Future<void> createNotificationChannel({
    String id = 'job_channel',
    String name = 'Job Notifications',
    String description = 'Notifications for job applications and updates',
  }) async {
    try {
      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? android =
            _localNotifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        await android?.createNotificationChannel(
          AndroidNotificationChannel(
            id,
            name,
            description: description,
            importance: Importance.high,
            enableVibration: true,
            playSound: true,
            enableLights: true,
            ledColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error creating notification channel: $e');
    }
  }

  // Get platform-specific notification details
  static Future<NotificationDetails> getPlatformNotificationDetails({
    String? channelId,
    String? channelName,
    String? channelDescription,
  }) async {
    // Android details
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channelId ?? 'job_channel',
      channelName ?? 'Job Notifications',
      channelDescription: channelDescription ?? 'Job application notifications',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      enableLights: true,
      ledColor: Colors.blue,
      ledOnMs: 1000,
      ledOffMs: 500,
      ticker: 'ticker',
    );

    // iOS details
    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  // Show periodic notification
  static Future<void> showPeriodicNotification({
    required int id,
    required String title,
    required String body,
    required RepeatInterval interval,
    String? payload,
  }) async {
    try {
      // Android notification details
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'job_channel',
        'Job Notifications',
        channelDescription: 'Notifications for job applications and updates',
        importance: Importance.high,
        priority: Priority.high,
      );

      // iOS notification details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Combined notification details
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.periodicallyShow(
        id,
        title,
        body,
        interval,
        details,
        payload: payload,
        androidScheduleMode:
            AndroidScheduleMode.inexact, // Added required parameter
      );
    } catch (e) {
      debugPrint('Error showing periodic notification: $e');
    }
  }

  // Get pending notification requests
  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    try {
      return await _localNotifications.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Error getting pending notifications: $e');
      return [];
    }
  }

  // Check if notification permission is granted
  static Future<bool> isPermissionGranted() async {
    try {
      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? android =
            _localNotifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        final bool? granted = await android?.areNotificationsEnabled();
        return granted ?? false;
      } else if (Platform.isIOS) {
        // For iOS, we need to check via a different method
        // This is a simplified check
        return true; // Assume granted if we can't check
      }
      return false;
    } catch (e) {
      debugPrint('Error checking permission granted: $e');
      return false;
    }
  }
}
