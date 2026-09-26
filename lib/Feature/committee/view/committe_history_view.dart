
import 'package:flutter/material.dart';

class CommitteeHistoryView extends StatelessWidget {
  const CommitteeHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    // Sample committee history data.
    // Later this can be connected with the actual database.
    final List<Map<String, String>> receivingHistory = [
      {
        'month': 'January',
        'member': 'Fatima',
        'amount': 'PKR 25,000',
        'status': 'Received',
      },
      {
        'month': 'February',
        'member': 'Maryam',
        'amount': 'PKR 25,000',
        'status': 'Received',
      },
      {
        'month': 'March',
        'member': 'Sheeza',
        'amount': 'PKR 25,000',
        'status': 'Received',
      },
      {
        'month': 'April',
        'member': 'Zara',
        'amount': 'PKR 25,000',
        'status': 'Received',
      },
    ];

    final List<Map<String, String>> paymentHistory = [
      {
        'member': 'Fatima',
        'amount': 'PKR 5,000',
        'date': 'January 5, 2026',
        'status': 'Paid',
      },
      {
        'member': 'Maryam',
        'amount': 'PKR 5,000',
        'date': 'January 5, 2026',
        'status': 'Paid',
      },
      {
        'member': 'Sheeza',
        'amount': 'PKR 5,000',
        'date': 'January 6, 2026',
        'status': 'Paid',
      },
      {
        'member': 'Zara',
        'amount': 'PKR 5,000',
        'date': 'January 6, 2026',
        'status': 'Paid',
      },
    ];

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
            _buildCommitteeSummary(
              isDark: isDark,
            ),

            const SizedBox(height: 24),

            Text(
              'Receiving History',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            ...receivingHistory.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildReceivingCard(
                  isDark: isDark,
                  month: item['month'] ?? '',
                  member: item['member'] ?? '',
                  amount: item['amount'] ?? '',
                  status: item['status'] ?? '',
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Payment History',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            ...paymentHistory.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPaymentCard(
                  isDark: isDark,
                  memberName: item['member'] ?? '',
                  amount: item['amount'] ?? '',
                  date: item['date'] ?? '',
                  status: item['status'] ?? '',
                ),
              ),
            ),

            const SizedBox(height: 8),

            _buildHistoryInfo(
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommitteeSummary({
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0A0A0A)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Committee Summary',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),

          const SizedBox(height: 18),

          _summaryRow(
            isDark: isDark,
            icon: Icons.groups_rounded,
            title: 'Members',
            value: '4',
          ),

          const SizedBox(height: 12),

          _summaryRow(
            isDark: isDark,
            icon: Icons.payments_rounded,
            title: 'Monthly Contribution',
            value: 'PKR 5,000',
          ),

          const SizedBox(height: 12),

          _summaryRow(
            isDark: isDark,
            icon: Icons.account_balance_wallet_rounded,
            title: 'Total Collected',
            value: 'PKR 20,000',
          ),

          const SizedBox(height: 12),

          _summaryRow(
            isDark: isDark,
            icon: Icons.send_rounded,
            title: 'Total Paid Out',
            value: 'PKR 20,000',
          ),

          const SizedBox(height: 12),

          _summaryRow(
            isDark: isDark,
            icon: Icons.check_circle_rounded,
            title: 'Completed Months',
            value: '4',
          ),

          const SizedBox(height: 12),

          _summaryRow(
            isDark: isDark,
            icon: Icons.event_rounded,
            title: 'Status',
            value: 'Completed',
          ),
        ],
      ),
    );
  }

  Widget _summaryRow({
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 22,
          color: isDark
              ? Colors.white70
              : Colors.grey[700],
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? Colors.white70
                  : Colors.grey[700],
            ),
          ),
        ),

        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark
                ? Colors.white
                : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildReceivingCard({
    required bool isDark,
    required String month,
    required String member,
    required String amount,
    required String status,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0A0A0A)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            child: Icon(
              Icons.calendar_month_rounded,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  month,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Receiving Member: $member',
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
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),

              const SizedBox(height: 5),

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

  Widget _buildPaymentCard({
    required bool isDark,
    required String memberName,
    required String amount,
    required String date,
    required String status,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0A0A0A)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            child: Icon(
              Icons.payments_rounded,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  memberName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),

                const SizedBox(height: 5),

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
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: status == 'Paid'
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryInfo({
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0A0A0A)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history_rounded,
            size: 42,
            color: isDark
                ? Colors.white70
                : Colors.grey,
          ),

          const SizedBox(height: 10),

          Text(
            'Committee History',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Your completed committee records, '
            'receiving order and payment history '
            'will be available here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? Colors.white60
                  : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
