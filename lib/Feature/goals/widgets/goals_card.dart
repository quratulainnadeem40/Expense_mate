import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/goals_controller.dart';
import '../model/goals_model.dart';

const Color kGoalGreen = Color(0xFF2EA44F);

String formatMoney(double value) =>
    NumberFormat('#,##0', 'en_US').format(value);

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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------------------------------------------- header
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kGoalGreen.withOpacity(isDark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(goal.emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
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
                    _StatusChip(goal: goal),
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
                  _menuItem('withdraw', Icons.south_west_rounded,
                      'Withdraw money', theme),
                  _menuItem('delete', Icons.delete_outline_rounded,
                      'Delete goal', theme, danger: true),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ---------------------------------------------------- amounts
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rs. ${formatMoney(goal.savedAmount)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kGoalGreen,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  'of Rs. ${formatMoney(goal.targetAmount)}',
                  style: TextStyle(fontSize: 13, color: theme.hintColor),
                ),
              ),
              const Spacer(),
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

          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 9,
              backgroundColor:
                  isDark ? Colors.white12 : Colors.black.withOpacity(0.07),
              valueColor: const AlwaysStoppedAnimation<Color>(kGoalGreen),
            ),
          ),

          const SizedBox(height: 12),

          // ---------------------------------------------------- footer
          if (done)
            Row(
              children: const [
                Icon(Icons.check_circle_rounded, size: 18, color: kGoalGreen),
                SizedBox(width: 8),
                Text(
                  'Goal completed. Well done!',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kGoalGreen,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rs. ${formatMoney(goal.remaining)} to go',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        goal.daysLeft > 0
                            ? 'Save about Rs. '
                                '${formatMoney(goal.monthlyTarget)} a month'
                            : 'Target date has passed',
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
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.goal});

  final GoalModel goal;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color colour;
    late final IconData icon;

    if (goal.isCompleted) {
      label = 'Completed';
      colour = kGoalGreen;
      icon = Icons.check_circle_rounded;
    } else if (goal.isOverdue) {
      label = '${goal.daysLeft.abs()} days overdue';
      colour = const Color(0xFFE53935);
      icon = Icons.error_outline_rounded;
    } else if (goal.daysLeft == 0) {
      label = 'Due today';
      colour = const Color(0xFFFF9800);
      icon = Icons.today_rounded;
    } else if (goal.daysLeft <= 30) {
      label = '${goal.daysLeft} days left';
      colour = const Color(0xFFFF9800);
      icon = Icons.schedule_rounded;
    } else {
      label = 'By ${DateFormat('d MMM yyyy').format(goal.targetDate)}';
      colour = Theme.of(context).hintColor;
      icon = Icons.event_outlined;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: colour),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: colour,
            ),
          ),
        ),
      ],
    );
  }
}