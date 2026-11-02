import 'package:expense_mate/Core/utils/formatters.dart';
import 'package:expense_mate/Core/constants/app_keys.dart';
import 'package:expense_mate/Feature/committee/model/committee_reminder_occurrence.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'bill_reminders';
  static const String _channelName = 'Bill Reminders';
  // Budget reset lives on its own channel so the user can silence it
  // without losing bill reminders.
  static const String _budgetChannelId = 'budget_reset';
  static const String _budgetChannelName = 'Budget Reset';
  static const String _budgetChannelDescription =
      'Reminders before your budget cycle resets';
  static const String _committeeChannelId = 'committee_reminders';
  static const String _committeeChannelName = 'Committee Reminders';
  static const String _committeeChannelDescription =
      'Reminders for upcoming committee dates';

  // Keep the budget reminder separate from bill and committee reminders.
  static const int _budgetReminderId = 9000001;
  static const int _committeeReminderIdBase = 1900000000;

  static const String _channelDescription =
      'Notifications for upcoming and due bills';

  Future<void> init() async {
    tz.initializeTimeZones();
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

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
          AndroidFlutterLocalNotificationsPlugin
        >();

    final notificationPermission = await androidPlugin
        ?.requestNotificationsPermission();

    debugPrint('NOTIFICATION PERMISSION: $notificationPermission');

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      999,
      'ExpenseMate',
      'Instant notification is working!',
      details,
    );

    debugPrint('INSTANT NOTIFICATION SENT');
  }

  Future<void> syncCommitteeReminders({
    required List<CommitteeReminderOccurrence> occurrences,
    required bool enabled,
    required int daysBefore,
  }) async {
    if (daysBefore != 0 && daysBefore != 1) {
      throw ArgumentError.value(daysBefore, 'daysBefore', 'Must be 0 or 1.');
    }

    final settings = Hive.box(AppKeys.settingsBox);
    final dynamic storedIds = settings.get(
      AppKeys.committeeReminderNotificationIdsKey,
      defaultValue: <int>[],
    );
    final List<int> oldIds = storedIds is List
        ? storedIds.whereType<num>().map((id) => id.toInt()).toList()
        : <int>[];
    final List<PendingNotificationRequest> pending = await _notifications
        .pendingNotificationRequests();
    final Set<int> usedIds = pending
        .map((notification) => notification.id)
        .toSet();
    usedIds.addAll(oldIds);

    final Map<String, Set<String>> namesByReminderDate = {};
    if (enabled && settings.get('notifications_enabled', defaultValue: true)) {
      final now = tz.TZDateTime.now(tz.local);

      for (final occurrence in occurrences) {
        final DateTime reminderDate = occurrence.reminderDate(
          daysBefore: daysBefore,
        );
        final tz.TZDateTime fireDate = tz.TZDateTime(
          tz.local,
          reminderDate.year,
          reminderDate.month,
          reminderDate.day,
          reminderDate.hour,
        );
        if (!fireDate.isAfter(now)) continue;

        final String key =
            '${fireDate.year}-${fireDate.month.toString().padLeft(2, '0')}-'
            '${fireDate.day.toString().padLeft(2, '0')}';
        namesByReminderDate
            .putIfAbsent(key, () => <String>{})
            .add(occurrence.committeeName);
      }
    }

    if (namesByReminderDate.isEmpty) {
      for (final int id in oldIds) {
        await _notifications.cancel(id);
      }
      await settings.put(AppKeys.committeeReminderNotificationIdsKey, <int>[]);
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      _committeeChannelId,
      _committeeChannelName,
      channelDescription: _committeeChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    final List<int> newIds = [];
    final List<String> reminderDates = namesByReminderDate.keys.toList()
      ..sort();
    try {
      for (int index = 0; index < reminderDates.length; index++) {
        final String key = reminderDates[index];
        final List<String> committeeNames = namesByReminderDate[key]!.toList()
          ..sort();
        final DateTime reminderDate = DateTime.parse(key);
        final tz.TZDateTime fireDate = tz.TZDateTime(
          tz.local,
          reminderDate.year,
          reminderDate.month,
          reminderDate.day,
          9,
        );

        int notificationId = _committeeReminderIdBase + index;
        while (usedIds.contains(notificationId)) {
          notificationId++;
        }
        usedIds.add(notificationId);

        final String names = committeeNames.join(', ');
        final String title = 'Committee reminder'.tr;
        final bool isDueTomorrow = daysBefore == 1;
        final String body = isDueTomorrow
            ? 'Your committee contribution for @name is due tomorrow.'.trParams(
                {'name': names},
              )
            : 'Your committee contribution for @name is due today.'.trParams({
                'name': names,
              });

        await _notifications.zonedSchedule(
          notificationId,
          title,
          body,
          fireDate,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
        newIds.add(notificationId);
      }
    } catch (error) {
      for (final int id in newIds) {
        await _notifications.cancel(id);
      }
      rethrow;
    }

    for (final int id in oldIds) {
      await _notifications.cancel(id);
    }
    await settings.put(AppKeys.committeeReminderNotificationIdsKey, newIds);
    debugPrint('COMMITTEE REMINDERS SCHEDULED: ${newIds.length}');
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

    const details = NotificationDetails(android: androidDetails);

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

  /// Reminder before the budget cycle resets.
  ///
  /// Only one is ever scheduled: the previous one is cancelled first, so
  /// changing the start day or the reminder setting can never leave an
  /// old notification behind.
  Future<void> scheduleBudgetResetReminder({
    required DateTime resetDate,
    required int daysBefore,
    required double budgetAmount,
    required double spentAmount,
  }) async {
    await cancelBudgetResetReminder();

    final now = tz.TZDateTime.now(tz.local);

    final fireDate = tz.TZDateTime(
      tz.local,
      resetDate.year,
      resetDate.month,
      resetDate.day,
      9,
    ).subtract(Duration(days: daysBefore));

    // Already in the past - nothing to schedule.
    if (!fireDate.isAfter(now)) {
      debugPrint('BUDGET REMINDER SKIPPED (date already passed)');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      _budgetChannelId,
      _budgetChannelName,
      channelDescription: _budgetChannelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const details = NotificationDetails(android: androidDetails);

    final whenText = daysBefore == 1 ? 'tomorrow' : 'in $daysBefore days';

    await _notifications.zonedSchedule(
      _budgetReminderId,
      'Budget Reset Reminder',
      'Your monthly budget will reset $whenText. '
          'Budget: ${Formatters.money(budgetAmount)} · '
          'Spent: Rs ${spentAmount.toStringAsFixed(0)}',
      fireDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );

    debugPrint('BUDGET REMINDER SCHEDULED FOR $fireDate');
  }

  Future<void> cancelBudgetResetReminder() async {
    await _notifications.cancel(_budgetReminderId);
    debugPrint('BUDGET REMINDER CANCELLED');
  }

  Future<void> cancelNotification(int notificationId) async {
    await _notifications.cancel(notificationId);
    await _notifications.cancel(notificationId + 1000000);

    debugPrint('NOTIFICATION CANCELLED: $notificationId');
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
