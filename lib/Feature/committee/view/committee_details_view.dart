import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../Core/constants/app_keys.dart';
import '../widgets/member_card.dart';

class CommitteeDetailsView extends StatefulWidget {
  final Map<String, dynamic>? committeeData;

  const CommitteeDetailsView({
    super.key,
    this.committeeData,
  });

  @override
  State<CommitteeDetailsView> createState() =>
      _CommitteeDetailsViewState();
}

class _CommitteeDetailsViewState
    extends State<CommitteeDetailsView> {
  List<Map<String, String>> members = [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  // Load actual members saved in Hive.
  void _loadMembers() {
    final Box committeeBox =
        Hive.box(AppKeys.committeeBox);

    final dynamic savedData =
        committeeBox.get('currentCommittee');

    if (savedData is Map) {
      final Map<String, dynamic> committee =
          Map<String, dynamic>.from(savedData);

      final dynamic savedMembers =
          committee['membersList'];

      if (savedMembers is List) {
        final loadedMembers =
            <Map<String, String>>[];

        for (final member in savedMembers) {
          if (member is Map) {
            loadedMembers.add({
              'name':
                  member['name']?.toString() ?? '',
              'fatherName':
                  member['fatherName']?.toString() ?? '',
              'phone':
                  member['phone']?.toString() ?? '',
              'contribution':
                  member['contribution']?.toString() ??
                      'PKR 0',
              'paymentStatus':
                  member['paymentStatus']?.toString() ??
                      'Pending',
            });
          }
        }

        setState(() {
          members = loadedMembers;
        });
      }
    }
  }

  // Save actual members in the current committee.
  Future<void> _saveMembers() async {
    final Box committeeBox =
        Hive.box(AppKeys.committeeBox);

    final dynamic savedData =
        committeeBox.get('currentCommittee');

    if (savedData is! Map) {
      return;
    }

    final Map<String, dynamic> committee =
        Map<String, dynamic>.from(savedData);

    committee['membersList'] = members;

    await committeeBox.put(
      'currentCommittee',
      committee,
    );
  }

  double get totalPool {
    double total = 0;

    for (final memberData in members) {
      final contribution =
          memberData['contribution'] ?? '0';

      final cleanValue = contribution
          .replaceAll('PKR', '')
          .replaceAll(',', '')
          .trim();

      total +=
          double.tryParse(cleanValue) ?? 0;
    }

    return total;
  }

  double get collectedAmount {
    double collected = 0;

    for (final memberData in members) {
      final status =
          memberData['paymentStatus'] ??
              'Pending';

      if (status.toLowerCase() == 'paid' ||
          status.toLowerCase() == 'received') {
        final contribution =
            memberData['contribution'] ?? '0';

        final cleanValue = contribution
            .replaceAll('PKR', '')
            .replaceAll(',', '')
            .trim();

        collected +=
            double.tryParse(cleanValue) ?? 0;
      }
    }

    return collected;
  }

  double get remainingAmount {
    final remaining =
        totalPool - collectedAmount;

    if (remaining < 0) {
      return 0;
    }

    return remaining;
  }

  double get progress {
    if (totalPool <= 0) {
      return 0;
    }

    return (collectedAmount / totalPool)
        .clamp(0.0, 1.0);
  }

  String _formatAmount(double amount) {
    final value =
        amount.round().toString();

    if (value.length <= 3) {
      return value;
    }

    final List<String> parts = [];
    int end = value.length;

    while (end > 3) {
      parts.insert(
        0,
        value.substring(
          end - 3,
          end,
        ),
      );

      end -= 3;
    }

    parts.insert(
      0,
      value.substring(0, end),
    );

    return parts.join(',');
  }

  void _showAddMemberDialog() {
    final nameController =
        TextEditingController();

    final fatherNameController =
        TextEditingController();

    final phoneController =
        TextEditingController();

    final contributionController =
        TextEditingController();

    String? nameError;
    String? fatherNameError;
    String? phoneError;
    String? contributionError;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            void addMember() {
              final name =
                  nameController.text.trim();

              final fatherName =
                  fatherNameController.text.trim();

              final phone =
                  phoneController.text.trim();

              final contribution =
                  contributionController.text.trim();

              setDialogState(() {
                nameError = name.isEmpty
                    ? 'Please enter member name'
                    : null;

                fatherNameError =
                    fatherName.isEmpty
                        ? 'Please enter father name'
                        : null;

                phoneError = phone.isEmpty
                    ? 'Please enter phone number'
                    : null;

                contributionError =
                    contribution.isEmpty
                        ? 'Please enter monthly contribution'
                        : null;
              });

              if (nameError != null ||
                  fatherNameError != null ||
                  phoneError != null ||
                  contributionError != null) {
                return;
              }

              final cleanContribution =
                  contribution
                      .replaceAll(',', '')
                      .replaceAll('PKR', '')
                      .trim();

              final amount =
                  double.tryParse(
                cleanContribution,
              );

              if (amount == null ||
                  amount <= 0) {
                setDialogState(() {
                  contributionError =
                      'Please enter a valid contribution amount';
                });

                return;
              }

              final formattedContribution =
                  'PKR ${_formatAmount(amount)}';

              setState(() {
                members.add({
                  'name': name,
                  'fatherName': fatherName,
                  'phone': phone,
                  'contribution':
                      formattedContribution,
                  'paymentStatus': 'Pending',
                });
              });

              // Save actual member data.
              _saveMembers();

              Navigator.of(
                dialogContext,
              ).pop();
            }

            return AlertDialog(
              title: const Text(
                'Add Member',
              ),
              content:
                  SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    TextField(
                      controller:
                          nameController,
                      textCapitalization:
                          TextCapitalization.words,
                      decoration:
                          InputDecoration(
                        labelText:
                            'Member Name',
                        border:
                            const OutlineInputBorder(),
                        errorText:
                            nameError,
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    TextField(
                      controller:
                          fatherNameController,
                      textCapitalization:
                          TextCapitalization.words,
                      decoration:
                          InputDecoration(
                        labelText:
                            'Father Name',
                        border:
                            const OutlineInputBorder(),
                        errorText:
                            fatherNameError,
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    TextField(
                      controller:
                          phoneController,
                      keyboardType:
                          TextInputType.phone,
                      decoration:
                          InputDecoration(
                        labelText:
                            'Phone Number',
                        border:
                            const OutlineInputBorder(),
                        errorText:
                            phoneError,
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    TextField(
                      controller:
                          contributionController,
                      keyboardType:
                          TextInputType.number,
                      decoration:
                          InputDecoration(
                        labelText:
                            'Monthly Contribution',
                        prefixText: 'PKR ',
                        border:
                            const OutlineInputBorder(),
                        errorText:
                            contributionError,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },
                  child:
                      const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: addMember,
                  child:
                      const Text('Add Member'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.all(14),
        decoration:
            BoxDecoration(
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: Theme.of(context)
                .dividerColor,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 24,
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              title,
              softWrap: true,
              style:
                  const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            Text(
              value,
              softWrap: true,
              style:
                  const TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMembers() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(24),
      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context)
              .dividerColor,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 48,
          ),

          SizedBox(
            height: 12,
          ),

          Text(
            'No members added yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          SizedBox(
            height: 6,
          ),

          Text(
            'Add members to manage your committee.',
            textAlign:
                TextAlign.center,
            softWrap: true,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final committeeName =
        widget.committeeData?['name']
                ?.toString() ??
            'Digital Committee';

    final dynamic savedContribution =
        widget.committeeData?['contribution'];

    final String monthlyContribution =
        savedContribution == null
            ? '0'
            : _formatAmount(
                double.tryParse(
                      savedContribution
                          .toString()
                          .replaceAll(
                            'PKR',
                            '',
                          )
                          .replaceAll(
                            ',',
                            '',
                          )
                          .trim(),
                    ) ??
                    0,
              );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Committee Details',
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // Committee Header
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(18),
              decoration:
                  BoxDecoration(
                borderRadius:
                    BorderRadius.circular(16),
                border: Border.all(
                  color:
                      Theme.of(context)
                          .dividerColor,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    committeeName,
                    softWrap: true,
                    style:
                        const TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    'Monthly Contribution: PKR $monthlyContribution',
                    softWrap: true,
                    style:
                        const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // Summary Row 1
            Row(
              children: [
                _buildSummaryCard(
                  title:
                      'Total Pool',
                  value:
                      'PKR ${_formatAmount(totalPool)}',
                  icon: Icons
                      .account_balance_wallet_outlined,
                ),

                const SizedBox(
                  width: 10,
                ),

                _buildSummaryCard(
                  title:
                      'Collected',
                  value:
                      'PKR ${_formatAmount(collectedAmount)}',
                  icon: Icons
                      .payments_outlined,
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            ),

            // Summary Row 2
            Row(
              children: [
                _buildSummaryCard(
                  title:
                      'Remaining',
                  value:
                      'PKR ${_formatAmount(remainingAmount)}',
                  icon: Icons
                      .account_balance_outlined,
                ),

                const SizedBox(
                  width: 10,
                ),

                _buildSummaryCard(
                  title:
                      'Members',
                  value:
                      members.length
                          .toString(),
                  icon: Icons
                      .people_outline,
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            // Payment Progress
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(16),
              decoration:
                  BoxDecoration(
                borderRadius:
                    BorderRadius.circular(14),
                border: Border.all(
                  color:
                      Theme.of(context)
                          .dividerColor,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Progress',
                    style:
                        TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    '${(progress * 100).toStringAsFixed(0)}% collected',
                    softWrap: true,
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // Members Header
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Members',
                    softWrap: true,
                    style:
                        TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                ElevatedButton.icon(
                  onPressed:
                      _showAddMemberDialog,
                  icon: const Icon(
                    Icons
                        .person_add_outlined,
                  ),
                  label: const Text(
                    'Add Member',
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 12,
            ),

            // Members List
            if (members.isEmpty)
              _buildEmptyMembers()
            else
              Column(
                children:
                    members.map(
                  (memberData) {
                    return Padding(
                      padding:
                          const EdgeInsets
                              .only(
                        bottom: 12,
                      ),
                      child: MemberCard(
                        memberName:
                            memberData[
                                    'name'] ??
                                'Member Name',
                        fatherName:
                            memberData[
                                    'fatherName'] ??
                                '',
                        phone:
                            memberData[
                                    'phone'] ??
                                '',
                        contribution:
                            memberData[
                                    'contribution'] ??
                                'PKR 0',
                        paymentStatus:
                            memberData[
                                    'paymentStatus'] ??
                                'Pending',
                      ),
                    );
                  },
                ).toList(),
              ),
          ],
        ),
      ),
    );
  }
}