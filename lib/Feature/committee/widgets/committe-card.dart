import 'package:flutter/material.dart';

class CommitteeCard extends StatelessWidget {
  final String committeeName;
  final String monthlyAmount;
  final String members;
  final String status;

  const CommitteeCard({
    super.key,
    this.committeeName = 'Digital Committee',
    this.monthlyAmount = 'PKR 0',
    this.members = '0 Members',
    this.status = 'Active',
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0A0A0A)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white10
              : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? Colors.white10
                      : Colors.black12,
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  size: 26,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  committeeName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(20),
                  color: status == 'Active'
                      ? Colors.green.withOpacity(0.12)
                      : Colors.orange.withOpacity(0.12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: status == 'Active'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _infoItem(
                  icon: Icons.payments_rounded,
                  title: 'Monthly',
                  value: monthlyAmount,
                  isDark: isDark,
                ),
              ),

              Expanded(
                child: _infoItem(
                  icon: Icons.people_alt_rounded,
                  title: 'Members',
                  value: members,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark
              ? Colors.white70
              : Colors.black54,
        ),

        const SizedBox(width: 8),

        Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? Colors.white54
                    : Colors.black45,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              value,
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
      ],
    );
  }
}