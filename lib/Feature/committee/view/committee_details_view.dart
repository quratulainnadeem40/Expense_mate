import 'package:flutter/material.dart';

import '../widgets/member_card.dart';

class CommitteeDetailsView extends StatefulWidget {
  const CommitteeDetailsView({super.key});

  @override
  State<CommitteeDetailsView> createState() => _CommitteeDetailsViewState();
}

class _CommitteeDetailsViewState extends State<CommitteeDetailsView> {
  final List<Map<String, String>> members = [];

  double get totalPool {
    double total = 0;

    for (final member in members) {
      total += double.tryParse(member['contribution'] ?? '0') ?? 0;
    }

    return total;
  }

  double get collectedAmount {
    double collected = 0;

    for (final member in members) {
      final status = (member['paymentStatus'] ?? '').toLowerCase();

      if (status == 'paid' || status == 'received') {
        collected +=
            double.tryParse(member['contribution'] ?? '0') ?? 0;
      }
    }

    return collected;
  }

  double get remainingAmount {
    final remaining = totalPool - collectedAmount;
    return remaining < 0 ? 0 : remaining;
  }

  double get progress {
    if (totalPool == 0) {
      return 0;
    }

    return (collectedAmount / totalPool).clamp(0.0, 1.0);
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }

    return amount.toStringAsFixed(2);
  }

  void _showMemberDialog({int? editIndex}) {
    final bool isEdit = editIndex != null;

    final Map<String, String>? existingMember =
        isEdit ? members[editIndex!] : null;

    final TextEditingController nameController =
        TextEditingController(
      text: existingMember?['name'] ?? '',
    );

    final TextEditingController phoneController =
        TextEditingController(
      text: existingMember?['phone'] ?? '',
    );

    final TextEditingController contributionController =
        TextEditingController(
      text: existingMember?['contribution'] ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            isEdit ? 'Edit Member' : 'Add Member',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Member Name',
                    hintText: 'Enter member name',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number (Optional)',
                    hintText: 'Enter phone number',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contributionController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Monthly Contribution',
                    hintText: 'Enter contribution',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final String name =
                    nameController.text.trim();

                final String phone =
                    phoneController.text.trim();

                final String contribution =
                    contributionController.text.trim();

                if (name.isEmpty || contribution.isEmpty) {
                  return;
                }

                setState(() {
                  final Map<String, String> newMember = {
                    'name': name,
                    'phone': phone,
                    'contribution': contribution,
                    'paymentStatus': isEdit
                        ? (existingMember?['paymentStatus'] ??
                            'Pending')
                        : 'Pending',
                  };

                  if (isEdit) {
                    members[editIndex!] = newMember;
                  } else {
                    members.add(newMember);
                  }
                });

                Navigator.pop(dialogContext);
              },
              child: Text(
                isEdit ? 'Update' : 'Add',
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteMember(int index) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Member'),
          content: const Text(
            'Are you sure you want to delete this member?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  members.removeAt(index);
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Committee Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),

            _buildSummarySection(),

            const SizedBox(height: 20),

            _buildProgressSection(),

            const SizedBox(height: 20),

            _buildMembersSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.green.withOpacity(0.12),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Digital Committee',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Money Pool',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    final double monthlyContribution = members.isNotEmpty
        ? double.tryParse(
              members.first['contribution'] ?? '0',
            ) ??
            0
        : 0;

    return Row(
      children: [
        Expanded(
          child: _summaryItem(
            'Monthly',
            'PKR ${_formatAmount(monthlyContribution)}',
            Icons.payments_rounded,
            () {
              _showInfoDialog(
                'Monthly Contribution',
                members.isEmpty
                    ? 'No member has been added yet.'
                    : 'Monthly contribution per member is PKR ${_formatAmount(monthlyContribution)}.',
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryItem(
            'Members',
            members.length.toString(),
            Icons.groups_rounded,
            () {
              _showInfoDialog(
                'Members',
                members.isEmpty
                    ? 'No members have been added yet.'
                    : 'This committee has ${members.length} member${members.length == 1 ? '' : 's'}.',
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryItem(
            'Total Pool',
            'PKR ${_formatAmount(totalPool)}',
            Icons.account_balance_rounded,
            () {
              _showInfoDialog(
                'Total Pool',
                'Total committee pool is PKR ${_formatAmount(totalPool)}.',
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryItem(
            'Duration',
            '${members.length} Months',
            Icons.calendar_month_rounded,
            () {
              _showInfoDialog(
                'Duration',
                'Current duration is ${members.length} month${members.length == 1 ? '' : 's'}.',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Collection Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Track the total contribution from all members.',
            style: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 18),
          LinearProgressIndicator(
            value: progress,
            minHeight: 9,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _progressText(
                  'Collected',
                  'PKR ${_formatAmount(collectedAmount)}',
                ),
              ),
              Expanded(
                child: _progressText(
                  'Remaining',
                  'PKR ${_formatAmount(remainingAmount)}',
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Members',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showMemberDialog(),
                icon: const Icon(
                  Icons.person_add_alt_1_rounded,
                ),
                label: const Text('Add Member'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (members.isEmpty)
            _emptyState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount: members.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 10);
              },
              itemBuilder: (context, index) {
                final Map<String, String> member =
                    members[index];

                return MemberCard(
                  memberName: member['name'] ?? '',
                  phone: member['phone'] ?? '',
                  contribution:
                      member['contribution'] ?? '0',
                  paymentStatus:
                      member['paymentStatus'] ?? 'Pending',
                  onEdit: () {
                    _showMemberDialog(
                      editIndex: index,
                    );
                  },
                  onDelete: () {
                    _deleteMember(index);
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _summaryItem(
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Theme.of(context).cardColor,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressText(
    String title,
    String value, {
    bool alignEnd = false,
  }) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.color
                ?.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 30,
      ),
      child: Column(
        children: [
          Icon(
            Icons.groups_outlined,
            size: 48,
            color: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.color
                ?.withOpacity(0.5),
          ),
          const SizedBox(height: 10),
          Text(
            'No members added yet.',
            style: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

