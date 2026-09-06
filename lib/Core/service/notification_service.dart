import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance =
      NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'bill_reminders';
  static const String _channelName = 'Bill Reminders';
  static const String _channelDescription =
      'Notifications for upcoming and due bills';

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    debugPrint('NOTIFICATION SERVICE INITIALIZED');
  }

  Future<void> requestPermission() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final notificationPermission =
        await androidPlugin?.requestNotificationsPermission();

    debugPrint(
      'NOTIFICATION PERMISSION: $notificationPermission',
    );

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      999,
      'ExpenseMate',
      'Instant notification is working!',
      details,
    );

    debugPrint('INSTANT NOTIFICATION SENT');
  }

  
  Future<void> scheduleBillNotification({
    required int notificationId,
    required String billName,
    required double amount,
    required String currency,
    required DateTime dueDate,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
    );

    // Reminder one day before at 9 AM.
    final reminderDate = tz.TZDateTime(
      tz.local,
      dueDate.year,
      dueDate.month,
      dueDate.day,
      9,
    ).subtract(const Duration(days: 1));

    if (reminderDate.isAfter(now)) {
      await _notifications.zonedSchedule(
        notificationId + 1000000,
        'Bill Reminder',
        '$billName is due tomorrow. Amount: '
            '$currency ${amount.toStringAsFixed(2)}',
        reminderDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      debugPrint('DAY-BEFORE REMINDER SCHEDULED');
    }

    // Due date notification at 9 AM.
    final dueNotificationDate = tz.TZDateTime(
      tz.local,
      dueDate.year,
      dueDate.month,
      dueDate.day,
      9,
    );

    if (dueNotificationDate.isAfter(now)) {
      await _notifications.zonedSchedule(
        notificationId,
        'Bill Due Today',
        '$billName is due today. Amount: '
            '$currency ${amount.toStringAsFixed(2)}',
        dueNotificationDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      debugPrint('DUE-DATE NOTIFICATION SCHEDULED');
    }
  }

  Future<void> cancelNotification(int notificationId) async {
    await _notifications.cancel(notificationId);
    await _notifications.cancel(notificationId + 1000000);

    debugPrint(
      'NOTIFICATION CANCELLED: $notificationId',
    );
  }

Future<void> checkPendingNotifications() async {
  final pending = await _notifications.pendingNotificationRequests();

  debugPrint('================================');
  debugPrint('PENDING NOTIFICATIONS: ${pending.length}');

  for (final notification in pending) {
    debugPrint(
      'ID: ${notification.id} | '
      'TITLE: ${notification.title} | '
      'BODY: ${notification.body}',
    );
  }

  debugPrint('================================');
}

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();

    debugPrint('ALL NOTIFICATIONS CANCELLED');
  }
}