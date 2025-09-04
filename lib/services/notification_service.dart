// ignore_for_file: avoid_print

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize the notification plugin
  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );

    const iosSettings = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          print("🔔 Notification tapped with payload: ${response.payload}");
        }
      },
    );

    // iOS-specific permission
    await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Initialize timezone
    tz.initializeTimeZones();
  }

  /// Check & request notification permission
  static Future<bool> checkPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied || status.isRestricted) {
      final result = await Permission.notification.request();
      return result.isGranted;
    }
    return status.isGranted;
  }

  /// Notification details (consistent across platform)
  static NotificationDetails _notificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      'mywallet_channel',
      'MyWallet Notifications',
      channelDescription: 'Reminders for bills & transactions',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/launcher_icon',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  /// Show an instant notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!await checkPermission()) {
      print("❌ Notification permission not granted");
      return;
    }

    await _notifications.show(
      id,
      title,
      body,
      _notificationDetails(),
      payload: payload,
    );

    print("✅ Instant notification shown: [$id] $title – $body");
  }

  /// Schedule a notification at a specific date & time
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    bool repeatDaily = false,
  }) async {
    if (!await checkPermission()) {
      print("❌ Notification permission not granted");
      return;
    }

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: repeatDaily ? DateTimeComponents.time : null,
      payload: payload,
    );

    print(
      "📅 Scheduled notification set for ${scheduledDate.toLocal()} – [$id] $title",
    );
  }

  /// Cancel a specific notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    print("🗑️ Cancelled notification with ID $id");
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print("🗑️ All notifications cancelled");
  }
}
