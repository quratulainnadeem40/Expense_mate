import 'package:flutter/material.dart';

class MemberCard extends StatelessWidget {
  final String memberName;
  final String phone;
  final String contribution;
  final String paymentStatus;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MemberCard({
    super.key,
    this.memberName = 'Member Name',
    this.phone = '',
    this.contribution = 'PKR 0',
    this.paymentStatus = 'Pending',
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final bool isPaid =
        paymentStatus.toLowerCase() == 'paid' ||
        paymentStatus.toLowerCase() == 'received';

    final bool isOverdue =
        paymentStatus.toLowerCase() == 'overdue';

    final Color backgroundColor =
        isDark ? const Color(0xFF0A0A0A) : Colors.white;

    final Color primaryTextColor =
        isDark ? Colors.white : Colors.black87;

    final Color secondaryTextColor =
        isDark ? Colors.white60 : Colors.black54;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Member Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isDark ? Colors.white10 : Colors.black12,
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 28,
                  color: primaryTextColor,
                ),
              ),

              const SizedBox(width: 14),

              // Member Information
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
                        color: primaryTextColor,
                      ),
                    ),

                    if (phone.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_rounded,
                            size: 14,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              phone,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    secondaryTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(
                          Icons.payments_rounded,
                          size: 14,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          contribution,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Edit Menu
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit?.call();
                  } else if (value == 'delete') {
                    onDelete?.call();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded),
                        SizedBox(width: 10),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded),
                        SizedBox(width: 10),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Payment Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isPaid
                  ? Colors.green.withOpacity(0.10)
                  : isOverdue
                      ? Colors.red.withOpacity(0.10)
                      : Colors.orange.withOpacity(0.10),
            ),
            child: Row(
              children: [
                Icon(
                  isPaid
                      ? Icons.check_circle_outline_rounded
                      : isOverdue
                          ? Icons.warning_amber_rounded
                          : Icons.pending_outlined,
                  size: 18,
                  color: isPaid
                      ? Colors.green
                      : isOverdue
                          ? Colors.red
                          : Colors.orange,
                ),

                const SizedBox(width: 8),

                Text(
                  'Payment Status',
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),

                const Spacer(),

                Text(
                  paymentStatus,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isPaid
                        ? Colors.green
                        : isOverdue
                            ? Colors.red
                            : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}