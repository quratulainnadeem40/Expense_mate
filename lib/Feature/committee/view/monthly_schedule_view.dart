
import 'package:flutter/material.dart';

import '../widgets/schedule_card.dart';

class MonthlyScheduleView extends StatefulWidget {
  final double monthlyContribution;
  final int totalMembers;
  final int durationMonths;
  final DateTime startDate;

  const MonthlyScheduleView({
    super.key,
    required this.monthlyContribution,
    required this.totalMembers,
    required this.durationMonths,
    required this.startDate,
  });

  @override
  State<MonthlyScheduleView> createState() =>
      _MonthlyScheduleViewState();
}

class _MonthlyScheduleViewState
    extends State<MonthlyScheduleView> {
  final List<String> members = [
    'Fatima',
    'Maryam',
    'Sheeza',
    'Zara',
  ];

  late List<Map<String, String>> schedule;

  @override
  void initState() {
    super.initState();
    schedule = _createSchedule();
  }

  List<Map<String, String>> _createSchedule() {
    final List<Map<String, String>> result = [];

    final int numberOfMonths = widget.durationMonths;

    for (int i = 0; i < numberOfMonths; i++) {
      final DateTime monthDate = DateTime(
        widget.startDate.year,
        widget.startDate.month + i,
        widget.startDate.day,
      );

      final String monthName = _monthName(monthDate.month);

      final String memberName =
          members[i % members.length];

      final String amount =
          'PKR ${widget.monthlyContribution.toStringAsFixed(0)}';

      final String dueDate =
          '${monthDate.day} $monthName ${monthDate.year}';

      result.add({
        'month': '$monthName ${monthDate.year}',
        'memberName': memberName,
        'amount': amount,
        'dueDate': dueDate,
        'status': 'Upcoming',
      });
    }

    return result;
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

  void _changeReceivingMember(int index) {
    final String currentMember =
        schedule[index]['memberName'] ?? members.first;

    final TextEditingController nameController =
        TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final bool isDark =
            Theme.of(sheetContext).brightness ==
                Brightness.dark;

        final Color backgroundColor =
            isDark ? const Color(0xFF0A0A0A) : Colors.white;

        final Color primaryTextColor =
            isDark ? Colors.white : Colors.black87;

        final Color secondaryTextColor =
            isDark ? Colors.white60 : Colors.black54;

        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                      'Select Receiving Member',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      schedule[index]['month'] ?? 'Month',
                      style: TextStyle(
                        fontSize: 13,
                        color: secondaryTextColor,
                      ),
                    ),

                    const SizedBox(height: 16),

                    ...List.generate(
                      members.length,
                      (memberIndex) {
                        final String member =
                            members[memberIndex];

                        final bool isSelected =
                            member == currentMember;

                        return ListTile(
                          contentPadding: EdgeInsets.zero,

                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 24,
                                child: Text(
                                  '${memberIndex + 1}.',
                                  style: TextStyle(
                                    color: primaryTextColor,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.person_rounded,
                                color: primaryTextColor,
                              ),
                            ],
                          ),

                          title: Text(
                            member,
                            style: TextStyle(
                              color: primaryTextColor,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),

                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: primaryTextColor,
                                )
                              : null,

                          onTap: () {
                            setState(() {
                              schedule[index]['memberName'] =
                                  member;
                            });

                            Navigator.pop(sheetContext);

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${schedule[index]['month']} receiving member changed to $member.',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),

                    const Divider(),

                    ListTile(
                      contentPadding: EdgeInsets.zero,

                      leading: Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: secondaryTextColor,
                          ),
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+',
                          style: TextStyle(
                            fontSize: 20,
                            color: primaryTextColor,
                          ),
                        ),
                      ),

                      title: Text(
                        'Add a Name',
                        style: TextStyle(
                          color: primaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      subtitle: Text(
                        'Enter another receiving member',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),

                      onTap: () async {
                        nameController.clear();

                        final String? newName =
                            await showDialog<String>(
                          context: sheetContext,
                          builder: (dialogContext) {
                            return AlertDialog(
                              title: const Text(
                                'Add a Name',
                              ),
                              content: TextField(
                                controller:
                                    nameController,
                                autofocus: true,
                                textCapitalization:
                                    TextCapitalization.words,
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
                                  child: const Text(
                                    'Cancel',
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final String name =
                                        nameController.text
                                            .trim();

                                    if (name.isNotEmpty) {
                                      Navigator.pop(
                                        dialogContext,
                                        name,
                                      );
                                    }
                                  },
                                  child: const Text(
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
                            if (!members.contains(newName)) {
                              members.add(newName);
                            }

                            schedule[index]['memberName'] =
                                newName;
                          });

                          Navigator.pop(sheetContext);

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                '${schedule[index]['month']} receiving member changed to $newName.',
                              ),
                            ),
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
    ).whenComplete(() {
      nameController.dispose();
    });
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

    final Color borderColor =
        isDark ? Colors.white10 : Colors.black12;

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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
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
                          Icons.calendar_month_rounded,
                          size: 28,
                          color: primaryTextColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Receiving Order',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Each month, one member receives the committee amount according to the receiving order.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: secondaryTextColor,
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
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
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
                  borderColor: borderColor,
                )
              else
                ...List.generate(
                  schedule.length,
                  (index) {
                    final item = schedule[index];

                    return GestureDetector(
                      onTap: () {
                        _changeReceivingMember(index);
                      },
                      child: ScheduleCard(
                        title:
                            '${index + 1}. ${item['month'] ?? 'Month'}',
                        dueDate:
                            '${item['memberName'] ?? 'Member'} • ${item['dueDate'] ?? 'Date'}',
                        amount:
                            item['amount'] ?? 'PKR 0',
                        status:
                            item['status'] ?? 'Upcoming',
                      ),
                    );
                  },
                ),

              const SizedBox(height: 8),

              Text(
                'Tap a month to change its receiving member.',
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

  Widget _buildEmptyState({
    required Color cardColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Color borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 35,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 55,
            color: secondaryTextColor,
          ),
          const SizedBox(height: 12),
          Text(
            'No Schedule Available',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Monthly receiving schedule will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

