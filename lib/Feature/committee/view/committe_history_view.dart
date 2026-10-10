
import 'package:flutter/material.dart';

import '../controller/committe_controller.dart';

class CommitteeHistoryView extends StatelessWidget {
  const CommitteeHistoryView({super.key});

  static const Color teal = Color(0xFF27845D);
  static const Color softTeal = Color(0xFFDDF5EF);

  String _formatAmount(dynamic amount) {
    final String cleanAmount = amount
        .toString()
        .replaceAll('PKR', '')
        .replaceAll(',', '')
        .trim();

    final double? value = double.tryParse(cleanAmount);

    if (value == null) {
      return amount.toString();
    }

    final String number = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);

    final List<String> parts = number.split('.');
    final String integerPart = parts[0];
    final StringBuffer formatted = StringBuffer();

    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        formatted.write(',');
      }
      formatted.write(integerPart[i]);
    }

    if (parts.length > 1) {
      formatted.write('.');
      formatted.write(parts[1]);
    }

    return 'PKR ${formatted.toString()}';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not Added';

    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  String _monthName(int month) {
    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final Color backgroundColor =
        isDark ? Colors.black : const Color(0xFFF5F6F8);

    final Color cardColor =
        isDark ? const Color(0xFF202124) : Colors.white;

    final Color primaryTextColor =
        isDark ? const Color(0xFFF5F5F5) : const Color(0xFF252B35);

    final Color secondaryTextColor =
        isDark ? const Color(0xFFBDBDBD) : const Color(0xFF626B78);

    final Color borderColor =
        isDark ? const Color(0xFF383838) : const Color(0xFFDDE1E7);

    final CommitteeController committeeController =
        CommitteeController.instance;

    final List<Map<String, dynamic>> receivingHistory =
        committeeController.receivingSchedule;

    final List<Map<String, dynamic>> paymentHistory =
        committeeController.payments;

    final double monthlyContribution =
        committeeController.monthlyContribution.value;

    final int totalMembers = committeeController.members.length;

    final double totalCollected = paymentHistory.fold(
      0.0,
      (sum, payment) =>
          sum + ((payment['amount'] as num?)?.toDouble() ?? 0.0),
    );

    final double totalPaidOut = receivingHistory
        .where(
          (item) =>
              item['status']?.toString().toLowerCase() == 'received',
        )
        .fold(
          0.0,
          (sum, item) =>
              sum + ((item['amount'] as num?)?.toDouble() ?? 0.0),
        );

    final int completedMonths = receivingHistory
        .where(
          (item) =>
              item['status']?.toString().toLowerCase() == 'received',
        )
        .length;

    final String status;

    if (committeeController.committeeName.value.isEmpty) {
      status = 'No Committee';
    } else if (committeeController.endingDate.value != null &&
        DateTime.now().isAfter(
          committeeController.endingDate.value!,
        )) {
      status = 'Completed';
    } else {
      status = 'Active';
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded),
            SizedBox(width: 8),
            Text(
              'Committee History',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        foregroundColor: primaryTextColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCommitteeSummary(
              isDark: isDark,
              cardColor: cardColor,
              borderColor: borderColor,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
              committeeController: committeeController,
              totalMembers: totalMembers,
              monthlyContribution: monthlyContribution,
              totalCollected: totalCollected,
              totalPaidOut: totalPaidOut,
              completedMonths: completedMonths,
              status: status,
            ),

            const SizedBox(height: 24),

            _sectionTitle(
              'Receiving History',
              primaryTextColor,
            ),

            const SizedBox(height: 12),

            if (receivingHistory.isEmpty)
              _buildEmptyCard(
                isDark: isDark,
                cardColor: cardColor,
                borderColor: borderColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                icon: Icons.calendar_month_rounded,
                message: 'No receiving history available yet.',
              )
            else
              ...receivingHistory.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildReceivingCard(
                    isDark: isDark,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    month: _monthName(item['month'] as int? ?? 0),
                    member: item['memberName']?.toString() ?? 'Member',
                    amount: item['amount']?.toString() ?? '0',
                    status: item['status']?.toString() ?? 'Upcoming',
                  ),
                ),
              ),

            const SizedBox(height: 12),

            _sectionTitle(
              'Payment History',
              primaryTextColor,
            ),

            const SizedBox(height: 12),

            if (paymentHistory.isEmpty)
              _buildEmptyCard(
                isDark: isDark,
                cardColor: cardColor,
                borderColor: borderColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                icon: Icons.payments_rounded,
                message: 'No payment history available yet.',
              )
            else
              ...paymentHistory.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildPaymentCard(
                    isDark: isDark,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    memberName:
                        item['memberName']?.toString() ?? 'Member',
                    amount: item['amount']?.toString() ?? '0',
                    date: _formatPaymentDate(item['paymentDate']),
                    status: _paymentStatus(
                      item['status']?.toString(),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 8),

            _buildHistoryInfo(
              isDark: isDark,
              cardColor: cardColor,
              borderColor: borderColor,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
              hasCommittee:
                  committeeController.committeeName.value.isNotEmpty,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  String _formatPaymentDate(dynamic date) {
    if (date == null) return 'Date not available';
    if (date is DateTime) return _formatDate(date);

    final DateTime? parsed = DateTime.tryParse(date.toString());
    if (parsed == null) return date.toString();

    return _formatDate(parsed);
  }

  String _paymentStatus(String? status) {
    if (status == null || status.isEmpty) return 'Pending';
    if (status.toLowerCase() == 'received') return 'Paid';
    if (status.toLowerCase() == 'overdue') return 'Overdue';
    return 'Pending';
  }

  BoxDecoration _cardDecoration({
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
  }) {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: borderColor),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: isDark ? 0.12 : 0.035,
          ),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildCommitteeSummary({
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required CommitteeController committeeController,
    required int totalMembers,
    required double monthlyContribution,
    required double totalCollected,
    required double totalPaidOut,
    required int completedMonths,
    required String status,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(
        isDark: isDark,
        cardColor: cardColor,
        borderColor: borderColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Committee Summary',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),

          if (committeeController.committeeName.value.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              committeeController.committeeName.value,
              style: TextStyle(
                fontSize: 14,
                color: secondaryTextColor,
              ),
            ),
          ],

          const SizedBox(height: 18),

          _summaryRow(
            isDark: isDark,
            icon: Icons.groups_rounded,
            title: 'Members',
            value: totalMembers.toString(),
            primaryTextColor: primaryTextColor,
            secondaryTextColor: secondaryTextColor,
          ),

          const SizedBox(height: 12),

          _summaryRow(
            isDark: isDark,
            icon: Icons.payments_rounded,
            title: 'Monthly Contribution',
            value: _formatAmount(monthlyContribution),
            primaryTextColor: primaryTextColor,
            secondaryTextColor: secondaryTextColor,
          ),

          const SizedBox(height: 12),

          _summaryRow(
            isDark: isDark,
            icon: Icons.account_balance_wallet_rounded,
            title: 'Total Committee Amount',
            value: _formatAmount(committeeController.totalPool),
            primaryTextColor: primaryTextColor,
            secondaryTextColor: secondaryTextColor,
          ),

          const SizedBox(height: 12),

          _summaryRow(
            isDark: isDark,
            icon: Icons.account_balance_wallet_rounded,
            title: 'Total Collected',
            value: _formatAmount(totalCollected),
            primaryTextColor: primaryTextColor,
            secondaryTextColor: secondaryTextColor,
          ),

          const SizedBox(height: 12),

          _summaryRow(
            isDark: isDark,
            icon: Icons.send_rounded,
            title: 'Total Paid Out',
            value: _formatAmount(totalPaidOut),
            primaryTextColor: primaryTextColor,
            secondaryTextColor: secondaryTextColor,
          ),

          const SizedBox(height: 12),

          _summaryRow(
            isDark: isDark,
            icon: Icons.check_circle_rounded,
            title: 'Completed Months',
            value: completedMonths.toString(),
            primaryTextColor: primaryTextColor,
            secondaryTextColor: secondaryTextColor,
          ),

          const SizedBox(height: 12),

          _summaryRow(
            isDark: isDark,
            icon: Icons.play_circle_outline_rounded,
            title: 'Start Date',
            value: _formatDate(committeeController.startDate.value),
            primaryTextColor: primaryTextColor,
            secondaryTextColor: secondaryTextColor,
          ),

          const SizedBox(height: 12),

          _summaryRow(
            isDark: isDark,
            icon: Icons.event_rounded,
            title: 'Ending Date',
            value: _formatDate(committeeController.endingDate.value),
            primaryTextColor: primaryTextColor,
            secondaryTextColor: secondaryTextColor,
          ),

          const SizedBox(height: 12),

          _summaryRow(
            isDark: isDark,
            icon: Icons.check_circle_rounded,
            title: 'Status',
            value: status,
            primaryTextColor: primaryTextColor,
            secondaryTextColor: secondaryTextColor,
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
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    final Color iconColor = isDark
        ? const Color(0xFF65D6A0)
        : const Color(0xFF27845D);

    final Color iconBackground = isDark
        ? const Color(0xFF263D32)
        : const Color(0xFFE3F3EA);

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 21,
            color: iconColor,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: secondaryTextColor,
            ),
          ),
        ),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReceivingCard({
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required String month,
    required String member,
    required String amount,
    required String status,
  }) {
    final bool received = status.toLowerCase() == 'received';

    final Color statusColor = received
        ? (isDark ? const Color(0xFF65D6A0) : const Color(0xFF218653))
        : (isDark ? const Color(0xFFFFCA70) : const Color(0xFFAD6B08));

    final Color statusBackground = received
        ? (isDark ? const Color(0xFF263D32) : const Color(0xFFDDF5E5))
        : (isDark ? const Color(0xFF443622) : const Color(0xFFFFF0D9));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(
        isDark: isDark,
        cardColor: cardColor,
        borderColor: borderColor,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: isDark
                ? const Color(0xFF263D32)
                : const Color(0xFFE3F3EA),
            child: Icon(
              Icons.calendar_month_rounded,
              color: isDark
                  ? const Color(0xFF65D6A0)
                  : const Color(0xFF27845D),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Receiving Member: $member',
                  style: TextStyle(
                    fontSize: 13,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatAmount(amount),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
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
    required Color cardColor,
    required Color borderColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required String memberName,
    required String amount,
    required String date,
    required String status,
  }) {
    final bool paid = status == 'Paid';

    final Color statusColor = paid
        ? (isDark ? const Color(0xFF65D6A0) : const Color(0xFF218653))
        : (isDark ? const Color(0xFFFFCA70) : const Color(0xFFAD6B08));

    final Color statusBackground = paid
        ? (isDark ? const Color(0xFF263D32) : const Color(0xFFDDF5E5))
        : (isDark ? const Color(0xFF443622) : const Color(0xFFFFF0D9));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(
        isDark: isDark,
        cardColor: cardColor,
        borderColor: borderColor,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: isDark
                ? const Color(0xFF263D32)
                : const Color(0xFFE3F3EA),
            child: Icon(
              Icons.payments_rounded,
              color: isDark
                  ? const Color(0xFF65D6A0)
                  : const Color(0xFF27845D),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memberName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 13,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatAmount(amount),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard({
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required IconData icon,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(
        isDark: isDark,
        cardColor: cardColor,
        borderColor: borderColor,
      ),
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF263D32)
                  : const Color(0xFFE3F3EA),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: isDark
                  ? const Color(0xFF65D6A0)
                  : const Color(0xFF27845D),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryInfo({
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required bool hasCommittee,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(
        isDark: isDark,
        cardColor: cardColor,
        borderColor: borderColor,
      ),
      child: Column(
        children: [
          Icon(
            Icons.history_rounded,
            size: 42,
            color: isDark
                ? const Color(0xFF65D6A0)
                : const Color(0xFF27845D),
          ),
          const SizedBox(height: 10),
          Text(
            'Committee History',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasCommittee
                ? 'Your committee records, receiving order '
                    'and payment history are shown above.'
                : 'Create a committee first. Your committee '
                    'records and payment history will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
