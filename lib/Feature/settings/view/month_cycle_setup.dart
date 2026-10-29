import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../Core/constants/app_keys.dart';
import '../../Budgets/controller/budget_controller.dart';

const Color _green = Color(0xFF2EA44F);

/// Asked once, right after the guided tour.
///
/// The day chosen here drives both the budget and the category totals,
/// so the two start out in step. Either can be changed later from
/// Profile, where they are managed separately.
class MonthCycleSetup {
  MonthCycleSetup._();

  static const String _seenKey = 'month_cycle_setup_seen';

  static bool get hasSeen {
    if (!Hive.isBoxOpen(AppKeys.settingsBox)) return true;
    return Hive.box(AppKeys.settingsBox)
        .get(_seenKey, defaultValue: false) as bool;
  }

  static Future<void> _markSeen() async {
    if (!Hive.isBoxOpen(AppKeys.settingsBox)) return;
    await Hive.box(AppKeys.settingsBox).put(_seenKey, true);
  }

  /// Shows the sheet unless it has already been answered.
  static Future<void> showIfNeeded(BuildContext context) async {
    if (hasSeen) return;
    if (!context.mounted) return;

    await _show(context);
  }

  static Future<void> _show(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark ? Colors.white : const Color(0xFF1C1C1C);
    final secondaryText =
        isDark ? Colors.white70 : const Color(0xFF6B7280);

    final day = 1.obs;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: isDark ? const Color(0xFF151515) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _green.withOpacity(isDark ? 0.18 : 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.event_repeat_rounded,
                      size: 30,
                      color: _green,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  'When does your month start?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: primaryText,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Most people pick the day their salary arrives. Your '
                  'budget and category totals start fresh on this date '
                  'every month.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: secondaryText,
                  ),
                ),

                const SizedBox(height: 18),

                Obx(() {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(31, (i) {
                      final value = i + 1;
                      final active = value == day.value;

                      return GestureDetector(
                        onTap: () => day.value = value,
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: active
                                ? _green
                                : (isDark
                                    ? const Color(0xFF242424)
                                    : const Color(0xFFF1F4F0)),
                            borderRadius: BorderRadius.circular(11),
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
                      );
                    }),
                  );
                }),

                const SizedBox(height: 12),

                Obx(() {
                  if (day.value <= 28) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'February is shorter, so those months will start '
                      'on their last day instead.',
                      style: TextStyle(fontSize: 11.5, color: secondaryText),
                    ),
                  );
                }),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _apply(day.value);
                      Navigator.pop(sheetContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Center(
                  child: Text(
                    'You can change this later in Profile',
                    style: TextStyle(fontSize: 11.5, color: secondaryText),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Writes the day to both cycles.
  static Future<void> _apply(int day) async {
    if (Hive.isBoxOpen(AppKeys.budgetBox)) {
      final box = Hive.box(AppKeys.budgetBox);

      await box.put(AppKeys.categoryCycleStartDayKey, day);
      await box.put(AppKeys.categoryCycleAutomaticResetKey, true);
    }

    // Through the controller rather than straight into the box, so the
    // budget screen and the reset reminder both pick it up at once.
    if (Get.isRegistered<BudgetController>()) {
      Get.find<BudgetController>().setMonthStartDay(day);
    } else if (Hive.isBoxOpen(AppKeys.budgetBox)) {
      await Hive.box(AppKeys.budgetBox)
          .put(AppKeys.budgetMonthStartDayKey, day);
    }

    await _markSeen();
  }
}
