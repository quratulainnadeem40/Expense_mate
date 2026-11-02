import 'package:expense_mate/Core/constants/app_keys.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:expense_mate/Core/service/notification_service.dart';
import '../controller/committe_controller.dart';

class CommitteeRemindersView extends StatefulWidget {
  const CommitteeRemindersView({super.key});

  @override
  State<CommitteeRemindersView> createState() => _CommitteeRemindersViewState();
}

class _CommitteeRemindersViewState extends State<CommitteeRemindersView> {
  final CommitteeController _committeeController = CommitteeController.instance;
  final NotificationService _notificationService =
      Get.find<NotificationService>();
  late final Box _settings;
  late bool _enabled;
  late int _daysBefore;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _settings = Hive.box(AppKeys.settingsBox);
    _enabled = _settings.get(
      AppKeys.committeeReminderEnabledKey,
      defaultValue: true,
    );
    _daysBefore = _settings.get(
      AppKeys.committeeReminderDaysBeforeKey,
      defaultValue: 1,
    );
    if (_daysBefore != 0 && _daysBefore != 1) _daysBefore = 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncSchedule(showError: true);
    });
  }

  Future<void> _updateReminder({bool? enabled, int? daysBefore}) async {
    if (_isSaving) return;

    final bool previousEnabled = _enabled;
    final int previousDaysBefore = _daysBefore;
    setState(() {
      _enabled = enabled ?? _enabled;
      _daysBefore = daysBefore ?? _daysBefore;
      _isSaving = true;
    });

    try {
      await _settings.put(AppKeys.committeeReminderEnabledKey, _enabled);
      await _settings.put(AppKeys.committeeReminderDaysBeforeKey, _daysBefore);
      await _syncSchedule(showError: false);
      if (mounted) _showMessage('Reminder settings saved.'.tr);
    } catch (error) {
      await _settings.put(AppKeys.committeeReminderEnabledKey, previousEnabled);
      await _settings.put(
        AppKeys.committeeReminderDaysBeforeKey,
        previousDaysBefore,
      );
      if (mounted) {
        setState(() {
          _enabled = previousEnabled;
          _daysBefore = previousDaysBefore;
        });
        _showMessage(
          'Unable to update reminders: @message'.trParams({
            'message': error.toString(),
          }),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _syncSchedule({required bool showError}) async {
    try {
      await _notificationService.syncCommitteeReminders(
        occurrences: _committeeController.reminderOccurrences,
        enabled:
            _enabled &&
            _settings.get('notifications_enabled', defaultValue: true),
        daysBefore: _daysBefore,
      );
    } catch (error) {
      if (showError && mounted) {
        _showMessage(
          'Unable to update reminders: @message'.trParams({
            'message': error.toString(),
          }),
          isError: true,
        );
      } else {
        rethrow;
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        ),
      );
  }

  DateTime? get _nextReminderDate {
    if (!_enabled ||
        !_settings.get('notifications_enabled', defaultValue: true)) {
      return null;
    }

    final DateTime now = DateTime.now();
    for (final occurrence in _committeeController.reminderOccurrences) {
      final DateTime reminderDate = occurrence.reminderDate(
        daysBefore: _daysBefore,
      );
      if (reminderDate.isAfter(now)) return reminderDate;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_rounded),
            const SizedBox(width: 8),
            Text('Reminders & Notifications'.tr),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.notifications_active_rounded,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Committee Reminders'.tr,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Get one reminder for each committee date.'.tr,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      secondary: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.event_available_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        'Monthly committee reminder'.tr,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'A single notification for each upcoming committee date.'
                            .tr,
                      ),
                      value: _enabled,
                      onChanged: _isSaving
                          ? null
                          : (value) => _updateReminder(enabled: value),
                    ),
                    const Divider(height: 24),
                    Text(
                      'When should we remind you?'.tr,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    RadioGroup<int>(
                      groupValue: _daysBefore,
                      onChanged: (value) {
                        if (!_isSaving && value != null) {
                          _updateReminder(daysBefore: value);
                        }
                      },
                      child: Column(
                        children: [
                          RadioListTile<int>(
                            contentPadding: EdgeInsets.zero,
                            value: 1,
                            title: Text('One day before'.tr),
                            subtitle: Text(
                              'Get one reminder one day before the due date.'
                                  .tr,
                            ),
                          ),
                          RadioListTile<int>(
                            contentPadding: EdgeInsets.zero,
                            value: 0,
                            title: Text('On the due date'.tr),
                            subtitle: Text(
                              'Get one reminder on the committee due date.'.tr,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next reminder'.tr,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _nextReminderDate == null
                                ? (!_settings.get(
                                        'notifications_enabled',
                                        defaultValue: true,
                                      )
                                      ? 'Notifications are disabled in app settings.'
                                            .tr
                                      : _enabled
                                      ? 'No upcoming committee dates are scheduled.'
                                            .tr
                                      : 'Reminders are turned off.'.tr)
                                : DateFormat.yMMMd(
                                    Get.locale?.toLanguageTag(),
                                  ).add_jm().format(_nextReminderDate!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Reminders are sent at 9:00 AM using your device time.'.tr,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
