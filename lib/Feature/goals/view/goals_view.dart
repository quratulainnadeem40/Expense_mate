import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:expense_mate/Feature/goals/controller/goals_controller.dart';
import 'package:expense_mate/Feature/goals/model/goal_icon.dart';
import 'package:expense_mate/Feature/goals/model/goals_model.dart';
import 'package:expense_mate/Feature/goals/widgets/goals_card.dart';

class GoalsView extends GetView<GoalsController> {
  const GoalsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        // No back arrow - the only way out is the cross on the right.
        automaticallyImplyLeading: false,
        title: const Text(
          'Savings Goals',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close_rounded, size: 26),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kGoalGreen,
        foregroundColor: Colors.white,
        onPressed: () => _openGoalSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Goal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.goals.isEmpty)
            return _EmptyState(onCreate: () => _openGoalSheet(context));

          final active = controller.activeGoals;
          final completed = controller.completedGoals;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            physics: const BouncingScrollPhysics(),
            children: [
              _SummaryCard(
                saved: controller.totalSaved,
                target: controller.totalTarget,
                progress: controller.overallProgress,
                activeCount: active.length,
                completedCount: completed.length,
              ),
              const SizedBox(height: 22),

              if (active.isNotEmpty) ...[
                _SectionLabel(text: 'In progress', count: active.length),
                const SizedBox(height: 10),
                ...active.map(
                  (goal) => GoalsCard(
                    goal: goal,
                    onAddMoney: () => _openMoneySheet(context, goal, true),
                    onWithdraw: () => _openMoneySheet(context, goal, false),
                    onEdit: () => _openGoalSheet(context, goal: goal),
                    onDelete: () => _confirmDelete(context, goal),
                  ),
                ),
              ],

              if (completed.isNotEmpty) ...[
                const SizedBox(height: 12),
                _SectionLabel(text: 'Completed', count: completed.length),
                const SizedBox(height: 10),
                ...completed.map(
                  (goal) => GoalsCard(
                    goal: goal,
                    onAddMoney: () => _openMoneySheet(context, goal, true),
                    onWithdraw: () => _openMoneySheet(context, goal, false),
                    onEdit: () => _openGoalSheet(context, goal: goal),
                    onDelete: () => _confirmDelete(context, goal),
                  ),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }

  // =================================================================
  // CREATE / EDIT SHEET
  // =================================================================
  void _openGoalSheet(BuildContext context, {GoalModel? goal}) {
    if (goal == null) {
      controller.prepareForCreate();
    } else {
      controller.prepareForEdit(goal);
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetContext).size.height * 0.92,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 10,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SheetHandle(),
                const SizedBox(height: 6),

                // Title on the left, close on the right.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            goal == null ? 'New goal' : 'Edit goal',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'What are you saving for?',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      icon: Icon(
                        Icons.close_rounded,
                        size: 24,
                        color: theme.hintColor,
                      ),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // -------------------------------------------- icon picker
                Row(
                  children: [
                    const Expanded(child: _Label(text: 'Pick an icon')),
                    TextButton.icon(
                      onPressed: () =>
                          _showGoalIconPicker(context, isDark: isDark),
                      icon: const Icon(Icons.search_rounded, size: 18),
                      label: const Text('Browse icons'),
                      style: TextButton.styleFrom(
                        foregroundColor: kGoalGreen,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: Obx(() {
                    final current = controller.selectedIconKey.value;

                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: GoalsController.quickIconKeys.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final iconKey = GoalsController.quickIconKeys[i];
                        final option = goalIconFor(iconKey);
                        final selected = current == iconKey;
                        return GestureDetector(
                          onTap: () =>
                              controller.selectedIconKey.value = iconKey,
                          child: Container(
                            width: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected
                                  ? kGoalGreen.withOpacity(0.15)
                                  : (isDark
                                        ? Colors.white10
                                        : Colors.black.withOpacity(0.04)),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected
                                    ? kGoalGreen
                                    : Colors.transparent,
                                width: 1.6,
                              ),
                            ),
                            child: Icon(
                              option.icon,
                              size: 23,
                              color: selected
                                  ? kGoalGreen
                                  : theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),

                const SizedBox(height: 18),

                _Label(text: 'Goal name'),
                const SizedBox(height: 8),
                Obx(() {
                  final hint = controller.nameHint;

                  return _Field(
                    controller: controller.titleController,
                    hint: hint,
                    textCapitalization: TextCapitalization.sentences,
                  );
                }),

                const SizedBox(height: 16),

                _Label(text: 'Target amount'),
                const SizedBox(height: 8),
                _Field(
                  controller: controller.targetController,
                  hint: '0',
                  prefix: 'Rs. ',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),

                const SizedBox(height: 10),

                // Quick picks. Tapping sets the amount, and tapping a
                // second one adds to it, so 50k + 10k reaches 60k without
                // any typing.
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...[5000, 10000, 25000, 50000, 100000].map((amount) {
                      return GestureDetector(
                        onTap: () => _bumpTargetAmount(amount),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white10
                                : Colors.black.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '+ ${_shortAmount(amount)}',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      );
                    }),
                    GestureDetector(
                      onTap: () => controller.targetController.clear(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white10
                              : Colors.black.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: theme.hintColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _Label(text: 'Target date'),
                const SizedBox(height: 8),
                Obx(() {
                  final date = controller.selectedDate.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _DateChip(
                            label: '3 months',
                            onTap: () => controller.setDateInMonths(3),
                          ),
                          _DateChip(
                            label: '6 months',
                            onTap: () => controller.setDateInMonths(6),
                          ),
                          _DateChip(
                            label: '1 year',
                            onTap: () => controller.setDateInMonths(12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => controller.pickDate(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white10
                                : Colors.black.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: date == null
                                  ? Colors.transparent
                                  : kGoalGreen.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 18,
                                color: date == null
                                    ? theme.hintColor
                                    : kGoalGreen,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                date == null
                                    ? 'Choose a date'
                                    : '${date.day}/${date.month}/${date.year}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: date == null
                                      ? FontWeight.normal
                                      : FontWeight.w600,
                                  color: date == null
                                      ? theme.hintColor
                                      : theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 16),

                _Label(text: 'Already saved (optional)'),
                const SizedBox(height: 8),
                _Field(
                  controller: controller.savedController,
                  hint: '0',
                  prefix: 'Rs. ',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: controller.saveGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGoalGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      goal == null ? 'Create goal' : 'Save changes',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
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
  }

  /// Adds [amount] to whatever is already typed in the target field.
  ///
  /// Adding rather than replacing means a few taps can build any figure,
  /// instead of the chips only offering five fixed amounts.
  void _bumpTargetAmount(int amount) {
    final current =
        double.tryParse(controller.targetController.text.trim()) ?? 0;

    final next = (current + amount).round();

    controller.targetController.text = next.toString();
    controller.targetController.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.targetController.text.length),
    );
  }

  /// 5000 -> 5k, 100000 -> 1 lakh.
  String _shortAmount(int amount) {
    if (amount >= 100000) {
      final lakhs = amount / 100000;
      return lakhs == lakhs.roundToDouble()
          ? '${lakhs.toStringAsFixed(0)} lakh'
          : '${lakhs.toStringAsFixed(1)} lakh';
    }

    if (amount >= 1000) return '${amount ~/ 1000}k';

    return '$amount';
  }

  // =================================================================
  // ADD / WITHDRAW MONEY SHEET
  // =================================================================
  void _openMoneySheet(BuildContext context, GoalModel goal, bool isDeposit) {
    controller.amountController.clear();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetContext).size.height * 0.92,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 10,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SheetHandle(),
                const SizedBox(height: 6),

                // Same close affordance as the new goal sheet.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            isDeposit ? 'Add money' : 'Withdraw money',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                goalIconFor(goal.iconKey).icon,
                                size: 16,
                                color: kGoalGreen,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  isDeposit
                                      ? '${goal.title} — Rs. '
                                            '${formatMoney(goal.remaining)} still needed'
                                      : '${goal.title} — Rs. '
                                            '${formatMoney(goal.savedAmount)} available',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.hintColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      icon: Icon(
                        Icons.close_rounded,
                        size: 24,
                        color: theme.hintColor,
                      ),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _Field(
                  controller: controller.amountController,
                  hint: '0',
                  prefix: 'Rs. ',
                  autofocus: true,
                  fontSize: 22,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),

                const SizedBox(height: 14),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [500, 1000, 5000].map((amount) {
                    return GestureDetector(
                      onTap: () {
                        controller.amountController.text = amount.toString();
                        controller.amountController.selection =
                            TextSelection.fromPosition(
                              TextPosition(
                                offset: controller.amountController.text.length,
                              ),
                            );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white10
                              : Colors.black.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '+ $amount',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => isDeposit
                        ? controller.deposit(goal.id)
                        : controller.withdraw(goal.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDeposit
                          ? kGoalGreen
                          : const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      isDeposit ? 'Add to goal' : 'Withdraw',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
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
  }

  void _showGoalIconPicker(BuildContext context, {required bool isDark}) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (pickerContext) => _GoalIconPickerSheet(
        isDark: isDark,
        selectedKey: controller.selectedIconKey.value,
        onSelect: (iconKey) {
          controller.selectedIconKey.value = iconKey;
          Navigator.pop(pickerContext);
        },
      ),
    );
  }

  // =================================================================
  // DELETE CONFIRMATION
  // =================================================================
  void _confirmDelete(BuildContext context, GoalModel goal) {
    final theme = Theme.of(context);

    Get.dialog(
      AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Delete this goal?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        content: Text(
          '"${goal.title}" and its saved amount of Rs. '
          '${formatMoney(goal.savedAmount)} will be removed. '
          'This cannot be undone.',
          style: TextStyle(fontSize: 14, height: 1.5, color: theme.hintColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: theme.hintColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () {
              Get.back();
              controller.deleteGoal(goal.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// SUMMARY CARD
// =====================================================================
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.saved,
    required this.target,
    required this.progress,
    required this.activeCount,
    required this.completedCount,
  });

  final double saved;
  final double target;
  final double progress;
  final int activeCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF34A853), Color(0xFF1B5E20)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total saved',
            style: TextStyle(fontSize: 12.5, color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  'Rs. ${formatMoney(saved)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'of Rs. ${formatMoney(target)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(
                icon: Icons.trending_up_rounded,
                text: '$activeCount in progress',
              ),
              _Pill(
                icon: Icons.check_circle_rounded,
                text: '$completedCount completed',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.text});

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

// =====================================================================
// SMALL SHARED PIECES
// =====================================================================
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.count});

  final String text;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: theme.hintColor,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.hintColor.withOpacity(0.14),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: theme.hintColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _GoalIconPickerSheet extends StatefulWidget {
  const _GoalIconPickerSheet({
    required this.isDark,
    required this.selectedKey,
    required this.onSelect,
  });

  final bool isDark;
  final String selectedKey;
  final ValueChanged<String> onSelect;

  @override
  State<_GoalIconPickerSheet> createState() => _GoalIconPickerSheetState();
}

class _GoalIconPickerSheetState extends State<_GoalIconPickerSheet> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = theme.cardColor;
    final availableHeight =
        MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    final sheetHeight = (availableHeight * 0.78).clamp(280.0, 680.0);
    final query = _searchController.text.trim();
    final icons = goalIconOptions
        .where((option) => option.matches(query))
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: sheetHeight,
        decoration: BoxDecoration(
          color: background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: widget.isDark ? 0.35 : 0.16,
              ),
              blurRadius: 28,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            const _SheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 16, 16),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: kGoalGreen.withValues(
                        alpha: widget.isDark ? 0.2 : 0.1,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.widgets_rounded,
                      color: kGoalGreen,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose an icon',
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${goalIconOptions.length} icons · Search by name',
                          style: TextStyle(
                            color: theme.hintColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close icon picker',
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: theme.hintColor),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search home, travel, savings...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  filled: true,
                  fillColor: widget.isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.035),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.35),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: kGoalGreen, width: 1.5),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Row(
                children: [
                  Text(
                    query.isEmpty ? 'ALL ICONS' : 'SEARCH RESULTS',
                    style: TextStyle(
                      color: theme.hintColor,
                      fontSize: 11,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${icons.length} found',
                    style: TextStyle(
                      color: theme.hintColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: icons.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 42,
                            color: theme.disabledColor,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No matching icons',
                            style: TextStyle(
                              color: theme.hintColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 2, 16, 20),
                      itemCount: icons.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 100,
                            mainAxisExtent: 88,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemBuilder: (context, index) {
                        final option = icons[index];
                        final selected = option.key == widget.selectedKey;

                        return Material(
                          color: selected
                              ? kGoalGreen.withValues(
                                  alpha: widget.isDark ? 0.22 : 0.1,
                                )
                              : widget.isDark
                              ? Colors.white.withValues(alpha: 0.045)
                              : Colors.black.withValues(alpha: 0.025),
                          borderRadius: BorderRadius.circular(17),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(17),
                            onTap: () => widget.onSelect(option.key),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(17),
                                border: Border.all(
                                  color: selected
                                      ? kGoalGreen
                                      : theme.dividerColor.withValues(
                                          alpha: 0.28,
                                        ),
                                  width: selected ? 1.6 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    option.icon,
                                    size: 25,
                                    color: selected
                                        ? kGoalGreen
                                        : theme.textTheme.bodyLarge?.color,
                                  ),
                                  const SizedBox(height: 7),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Text(
                                      option.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: selected
                                            ? kGoalGreen
                                            : theme.hintColor,
                                        fontSize: 10.5,
                                        fontWeight: selected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
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
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).hintColor,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    this.prefix,
    this.keyboardType,
    this.autofocus = false,
    this.fontSize = 15,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String hint;
  final String? prefix;
  final TextInputType? keyboardType;
  final bool autofocus;
  final double fontSize;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      autofocus: autofocus,
      textCapitalization: textCapitalization,
      cursorColor: kGoalGreen,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: theme.textTheme.bodyLarge?.color,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefix,
        prefixStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: theme.hintColor,
        ),
        hintStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.normal,
          color: theme.hintColor.withOpacity(0.6),
        ),
        filled: true,
        fillColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kGoalGreen, width: 1.5),
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).hintColor.withOpacity(0.35),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                color: kGoalGreen.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.savings_outlined,
                size: 44,
                color: kGoalGreen,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'No goals yet',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Saving for a phone, a trip, or an emergency fund? '
              'Create a goal and add money to it whenever you can.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create your first goal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGoalGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
