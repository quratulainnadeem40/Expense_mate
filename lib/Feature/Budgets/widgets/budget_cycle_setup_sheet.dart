import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/budget_controller.dart';

Future<void> showBudgetCycleSetupSheet(
  BuildContext context, {
  required BudgetController controller,
  bool canSkip = false,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  var selectedDay = controller.monthStartDay.value;
  const green = Color(0xFF2EA44F);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: canSkip,
    enableDrag: canSkip,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setSheetState) {
        return Container(
          margin: const EdgeInsets.only(top: 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141414) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: green.withValues(alpha: isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: green,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Adjust Month Start Date'.tr,
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E1E1E),
                          ),
                        ),
                      ),
                      if (!canSkip)
                        IconButton(
                          tooltip: 'Close'.tr,
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: Icon(
                            Icons.close_rounded,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Choose the day your monthly budget cycle starts.'.tr,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.5,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Month Start'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(31, (index) {
                      final day = index + 1;
                      final isSelected = selectedDay == day;

                      return SizedBox(
                        width: 40,
                        height: 40,
                        child: Material(
                          color: isSelected
                              ? green
                              : (isDark
                                    ? const Color(0xFF242424)
                                    : const Color(0xFFF1F4F0)),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => setSheetState(() => selectedDay = day),
                            child: Center(
                              child: Text(
                                '$day',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                            ? Colors.white70
                                            : Colors.black87),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: green.withValues(alpha: isDark ? 0.12 : 0.07),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: green,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            'You can edit it from your profile screen.'.tr,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF4B5563),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      if (canSkip)
                        TextButton(
                          onPressed: () {
                            controller.markCycleConfigured();
                            Navigator.pop(sheetContext);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: isDark
                                ? Colors.white70
                                : Colors.black54,
                          ),
                          child: Text('Skip'.tr),
                        ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () {
                          controller.setMonthStartDay(selectedDay);
                          Navigator.pop(sheetContext);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text('Save'.tr),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
