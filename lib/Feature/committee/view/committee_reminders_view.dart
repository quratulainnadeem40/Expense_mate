import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../Core/constants/app_keys.dart';

class CommitteeRemindersView extends StatefulWidget {
  const CommitteeRemindersView({super.key});

  @override
  State<CommitteeRemindersView> createState() =>
      _CommitteeRemindersViewState();
}

class _CommitteeRemindersViewState
    extends State<CommitteeRemindersView> {
  bool paymentDueReminder = true;
  bool upcomingPaymentReminder = true;
  bool receivingReminder = true;
  bool overdueReminder = true;
  bool monthlyReminder = true;

  String committeeName = 'Digital Committee';
  double monthlyContribution = 0;
  int totalMembers = 0;

  @override
  void initState() {
    super.initState();
    _loadReminderData();
  }

  void _loadReminderData() {
    final Box committeeBox =
        Hive.box(AppKeys.committeeBox);

    final dynamic storedData =
        committeeBox.get('currentCommittee');

    if (storedData is Map) {
      final Map<dynamic, dynamic> committee =
          Map<dynamic, dynamic>.from(storedData);

      committeeName =
          committee['name']?.toString() ??
              'Digital Committee';

      monthlyContribution =
          _parseAmount(committee['contribution']);

      final dynamic membersList =
          committee['membersList'];

      if (membersList is List) {
        totalMembers = membersList.length;
      } else {
        totalMembers =
            int.tryParse(
                  committee['members']?.toString() ??
                      '0',
                ) ??
                0;
      }
    }

    final dynamic savedReminders =
        committeeBox.get('committeeReminders');

    if (savedReminders is Map) {
      paymentDueReminder =
          savedReminders['paymentDue'] ?? true;

      upcomingPaymentReminder =
          savedReminders['upcomingPayment'] ?? true;

      receivingReminder =
          savedReminders['receiving'] ?? true;

      overdueReminder =
          savedReminders['overdue'] ?? true;

      monthlyReminder =
          savedReminders['monthly'] ?? true;
    }

    if (mounted) {
      setState(() {});
    }
  }

  double _parseAmount(dynamic value) {
    if (value == null) {
      return 0;
    }

    final String cleaned =
        value
            .toString()
            .replaceAll('PKR', '')
            .replaceAll(',', '')
            .trim();

    return double.tryParse(cleaned) ?? 0;
  }

  String _formatAmount(double amount) {
    final String value =
        amount.toStringAsFixed(0);

    final StringBuffer result =
        StringBuffer();

    for (int i = 0; i < value.length; i++) {
      if (i > 0 &&
          (value.length - i) % 3 == 0) {
        result.write(',');
      }

      result.write(value[i]);
    }

    return result.toString();
  }

  Future<void> _saveReminderData() async {
    final Box committeeBox =
        Hive.box(AppKeys.committeeBox);

    await committeeBox.put(
      'committeeReminders',
      {
        'paymentDue': paymentDueReminder,
        'upcomingPayment':
            upcomingPaymentReminder,
        'receiving': receivingReminder,
        'overdue': overdueReminder,
        'monthly': monthlyReminder,
      },
    );
  }

  Future<void> _updateReminder(
    String key,
    bool value,
  ) async {
    setState(() {
      switch (key) {
        case 'paymentDue':
          paymentDueReminder = value;
          break;

        case 'upcomingPayment':
          upcomingPaymentReminder = value;
          break;

        case 'receiving':
          receivingReminder = value;
          break;

        case 'overdue':
          overdueReminder = value;
          break;

        case 'monthly':
          monthlyReminder = value;
          break;
      }
    });

    await _saveReminderData();
  }

  Widget _buildReminderCard({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: SwitchListTile(
        secondary: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          softWrap: true,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          description,
          softWrap: true,
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  void _showTestNotificationMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$committeeName reminder is enabled.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reminders & Notifications',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Committee Reminders',
              softWrap: true,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Manage reminders for $committeeName.',
              softWrap: true,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 16),

            if (monthlyContribution > 0 ||
                totalMembers > 0)
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.groups_rounded,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              committeeName,
                              softWrap: true,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Monthly Contribution: PKR ${_formatAmount(monthlyContribution)}',
                        softWrap: true,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Members: $totalMembers',
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            _buildReminderCard(
              icon: Icons.payment_rounded,
              title: 'Payment Due Reminder',
              description:
                  'Get a reminder when your committee payment is due.',
              value: paymentDueReminder,
              onChanged: (value) {
                _updateReminder(
                  'paymentDue',
                  value,
                );
              },
            ),

            _buildReminderCard(
              icon: Icons.event_available_rounded,
              title: 'Upcoming Payment Reminder',
              description:
                  'Get a reminder before your monthly contribution is due.',
              value: upcomingPaymentReminder,
              onChanged: (value) {
                _updateReminder(
                  'upcomingPayment',
                  value,
                );
              },
            ),

            _buildReminderCard(
              icon: Icons.person_rounded,
              title: 'Receiving Member Reminder',
              description:
                  'Get notified when it is your turn to receive the committee pool.',
              value: receivingReminder,
              onChanged: (value) {
                _updateReminder(
                  'receiving',
                  value,
                );
              },
            ),

            _buildReminderCard(
              icon: Icons.warning_amber_rounded,
              title: 'Overdue Payment Reminder',
              description:
                  'Get a reminder when a committee payment becomes overdue.',
              value: overdueReminder,
              onChanged: (value) {
                _updateReminder(
                  'overdue',
                  value,
                );
              },
            ),

            _buildReminderCard(
              icon: Icons.calendar_month_rounded,
              title: 'Monthly Committee Reminder',
              description:
                  'Receive a monthly reminder about your committee.',
              value: monthlyReminder,
              onChanged: (value) {
                _updateReminder(
                  'monthly',
                  value,
                );
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _showTestNotificationMessage,
                icon: const Icon(
                  Icons.notifications_active_rounded,
                ),
                label: const Text(
                  'Test Reminder',
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Center(
              child: Text(
                'Committee reminders are managed from this screen.',
                textAlign: TextAlign.center,
                softWrap: true,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}