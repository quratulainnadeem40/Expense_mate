import 'dart:math';

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
  State<MonthlyScheduleView> createState() => _MonthlyScheduleViewState();
}

class _MonthlyScheduleViewState extends State<MonthlyScheduleView> {
  final CommitteeController committeeController = CommitteeController.instance;

  static const Color primaryBlue = Color(0xFF173B67);
  static const Color backgroundBlue = Color(0xFFF4F7FC);
  static const Color softBlue = Color(0xFFE8F3FF);
  static const Color borderBlue = Color(0xFFDCE5F0);
  static const Color textColor = Color(0xFF243449);

  final Random _random = Random();

  late FixedExtentScrollController _wheelController;

  int _selectedMonthIndex = 0;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();

    _wheelController = FixedExtentScrollController(initialItem: 0);
  }

  @override
  void dispose() {
    _wheelController.dispose();
    super.dispose();
  }

  // --------------------------------------------------
  // FORMAT HELPERS
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

  String _formatDate(DateTime date) {
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  DateTime _dateForScheduleIndex(int index) {
    final DateTime start = committeeController.startDate.value!;

    final DateTime firstDay = DateTime(start.year, start.month + index, 1);

    final int lastDay = DateTime(firstDay.year, firstDay.month + 1, 0).day;

    final int day = start.day > lastDay ? lastDay : start.day;

    return DateTime(firstDay.year, firstDay.month, day);
  }

  // --------------------------------------------------
  // ACTUAL COMMITTEE MEMBERS
  // --------------------------------------------------

  List<Map<String, dynamic>> _getActualMembers() {
    return committeeController.members
        .where((member) => (member['name']?.toString().trim() ?? '').isNotEmpty)
        .map((member) => Map<String, dynamic>.from(member))
        .toList();
  }

  // --------------------------------------------------
  // CREATE SCHEDULE
  // --------------------------------------------------

  List<Map<String, dynamic>> _createSchedule() {
    final List<Map<String, dynamic>> result = [];

    final List<Map<String, dynamic>> actualMembers = _getActualMembers();

    final DateTime? start = committeeController.startDate.value;

    final int months = committeeController.durationInMonths.ceil();

    if (actualMembers.isEmpty || start == null || months <= 0) {
      return result;
    }

    final double amount = committeeController.totalPool;

    for (int i = 0; i < months; i++) {
      final DateTime receivingDate = _dateForScheduleIndex(i);

      // Original added order is used unless a spinner
      // result has been saved for this particular month.
      final String defaultMember =
          actualMembers[i % actualMembers.length]['name'].toString().trim();

      final String? savedMember = committeeController.getReceivingSelection(
        receivingDate,
      );

      final bool savedMemberExists =
          savedMember != null &&
          actualMembers.any(
            (member) => member['name']?.toString().trim() == savedMember,
          );

      final String receivingMember = savedMemberExists
          ? savedMember
          : defaultMember;

      result.add({
        'month':
            '${_monthName(receivingDate.month)} '
            '${receivingDate.year}',
        'memberName': receivingMember,
        'amount': amount,
        'formattedAmount': _formatAmount(amount),
        'date': receivingDate,
        'dueDate': _formatDate(receivingDate),
        'status': 'Upcoming',
      });
    }

    return result;
  }

  // --------------------------------------------------
  // SELECT MONTH
  // --------------------------------------------------

  void _selectMonth(int? index, List<Map<String, dynamic>> schedule) {
    if (index == null || index < 0 || index >= schedule.length) {
      return;
    }

    if (_isSpinning) return;

    setState(() {
      _selectedMonthIndex = index;
    });

    final List<Map<String, dynamic>> actualMembers = _getActualMembers();

    if (actualMembers.isEmpty || !_wheelController.hasClients) {
      return;
    }

    final String selectedName = schedule[index]['memberName'].toString();

    final int foundIndex = actualMembers.indexWhere(
      (member) => member['name']?.toString().trim() == selectedName,
    );

    if (foundIndex >= 0) {
      _wheelController.jumpToItem(foundIndex);
    }
  }

  // --------------------------------------------------
  // SPIN AND SAVE RESULT
  // --------------------------------------------------

  Future<void> _spinForReceiving(List<Map<String, dynamic>> schedule) async {
    final List<Map<String, dynamic>> actualMembers = _getActualMembers();

    if (_isSpinning) return;

    if (actualMembers.isEmpty) {
      Get.snackbar(
        'No Members',
        'Add committee members before spinning.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (schedule.isEmpty || _selectedMonthIndex >= schedule.length) {
      Get.snackbar(
        'No Schedule',
        'The committee schedule is not available yet.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!_wheelController.hasClients) {
      Get.snackbar(
        'Please Wait',
        'The spinner is not ready yet.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _isSpinning = true;
    });

    try {
      // Select one of the real committee members.
      final int targetIndex = _random.nextInt(actualMembers.length);

      await _wheelController.animateToItem(
        targetIndex,
        duration: const Duration(seconds: 3),
        curve: Curves.easeOutCubic,
      );

      if (!mounted) return;

      final DateTime receivingDate =
          schedule[_selectedMonthIndex]['date'] as DateTime;

      final String winner = actualMembers[targetIndex]['name']
          .toString()
          .trim();

      committeeController.saveReceivingSelection(
        date: receivingDate,
        memberName: winner,
      );

      Get.snackbar(
        'Receiving Member Selected',
        '$winner will receive the committee amount for '
            '${_monthName(receivingDate.month)} '
            '${receivingDate.year}.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: primaryBlue,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSpinning = false;
        });
      }
    }
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color backgroundColor = isDark
        ? const Color(0xFF121212)
        : backgroundBlue;
    final Color cardColor = theme.colorScheme.surface;
    final Color primaryTextColor = isDark ? Colors.white : textColor;
    final Color secondaryTextColor = theme.colorScheme.onSurfaceVariant;
    final Color borderColor = isDark ? const Color(0xFF3A3A3A) : borderBlue;
    final Color accentColor = isDark ? const Color(0xFF80CBC4) : primaryBlue;
    final Color iconBackgroundColor = isDark
        ? const Color(0xFF333333)
        : softBlue;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month_rounded, color: accentColor),
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
        backgroundColor: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        foregroundColor: primaryTextColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Obx(() {
          final List<Map<String, dynamic>> schedule = _createSchedule();

          final List<Map<String, dynamic>> actualMembers = _getActualMembers();

          if (_selectedMonthIndex >= schedule.length) {
            _selectedMonthIndex = 0;
          }

          final Map<String, dynamic>? selectedSchedule = schedule.isEmpty
              ? null
              : schedule[_selectedMonthIndex];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
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
                              borderRadius: BorderRadius.circular(13),
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
                        'View the committee schedule and spin '
                        'to select a receiving member for a '
                        'particular month.',
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
                  'Next Receiver',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),

                const SizedBox(height: 12),

                // SPINNER CARD
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
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Select Receiving Month',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: primaryTextColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      DropdownButtonFormField<int>(
                        initialValue: schedule.isEmpty
                            ? null
                            : _selectedMonthIndex,
                        isExpanded: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: iconBackgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                        ),
                        hint: const Text('No month available'),
                        items: List.generate(
                          schedule.length,
                          (index) => DropdownMenuItem<int>(
                            value: index,
                            child: Text(
                              schedule[index]['month'].toString(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        onChanged: _isSpinning
                            ? null
                            : (index) => _selectMonth(index, schedule),
                      ),

                      const SizedBox(height: 18),

                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: iconBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.45),
                            width: 1.5,
                          ),
                        ),
                        child: actualMembers.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'Add committee members to use '
                                    'the receiving spinner.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: secondaryTextColor),
                                  ),
                                ),
                              )
                            : Stack(
                                alignment: Alignment.center,
                                children: [
                                  IgnorePointer(
                                    child: Container(
                                      height: 58,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: accentColor,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  ListWheelScrollView.useDelegate(
                                    controller: _wheelController,
                                    itemExtent: 58,
                                    physics: _isSpinning
                                        ? const NeverScrollableScrollPhysics()
                                        : const FixedExtentScrollPhysics(),
                                    perspective: 0.003,
                                    diameterRatio: 1.7,
                                    childDelegate:
                                        ListWheelChildBuilderDelegate(
                                          childCount: actualMembers.length,
                                          builder: (context, index) {
                                            if (index < 0 ||
                                                index >= actualMembers.length) {
                                              return null;
                                            }

                                            final String name =
                                                actualMembers[index]['name']
                                                    .toString();

                                            return Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                    ),
                                                child: Text(
                                                  name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.bold,
                                                    color: primaryTextColor,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                  ),
                                ],
                              ),
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              _isSpinning ||
                                  actualMembers.isEmpty ||
                                  schedule.isEmpty
                              ? null
                              : () => _spinForReceiving(schedule),
                          icon: _isSpinning
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.casino_rounded),
                          label: Text(_isSpinning ? 'Spinning...' : 'Spin'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      if (selectedSchedule != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF303030)
                                : const Color(0xFFF8FAFD),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Selected Receiving Member',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                selectedSchedule['memberName'].toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                selectedSchedule['month'].toString(),
                                style: TextStyle(color: secondaryTextColor),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                selectedSchedule['formattedAmount'].toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: primaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

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
                  ...List.generate(schedule.length, (index) {
                    final Map<String, dynamic> item = schedule[index];

                    return ScheduleCard(
                      title: '${index + 1}. ${item['month']}',
                      dueDate: '${item['memberName']} • ${item['dueDate']}',
                      amount: item['formattedAmount'].toString(),
                      status: item['status'].toString(),
                    );
                  }),

                const SizedBox(height: 8),

                Text(
                  'The schedule uses the active committee’s '
                  'saved members, start date, duration and '
                  'saved spinner selections.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: secondaryTextColor),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.035),
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
            'Add committee members and ensure the committee '
            'start date and duration are set to generate the '
            'receiving schedule.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: secondaryTextColor),
          ),
        ],
      ),
    );
  }
}
