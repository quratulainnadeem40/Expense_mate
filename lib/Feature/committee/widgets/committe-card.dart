import 'package:flutter/material.dart';

class MemberCard extends StatelessWidget {
  final Map<String, String> member;

  const MemberCard({
    super.key,
    required this.member,
  });

  String _getValue(String key) {
    return member[key]?.trim().isNotEmpty == true
        ? member[key]!
        : 'Not available';
  }

  @override
  Widget build(BuildContext context) {
    final String name = _getValue('name');
    final String fatherName = _getValue('fatherName');
    final String phone = _getValue('phone');
    final String contribution = _getValue('contribution');
    final String paymentStatus = member['paymentStatus'] ?? 'Pending';

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Member Name
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.person,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Father Name
            _buildInfoRow(
              icon: Icons.person_outline,
              label: 'Father Name',
              value: fatherName,
            ),

            const SizedBox(height: 12),

            // Phone Number
            _buildInfoRow(
              icon: Icons.phone_outlined,
              label: 'Phone Number',
              value: phone,
            ),

            const SizedBox(height: 12),

            // Monthly Contribution
            _buildInfoRow(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Monthly Contribution',
              value: contribution.startsWith('PKR')
                  ? contribution
                  : 'PKR $contribution',
            ),

            const SizedBox(height: 14),

            // Payment Status
            Row(
              children: [
                const Icon(
                  Icons.payment_outlined,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Payment Status',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(),
                  ),
                  child: Text(
                    paymentStatus,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                ),
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}