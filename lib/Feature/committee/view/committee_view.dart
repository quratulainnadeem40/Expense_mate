import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../Core/constants/app_keys.dart';

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

  @override
  void initState() {
    super.initState();
    _loadCommittee();
  }

  // Load actual committee data saved in Hive.
  void _loadCommittee() {
    final Box committeeBox = Hive.box(AppKeys.committeeBox);

    final dynamic savedData =
        committeeBox.get('currentCommittee');

    if (savedData is Map) {
      setState(() {
        committeeData =
            Map<String, dynamic>.from(savedData);
      });
    }
  }

  // Open Add Committee screen.
  Future<void> _openAddCommittee() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCommitteeView(),
      ),
    );

    if (result != null && result is Map) {
      setState(() {
        committeeData =
            Map<String, dynamic>.from(result);
      });

      // Reload from Hive to make sure the latest saved
      // actual data is being displayed.
      _loadCommittee();
    }
  }

  // Open Members screen.
  void _openMembers() {
    if (committeeData == null) {
      _showNoCommitteeMessage();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommitteeDetailsView(
          committeeData: committeeData,
        ),
      ),
    );
  }

  // Open Payment Tracking.
  void _openPaymentTracking() {
    if (committeeData == null) {
      _showNoCommitteeMessage();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaymentTrackingView(),
      ),
    );
  }

  // Open Monthly Schedule.
  void _openMonthlySchedule() {
    if (committeeData == null) {
      _showNoCommitteeMessage();
      return;
    }

    final double monthlyContribution =
        _parseAmount(
      committeeData!['contribution'],
    );

    final int totalMembers =
        int.tryParse(
          committeeData!['members']?.toString() ?? '0',
        ) ??
        0;

    final int duration =
        int.tryParse(
          committeeData!['duration']?.toString() ?? '0',
        ) ??
        0;

    DateTime? startDate;

    final dynamic savedStartDate =
        committeeData!['startDate'];

    if (savedStartDate is DateTime) {
      startDate = savedStartDate;
    } else if (savedStartDate is String) {
      startDate = DateTime.tryParse(savedStartDate);
    }

    if (startDate == null) {
      _showMessage('Start date is not available.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MonthlyScheduleView(
          monthlyContribution: monthlyContribution,
          totalMembers: totalMembers,
          durationMonths: duration,
          startDate: startDate!,
        ),
      ),
    );
  }

  // Open Reminders.
  void _openReminders() {
    if (committeeData == null) {
      _showNoCommitteeMessage();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CommitteeRemindersView(),
      ),
    );
  }

  // Open Committee History.
  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CommitteeHistoryView(),
      ),
    );
  }

  double _parseAmount(dynamic value) {
    if (value == null) {
      return 0;
    }

    String amount = value.toString();

    amount = amount
        .replaceAll('PKR', '')
        .replaceAll(',', '')
        .trim();

    return double.tryParse(amount) ?? 0;
  }

  String _formatAmount(dynamic value) {
    final double amount = _parseAmount(value);

    final String formatted =
        amount.toStringAsFixed(0);

    final StringBuffer buffer =
        StringBuffer();

    for (int i = 0; i < formatted.length; i++) {
      if (i > 0 &&
          (formatted.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(formatted[i]);
    }

    return buffer.toString();
  }

  void _showNoCommitteeMessage() {
    _showMessage(
      'Please add a committee first.',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Committee',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // Header
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
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20),

            // Add Committee Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openAddCommittee,
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                ),
                label: const Text(
                  'Add Committee',
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Your Committees',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Actual committee data
            if (committeeData == null)
              _buildEmptyCommitteeCard()
            else
              _buildCommitteeCard(),

            const SizedBox(height: 20),

            // Feature Cards
            _buildFeatureCard(
              icon: Icons.people_alt_rounded,
              title: 'Members',
              subtitle:
                  'Manage committee members',
              onTap: _openMembers,
            ),

            _buildFeatureCard(
              icon: Icons.payments_rounded,
              title: 'Payment Tracking',
              subtitle:
                  'Track member payments',
              onTap: _openPaymentTracking,
            ),

            _buildFeatureCard(
              icon: Icons.calendar_month_rounded,
              title: 'Monthly Schedule',
              subtitle:
                  'Manage receiving order',
              onTap: _openMonthlySchedule,
            ),

            _buildFeatureCard(
              icon: Icons.notifications_active_rounded,
              title: 'Reminders & Notifications',
              subtitle:
                  'Manage payment reminders',
              onTap: _openReminders,
            ),

            _buildFeatureCard(
              icon: Icons.history_rounded,
              title: 'Committee History',
              subtitle:
                  'View previous committee records',
              onTap: _openHistory,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCommitteeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.groups_rounded,
              size: 48,
            ),

            const SizedBox(height: 12),

            const Text(
              'No Committee Added',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Create your first committee to get started.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommitteeCard() {
    final String name =
        committeeData!['name']?.toString() ??
            'Digital Committee';

    final String contribution =
        _formatAmount(
      committeeData!['contribution'],
    );

    final String members =
        committeeData!['members']?.toString() ??
            '0';

    final String totalAmount =
        _formatAmount(
      committeeData!['totalAmount'],
    );

    final String duration =
        committeeData!['duration']?.toString() ??
            '0';

    final String durationUnit =
        committeeData!['durationUnit']?.toString() ??
            'Months';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.account_balance_rounded,
                  size: 32,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    name,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildInfoRow(
              Icons.currency_exchange_rounded,
              'Monthly Contribution',
              'PKR $contribution',
            ),

            _buildInfoRow(
              Icons.people_alt_rounded,
              'Members',
              members,
            ),

            _buildInfoRow(
              Icons.account_balance_wallet_rounded,
              'Total Amount',
              'PKR $totalAmount',
            ),

            _buildInfoRow(
              Icons.calendar_month_rounded,
              'Duration',
              '$duration $durationUnit',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              title,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),

          const SizedBox(width: 10),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              softWrap: true,
              overflow: TextOverflow.visible,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 30,
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      softWrap: true,
                      overflow:
                          TextOverflow.visible,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      softWrap: true,
                      overflow:
                          TextOverflow.visible,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Temporary empty history screen.
// Dummy history data has been removed.
// Actual history will be connected with saved committee
// payment/receiving records.
class CommitteeHistoryView extends StatelessWidget {
  const CommitteeHistoryView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Committee History',
        ),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.history_rounded,
                size: 60,
              ),

              const SizedBox(height: 16),

              const Text(
                'No Committee History',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Completed committee records will appear here.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}