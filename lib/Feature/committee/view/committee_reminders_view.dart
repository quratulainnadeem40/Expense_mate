import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:expense_mate/Core/service/notification_service.dart';

class CommitteeRemindersView extends StatefulWidget {
  const CommitteeRemindersView({super.key});

  @override
  State<CommitteeRemindersView> createState() => _CommitteeRemindersViewState();
}

class _CommitteeRemindersViewState extends State<CommitteeRemindersView> {
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
        secondary: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(description),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _showTestNotification() async {
    try {
      final notificationService = Get.find<NotificationService>();

      await notificationService.showCommitteeNotification();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Committee reminder notification sent successfully.'.tr),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to send notification: @message'.trParams({'message': e.toString()}))),
      );
    }
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Committee Reminders'.tr,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              'Manage your committee payment and monthly reminders.'.tr,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            _buildReminderCard(
              icon: Icons.payment_rounded,
              title: 'Payment Due Reminder'.tr,
              description: 'Get a reminder when your committee payment is due.'.tr,
              value: paymentDueReminder,
              onChanged: (value) {
                setState(() {
                  paymentDueReminder = value;
                });
              },
            ),

            _buildReminderCard(
              icon: Icons.event_available_rounded,
              title: 'Upcoming Payment Reminder'.tr,
              description:
                  'Get a reminder before your monthly contribution is due.'.tr,
              value: upcomingPaymentReminder,
              onChanged: (value) {
                setState(() {
                  upcomingPaymentReminder = value;
                });
              },
            ),

            _buildReminderCard(
              icon: Icons.person_rounded,
              title: 'Receiving Member Reminder'.tr,
              description:
                  'Get notified when it is your turn to receive the committee pool.'.tr,
              value: receivingReminder,
              onChanged: (value) {
                setState(() {
                  receivingReminder = value;
                });
              },
            ),

            _buildReminderCard(
              icon: Icons.warning_amber_rounded,
              title: 'Overdue Payment Reminder'.tr,
              description:
                  'Get a reminder when a committee payment becomes overdue.'.tr,
              value: overdueReminder,
              onChanged: (value) {
                setState(() {
                  overdueReminder = value;
                });
              },
            ),

            _buildReminderCard(
              icon: Icons.calendar_month_rounded,
              title: 'Monthly Committee Reminder'.tr,
              description: 'Receive a monthly reminder about your committee.'.tr,
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
                onPressed: _showTestNotification,
                icon: const Icon(Icons.notifications_active_rounded),
                label: Text('Test Reminder'.tr),
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: Text(
                'Committee reminders are managed from this screen.'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
