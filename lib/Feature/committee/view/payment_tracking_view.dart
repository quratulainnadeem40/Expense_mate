
import 'package:flutter/material.dart';

import '../controller/committe_controller.dart';
import '../widgets/payment_card.dart';

class PaymentTrackingView extends StatefulWidget {
  const PaymentTrackingView({super.key});

  @override
  State<PaymentTrackingView> createState() =>
      _PaymentTrackingViewState();
}

class _PaymentTrackingViewState
    extends State<PaymentTrackingView> {
  final CommitteeController committeeController =
      CommitteeController.instance;

  @override
  void initState() {
    super.initState();
    _createPaymentRecordsForMembers();
  }

  // --------------------------------------------------
  // CREATE PAYMENT RECORDS FOR REAL MEMBERS ONLY
  // --------------------------------------------------

  void _createPaymentRecordsForMembers() {
    final members = committeeController.members;

    for (final member in members) {
      final String memberName =
          member['name']?.toString().trim() ?? '';

      if (memberName.isEmpty) continue;

      final bool alreadyExists =
          committeeController.payments.any(
        (payment) =>
            payment['memberName']?.toString() ==
            memberName,
      );

      if (alreadyExists) continue;

      final double contribution =
          member['contribution'] is num
              ? (member['contribution'] as num).toDouble()
              : double.tryParse(
                    member['contribution']
                            ?.toString()
                            .replaceAll(',', '') ??
                        '',
                  ) ??
                  committeeController
                      .monthlyContribution.value;

      committeeController.addPayment(
        memberName: memberName,
        amount: contribution,
        status: 'Pending',
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  // --------------------------------------------------
  // FORMAT AMOUNT
  // --------------------------------------------------

  String _formatAmount(double amount) {
    final int roundedAmount = amount.round();
    final String value = roundedAmount.toString();
    final StringBuffer result = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      if (i > 0 && (value.length - i) % 3 == 0) {
        result.write(',');
      }
      result.write(value[i]);
    }

    return 'PKR $result';
  }

  // --------------------------------------------------
  // FORMAT DATE
  // --------------------------------------------------

  String _formatDate(DateTime date) {
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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // --------------------------------------------------
  // GET PAYMENT AMOUNT
  // --------------------------------------------------

  double _getPaymentAmount(
    Map<String, dynamic> payment,
  ) {
    final dynamic amount = payment['amount'];

    if (amount is num) {
      return amount.toDouble();
    }

    return double.tryParse(
          amount?.toString().replaceAll(',', '') ?? '',
        ) ??
        0;
  }

  // --------------------------------------------------
  // PAYMENT COUNTS
  // --------------------------------------------------

  int get receivedCount {
    return committeeController.payments.where((payment) {
      final String status =
          (payment['status'] ?? '').toString().toLowerCase();

      return status == 'received' || status == 'paid';
    }).length;
  }

  int get pendingCount {
    return committeeController.payments.where((payment) {
      return (payment['status'] ?? '')
              .toString()
              .toLowerCase() ==
          'pending';
    }).length;
  }

  int get overdueCount {
    return committeeController.payments.where((payment) {
      return (payment['status'] ?? '')
              .toString()
              .toLowerCase() ==
          'overdue';
    }).length;
  }

  // --------------------------------------------------
  // CHANGE PAYMENT STATUS
  // --------------------------------------------------

  void _changeStatus(int index) {
    if (index < 0 ||
        index >= committeeController.payments.length) {
      return;
    }

    final String currentStatus =
        committeeController.payments[index]['status']
                ?.toString() ??
            'Pending';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final bool isDark =
            Theme.of(sheetContext).brightness == Brightness.dark;

        final Color backgroundColor = isDark
            ? const Color(0xFF202124)
            : Colors.white;

        final Color textColor =
            isDark ? const Color(0xFFF5F5F5) : const Color(0xFF252B35);

        final Color secondaryColor =
            isDark ? const Color(0xFFBDBDBD) : const Color(0xFF626B78);

        final Color borderColor =
            isDark ? const Color(0xFF383838) : const Color(0xFFDDE1E7);

        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(22),
            ),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Change Payment Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Current status: $currentStatus',
                  style: TextStyle(
                    fontSize: 13,
                    color: secondaryColor,
                  ),
                ),
                const SizedBox(height: 18),
                _statusOption(
                  context: sheetContext,
                  title: 'Received',
                  icon: Icons.check_circle_outline_rounded,
                  color: isDark
                      ? const Color(0xFF65D6A0)
                      : const Color(0xFF27845D),
                  index: index,
                  textColor: textColor,
                ),
                _statusOption(
                  context: sheetContext,
                  title: 'Pending',
                  icon: Icons.pending_outlined,
                  color: isDark
                      ? const Color(0xFFFFCA70)
                      : const Color(0xFFB7791F),
                  index: index,
                  textColor: textColor,
                ),
                _statusOption(
                  context: sheetContext,
                  title: 'Overdue',
                  icon: Icons.warning_amber_rounded,
                  color: isDark
                      ? const Color(0xFFFF8585)
                      : const Color(0xFFC43D45),
                  index: index,
                  textColor: textColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------
  // STATUS OPTION
  // --------------------------------------------------

  Widget _statusOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required int index,
    required Color textColor,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      onTap: () {
        if (index < 0 ||
            index >= committeeController.payments.length) {
          Navigator.pop(context);
          return;
        }

        if (title == 'Received') {
          committeeController.markPaymentReceived(index);
        } else if (title == 'Pending') {
          committeeController.markPaymentPending(index);
        } else if (title == 'Overdue') {
          committeeController.markPaymentOverdue(index);
        }

        if (mounted) {
          setState(() {});
        }

        Navigator.pop(context);

        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
            content: Text('Payment marked as $title.'),
          ),
        );
      },
    );
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final Color backgroundColor = isDark
        ? Colors.black
        : const Color(0xFFF5F6F8);

    final Color cardColor = isDark
        ? const Color(0xFF202124)
        : Colors.white;

    final Color primaryTextColor = isDark
        ? const Color(0xFFF5F5F5)
        : const Color(0xFF252B35);

    final Color secondaryTextColor = isDark
        ? const Color(0xFFBDBDBD)
        : const Color(0xFF626B78);

    final Color borderColor = isDark
        ? const Color(0xFF383838)
        : const Color(0xFFDDE1E7);

    final List<Map<String, dynamic>> payments =
        committeeController.payments;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.payments_rounded),
            SizedBox(width: 8),
            Text(
              'Payment Tracking',
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummary(
                isDark: isDark,
                cardColor: cardColor,
                borderColor: borderColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
              ),
              const SizedBox(height: 20),
              Text(
                'Payment Records',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 12),
              if (payments.isEmpty)
                _buildEmptyState(
                  secondaryTextColor: secondaryTextColor,
                )
              else
                ...List.generate(
                  payments.length,
                  (index) {
                    final payment = payments[index];
                    final double amount =
                        _getPaymentAmount(payment);

                    final DateTime? paymentDate =
                        payment['paymentDate'] is DateTime
                            ? payment['paymentDate'] as DateTime
                            : null;

                    final String dateText = paymentDate != null
                        ? _formatDate(paymentDate)
                        : 'Date not added';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: InkWell(
                        onTap: () => _changeStatus(index),
                        borderRadius: BorderRadius.circular(16),
                        child: PaymentCard(
                          memberName:
                              payment['memberName']?.toString() ??
                                  'Member Name',
                          amount: _formatAmount(amount),
                          paymentDate: dateText,
                          status:
                              payment['status']?.toString() ??
                                  'Pending',
                          note: payment['note']?.toString(),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 12),
              Text(
                'Tap any payment record to change its status.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // PAYMENT SUMMARY
  // --------------------------------------------------

  Widget _buildSummary({
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Summary',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  title: 'Received',
                  value: '$receivedCount',
                  icon: Icons.check_circle_outline_rounded,
                  color: isDark
                      ? const Color(0xFF65D6A0)
                      : const Color(0xFF27845D),
                  primaryTextColor: primaryTextColor,
                  secondaryTextColor: secondaryTextColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryItem(
                  title: 'Pending',
                  value: '$pendingCount',
                  icon: Icons.pending_outlined,
                  color: isDark
                      ? const Color(0xFFFFCA70)
                      : const Color(0xFFB7791F),
                  primaryTextColor: primaryTextColor,
                  secondaryTextColor: secondaryTextColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryItem(
                  title: 'Overdue',
                  value: '$overdueCount',
                  icon: Icons.warning_amber_rounded,
                  color: isDark
                      ? const Color(0xFFFF8585)
                      : const Color(0xFFC43D45),
                  primaryTextColor: primaryTextColor,
                  secondaryTextColor: secondaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // SUMMARY ITEM
  // --------------------------------------------------

  Widget _summaryItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 23),
        const SizedBox(height: 7),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: secondaryTextColor,
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // EMPTY STATE
  // --------------------------------------------------

  Widget _buildEmptyState({
    required Color secondaryTextColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 35,
      ),
      child: Column(
        children: [
          Icon(
            Icons.payments_outlined,
            size: 55,
            color: secondaryTextColor,
          ),
          const SizedBox(height: 12),
          Text(
            'No Payment Records Yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
