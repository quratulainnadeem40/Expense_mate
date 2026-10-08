import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/committe_controller.dart';

class CommitteeDetailsView extends StatefulWidget {
  const CommitteeDetailsView({
    super.key,
  });

  @override
  State<CommitteeDetailsView> createState() =>
      _CommitteeDetailsViewState();
}

class _CommitteeDetailsViewState
    extends State<CommitteeDetailsView> {
  final CommitteeController committeeController =
      CommitteeController.instance;

  double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0.0;
  }

  String _formatAmount(double amount) {
    return 'PKR ${amount.toStringAsFixed(0)}';
  }

  String _durationText() {
    final int duration =
        committeeController.duration.value;

    if (duration <= 0) {
      return 'Not Set';
    }

    final String unit =
        committeeController.durationUnit.value;

    if (duration == 1) {
      if (unit.toLowerCase().contains('year')) {
        return '1 Year';
      }

      if (unit.toLowerCase().contains('week')) {
        return '1 Week';
      }

      if (unit.toLowerCase().contains('day')) {
        return '1 Day';
      }

      return '1 Month';
    }

    return '$duration $unit';
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Not Set';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // --------------------------------------------------
  // PAYMENT SUMMARY
  // --------------------------------------------------

  double get collectedAmount {
    double total = 0;

    for (
      final Map<String, dynamic> member
          in committeeController.members
    ) {
      final String status =
          (member['paymentStatus'] ??
                  'Pending')
              .toString()
              .toLowerCase();

      if (status == 'received' ||
          status == 'paid') {
        total +=
            _toDouble(
          member['contribution'],
        );
      }
    }

    return total;
  }

  double get remainingAmount {
    final double value =
        committeeController.totalPool -
            collectedAmount;

    return value < 0 ? 0 : value;
  }

  double get progress {
    final double total =
        committeeController.totalPool;

    if (total <= 0) {
      return 0;
    }

    final double value =
        collectedAmount / total;

    return value > 1 ? 1 : value;
  }

  // --------------------------------------------------
  // DUPLICATE MEMBER CHECK
  // --------------------------------------------------

  bool _isDuplicateMember({
    required String name,
    required String fatherHusbandName,
    int? editIndex,
  }) {
    final String newName =
        name.trim().toLowerCase();

    final String newFatherHusband =
        fatherHusbandName
            .trim()
            .toLowerCase();

    for (
      int i = 0;
      i < committeeController.members.length;
      i++
    ) {
      if (editIndex != null &&
          i == editIndex) {
        continue;
      }

      final Map<String, dynamic> member =
          committeeController.members[i];

      final String existingName =
          (member['name'] ?? '')
              .toString()
              .trim()
              .toLowerCase();

      final String existingFatherHusband =
          (member['fatherHusbandName'] ??
                  member['fatherName'] ??
                  '')
              .toString()
              .trim()
              .toLowerCase();

      if (existingName == newName &&
          existingFatherHusband ==
              newFatherHusband) {
        return true;
      }
    }

    return false;
  }

  // --------------------------------------------------
  // ORDINAL
  // --------------------------------------------------

  String _ordinal(int number) {
    if (number % 100 >= 11 &&
        number % 100 <= 13) {
      return '${number}th';
    }

    switch (number % 10) {
      case 1:
        return '${number}st';

      case 2:
        return '${number}nd';

      case 3:
        return '${number}rd';

      default:
        return '${number}th';
    }
  }

  // --------------------------------------------------
  // ADD / EDIT MEMBER
  // --------------------------------------------------

  void _showMemberDialog({
    int? editIndex,
  }) {
    final bool isEdit =
        editIndex != null;

    Map<String, dynamic>?
        existingMember;

    if (isEdit &&
        editIndex >= 0 &&
        editIndex <
            committeeController
                .members
                .length) {
      existingMember =
          committeeController
              .members[editIndex];
    }

    final TextEditingController
        nameController =
        TextEditingController(
      text:
          existingMember?['name']
                  ?.toString() ??
              '',
    );

    final TextEditingController
        fatherHusbandController =
        TextEditingController(
      text:
          (existingMember?[
                      'fatherHusbandName'] ??
                  existingMember?[
                      'fatherName'] ??
                  '')
              .toString(),
    );

    final TextEditingController
        phoneController =
        TextEditingController(
      text:
          existingMember?['phone']
                  ?.toString() ??
              '',
    );

    final TextEditingController
        contributionController =
        TextEditingController(
      text: existingMember == null
          ? ''
          : _toDouble(
              existingMember[
                  'contribution'],
            ).toStringAsFixed(0),
    );

    final GlobalKey<FormState>
        formKey =
        GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            isEdit
                ? 'Edit Member'
                : 'Add Member',
          ),
          content:
              SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  TextFormField(
                    controller:
                        nameController,
                    textCapitalization:
                        TextCapitalization
                            .words,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Member Name',
                      border:
                          OutlineInputBorder(),
                    ),
                    validator:
                        (value) {
                      if (value ==
                              null ||
                          value
                              .trim()
                              .isEmpty) {
                        return 'Please enter member name';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  TextFormField(
                    controller:
                        fatherHusbandController,
                    textCapitalization:
                        TextCapitalization
                            .words,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Father Name / Husband Name',
                      border:
                          OutlineInputBorder(),
                    ),
                    validator:
                        (value) {
                      if (value ==
                              null ||
                          value
                              .trim()
                              .isEmpty) {
                        return 'Please enter father/husband name';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  TextFormField(
                    controller:
                        phoneController,
                    keyboardType:
                        TextInputType.phone,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Phone Number (Optional)',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  TextFormField(
                    controller:
                        contributionController,
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Monthly Contribution',
                      prefixText:
                          'PKR ',
                      border:
                          OutlineInputBorder(),
                    ),
                    validator:
                        (value) {
                      if (value ==
                              null ||
                          value
                              .trim()
                              .isEmpty) {
                        return 'Please enter contribution';
                      }

                      final double?
                          amount =
                          double.tryParse(
                        value.trim(),
                      );

                      if (amount ==
                              null ||
                          amount <= 0) {
                        return 'Enter a valid amount';
                      }

                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                if (!formKey
                    .currentState!
                    .validate()) {
                  return;
                }

                final String name =
                    nameController.text
                        .trim();

                final String
                    fatherHusbandName =
                    fatherHusbandController
                        .text
                        .trim();

                final String phone =
                    phoneController.text
                        .trim();

                final double
                    contribution =
                    double.parse(
                  contributionController
                      .text
                      .trim(),
                );

                // --------------------------------
                // DUPLICATE CHECK
                // --------------------------------

                if (_isDuplicateMember(
                  name: name,
                  fatherHusbandName:
                      fatherHusbandName,
                  editIndex:
                      editIndex,
                )) {
                  ScaffoldMessenger
                          .of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'This member already exists with the same name and father/husband name.',
                      ),
                    ),
                  );

                  return;
                }

                // --------------------------------
                // EDIT MEMBER
                // --------------------------------

                if (isEdit &&
                    editIndex != null) {
                  committeeController
                      .updateMember(
                    index: editIndex,
                    name: name,
                    fatherName:
                        fatherHusbandName,
                    phone: phone,
                    contribution:
                        contribution,
                  );

                  Navigator.pop(
                    dialogContext,
                  );

                  setState(() {});

                  ScaffoldMessenger
                          .of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Member updated successfully.',
                      ),
                    ),
                  );

                  return;
                }

                // --------------------------------
                // HARD MEMBER LIMIT
                // --------------------------------

                final int selectedMembers =
                    committeeController
                        .totalMembers
                        .value;

                final int nextMemberNumber =
                    committeeController
                            .members
                            .length +
                        1;

                if (selectedMembers <=
                        0 ||
                    committeeController
                            .members
                            .length >=
                        selectedMembers) {
                  ScaffoldMessenger
                          .of(context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        'You selected $selectedMembers members. ${_ordinal(nextMemberNumber)} member cannot be added.',
                      ),
                    ),
                  );

                  return;
                }

                // --------------------------------
                // ADD MEMBER
                // --------------------------------

                final bool added =
                    committeeController
                        .addMember(
                  name: name,
                  fatherName:
                      fatherHusbandName,
                  phone: phone,
                  contribution:
                      contribution,
                );

                if (!added) {
                  ScaffoldMessenger
                          .of(context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        'You selected $selectedMembers members. ${_ordinal(nextMemberNumber)} member cannot be added.',
                      ),
                    ),
                  );

                  return;
                }

                Navigator.pop(
                  dialogContext,
                );

                setState(() {});

                ScaffoldMessenger
                        .of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Member added successfully.',
                    ),
                  ),
                );
              },
              child: Text(
                isEdit
                    ? 'Update'
                    : 'Add',
              ),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------
  // DELETE MEMBER
  // --------------------------------------------------

  void _deleteMember(int index) {
    if (index < 0 ||
        index >=
            committeeController
                .members
                .length) {
      return;
    }

    final String name =
        committeeController
                .members[index]['name']
                ?.toString() ??
            'Member';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
              const Text('Delete Member'),
          content: Text(
            'Are you sure you want to delete $name?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                committeeController
                    .deleteMember(index);

                Navigator.pop(
                  dialogContext,
                );

                setState(() {});

                ScaffoldMessenger
                        .of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Member deleted successfully.',
                    ),
                  ),
                );
              },
              child:
                  const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------
  // MEMBER CARD
  // --------------------------------------------------

  Widget _buildMemberCard(
    Map<String, dynamic> member,
    int index,
  ) {
    final String name =
        member['name']
                ?.toString() ??
            'Member';

    final String fatherHusband =
        (member['fatherHusbandName'] ??
                member['fatherName'] ??
                '')
            .toString();

    final String phone =
        member['phone']
                ?.toString() ??
            '';

    final double contribution =
        _toDouble(
      member['contribution'],
    );

    final String status =
        member['paymentStatus']
                ?.toString() ??
            'Pending';

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    name.isNotEmpty
                        ? name[0]
                            .toUpperCase()
                        : 'M',
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        name,
                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        fatherHusband
                                .isEmpty
                            ? 'Father/Husband: Not Added'
                            : 'Father/Husband: $fatherHusband',
                        style:
                            const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<
                    String>(
                  onSelected:
                      (value) {
                    if (value ==
                        'edit') {
                      _showMemberDialog(
                        editIndex:
                            index,
                      );
                    }

                    if (value ==
                        'delete') {
                      _deleteMember(
                        index,
                      );
                    }
                  },
                  itemBuilder:
                      (context) {
                    return const [
                      PopupMenuItem(
                        value: 'edit',
                        child:
                            Text(
                          'Edit',
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child:
                            Text(
                          'Delete',
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),

            const SizedBox(
              height: 12,
            ),

            Row(
              children: [
                Expanded(
                  child: Text(
                    phone.isEmpty
                        ? 'Phone: Not Added'
                        : 'Phone: $phone',
                    style:
                        const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),

                Expanded(
                  child: Text(
                    _formatAmount(
                      contribution,
                    ),
                    textAlign:
                        TextAlign.end,
                    style:
                        const TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            ),

            Align(
              alignment:
                  Alignment.centerLeft,
              child: Text(
                'Payment Status: $status',
                style:
                    TextStyle(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w600,
                  color: status
                              .toLowerCase() ==
                          'received'
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // SUMMARY CARD
  // --------------------------------------------------

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(icon),

            const SizedBox(
              height: 7,
            ),

            Text(
              title,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  const TextStyle(
                fontSize: 11,
              ),
            ),

            const SizedBox(
              height: 3,
            ),

            Text(
              value,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  const TextStyle(
                fontSize: 15,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // COMMITTEE SUMMARY
  // --------------------------------------------------

  Widget _buildSummary() {
    return Obx(
      () {
        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Committee Summary',
              style:
                  TextStyle(
                fontSize: 19,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.65,
              children: [
                _buildSummaryCard(
                  icon:
                      Icons.payments_outlined,
                  title:
                      'Monthly Contribution',
                  value:
                      _formatAmount(
                    committeeController
                        .monthlyContribution
                        .value,
                  ),
                ),

                _buildSummaryCard(
                  icon:
                      Icons.people_outline,
                  title:
                      'Members',
                  value:
                      '${committeeController.members.length}/${committeeController.totalMembers.value}',
                ),

                _buildSummaryCard(
                  icon:
                      Icons.account_balance_wallet_outlined,
                  title:
                      'Total Pool',
                  value:
                      _formatAmount(
                    committeeController
                        .totalPool,
                  ),
                ),

                _buildSummaryCard(
                  icon:
                      Icons.schedule_outlined,
                  title:
                      'Duration',
                  value:
                      _durationText(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------
  // PAYMENT SUMMARY
  // --------------------------------------------------

  Widget _buildPaymentSummary() {
    return Obx(
      () {
        return Card(
          child: Padding(
            padding:
                const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                const Text(
                  'Payment Summary',
                  style:
                      TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                Row(
                  children: [
                    Expanded(
                      child:
                          _paymentItem(
                        'Total',
                        committeeController
                            .totalPool,
                        Icons
                            .account_balance_outlined,
                      ),
                    ),

                    Expanded(
                      child:
                          _paymentItem(
                        'Received',
                        collectedAmount,
                        Icons
                            .check_circle_outline,
                      ),
                    ),

                    Expanded(
                      child:
                          _paymentItem(
                        'Remaining',
                        remainingAmount,
                        Icons
                            .pending_outlined,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 18,
                ),

                LinearProgressIndicator(
                  value:
                      progress,
                  minHeight: 8,
                ),

                const SizedBox(
                  height: 7,
                ),

                Text(
                  '${(progress * 100).toStringAsFixed(0)}% received',
                  style:
                      const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _paymentItem(
    String title,
    double amount,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 21,
        ),

        const SizedBox(
          height: 6,
        ),

        Text(
          title,
          textAlign:
              TextAlign.center,
          style:
              const TextStyle(
            fontSize: 11,
          ),
        ),

        const SizedBox(
          height: 3,
        ),

        Text(
          _formatAmount(amount),
          textAlign:
              TextAlign.center,
          style:
              const TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Committee Details',
          style:
              TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          _showMemberDialog();
        },
        icon:
            const Icon(
          Icons.person_add_alt_1,
        ),
        label:
            const Text(
          'Add Member',
        ),
      ),

      body: Obx(
        () {
          final members =
              committeeController
                  .members;

          return SingleChildScrollView(
            padding:
                const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  committeeController
                          .committeeName
                          .value
                          .isEmpty
                      ? 'Committee'
                      : committeeController
                          .committeeName
                          .value,
                  style:
                      const TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                const Text(
                  'Digital Committee',
                  style:
                      TextStyle(
                    fontSize: 13,
                    color:
                        Colors.grey,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                if (committeeController
                        .startDate
                        .value !=
                    null)
                  Text(
                    'Start Date: ${_formatDate(committeeController.startDate.value)}',
                    style:
                        const TextStyle(
                      fontSize: 12,
                      color:
                          Colors.grey,
                    ),
                  ),

                if (committeeController
                        .endingDate
                        .value !=
                    null)
                  Text(
                    'Ending Date: ${_formatDate(committeeController.endingDate.value)}',
                    style:
                        const TextStyle(
                      fontSize: 12,
                      color:
                          Colors.grey,
                    ),
                  ),

                const SizedBox(
                  height: 20,
                ),

                _buildSummary(),

                const SizedBox(
                  height: 20,
                ),

                _buildPaymentSummary(),

                const SizedBox(
                  height: 24,
                ),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Members',
                        style:
                            TextStyle(
                          fontSize: 19,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ),

                    Text(
                      '${members.length} / ${committeeController.totalMembers.value} Added',
                      style:
                          const TextStyle(
                        fontSize: 12,
                        color:
                            Colors.grey,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 12,
                ),

                if (members.isEmpty)
                  _buildEmptyState()
                else
                  ...List.generate(
                    members.length,
                    (index) {
                      return _buildMemberCard(
                        members[index],
                        index,
                      );
                    },
                  ),

                const SizedBox(
                  height: 100,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 35,
        ),
        child: Column(
          children: [
            const Icon(
              Icons.people_outline,
              size: 52,
              color: Colors.grey,
            ),

            const SizedBox(
              height: 12,
            ),

            const Text(
              'No Members Added',
              style:
                  TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            const Text(
              'Tap "Add Member" to add committee members.',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                fontSize: 13,
                color:
                    Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}