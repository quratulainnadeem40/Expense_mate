import 'package:flutter/material.dart';

import '../controller/committe_controller.dart';
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
  final CommitteeController committeeController =
      CommitteeController.instance;

  late List<Map<String, String>> schedule;

  @override
  void initState() {
    super.initState();
    schedule = _createSchedule();
  }

  List<Map<String, String>> _createSchedule() {
    final List<Map<String, String>> result = [];

    final List<Map<String, dynamic>> actualMembers =
        committeeController.members.toList();

    final List<String> memberNames = actualMembers
        .map(
          (member) =>
              member['name']?.toString().trim() ?? '',
        )
        .where((name) => name.isNotEmpty)
        .toList();

    if (memberNames.isEmpty) {
      return result;
    }

    final double committeeAmount =
        committeeController.totalPool > 0
            ? committeeController.totalPool
            : widget.monthlyContribution *
                widget.totalMembers;

    /*
      Special case:

      If the committee duration is 1 month and there are
      multiple members, each member receives the committee
      amount on a different date in the same month.

      Example:
      3 members:
      Member 1 -> 10th
      Member 2 -> 20th
      Member 3 -> 30th
    */
    if (widget.durationMonths == 1 &&
        memberNames.length > 1) {
      final List<int> receivingDays =
          _createReceivingDays(
        memberNames.length,
        widget.startDate,
      );

      for (int i = 0; i < memberNames.length; i++) {
        final DateTime receivingDate = DateTime(
          widget.startDate.year,
          widget.startDate.month,
          receivingDays[i],
        );

        final String monthName =
            _monthName(receivingDate.month);

        result.add({
          'month':
              '$monthName ${receivingDate.year}',
          'memberName': memberNames[i],
          'amount': _formatAmount(committeeAmount),
          'dueDate':
              '${receivingDate.day} $monthName ${receivingDate.year}',
          'status': 'Upcoming',
        });
      }

      return result;
    }

    /*
      Normal case:

      One member receives the committee amount each month.

      Example:
      3 members + 3 months

      Month 1 -> Member 1
      Month 2 -> Member 2
      Month 3 -> Member 3

      If duration is longer:

      3 members + 6 months

      Month 1 -> Member 1
      Month 2 -> Member 2
      Month 3 -> Member 3
      Month 4 -> Member 1
      Month 5 -> Member 2
      Month 6 -> Member 3
    */
    final int numberOfMonths =
        widget.durationMonths > 0
            ? widget.durationMonths
            : committeeController.durationInMonths.ceil();

    for (int i = 0; i < numberOfMonths; i++) {
      final DateTime monthDate = DateTime(
        widget.startDate.year,
        widget.startDate.month + i,
        widget.startDate.day,
      );

      final String monthName =
          _monthName(monthDate.month);

      final String memberName =
          memberNames[i % memberNames.length];

      final String dueDate =
          '${monthDate.day} $monthName ${monthDate.year}';

      result.add({
        'month':
            '$monthName ${monthDate.year}',
        'memberName': memberName,
        'amount': _formatAmount(committeeAmount),
        'dueDate': dueDate,
        'status': 'Upcoming',
      });
    }

    return result;
  }

  List<int> _createReceivingDays(
    int memberCount,
    DateTime startDate,
  ) {
    final int daysInMonth = DateTime(
      startDate.year,
      startDate.month + 1,
      0,
    ).day;

    if (memberCount == 1) {
      return [
        startDate.day.clamp(1, daysInMonth),
      ];
    }

    /*
      For 3 members this gives:
      10, 20, 30

      For other member counts, dates are distributed
      across the month as evenly as possible.
    */
    final List<int> days = [];

    for (int i = 1; i <= memberCount; i++) {
      int day =
          ((daysInMonth * i) / memberCount).round();

      if (day < 1) {
        day = 1;
      }

      if (day > daysInMonth) {
        day = daysInMonth;
      }

      if (days.isNotEmpty &&
          day <= days.last) {
        day = days.last + 1;

        if (day > daysInMonth) {
          day = daysInMonth;
        }
      }

      days.add(day);
    }

    return days;
  }

  String _formatAmount(double amount) {
    final int roundedAmount = amount.round();

    final String value =
        roundedAmount.toString();

    final StringBuffer result =
        StringBuffer();

    for (int i = 0; i < value.length; i++) {
      if (i > 0 &&
          (value.length - i) % 3 == 0) {
        result.write(',');
      }

      result.write(value[i]);
    }

    return 'PKR $result';
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
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_rounded,
            ),
            SizedBox(width: 8),
            Text(
              'Monthly Schedule',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
          padding:
              const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(18),
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
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Each member receives the committee amount automatically according to the receiving order.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color:
                            secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 22,
              ),

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

              const SizedBox(
                height: 12,
              ),

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
                    final Map<String, String>
                        item = schedule[index];

                    return ScheduleCard(
                      title:
                          '${index + 1}. ${item['month'] ?? 'Month'}',
                      dueDate:
                          '${item['memberName'] ?? 'Member'} • ${item['dueDate'] ?? 'Date'}',
                      amount:
                          item['amount'] ??
                              'PKR 0',
                      status:
                          item['status'] ??
                              'Upcoming',
                    );
                  },
                ),

              const SizedBox(
                height: 8,
              ),

              Text(
                'Receiving order is automatically generated from the committee members.',
                textAlign:
                    TextAlign.center,
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
      decoration: BoxDecoration(
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
          const SizedBox(
            height: 12,
          ),
          Text(
            'No Schedule Available',
            style: TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.bold,
              color:
                  primaryTextColor,
            ),
          ),
          const SizedBox(
            height: 7,
          ),
          Text(
            'Add committee members first to generate the receiving schedule.',
            textAlign:
                TextAlign.center,
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