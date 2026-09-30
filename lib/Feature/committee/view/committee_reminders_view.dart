import 'package:flutter/material.dart';

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
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(description),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  void _showTestNotificationMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Committee notification reminder is enabled.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders & Notifications'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Committee Reminders',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Manage your committee payment and monthly reminders.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            _buildReminderCard(
              icon: Icons.payment_rounded,
              title: 'Payment Due Reminder',
              description:
                  'Get a reminder when your committee payment is due.',
              value: paymentDueReminder,
              onChanged: (value) {
                setState(() {
                  paymentDueReminder = value;
                });
              },
            ),

            _buildReminderCard(
              icon: Icons.event_available_rounded,
              title: 'Upcoming Payment Reminder',
              description:
                  'Get a reminder before your monthly contribution is due.',
              value: upcomingPaymentReminder,
              onChanged: (value) {
                setState(() {
                  upcomingPaymentReminder = value;
                });
              },
            ),

            _buildReminderCard(
              icon: Icons.person_rounded,
              title: 'Receiving Member Reminder',
              description:
                  'Get notified when it is your turn to receive the committee pool.',
              value: receivingReminder,
              onChanged: (value) {
                setState(() {
                  receivingReminder = value;
                });
              },
            ),

            _buildReminderCard(
              icon: Icons.warning_amber_rounded,
              title: 'Overdue Payment Reminder',
              description:
                  'Get a reminder when a committee payment becomes overdue.',
              value: overdueReminder,
              onChanged: (value) {
                setState(() {
                  overdueReminder = value;
                });
              },
            ),

            _buildReminderCard(
              icon: Icons.calendar_month_rounded,
              title: 'Monthly Committee Reminder',
              description:
                  'Receive a monthly reminder about your committee.',
              value: monthlyReminder,
              onChanged: (value) {
                setState(() {
                  monthlyReminder = value;
                });
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showTestNotificationMessage,
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




