import 'package:flutter/material.dart';

class PaymentCard extends StatelessWidget {
  final String memberName;
  final String amount;
  final String paymentDate;
  final String status;
  final String? note;

  const PaymentCard({
    super.key,
    this.memberName = 'Member Name',
    this.amount = 'PKR 0',
    this.paymentDate = 'Date',
    this.status = 'Pending',
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final bool isReceived =
        status.toLowerCase() == 'received';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0A0A0A)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white10
              : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Payment Icon
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? Colors.white10
                      : Colors.black12,
                ),
                child: Icon(
                  Icons.payments_rounded,
                  size: 24,
                  color: isDark
                      ? Colors.white70
                      : Colors.black54,
                ),
              ),

              const SizedBox(width: 12),

              // Member Name
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      memberName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: isDark
                              ? Colors.white54
                              : Colors.black45,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          paymentDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white54
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isReceived
                      ? Colors.green.withOpacity(0.12)
                      : Colors.orange.withOpacity(0.12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isReceived
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Amount
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.04),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 18,
                  color: isDark
                      ? Colors.white70
                      : Colors.black54,
                ),

                const SizedBox(width: 8),

                Text(
                  'Amount',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white54
                        : Colors.black54,
                  ),
                ),

                const Spacer(),

                Text(
                  amount,
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
          ),

          // Optional Note
          if (note != null && note!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.notes_rounded,
                  size: 17,
                  color: isDark
                      ? Colors.white54
                      : Colors.black45,
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: Text(
                    note!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.white60
                          : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}