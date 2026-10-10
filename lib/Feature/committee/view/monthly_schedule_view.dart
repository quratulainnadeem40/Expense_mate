
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  static const Color primaryBlue = Color(0xFF173B67);
  static const Color backgroundBlue = Color(0xFFF4F7FC);
  static const Color softBlue = Color(0xFFE8F3FF);
  static const Color borderBlue = Color(0xFFDCE5F0);
  static const Color textColor = Color(0xFF243449);

  // --------------------------------------------------
  // BUILD SCHEDULE FROM THE ACTIVE COMMITTEE
  // --------------------------------------------------

  List<Map<String, String>> _createSchedule() {
    final List<Map<String, String>> result = [];

    // Read the original members of the active committee.
    final List<Map<String, dynamic>> actualMembers =
        committeeController.members.toList();

    // Do not generate a schedule without actual members.
    if (actualMembers.isEmpty) {
      return result;
    }

    // Use the active committee's saved start date.
    final DateTime? committeeStartDate =
        committeeController.startDate.value;

    if (committeeStartDate == null) {
      return result;
    }

    // Use the active committee's actual duration.
    final int durationMonths =
        committeeController.durationInMonths.ceil();

    if (durationMonths <= 0) {
      return result;
    }

    // Keep only actual members with valid names.
    // Their existing order is preserved.
    final List<Map<String, dynamic>> validMembers =
        actualMembers.where((member) {
      return (member['name']?.toString().trim() ?? '')
          .isNotEmpty;
    }).toList();

    if (validMembers.isEmpty) {
      return result;
    }

    // Never repeat a member to fill extra months.
    // Each real member receives at most one schedule entry.
    final int scheduleCount =
        validMembers.length < durationMonths
            ? validMembers.length
            : durationMonths;

    // Amount collected for the committee each month.
    final double committeeAmount =
        committeeController.totalPool;

    for (int i = 0; i < scheduleCount; i++) {
      // Calculate each month from the actual start date.
      // Using day 1 first avoids invalid dates such as
      // 31 February when moving between months.
      final DateTime firstDayOfMonth = DateTime(
        committeeStartDate.year,
        committeeStartDate.month + i,
        1,
      );

      final int lastDayOfMonth = DateTime(
        firstDayOfMonth.year,
        firstDayOfMonth.month + 1,
        0,
      ).day;

      final int validDay =
          committeeStartDate.day > lastDayOfMonth
              ? lastDayOfMonth
              : committeeStartDate.day;

      final DateTime receivingDate = DateTime(
        firstDayOfMonth.year,
        firstDayOfMonth.month,
        validDay,
      );

      // Use the member at this exact position.
      // There is no modulo or repeated-member logic.
      final Map<String, dynamic> member = validMembers[i];

      final String memberName =
          member['name'].toString().trim();

      final String monthName =
          _monthName(receivingDate.month);

      result.add({
        'month': '$monthName ${receivingDate.year}',
        'memberName': memberName,
        'amount': _formatAmount(committeeAmount),
        'dueDate':
            '${receivingDate.day} $monthName ${receivingDate.year}',
        'status': 'Upcoming',
      });
    }

    return result;
  }

  // --------------------------------------------------
  // FORMAT AMOUNT
  // --------------------------------------------------

  String _formatAmount(double amount) {
    final int roundedAmount = amount.round();
    final String value = roundedAmount.toString();
    final StringBuffer result = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      if (i > 0 && (value.length - i) % 3 == 0) {
        result.write(',');
      }

      result.write(value[i]);
    }

    return 'PKR $result';
  }

  // --------------------------------------------------
  // MONTH NAME
  // --------------------------------------------------

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

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final Color backgroundColor = isDark
        ? const Color(0xFF121212)
        : backgroundBlue;

    final Color cardColor = isDark
        ? const Color(0xFF242424)
        : Colors.white;

    final Color appBarColor = isDark
        ? const Color(0xFF1C1C1C)
        : Colors.white;

    final Color primaryTextColor =
        isDark ? Colors.white : textColor;

    final Color secondaryTextColor =
        isDark ? Colors.white60 : const Color(0xFF718096);

    final Color borderColor = isDark
        ? const Color(0xFF3A3A3A)
        : borderBlue;

    final Color accentColor =
        isDark ? const Color(0xFF80CBC4) : primaryBlue;

    final Color iconBackgroundColor = isDark
        ? const Color(0xFF333333)
        : softBlue;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_rounded,
              color: accentColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Monthly Schedule',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: appBarColor,
        foregroundColor: primaryTextColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        // Obx keeps the schedule connected to the
        // controller's reactive committee data.
        child: Obx(() {
          final List<Map<String, String>> schedule =
              _createSchedule();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.16 : 0.035,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: iconBackgroundColor,
                              borderRadius:
                                  BorderRadius.circular(13),
                            ),
                            child: Icon(
                              Icons.calendar_month_rounded,
                              size: 28,
                              color: accentColor,
                            ),
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
                        'Each actual committee member appears '
                        'once in the receiving schedule, in the '
                        'order they were added.',
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
                    isDark: isDark,
                    cardColor: cardColor,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    borderColor: borderColor,
                    accentColor: accentColor,
                    iconBackgroundColor: iconBackgroundColor,
                  )
                else
                  ...List.generate(
                    schedule.length,
                    (index) {
                      final Map<String, String> item =
                          schedule[index];

                      return ScheduleCard(
                        title:
                            '${index + 1}. ${item['month']!}',
                        dueDate:
                            '${item['memberName']!} • '
                            '${item['dueDate']!}',
                        amount: item['amount']!,
                        status: item['status']!,
                      );
                    },
                  ),
                const SizedBox(height: 8),
                Text(
                  'The schedule uses the active committee’s '
                  'saved members, start date and duration.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // --------------------------------------------------
  // EMPTY STATE
  // --------------------------------------------------

  Widget _buildEmptyState({
    required bool isDark,
    required Color cardColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Color borderColor,
    required Color accentColor,
    required Color iconBackgroundColor,
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
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.16 : 0.035,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_month_outlined,
              size: 42,
              color: accentColor,
            ),
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
            'Add committee members and ensure the '
            'committee start date and duration are set '
            'to generate the receiving schedule.',
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
