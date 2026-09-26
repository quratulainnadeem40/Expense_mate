
import 'package:flutter/material.dart';

import 'add_committee_view.dart';
import 'committee_details_view.dart';
import 'monthly_schedule_view.dart';
import 'payment_tracking_view.dart';
import 'committee_reminders_view.dart';

class CommitteeView extends StatefulWidget {
  const CommitteeView({super.key});

  @override
  State<CommitteeView> createState() => _CommitteeViewState();
}

class _CommitteeViewState extends State<CommitteeView> {
  Map<String, dynamic>? committeeData;

  void _openAddCommittee() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCommitteeView(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        committeeData = result;
      });
    }
  }

  void _openMembers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CommitteeDetailsView(),
      ),
    );
  }

  void _openPaymentTracking() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaymentTrackingView(),
      ),
    );
  }

  void _openMonthlySchedule() {
    if (committeeData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a committee first.'),
        ),
      );
      return;
    }

    final double monthlyContribution =
        double.tryParse(
          committeeData!['contribution']
                  ?.toString()
                  .replaceAll(',', '') ??
              '0',
        ) ??
        0;

    final int totalMembers =
        int.tryParse(
          committeeData!['members']?.toString() ?? '0',
        ) ??
        0;

    final int durationMonths =
        int.tryParse(
          committeeData!['duration']?.toString() ?? '0',
        ) ??
        0;

    DateTime startDate;

    final dynamic savedStartDate = committeeData!['startDate'];

    if (savedStartDate is DateTime) {
      startDate = savedStartDate;
    } else {
      startDate =
          DateTime.tryParse(savedStartDate?.toString() ?? '') ??
              DateTime.now();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MonthlyScheduleView(
          monthlyContribution: monthlyContribution,
          totalMembers: totalMembers,
          durationMonths: durationMonths,
          startDate: startDate,
        ),
      ),
    );
  }

  void _openReminders() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CommitteeRemindersView(),
      ),
    );
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CommitteeHistoryView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Committee'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Digital Committee',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Manage your monthly money pool easily.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openAddCommittee,
                icon: const Icon(Icons.add),
                label: const Text('Add Committee'),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Your Committees',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            if (committeeData == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.groups_rounded,
                      size: 45,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No committee added yet.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Create your first committee to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            else
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.groups_rounded),
                  ),
                  title: Text(
                    committeeData?['name']?.toString() ??
                        'Committee',
                  ),
                  subtitle: Text(
                    'PKR ${committeeData?['contribution'] ?? '0'} monthly',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                  ),
                  onTap: _openMembers,
                ),
              ),

            const SizedBox(height: 28),

            const Text(
              'Committee Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _buildFeatureCard(
              icon: Icons.groups_rounded,
              title: 'Members',
              description:
                  'Manage committee members and their details.',
              onTap: _openMembers,
            ),

            _buildFeatureCard(
              icon: Icons.receipt_long_rounded,
              title: 'Payment Tracking',
              description:
                  'Track paid, pending and overdue committee payments.',
              onTap: _openPaymentTracking,
            ),

            _buildFeatureCard(
              icon: Icons.calendar_month_rounded,
              title: 'Monthly Schedule',
              description:
                  'Manage monthly schedule and receiving order.',
              onTap: _openMonthlySchedule,
            ),

            _buildFeatureCard(
              icon: Icons.notifications_active_rounded,
              title: 'Reminders & Notifications',
              description:
                  'Manage payment due dates and monthly reminders.',
              onTap: _openReminders,
            ),

            _buildFeatureCard(
              icon: Icons.history_rounded,
              title: 'Committee History',
              description:
                  'View completed committees and payment history.',
              onTap: _openHistory,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(description),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }
}

class CommitteeHistoryView extends StatelessWidget {
  const CommitteeHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? Colors.black : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Committee History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor:
            isDark ? Colors.black : Colors.white,
        foregroundColor:
            isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryCard(
              context,
              isDark,
              'Completed Committee',
              'Digital Committee',
              Icons.check_circle_rounded,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _infoCard(
                    context,
                    isDark,
                    'Members',
                    '4',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _infoCard(
                    context,
                    isDark,
                    'Monthly',
                    'PKR 5,000',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _infoCard(
                    context,
                    isDark,
                    'Total Collected',
                    'PKR 20,000',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _infoCard(
                    context,
                    isDark,
                    'Total Paid Out',
                    'PKR 20,000',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0A0A0A)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Committee Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _detailRow(
                    context,
                    isDark,
                    'Start Date',
                    'January 2026',
                  ),
                  _detailRow(
                    context,
                    isDark,
                    'Completion Date',
                    'April 2026',
                  ),
                  _detailRow(
                    context,
                    isDark,
                    'Completed Months',
                    '4',
                  ),
                  _detailRow(
                    context,
                    isDark,
                    'Status',
                    'Completed',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Receiving History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            _historyCard(
              context,
              isDark,
              'January',
              'Fatima',
              'PKR 25,000',
              'Received',
            ),

            _historyCard(
              context,
              isDark,
              'February',
              'Maryam',
              'PKR 25,000',
              'Received',
            ),

            _historyCard(
              context,
              isDark,
              'March',
              'Sheeza',
              'PKR 25,000',
              'Received',
            ),

            _historyCard(
              context,
              isDark,
              'April',
              'Zara',
              'PKR 25,000',
              'Received',
            ),

            const SizedBox(height: 24),

            Text(
              'Payment History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            _paymentCard(
              context,
              isDark,
              'Fatima',
              'PKR 5,000',
              'January 5, 2026',
            ),

            _paymentCard(
              context,
              isDark,
              'Maryam',
              'PKR 5,000',
              'January 6, 2026',
            ),

            _paymentCard(
              context,
              isDark,
              'Sheeza',
              'PKR 5,000',
              'January 6, 2026',
            ),

            _paymentCard(
              context,
              isDark,
              'Zara',
              'PKR 5,000',
              'January 7, 2026',
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0A0A0A)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'This section keeps a record of completed '
                'committees, receiving order and payment '
                'history.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? Colors.white60
                      : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(
    BuildContext context,
    bool isDark,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0A0A0A)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            child: Icon(icon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? Colors.white60
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(
    BuildContext context,
    bool isDark,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0A0A0A)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? Colors.white60
                  : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    bool isDark,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark
                  ? Colors.white60
                  : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(
    BuildContext context,
    bool isDark,
    String month,
    String member,
    String amount,
    String status,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0A0A0A)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            child: Icon(Icons.person_rounded),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  month,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  member,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white60
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentCard(
    BuildContext context,
    bool isDark,
    String member,
    String amount,
    String date,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0A0A0A)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            child: Icon(Icons.payments_rounded),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  member,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white60
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Paid',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


