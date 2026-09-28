import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../Core/constants/app_keys.dart';
import '../widgets/schedule_card.dart';

class MonthlyScheduleView extends StatefulWidget {
  final double monthlyContribution;
  final int totalMembers;
  final int durationMonths;
  final DateTime startDate;
  final String durationUnit;

  const MonthlyScheduleView({
    super.key,
    required this.monthlyContribution,
    required this.totalMembers,
    required this.durationMonths,
    required this.startDate,
    this.durationUnit = 'Months',
  });

  @override
  State<MonthlyScheduleView> createState() =>
      _MonthlyScheduleViewState();
}

class _MonthlyScheduleViewState
    extends State<MonthlyScheduleView> {
  List<String> members = [];

  late List<String> receivingOrder;
  List<Map<String, String>> schedule = [];

  double actualContribution = 0;
  int actualDuration = 0;
  String actualDurationUnit = 'Months';
  DateTime? actualStartDate;

  @override
  void initState() {
    super.initState();

    receivingOrder = [];
    _loadActualCommitteeData();
  }

  void _loadActualCommitteeData() {
    final Box committeeBox =
        Hive.box(AppKeys.committeeBox);

    final dynamic storedData =
        committeeBox.get('currentCommittee');

    if (storedData is Map) {
      final Map<dynamic, dynamic> committee =
          Map<dynamic, dynamic>.from(storedData);

      actualContribution =
          _parseAmount(committee['contribution']);

      actualDuration =
          int.tryParse(
                committee['duration']?.toString() ?? '',
              ) ??
              widget.durationMonths;

      actualDurationUnit =
          committee['durationUnit']?.toString() ??
              widget.durationUnit;

      actualStartDate =
          _parseDate(committee['startDate']) ??
              widget.startDate;

      final dynamic membersData =
          committee['membersList'];

      if (membersData is List) {
        members = membersData
            .whereType<Map>()
            .map(
              (member) =>
                  member['name']?.toString().trim() ?? '',
            )
            .where((name) => name.isNotEmpty)
            .toList();
      }

      final dynamic savedOrder =
          committee['receivingOrder'];

      if (savedOrder is List) {
        receivingOrder = savedOrder
            .map((item) => item.toString().trim())
            .where((name) => name.isNotEmpty)
            .toList();
      }

      // Keep only members that still exist in actual members.
      receivingOrder = receivingOrder
          .where(
            (name) => members.contains(name),
          )
          .toList();

      // Add any actual member which is not yet
      // present in the receiving order.
      for (final String member in members) {
        if (!receivingOrder.contains(member)) {
          receivingOrder.add(member);
        }
      }
    } else {
      // No stored committee.
      actualContribution =
          widget.monthlyContribution;

      actualDuration = widget.durationMonths;
      actualDurationUnit = widget.durationUnit;
      actualStartDate = widget.startDate;
    }

    if (actualStartDate == null) {
      actualStartDate = widget.startDate;
    }

    if (actualDuration <= 0) {
      actualDuration = widget.durationMonths;
    }

    if (actualDurationUnit.isEmpty) {
      actualDurationUnit = 'Months';
    }

    if (receivingOrder.isEmpty && members.isNotEmpty) {
      receivingOrder = List<String>.from(members);
    }

    schedule = _createSchedule();

    if (mounted) {
      setState(() {});
    }
  }

  double _parseAmount(dynamic value) {
    if (value == null) {
      return 0;
    }

    final String cleaned =
        value
            .toString()
            .replaceAll('PKR', '')
            .replaceAll(',', '')
            .trim();

    return double.tryParse(cleaned) ?? 0;
  }

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  int _getScheduleCount() {
    if (actualDuration <= 0) {
      return 0;
    }

    switch (actualDurationUnit.toLowerCase()) {
      case 'days':
        return actualDuration;

      case 'weeks':
        return actualDuration;

      case 'months':
      default:
        return actualDuration;
    }
  }

  List<Map<String, String>> _createSchedule() {
    final List<Map<String, String>> result = [];

    if (members.isEmpty ||
        receivingOrder.isEmpty ||
        actualStartDate == null ||
        actualDuration <= 0) {
      return result;
    }

    final int scheduleCount = _getScheduleCount();

    for (int i = 0; i < scheduleCount; i++) {
      final DateTime periodDate =
          _getPeriodDate(i);

      final String memberName =
          receivingOrder[i % receivingOrder.length];

      final String amount =
          'PKR ${_formatAmount(actualContribution)}';

      final String periodName =
          _getPeriodName(periodDate, i);

      final String dueDate =
          _formatDate(periodDate);

      result.add({
        'month': periodName,
        'memberName': memberName,
        'amount': amount,
        'dueDate': dueDate,
        'status': 'Upcoming',
      });
    }

    return result;
  }

  DateTime _getPeriodDate(int index) {
    final DateTime start =
        actualStartDate ?? widget.startDate;

    switch (actualDurationUnit.toLowerCase()) {
      case 'days':
        return start.add(
          Duration(days: index),
        );

      case 'weeks':
        return start.add(
          Duration(days: index * 7),
        );

      case 'months':
      default:
        return _addMonths(start, index);
    }
  }

  String _getPeriodName(
    DateTime date,
    int index,
  ) {
    switch (actualDurationUnit.toLowerCase()) {
      case 'days':
        return 'Day ${index + 1} • ${_formatDate(date)}';

      case 'weeks':
        return 'Week ${index + 1} • ${_formatDate(date)}';

      case 'months':
      default:
        return '${_monthName(date.month)} ${date.year}';
    }
  }

  DateTime _addMonths(
    DateTime date,
    int months,
  ) {
    final DateTime firstDayOfTargetMonth =
        DateTime(
      date.year,
      date.month + months,
      1,
    );

    final int lastDayOfTargetMonth =
        DateTime(
          firstDayOfTargetMonth.year,
          firstDayOfTargetMonth.month + 1,
          0,
        ).day;

    final int day =
        date.day > lastDayOfTargetMonth
            ? lastDayOfTargetMonth
            : date.day;

    return DateTime(
      firstDayOfTargetMonth.year,
      firstDayOfTargetMonth.month,
      day,
    );
  }

  String _monthName(int month) {
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

    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _formatAmount(double amount) {
    final String value =
        amount.toStringAsFixed(0);

    final StringBuffer result =
        StringBuffer();

    for (int i = 0; i < value.length; i++) {
      if (i > 0 &&
          (value.length - i) % 3 == 0) {
        result.write(',');
      }

      result.write(value[i]);
    }

    return result.toString();
  }

  Future<void> _saveReceivingOrder() async {
    final Box committeeBox =
        Hive.box(AppKeys.committeeBox);

    final dynamic storedData =
        committeeBox.get('currentCommittee');

    if (storedData is! Map) {
      return;
    }

    final Map<String, dynamic> committee =
        Map<String, dynamic>.from(
      storedData,
    );

    committee['receivingOrder'] =
        List<String>.from(receivingOrder);

    await committeeBox.put(
      'currentCommittee',
      committee,
    );
  }

  Future<void> _changeReceivingMember(
    int index,
  ) async {
    if (members.isEmpty) {
      _showMessage(
        'No members available. Please add members first.',
      );
      return;
    }

    final String currentMember =
        schedule[index]['memberName'] ??
            members.first;

    final TextEditingController nameController =
        TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final bool isDark =
            Theme.of(sheetContext).brightness ==
                Brightness.dark;

        final Color backgroundColor =
            isDark
                ? const Color(0xFF0A0A0A)
                : Colors.white;

        final Color primaryTextColor =
            isDark
                ? Colors.white
                : Colors.black87;

        final Color secondaryTextColor =
            isDark
                ? Colors.white60
                : Colors.black54;

        return StatefulBuilder(
          builder: (
            context,
            setSheetState,
          ) {
            return Container(
              color: backgroundColor,
              padding: const EdgeInsets.all(20),
              child: SafeArea(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Receiving Member',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      schedule[index]['month'] ??
                          'Period',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ...List.generate(
                      members.length,
                      (memberIndex) {
                        final String member =
                            members[memberIndex];

                        final bool isSelected =
                            member ==
                                currentMember;

                        return ListTile(
                          contentPadding:
                              EdgeInsets.zero,
                          leading: Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 24,
                                child: Text(
                                  '${memberIndex + 1}.',
                                  style:
                                      TextStyle(
                                    color:
                                        primaryTextColor,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              Icon(
                                Icons
                                    .person_rounded,
                                color:
                                    primaryTextColor,
                              ),
                            ],
                          ),
                          title: Text(
                            member,
                            softWrap: true,
                            overflow:
                                TextOverflow
                                    .visible,
                            style: TextStyle(
                              color:
                                  primaryTextColor,
                              fontWeight:
                                  isSelected
                                      ? FontWeight
                                          .w600
                                      : FontWeight
                                          .normal,
                            ),
                          ),
                          trailing:
                              isSelected
                                  ? Icon(
                                      Icons
                                          .check_circle_rounded,
                                      color:
                                          primaryTextColor,
                                    )
                                  : null,
                          onTap: () async {
                            setState(() {
                              schedule[index]
                                      ['memberName'] =
                                  member;
                            });

                            await _saveScheduleMember(
                              index,
                              member,
                            );

                            if (!sheetContext
                                .mounted) {
                              return;
                            }

                            Navigator.pop(
                              sheetContext,
                            );

                            _showMessage(
                              '${schedule[index]['month']} receiving member changed to $member.',
                            );
                          },
                        );
                      },
                    ),

                    const Divider(),

                    ListTile(
                      contentPadding:
                          EdgeInsets.zero,
                      leading: Container(
                        width: 30,
                        height: 30,
                        alignment:
                            Alignment.center,
                        decoration:
                            BoxDecoration(
                          border: Border.all(
                            color:
                                secondaryTextColor,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            8,
                          ),
                        ),
                        child: Text(
                          '+',
                          style: TextStyle(
                            fontSize: 20,
                            color:
                                primaryTextColor,
                          ),
                        ),
                      ),
                      title: Text(
                        'Add a Name',
                        style: TextStyle(
                          color:
                              primaryTextColor,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Enter another receiving member',
                        style: TextStyle(
                          color:
                              secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                      onTap: () async {
                        nameController.clear();

                        final String? newName =
                            await showDialog<String>(
                          context: sheetContext,
                          builder:
                              (dialogContext) {
                            return AlertDialog(
                              title: const Text(
                                'Add a Name',
                              ),
                              content:
                                  TextField(
                                controller:
                                    nameController,
                                autofocus: true,
                                textCapitalization:
                                    TextCapitalization
                                        .words,
                                decoration:
                                    const InputDecoration(
                                  hintText:
                                      'Enter member name',
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
                                      const Text(
                                    'Cancel',
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final String
                                        name =
                                        nameController
                                            .text
                                            .trim();

                                    if (name
                                        .isNotEmpty) {
                                      Navigator.pop(
                                        dialogContext,
                                        name,
                                      );
                                    }
                                  },
                                  child:
                                      const Text(
                                    'Add',
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        if (newName != null &&
                            newName.isNotEmpty) {
                          setState(() {
                            if (!members
                                .contains(
                              newName,
                            )) {
                              members.add(
                                newName,
                              );
                            }

                            if (!receivingOrder
                                .contains(
                              newName,
                            )) {
                              receivingOrder.add(
                                newName,
                              );
                            }

                            schedule[index]
                                    ['memberName'] =
                                newName;
                          });

                          await _saveReceivingOrder();
                          await _saveScheduleMember(
                            index,
                            newName,
                          );

                          if (!sheetContext
                              .mounted) {
                            return;
                          }

                          Navigator.pop(
                            sheetContext,
                          );

                          _showMessage(
                            '${schedule[index]['month']} receiving member changed to $newName.',
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
  }

  Future<void> _saveScheduleMember(
    int index,
    String memberName,
  ) async {
    final Box committeeBox =
        Hive.box(AppKeys.committeeBox);

    final dynamic storedData =
        committeeBox.get('currentCommittee');

    if (storedData is! Map) {
      return;
    }

    final Map<String, dynamic> committee =
        Map<String, dynamic>.from(
      storedData,
    );

    List<Map<String, dynamic>>
        savedSchedule = [];

    final dynamic existingSchedule =
        committee['receivingSchedule'];

    if (existingSchedule is List) {
      savedSchedule = existingSchedule
          .whereType<Map>()
          .map(
            (item) =>
                Map<String, dynamic>.from(
              item,
            ),
          )
          .toList();
    }

    while (savedSchedule.length <= index) {
      savedSchedule.add(
        <String, dynamic>{},
      );
    }

    savedSchedule[index] =
        Map<String, dynamic>.from(
      schedule[index],
    );

    await committeeBox.put(
      'currentCommittee',
      {
        ...committee,
        'receivingSchedule':
            savedSchedule,
        'receivingOrder':
            List<String>.from(
          receivingOrder,
        ),
      },
    );
  }

  void _editReceivingOrder() {
    List<String> editedOrder =
        List<String>.from(receivingOrder);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final bool isDark =
            Theme.of(sheetContext).brightness ==
                Brightness.dark;

        final Color backgroundColor =
            isDark
                ? const Color(0xFF0A0A0A)
                : Colors.white;

        final Color primaryTextColor =
            isDark
                ? Colors.white
                : Colors.black87;

        final Color secondaryTextColor =
            isDark
                ? Colors.white60
                : Colors.black54;

        return StatefulBuilder(
          builder: (
            context,
            setSheetState,
          ) {
            return Container(
              color: backgroundColor,
              padding: const EdgeInsets.all(20),
              child: SafeArea(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          color:
                              primaryTextColor,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            'Edit Receiving Order',
                            softWrap: true,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  primaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Drag members to change the receiving sequence.',
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (editedOrder.isEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.all(
                          20,
                        ),
                        child: Text(
                          'No members available.',
                          style: TextStyle(
                            color:
                                secondaryTextColor,
                          ),
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints:
                            const BoxConstraints(
                          maxHeight: 400,
                        ),
                        child:
                            ReorderableListView
                                .builder(
                          shrinkWrap: true,
                          itemCount:
                              editedOrder.length,
                          buildDefaultDragHandles:
                              false,
                          itemBuilder:
                              (
                            context,
                            index,
                          ) {
                            final String
                                member =
                                editedOrder[
                                    index];

                            return ListTile(
                              key: ValueKey(
                                member,
                              ),
                              contentPadding:
                                  EdgeInsets.zero,
                              leading: SizedBox(
                                width: 32,
                                child: Text(
                                  '${index + 1}.',
                                  style:
                                      TextStyle(
                                    color:
                                        primaryTextColor,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                member,
                                softWrap: true,
                                overflow:
                                    TextOverflow
                                        .visible,
                                style: TextStyle(
                                  color:
                                      primaryTextColor,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                              ),
                              trailing:
                                  ReorderableDragStartListener(
                                index: index,
                                child: Icon(
                                  Icons
                                      .drag_handle_rounded,
                                  color:
                                      secondaryTextColor,
                                ),
                              ),
                            );
                          },
                          onReorder:
                              (
                            oldIndex,
                            newIndex,
                          ) {
                            setSheetState(() {
                              if (newIndex >
                                  oldIndex) {
                                newIndex -= 1;
                              }

                              final String
                                  movedMember =
                                  editedOrder
                                      .removeAt(
                                oldIndex,
                              );

                              editedOrder.insert(
                                newIndex,
                                movedMember,
                              );
                            });
                          },
                        ),
                      ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child:
                          ElevatedButton.icon(
                        onPressed:
                            editedOrder.isEmpty
                                ? null
                                : () async {
                                    setState(() {
                                      receivingOrder =
                                          List<
                                              String>.from(
                                        editedOrder,
                                      );

                                      schedule =
                                          _createSchedule();
                                    });

                                    await _saveReceivingOrder();

                                    if (!sheetContext
                                        .mounted) {
                                      return;
                                    }

                                    Navigator.pop(
                                      sheetContext,
                                    );

                                    _showMessage(
                                      'Receiving order updated successfully.',
                                    );
                                  },
                        icon: const Icon(
                          Icons.check_rounded,
                        ),
                        label: const Text(
                          'Save Receiving Order',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final Color backgroundColor =
        isDark
            ? Colors.black
            : const Color(0xFFF5F5F5);

    final Color cardColor =
        isDark
            ? const Color(0xFF0A0A0A)
            : Colors.white;

    final Color primaryTextColor =
        isDark
            ? Colors.white
            : Colors.black87;

    final Color secondaryTextColor =
        isDark
            ? Colors.white60
            : Colors.black54;

    final Color borderColor =
        isDark
            ? Colors.white10
            : Colors.black12;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Monthly Schedule',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor:
            isDark
                ? Colors.black
                : Colors.white,
        foregroundColor:
            primaryTextColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(18),
                decoration:
                    BoxDecoration(
                  color: cardColor,
                  borderRadius:
                      BorderRadius.circular(18),
                  border: Border.all(
                    color: borderColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons
                              .calendar_month_rounded,
                          size: 28,
                          color:
                              primaryTextColor,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            'Receiving Order',
                            softWrap: true,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  primaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Each period, one member receives the committee amount according to the receiving order.',
                      softWrap: true,
                      overflow:
                          TextOverflow.visible,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color:
                            secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child:
                          OutlinedButton.icon(
                        onPressed:
                            receivingOrder
                                    .isEmpty
                                ? null
                                : _editReceivingOrder,
                        icon: const Icon(
                          Icons.edit_rounded,
                        ),
                        label: const Text(
                          'Edit Receiving Order',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              Text(
                'Monthly Schedule',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      primaryTextColor,
                ),
              ),

              const SizedBox(height: 12),

              if (schedule.isEmpty)
                _buildEmptyState(
                  cardColor: cardColor,
                  primaryTextColor:
                      primaryTextColor,
                  secondaryTextColor:
                      secondaryTextColor,
                  borderColor:
                      borderColor,
                )
              else
                ...List.generate(
                  schedule.length,
                  (index) {
                    final Map<String, String>
                        item =
                        schedule[index];

                    return GestureDetector(
                      onTap: () {
                        _changeReceivingMember(
                          index,
                        );
                      },
                      child: ScheduleCard(
                        title:
                            '${index + 1}. ${item['month'] ?? 'Period'}',
                        dueDate:
                            '${item['memberName'] ?? 'Member'} • ${item['dueDate'] ?? 'Date'}',
                        amount:
                            item['amount'] ??
                                'PKR 0',
                        status:
                            item['status'] ??
                                'Upcoming',
                      ),
                    );
                  },
                ),

              const SizedBox(height: 8),

              Text(
                'Tap a period to change its receiving member.',
                textAlign:
                    TextAlign.center,
                softWrap: true,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required Color cardColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Color borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 35,
      ),
      decoration:
          BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons
                .calendar_month_outlined,
            size: 55,
            color:
                secondaryTextColor,
          ),
          const SizedBox(height: 12),
          Text(
            'No Schedule Available',
            softWrap: true,
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.bold,
              color:
                  primaryTextColor,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            members.isEmpty
                ? 'Please add members to create the receiving schedule.'
                : 'Committee receiving schedule will appear here.',
            textAlign:
                TextAlign.center,
            softWrap: true,
            style: TextStyle(
              fontSize: 13,
              color:
                  secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
