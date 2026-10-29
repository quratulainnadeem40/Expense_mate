import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../settings/controller/settings_controller.dart';

import '../model/goal_icon.dart';
import '../model/goals_model.dart';

const Color kGoalGreen = Color(0xFF2EA44F);

String formatMoney(double value) =>
    NumberFormat('#,##0', 'en_US').format(value);

/// Whatever currency the user picked in Settings.
///
/// Goals used to print "Rs." everywhere, so switching the app to USD
/// left this one screen still showing rupees.
String get goalCurrency {
  if (!Get.isRegistered<SettingsController>()) return 'Rs.';
  return Get.find<SettingsController>().selectedCurrency.value;
}

/// An amount with the current symbol in front.
String goalMoney(double value) =>
    '$goalCurrency ${formatMoney(value)}';

/// "8 months left" reads better than "243 days left".
String _timeLeft(int days) {
  if (days >= 60) return '${(days / 30).round()} months left';
  if (days >= 14) return '${(days / 7).round()} weeks left';
  if (days == 1) return '1 day left';
  return '$days days left';
}

class GoalsCard extends StatelessWidget {
  const GoalsCard({
    super.key,
    required this.goal,
    required this.onAddMoney,
    required this.onEdit,
    required this.onWithdraw,
    required this.onDelete,
  });

  final GoalModel goal;
  final VoidCallback onAddMoney;
  final VoidCallback onEdit;
  final VoidCallback onWithdraw;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final done = goal.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: done
              ? kGoalGreen.withOpacity(0.45)
              : (isDark ? Colors.white10 : Colors.black.withOpacity(0.06)),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------------------------------------------- header
          Row(
            children: [
              // The ring turns progress into something you can read at a
              // glance, instead of only from the bar further down.
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        value: goal.progress,
                        strokeWidth: 4,
                        strokeCap: StrokeCap.round,
                        backgroundColor: isDark
                            ? Colors.white12
                            : Colors.black.withOpacity(0.07),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          kGoalGreen,
                        ),
                      ),
                    ),
                    GoalIconBadge(
                      iconKey: goal.iconKey,
                      size: 40,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 3),

                    // A plain line reads easier than a chip here, and it
                    // leaves the width for the title.
                    Text(
                      done
                          ? 'Completed'
                          : (goal.daysLeft > 0
                              ? '${_timeLeft(goal.daysLeft)} · '
                                  '${goal.progressPercent}% done'
                              : 'Target date has passed'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: done ? FontWeight.w600 : FontWeight.w400,
                        color: done ? kGoalGreen : theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, color: theme.hintColor),
                color: theme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'withdraw') onWithdraw();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  _menuItem('edit', Icons.edit_outlined, 'Edit goal', theme),
                  _menuItem(
                    'withdraw',
                    Icons.south_west_rounded,
                    'Withdraw money',
                    theme,
                  ),
                  _menuItem(
                    'delete',
                    Icons.delete_outline_rounded,
                    'Delete goal',
                    theme,
                    danger: true,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ---------------------------------------------------- amounts
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  goalMoney(goal.savedAmount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kGoalGreen,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    'of ${goalMoney(goal.targetAmount)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: theme.hintColor),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${goal.progressPercent}%',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // A gradient fill rather than a flat block; the bar is the
          // biggest piece of colour on the card.
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 9,
              color: isDark
                  ? Colors.white12
                  : Colors.black.withOpacity(0.07),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: goal.progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4CC66A), Color(0xFF1F7A37)],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ---------------------------------------------------- footer
          if (done)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: kGoalGreen.withOpacity(isDark ? 0.16 : 0.09),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 17,
                    color: kGoalGreen,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      '${goalMoney(goal.savedAmount)} saved — goal reached',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: kGoalGreen,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${goalMoney(goal.remaining)} to go',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        goal.daysLeft > 0
                            ? 'Save about $goalCurrency '
                                  '${formatMoney(goal.monthlyTarget)} a month'
                            : 'Target date has passed',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: theme.hintColor),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: onAddMoney,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add money'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGoalGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
    String value,
    IconData icon,
    String label,
    ThemeData theme, {
    bool danger = false,
  }) {
    final colour = danger ? const Color(0xFFE53935) : theme.hintColor;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: colour),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: danger
                  ? const Color(0xFFE53935)
                  : theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// STATUS CHIP - days left / overdue / completed
// =====================================================================
