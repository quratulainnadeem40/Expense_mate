import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  final String title;
  final String dueDate;
  final String amount;
  final String status;

  const ScheduleCard({
    super.key,
    this.title = 'Monthly Payment',
    this.dueDate = 'Due Date',
    this.amount = 'PKR 0',
    this.status = 'Upcoming',
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white10
                  : Colors.black12,
            ),
            child: Icon(
              Icons.event_note_rounded,
              size: 25,
              color: isDark
                  ? Colors.white70
                  : Colors.black54,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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

                const SizedBox(height: 6),

                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 14,
                      color: isDark
                          ? Colors.white54
                          : Colors.black45,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      dueDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white54
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: status.toLowerCase() == 'paid'
                  ? Colors.green.withOpacity(0.12)
                  : Colors.orange.withOpacity(0.12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: status.toLowerCase() == 'paid'
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}