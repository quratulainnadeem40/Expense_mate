import 'package:flutter/material.dart';

import '../widgets/payment_card.dart';

class PaymentTrackingView extends StatefulWidget {
  const PaymentTrackingView({super.key});

  @override
  State<PaymentTrackingView> createState() =>
      _PaymentTrackingViewState();
}

class _PaymentTrackingViewState
    extends State<PaymentTrackingView> {
  final List<Map<String, String>> payments = [
    {
      'memberName': 'Ali',
      'amount': 'PKR 5,000',
      'paymentDate': '01 September 2026',
      'status': 'Received',
      'note': 'Monthly contribution received.',
    },
    {
      'memberName': 'Sara',
      'amount': 'PKR 5,000',
      'paymentDate': '05 September 2026',
      'status': 'Pending',
      'note': 'Payment is still pending.',
    },
    {
      'memberName': 'Ahmed',
      'amount': 'PKR 5,000',
      'paymentDate': '01 September 2026',
      'status': 'Overdue',
      'note': 'Payment due date has passed.',
    },
  ];

  int get receivedCount {
    return payments.where((payment) {
      final status =
          (payment['status'] ?? '').toLowerCase();

      return status == 'received' || status == 'paid';
    }).length;
  }

  int get pendingCount {
    return payments.where((payment) {
      return (payment['status'] ?? '').toLowerCase() ==
          'pending';
    }).length;
  }

  int get overdueCount {
    return payments.where((payment) {
      return (payment['status'] ?? '').toLowerCase() ==
          'overdue';
    }).length;
  }

  void _changeStatus(int index) {
    final currentStatus =
        payments[index]['status'] ?? 'Pending';

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        final bool isDark =
            Theme.of(sheetContext).brightness ==
                Brightness.dark;

        final Color backgroundColor =
            isDark ? const Color(0xFF0A0A0A) : Colors.white;

        final Color textColor =
            isDark ? Colors.white : Colors.black87;

        return Container(
          color: backgroundColor,
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                    color:
                        isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 18),
                _statusOption(
                  context: sheetContext,
                  title: 'Received',
                  icon: Icons.check_circle_outline_rounded,
                  color: Colors.green,
                  index: index,
                ),
                _statusOption(
                  context: sheetContext,
                  title: 'Pending',
                  icon: Icons.pending_outlined,
                  color: Colors.orange,
                  index: index,
                ),
                _statusOption(
                  context: sheetContext,
                  title: 'Overdue',
                  icon: Icons.warning_amber_rounded,
                  color: Colors.red,
                  index: index,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required int index,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(title),
      onTap: () {
        setState(() {
          payments[index]['status'] = title;
        });

        Navigator.pop(context);

        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment marked as $title.',
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final Color backgroundColor =
        isDark ? Colors.black : const Color(0xFFF5F5F5);

    final Color cardColor =
        isDark ? const Color(0xFF0A0A0A) : Colors.white;

    final Color primaryTextColor =
        isDark ? Colors.white : Colors.black87;

    final Color secondaryTextColor =
        isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Payment Tracking',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor:
            isDark ? Colors.black : Colors.white,
        foregroundColor: primaryTextColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildSummary(
                isDark: isDark,
                cardColor: cardColor,
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
                  secondaryTextColor:
                      secondaryTextColor,
                )
              else
                ...List.generate(
                  payments.length,
                  (index) {
                    final payment = payments[index];

                    return InkWell(
                      onTap: () => _changeStatus(index),
                      borderRadius:
                          BorderRadius.circular(16),
                      child: PaymentCard(
                        memberName:
                            payment['memberName'] ??
                                'Member Name',
                        amount:
                            payment['amount'] ??
                                'PKR 0',
                        paymentDate:
                            payment['paymentDate'] ??
                                'Date',
                        status:
                            payment['status'] ??
                                'Pending',
                        note: payment['note'],
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

  Widget _buildSummary({
    required bool isDark,
    required Color cardColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color:
              isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
                  icon:
                      Icons.check_circle_outline_rounded,
                  color: Colors.green,
                  primaryTextColor:
                      primaryTextColor,
                  secondaryTextColor:
                      secondaryTextColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryItem(
                  title: 'Pending',
                  value: '$pendingCount',
                  icon: Icons.pending_outlined,
                  color: Colors.orange,
                  primaryTextColor:
                      primaryTextColor,
                  secondaryTextColor:
                      secondaryTextColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryItem(
                  title: 'Overdue',
                  value: '$overdueCount',
                  icon:
                      Icons.warning_amber_rounded,
                  color: Colors.red,
                  primaryTextColor:
                      primaryTextColor,
                  secondaryTextColor:
                      secondaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
        Icon(
          icon,
          color: color,
          size: 23,
        ),
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