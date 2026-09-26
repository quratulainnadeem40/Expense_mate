import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/budget_controller.dart';
import '../model/budget_model.dart';

DateTime calculateNextBudgetResetDate({
  required DateTime now,
  required int selectedDay,
}) {
  final currentMonth = now.month;
  final currentYear = now.year;

  final nextMonth = currentMonth == 12 ? 1 : currentMonth + 1;
  final nextYear = currentMonth == 12 ? currentYear + 1 : currentYear;
  final normalizedNextMonthDay = _normalizeSelectedDayForDateCalculation(
    selectedDay,
    nextYear,
    nextMonth,
  );

  return DateTime(nextYear, nextMonth, normalizedNextMonthDay);
}

int _normalizeSelectedDayForDateCalculation(
  int selectedDay,
  int year,
  int month,
) {
  final lastDay = DateTime(year, month + 1, 0).day;
  return selectedDay > lastDay ? lastDay : selectedDay;
}

class BudgetView extends StatefulWidget {
  const BudgetView({Key? key}) : super(key: key);

  @override
  State<BudgetView> createState() => _BudgetViewState();
}

class _BudgetViewState extends State<BudgetView> {
  final Set<String> _selectedCategoryIds = <String>{};
  bool _isSelectionMode = false;

  BudgetController get controller => Get.find<BudgetController>();

  /// Offered once per app run. If the user closes it without saving we do
  /// not nag them again until the next launch.
  static bool _setupOfferedThisSession = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (controller.isCycleConfigured.value) return;
      if (_setupOfferedThisSession) return;

      _setupOfferedThisSession = true;
      _showFirstTimeSetup(context);
    });
  }

  // ==================================================================
  // STEP 22 - first-time budget cycle setup
  // ==================================================================
  Future<void> _showFirstTimeSetup(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    int day = controller.monthStartDay.value;
    bool automatic = controller.isAutomaticReset.value;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              margin: const EdgeInsets.only(top: 18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141414) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 52,
                            height: 5,
                            decoration: BoxDecoration(
                              color:
                                  isDark ? Colors.white24 : Colors.black12,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Set Up Your Budget Cycle',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E1E1E),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Choose when your monthly budget should start.',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 22),

                        Text(
                          'Month Start',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(31, (index) {
                            final value = index + 1;
                            final active = value == day;

                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () =>
                                    setSheetState(() => day = value),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: active
                                        ? const Color(0xFF4CAF50)
                                        : (isDark
                                            ? const Color(0xFF202020)
                                            : const Color(0xFFF1F4F0)),
                                    borderRadius:
                                        BorderRadius.circular(11),
                                  ),
                                  child: Text(
                                    '$value',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: active
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: active
                                          ? Colors.white
                                          : (isDark
                                              ? Colors.white70
                                              : Colors.black87),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 22),

                        Text(
                          'Reset Mode',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF202020)
                                : const Color(0xFFEAEFEA),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [true, false].map((auto) {
                              final active = automatic == auto;

                              return Expanded(
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () => setSheetState(
                                      () => automatic = auto,
                                    ),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: active
                                            ? const Color(0xFF4CAF50)
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        auto ? 'Automatic' : 'Manual',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: active
                                              ? Colors.white
                                              : (isDark
                                                  ? Colors.white70
                                                  : Colors.black54),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 14),

                        Text(
                          automatic
                              ? 'Your budget will reset automatically on '
                                  'the selected date every month.'
                              : 'You will reset the budget yourself '
                                  'whenever you want.',
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.5,
                            color:
                                isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              controller.setMonthStartDay(day);
                              controller.setAutomaticReset(automatic);
                              controller.markCycleConfigured();
                              Navigator.pop(sheetContext);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Save Budget Cycle',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showMonthlyLimitExceededDialog({
    required BuildContext context,
    required String categoryName,
    required double proposedLimit,
  }) async {
    final monthlyLimit = controller.customTotalBudget.value;
    if (monthlyLimit == null) return;

    final projectedTotal = controller.projectedAllocationAfterUpdate(
      categoryName,
      proposedLimit,
    );
    final amountOver = projectedTotal - monthlyLimit;

    final action = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly budget exceeded',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'This category would push your total monthly budget from RS ${monthlyLimit.toStringAsFixed(0)} to RS ${projectedTotal.toStringAsFixed(0)}.\n\nYou are over by RS ${amountOver.toStringAsFixed(0)}.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Get.back(result: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: const Text(
                          'Edit Monthly Limit',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (action == true) {
      final activeContext = Get.context;
      if (activeContext != null && activeContext.mounted) {
        _showEditTotalBudgetDialog(
          activeContext,
          controller.customTotalBudget.value ?? controller.totalAllocated,
        );
      }
    }
  }

  int _getLastDayOfMonth(int year, int month) {
    final nextMonth = month == 12
        ? DateTime(year + 1, 1, 0)
        : DateTime(year, month + 1, 0);
    return nextMonth.day;
  }

  int _normalizeSelectedDay(int selectedDay, int year, int month) {
    final lastDay = _getLastDayOfMonth(year, month);
    return selectedDay > lastDay ? lastDay : selectedDay;
  }

  String _formatDisplayDate(DateTime date) {
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  Future<void> _showBudgetCycleBottomSheet(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Read from the controller so these choices are remembered.
    int selectedMonthStartDay = controller.monthStartDay.value;
    int selectedResetMode = controller.isAutomaticReset.value ? 0 : 1;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final now = DateTime.now();
            final currentMonth = now.month;
            final currentYear = now.year;

            final candidateResetDate = controller.nextResetDate;

            final lastResetDate =
                controller.lastResetDate.value ?? controller.cycleStartDate;

            final nextResetText =
                '${candidateResetDate.day} ${_monthName(candidateResetDate.month)} ${candidateResetDate.year}';
            final monthStartLabel = '${selectedMonthStartDay}th of every month';

            return Container(
              margin: const EdgeInsets.only(top: 18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141414) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 52,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white24 : Colors.black12,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Budget Cycle',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1E1E1E),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            icon: Icon(
                              Icons.close_rounded,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1C1C1C)
                              : const Color(0xFFF4F7F1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Budget Cycle',
                              style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 0.4,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 10),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () async {
                                  final picked = await showDialog<int>(
                                    context: sheetContext,
                                    builder: (dialogContext) {
                                      int dialogSelectedDay =
                                          selectedMonthStartDay;

                                      // One reading of the clock for this
                                      // dialog, so the header and the
                                      // preview always agree.
                                      final dialogNow = DateTime.now();

                                      return StatefulBuilder(
                                        builder: (context, setDialogState) {
                                          return Dialog(
                                            insetPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 24,
                                                  vertical: 28,
                                                ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                            ),
                                            // On a short screen the buttons
                                            // were pushed past the bottom
                                            // edge. Now the contents scroll
                                            // instead of overflowing.
                                            child: SingleChildScrollView(
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  20,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Select Month Start',
                                                      style: TextStyle(
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: isDark
                                                            ? Colors.white
                                                            : const Color(
                                                                0xFF1F2937,
                                                              ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            12,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: isDark
                                                            ? const Color(
                                                                0xFF1F1F1F,
                                                              )
                                                            : const Color(
                                                                0xFFF3F6F2,
                                                              ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              18,
                                                            ),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // The month is read
                                                          // from the clock every
                                                          // time this opens, so
                                                          // it rolls over on its
                                                          // own. Nothing to tap.
                                                          Container(
                                                            width:
                                                                double.infinity,
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      14,
                                                                  vertical: 12,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: isDark
                                                                  ? const Color(
                                                                      0xFF262626,
                                                                    )
                                                                  : Colors
                                                                        .white,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                const Icon(
                                                                  Icons
                                                                      .event_repeat_rounded,
                                                                  size: 20,
                                                                  color: Color(
                                                                    0xFF4CAF50,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        '${_monthName(dialogNow.month)} ${dialogNow.year}',
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              17,
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                          color:
                                                                              isDark
                                                                              ? Colors.white
                                                                              : const Color(
                                                                                  0xFF1F2937,
                                                                                ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            2,
                                                                      ),
                                                                      Text(
                                                                        'Updates on its own every month',
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              11.5,
                                                                          color:
                                                                              isDark
                                                                              ? Colors.white54
                                                                              : Colors.black54,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Wrap(
                                                            spacing: 12,
                                                            runSpacing: 12,
                                                            children: List.generate(31, (
                                                              index,
                                                            ) {
                                                              final day =
                                                                  index + 1;
                                                              final isSelected =
                                                                  day ==
                                                                  dialogSelectedDay;
                                                              return MouseRegion(
                                                                cursor:
                                                                    SystemMouseCursors
                                                                        .click,
                                                                child: GestureDetector(
                                                                  onTap: () {
                                                                    setDialogState(
                                                                      () {
                                                                        dialogSelectedDay =
                                                                            day;
                                                                      },
                                                                    );
                                                                  },
                                                                  child: Container(
                                                                    width: 42,
                                                                    height: 42,
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    decoration: BoxDecoration(
                                                                      color:
                                                                          isSelected
                                                                          ? const Color(
                                                                              0xFF4CAF50,
                                                                            )
                                                                          : (isDark
                                                                                ? const Color(
                                                                                    0xFF2A2A2A,
                                                                                  )
                                                                                : Colors.white),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                      border: Border.all(
                                                                        color:
                                                                            isSelected
                                                                            ? const Color(
                                                                                0xFF4CAF50,
                                                                              )
                                                                            : (isDark
                                                                                  ? Colors.white12
                                                                                  : Colors.black12),
                                                                      ),
                                                                    ),
                                                                    child: Text(
                                                                      '$day',
                                                                      style: TextStyle(
                                                                        color:
                                                                            isSelected
                                                                            ? Colors.white
                                                                            : (isDark
                                                                                  ? Colors.white70
                                                                                  : Colors.black87),
                                                                        fontWeight:
                                                                            isSelected
                                                                            ? FontWeight.w700
                                                                            : FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                dialogContext,
                                                              ),
                                                          child: const Text(
                                                            'Cancel',
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                dialogContext,
                                                                dialogSelectedDay,
                                                              ),
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                const Color(
                                                                  0xFF4CAF50,
                                                                ),
                                                            foregroundColor:
                                                                Colors.white,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: const Text(
                                                            'Save',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );

                                  if (picked == null) return;

                                  // Same day picked again: nothing to warn
                                  // about.
                                  if (picked ==
                                      controller.monthStartDay.value) {
                                    return;
                                  }

                                  final confirmed =
                                      await _confirmStartDayChange(
                                    sheetContext,
                                    picked,
                                    isDark,
                                  );

                                  if (confirmed != true) return;

                                  controller.setMonthStartDay(picked);
                                  setSheetState(() {
                                    selectedMonthStartDay = picked;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Month Start',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF1F2937),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      monthStartLabel,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Reset Mode',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF202020)
                                    : const Color(0xFFEAEFEA),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          controller.setAutomaticReset(true);
                                          setSheetState(
                                            () => selectedResetMode = 0,
                                          );
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 180,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: selectedResetMode == 0
                                                ? const Color(0xFF4CAF50)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            'Automatic',
                                            style: TextStyle(
                                              color: selectedResetMode == 0
                                                  ? Colors.white
                                                  : (isDark
                                                        ? Colors.white70
                                                        : Colors.black54),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          controller.setAutomaticReset(false);
                                          setSheetState(
                                            () => selectedResetMode = 1,
                                          );
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 180,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: selectedResetMode == 1
                                                ? const Color(0xFF4CAF50)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            'Manual',
                                            style: TextStyle(
                                              color: selectedResetMode == 1
                                                  ? Colors.white
                                                  : (isDark
                                                        ? Colors.white70
                                                        : Colors.black54),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // ------------------------------------
                            // Step 18 - reset reminder
                            // Only meaningful in Automatic mode, so it is
                            // hidden entirely in Manual.
                            // ------------------------------------
                            if (selectedResetMode == 0) ...[
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Reset Reminder',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1F2937),
                                      ),
                                    ),
                                  ),
                                  Switch(
                                    value: controller.resetReminderOn.value,
                                    activeColor: const Color(0xFF4CAF50),
                                    onChanged: (value) {
                                      controller.setResetReminderOn(value);
                                      setSheetState(() {});
                                    },
                                  ),
                                ],
                              ),
                              if (controller.resetReminderOn.value) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Remind me',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [1, 2, 3].map((days) {
                                    final active =
                                        controller.reminderDaysBefore.value ==
                                            days;

                                    return MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          controller
                                              .setReminderDaysBefore(days);
                                          setSheetState(() {});
                                        },
                                        child: Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 9,
                                          ),
                                          decoration: BoxDecoration(
                                            color: active
                                                ? const Color(0xFF4CAF50)
                                                : (isDark
                                                    ? const Color(0xFF202020)
                                                    : const Color(
                                                        0xFFEAEFEA,
                                                      )),
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            days == 1
                                                ? '1 day before'
                                                : '$days days before',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                              color: active
                                                  ? Colors.white
                                                  : (isDark
                                                      ? Colors.white70
                                                      : Colors.black54),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],

                            const SizedBox(height: 18),

                            // One line about what the chosen mode does.
                            Text(
                              selectedResetMode == 0
                                  ? 'Budget resets on its own each cycle.'
                                  : 'Budget will not reset automatically.',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF4B5563),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Both dates are useful in either mode, so
                            // they are no longer hidden behind Manual.
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Last Reset',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF1F2937),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _formatDisplayDate(lastResetDate),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2B82FB),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Next Reset',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF1F2937),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        nextResetText,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2B82FB),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            Divider(
                              height: 1,
                              color:
                                  isDark ? Colors.white12 : Colors.black12,
                            ),

                            const SizedBox(height: 18),

                            // Available in both modes now. Automatic used
                            // to have no button at all, which made reset
                            // look broken.
                            Center(
                              child: SizedBox(
                                width: 220,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: sheetContext,
                                      builder: (dialogContext) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          title: const Text('Reset Budget?'),
                                          content: Text(
                                            "This will reset your current "
                                            "cycle's spent amount to Rs 0."
                                            "\n\nYour transactions will not "
                                            "be deleted.",
                                            style: TextStyle(
                                              fontSize: 15,
                                              height: 1.5,
                                              color: isDark
                                                  ? Colors.white
                                                  : const Color(0xFF1F2937),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                dialogContext,
                                                false,
                                              ),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(
                                                dialogContext,
                                                true,
                                              ),
                                              style:
                                                  ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFF4CAF50),
                                                foregroundColor:
                                                    Colors.white,
                                                shape:
                                                    RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    10,
                                                  ),
                                                ),
                                              ),
                                              child: const Text('Reset'),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirmed == true) {
                                      await controller.performReset();
                                      setSheetState(() {});
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4CAF50),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Reset Budget Now',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ],
                        
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Step 16 - warn before changing the start day.
  ///
  /// The change never clears anything; it only moves where the current
  /// cycle ends. Spending stays exactly as it is.
  Future<bool?> _confirmStartDayChange(
    BuildContext context,
    int newDay,
    bool isDark,
  ) {
    final currentCycle = controller.previewCycleLabel(newDay);
    final nextCycle = controller.previewNextCycleLabel(newDay);

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              isDark ? const Color(0xFF1F1F1F) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Change Budget Start Date?',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your current budget cycle will become:',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                currentCycle,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2B82FB),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'The cycle after that:',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                nextCycle,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2B82FB),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50)
                      .withOpacity(isDark ? 0.14 : 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your spent amount, limits and transactions stay '
                        'as they are. Only the reset date moves.',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  String _monthName(int month) {
    const months = [
      '',
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
    return months[month];
  }

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Custom Category',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'e.g., Travel',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF4CAF50)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  onTap: () {
                    if (amountController.text == '0') {
                      amountController.clear();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Monthly Limit',
                    hintText: 'e.g., 20000',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF4CAF50)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          final categoryName = nameController.text.trim();
                          final amount =
                              double.tryParse(amountController.text.trim()) ??
                              10000;

                          if (categoryName.isEmpty) {
                            Get.snackbar(
                              'Required',
                              'Please enter a category name.',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }

                          if (controller.customTotalBudget.value != null &&
                              controller.projectedAllocationAfterUpdate(
                                    categoryName,
                                    amount,
                                  ) >
                                  controller.customTotalBudget.value!) {
                            final parentContext = Get.context;
                            Get.back(result: false);
                            if (parentContext != null &&
                                parentContext.mounted) {
                              _showMonthlyLimitExceededDialog(
                                context: parentContext,
                                categoryName: categoryName,
                                proposedLimit: amount,
                              );
                            }
                            return;
                          }

                          controller.addNewBudget(categoryName, amount);
                          Get.back(result: true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                        ),
                        child: const Text(
                          'Add',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == true && context.mounted) {
      Get.snackbar(
        'Success',
        'Custom category added.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _deleteSelectedCategories() async {
    if (_selectedCategoryIds.isEmpty) {
      return;
    }

    final removableIds = _selectedCategoryIds
        .where(
          (id) => !controller.categoriesController.categoryList.any(
            (category) => category.id == id && category.isDefault,
          ),
        )
        .toList();

    if (removableIds.isEmpty) {
      _selectedCategoryIds.clear();
      _isSelectionMode = false;
      Get.snackbar(
        'Protected',
        'Default categories cannot be deleted.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await controller.categoriesController.deleteCategories(removableIds);
    _selectedCategoryIds.clear();
    _isSelectionMode = false;
  }

  void _showDeleteOption(
    BuildContext context,
    String categoryId,
    bool isDefault,
  ) {
    if (isDefault) {
      Get.snackbar(
        'Protected',
        'This default category cannot be deleted.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final linkedTransactions = controller.categoriesController
            .getCategoryCount(categoryId);

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          backgroundColor: Colors.transparent,
          child: Container(
            width: 420,
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delete Category',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  linkedTransactions > 0
                      ? 'This will permanently delete this category and all related transaction data from the Transactions screen.\n\nDo you want to continue?'
                      : 'This will permanently delete this category.\n\nDo you want to continue?',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 42,
                      child: TextButton(
                        onPressed: () async {
                          Get.back();
                          await controller.categoriesController
                              .deleteCategories([categoryId]);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFFE53935),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditLimitDialog(
    BuildContext context,
    String categoryName,
    double currentLimit,
  ) {
    final amountController = TextEditingController(
      text: currentLimit > 0 ? currentLimit.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set Limit for $categoryName',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  onTap: () {
                    if (amountController.text == '0') {
                      amountController.clear();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Monthly Limit',
                    hintText: 'e.g., 20000',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark ? Colors.white30 : Colors.black26,
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF4CAF50)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          final limit =
                              double.tryParse(amountController.text.trim()) ??
                              currentLimit;

                          if (controller.customTotalBudget.value != null &&
                              controller.willExceedMonthlyBudget(
                                categoryName,
                                limit,
                              )) {
                            final parentContext = Get.context;
                            Get.back();
                            if (parentContext != null &&
                                parentContext.mounted) {
                              _showMonthlyLimitExceededDialog(
                                context: parentContext,
                                categoryName: categoryName,
                                proposedLimit: limit,
                              );
                            }
                            return;
                          }

                          controller.setCategoryLimit(categoryName, limit);
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                        ),
                        child: const Text(
                          'Update',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditTotalBudgetDialog(
    BuildContext context,
    double currentTotalLimit,
  ) {
    final amountController = TextEditingController(
      text: currentTotalLimit > 0 ? currentTotalLimit.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set Total Monthly Budget',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  onTap: () {
                    if (amountController.text == '0') {
                      amountController.clear();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Total Limit',
                    hintText: 'e.g., 60000',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark ? Colors.white30 : Colors.black26,
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF4CAF50)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          final totalLimit =
                              double.tryParse(amountController.text.trim()) ??
                              currentTotalLimit;

                          controller.setTotalBudget(totalLimit);
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                        ),
                        child: const Text(
                          'Update',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Theme colors
    final backgroundColor = isDark
        ? const Color(0xFF080808)
        : const Color(0xFFF6F7F2);

    final cardColor = isDark
        ? const Color(0xFF1A1A1A)
        : const Color(0xFFF2F6ED);

    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1E1E1E);

    final secondaryTextColor = isDark
        ? Colors.white70
        : const Color(0xFF555B51);

    final progressBackgroundColor = isDark
        ? const Color(0xFF303030)
        : const Color(0xFFD3E7CB);

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: Text(
          'Live Budget',
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            tooltip: 'Budget cycle settings',
            onPressed: () => _showBudgetCycleBottomSheet(context),
            icon: Icon(
              Icons.calendar_month_rounded,
              color: primaryTextColor,
              size: 24,
            ),
          ),
          IconButton(
            tooltip: 'Budget history',
            onPressed: () => Get.to(() => const BudgetHistoryView()),
            icon: Icon(
              Icons.history_rounded,
              color: primaryTextColor,
              size: 24,
            ),
          ),
        ],
      ),

      body: Obx(() {
        final budgets = controller.budgetList;

        if (budgets.isEmpty) {
          return Center(
            child: Text(
              'No categories found.',
              style: TextStyle(color: secondaryTextColor),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================================
              // TOTAL BUDGET CARD
              // ============================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Monthly Budget Spent',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: secondaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              // Which cycle these figures belong to.
                              Text(
                                '${controller.cycleLabel}  ·  '
                                '${controller.daysLeftInCycle} days left',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            size: 18,
                            color: isDark ? Colors.white70 : Colors.grey,
                          ),
                          onPressed: () => _showEditTotalBudgetDialog(
                            context,
                            controller.totalAllocated,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'RS ${controller.totalSpent.toStringAsFixed(0)} / RS ${controller.totalAllocated.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: controller.isOverBudget
                            ? const Color(0xFFE53935)
                            : const Color(0xFF2B82FB),
                      ),
                    ),

                    const SizedBox(height: 12),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: controller.spendProgress,
                        backgroundColor: progressBackgroundColor,
                        color: controller.isOverBudget
                            ? const Color(0xFFE53935)
                            : const Color(0xFF4CAF50),
                        minHeight: 8,
                      ),
                    ),

                    // Step 27 - say it plainly when the budget is passed.
                    if (controller.isOverBudget) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935)
                              .withOpacity(isDark ? 0.18 : 0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              size: 18,
                              color: Color(0xFFE53935),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Budget Exceeded',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFE53935),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Rs ${controller.overspentAmount.toStringAsFixed(0)} over budget',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ============================================================
              // CATEGORY TITLE
              // ============================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Category Budgets',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  Row(
                    children: [
                      if (_isSelectionMode)
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE53935), Color(0xFFC62828)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.22),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: IconButton(
                            tooltip: 'Delete selected categories',
                            onPressed: _deleteSelectedCategories,
                            icon: const Icon(Icons.delete_outline_rounded),
                            color: Colors.white,
                          ),
                        )
                      else
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF4CAF50,
                                ).withOpacity(0.22),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: IconButton(
                            tooltip: 'Add category budget',
                            onPressed: () => _showAddCategoryDialog(context),
                            icon: const Icon(Icons.add_rounded),
                            color: Colors.white,
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (_isSelectionMode)
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2A2A2A)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.white12 : Colors.black12,
                            ),
                          ),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategoryIds.clear();
                                _isSelectionMode = false;
                              });
                            },
                            child: const Text('Done'),
                          ),
                        )
                      else
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2A2A2A)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.white12 : Colors.black12,
                            ),
                          ),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _isSelectionMode = true;
                              });
                            },
                            child: const Text('Select'),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ============================================================
              // CATEGORY BUDGETS
              // ============================================================
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: budgets.length,
                itemBuilder: (context, index) {
                  final item = budgets[index];
                  final category = controller.categoriesController.categoryList
                      .firstWhere(
                        (element) =>
                            element.name.trim().toLowerCase() ==
                            item.categoryName.trim().toLowerCase(),
                        orElse: () =>
                            controller.categoriesController.categoryList.first,
                      );
                  final isProtected = category.isDefault;
                  final isSelected = _selectedCategoryIds.contains(category.id);

                  final progress = item.allocatedAmount == 0
                      ? 0.0
                      : (item.spentAmount / item.allocatedAmount).clamp(
                          0.0,
                          1.0,
                        );

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  if (_isSelectionMode && !isProtected)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Checkbox(
                                        value: isSelected,
                                        onChanged: (_) {
                                          setState(() {
                                            if (isSelected) {
                                              _selectedCategoryIds.remove(
                                                category.id,
                                              );
                                            } else {
                                              _selectedCategoryIds.add(
                                                category.id,
                                              );
                                            }
                                            if (_selectedCategoryIds.isEmpty) {
                                              _isSelectionMode = false;
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  Expanded(
                                    child: Text(
                                      item.categoryName,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: primaryTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_isSelectionMode)
                              const SizedBox.shrink()
                            else if (isProtected)
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: isDark ? Colors.white70 : Colors.grey,
                                ),
                                onPressed: () => _showEditLimitDialog(
                                  context,
                                  item.categoryName,
                                  item.allocatedAmount,
                                ),
                              )
                            else
                              PopupMenuButton<String>(
                                icon: Icon(
                                  Icons.more_vert_rounded,
                                  color: isDark ? Colors.white70 : Colors.grey,
                                ),
                                color: isDark
                                    ? const Color(0xFF1F1F1F)
                                    : Colors.white,
                                elevation: 12,
                                shadowColor: Colors.black.withOpacity(0.12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  side: BorderSide(
                                    color: isDark
                                        ? Colors.white12
                                        : Colors.black12,
                                  ),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 180,
                                ),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditLimitDialog(
                                      context,
                                      item.categoryName,
                                      item.allocatedAmount,
                                    );
                                  } else if (value == 'delete') {
                                    _showDeleteOption(
                                      context,
                                      category.id,
                                      false,
                                    );
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.edit_outlined,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Edit limit',
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.delete_outline_rounded,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: progressBackgroundColor,
                            color: item.allocatedAmount > 0 &&
                                    item.spentAmount > item.allocatedAmount
                                ? const Color(0xFFE53935)
                                : (progress > 0.9
                                    ? const Color(0xFFFF9800)
                                    : const Color(0xFF2B82FB)),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Spent: RS ${item.spentAmount.toStringAsFixed(0)} / RS ${item.allocatedAmount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ),
                            if (item.allocatedAmount > 0 &&
                                item.spentAmount > item.allocatedAmount)
                              Text(
                                'Over by RS ${(item.spentAmount - item.allocatedAmount).toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFE53935),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}

// =====================================================================
// BUDGET HISTORY SCREEN
// Kept in this same file so no new file has to be created.
// =====================================================================

const Color _histGreen = Color(0xFF4CAF50);
const Color _histRed = Color(0xFFE53935);

const List<String> _histMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _histDate(DateTime d) => '${d.day} ${_histMonths[d.month - 1]}';

String _histDateFull(DateTime d) =>
    '${d.day} ${_histMonths[d.month - 1]} ${d.year}';

String _histMoney(double value) {
  final digits = value.abs().round().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }

  return buffer.toString();
}

class BudgetHistoryView extends GetView<BudgetController> {
  const BudgetHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final background = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF7F9F8);
    final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryText = isDark ? Colors.white : const Color(0xFF1F2937);
    final secondaryText = isDark ? Colors.white70 : const Color(0xFF555B51);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryText),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Budget History',
          style: TextStyle(color: primaryText, fontWeight: FontWeight.bold),
        ),
        actions: [
          Obx(() {
            if (controller.cycleHistory.isEmpty) {
              return const SizedBox.shrink();
            }

            return IconButton(
              tooltip: 'Clear history',
              icon: Icon(Icons.delete_sweep_outlined, color: secondaryText),
              onPressed: () =>
                  _confirmClearAll(card, primaryText, secondaryText),
            );
          }),
        ],
      ),
      body: Obx(() {
        final history = controller.cycleHistory;

        if (history.isEmpty) {
          return _HistEmpty(
            primaryText: primaryText,
            secondaryText: secondaryText,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          physics: const BouncingScrollPhysics(),
          itemCount: history.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _HistSummary(history: history);

            final cycle = history[index - 1];

            return _HistCycleCard(
              cycle: cycle,
              card: card,
              isDark: isDark,
              primaryText: primaryText,
              secondaryText: secondaryText,
              onDelete: () => controller.deleteHistoryEntry(cycle.id),
            );
          },
        );
      }),
    );
  }

  void _confirmClearAll(Color card, Color primaryText, Color secondaryText) {
    Get.dialog(
      AlertDialog(
        backgroundColor: card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Clear all history?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: primaryText,
          ),
        ),
        content: Text(
          'Every past budget cycle will be removed. Your current budget, '
          'categories and transactions are not affected.',
          style: TextStyle(fontSize: 14, height: 1.5, color: secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: secondaryText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _histRed,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () {
              Get.back();
              controller.clearHistory();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _HistSummary extends StatelessWidget {
  const _HistSummary({required this.history});

  final List<BudgetCycleHistory> history;

  @override
  Widget build(BuildContext context) {
    final savedCount = history.where((c) => c.isSaved).length;
    final overCount = history.length - savedCount;
    final net = history.fold<double>(0, (sum, c) => sum + c.difference);
    final positive = net >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: positive
              ? const [Color(0xFF34A853), Color(0xFF1B5E20)]
              : const [Color(0xFFEF5350), Color(0xFFB71C1C)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            positive
                ? 'Saved across all cycles'
                : 'Overspent across all cycles',
            style: const TextStyle(fontSize: 12.5, color: Colors.white70),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'RS ${_histMoney(net)}',
              maxLines: 1,
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HistPill(
                icon: Icons.check_circle_rounded,
                text: '$savedCount within budget',
              ),
              _HistPill(
                icon: Icons.warning_amber_rounded,
                text: '$overCount over budget',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistPill extends StatelessWidget {
  const _HistPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistCycleCard extends StatefulWidget {
  const _HistCycleCard({
    required this.cycle,
    required this.card,
    required this.isDark,
    required this.primaryText,
    required this.secondaryText,
    required this.onDelete,
  });

  final BudgetCycleHistory cycle;
  final Color card;
  final bool isDark;
  final Color primaryText;
  final Color secondaryText;
  final VoidCallback onDelete;

  @override
  State<_HistCycleCard> createState() => _HistCycleCardState();
}

class _HistCycleCardState extends State<_HistCycleCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final cycle = widget.cycle;
    final saved = cycle.isSaved;
    final accent = saved ? _histGreen : _histRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.isDark
              ? Colors.white10
              : Colors.black.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_histDate(cycle.startDate)} - '
                      '${_histDateFull(cycle.endDate)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: widget.primaryText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          cycle.wasAutomatic
                              ? Icons.autorenew_rounded
                              : Icons.touch_app_outlined,
                          size: 13,
                          color: widget.secondaryText,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          cycle.wasAutomatic
                              ? 'Automatic reset'
                              : 'Manual reset',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: widget.secondaryText,
                          ),
                        ),
                        Text(
                          '  ·  ${cycle.lengthInDays} days',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: widget.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: accent.withOpacity(widget.isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  saved ? 'Saved' : 'Over',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _HistFigure(
                label: 'Limit',
                value: 'RS ${_histMoney(cycle.totalLimit)}',
                colour: widget.primaryText,
                secondary: widget.secondaryText,
              ),
              _HistFigure(
                label: 'Spent',
                value: 'RS ${_histMoney(cycle.totalSpent)}',
                colour: widget.primaryText,
                secondary: widget.secondaryText,
              ),
              _HistFigure(
                label: saved ? 'Saved' : 'Over by',
                value: 'RS ${_histMoney(cycle.difference)}',
                colour: accent,
                secondary: widget.secondaryText,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: cycle.progress,
              minHeight: 8,
              backgroundColor: widget.isDark
                  ? const Color(0xFF303030)
                  : const Color(0xFFD3E7CB),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${cycle.progressPercent}% of the budget used',
            style: TextStyle(fontSize: 11.5, color: widget.secondaryText),
          ),
          if (cycle.categories.isNotEmpty) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: () => setState(() => expanded = !expanded),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Text(
                      expanded
                          ? 'Hide categories'
                          : 'Show ${cycle.categories.length} categories',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: _histGreen,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: _histGreen,
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: widget.onDelete,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: widget.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (expanded) ...[
              const SizedBox(height: 4),
              ...cycle.categories.map(
                (entry) => _HistCategoryRow(
                  entry: entry,
                  isDark: widget.isDark,
                  primaryText: widget.primaryText,
                  secondaryText: widget.secondaryText,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _HistFigure extends StatelessWidget {
  const _HistFigure({
    required this.label,
    required this.value,
    required this.colour,
    required this.secondary,
  });

  final String label;
  final String value;
  final Color colour;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: secondary)),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: colour,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistCategoryRow extends StatelessWidget {
  const _HistCategoryRow({
    required this.entry,
    required this.isDark,
    required this.primaryText,
    required this.secondaryText,
  });

  final CategoryCycleEntry entry;
  final bool isDark;
  final Color primaryText;
  final Color secondaryText;

  @override
  Widget build(BuildContext context) {
    final accent = entry.isOver ? _histRed : _histGreen;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'RS ${_histMoney(entry.spent)} / ${_histMoney(entry.limit)}',
                style: TextStyle(fontSize: 12, color: secondaryText),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: entry.progress,
              minHeight: 5,
              backgroundColor: isDark
                  ? const Color(0xFF303030)
                  : const Color(0xFFE6EFE2),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistEmpty extends StatelessWidget {
  const _HistEmpty({required this.primaryText, required this.secondaryText});

  final Color primaryText;
  final Color secondaryText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: _histGreen.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 44,
                color: _histGreen,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'No history yet',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Once your budget resets, that finished month is saved here '
              'with its limit, what you spent, and what was left over.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.6, color: secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}