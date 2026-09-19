import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/goals_controller.dart';
import '../model/goals_model.dart';

class GoalsCard extends StatelessWidget {
  final GoalModel goal;

  const GoalsCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<GoalsController>();

    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Add Funds Button Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Color(0xFF2EA44F)),
                  onPressed: () => _showAddMoneyDialog(context, controller, goal),
                  tooltip: 'Add Savings',
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Custom Styled Green Progress Line
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: goal.progress,
                minHeight: 8,
                backgroundColor: theme.dividerColor.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2EA44F)),
              ),
            ),
            const SizedBox(height: 10),

            // Saved and Target Amounts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saved: Rs. ${goal.savedAmount.toStringAsFixed(0)}',
                  style: TextStyle(color: theme.hintColor, fontSize: 13),
                ),
                Text(
                  'Target: Rs. ${goal.targetAmount.toStringAsFixed(0)}',
                  style: TextStyle(color: theme.hintColor, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Target Date Display
            Text(
              'Target Date: ${goal.targetDate.day}/${goal.targetDate.month}/${goal.targetDate.year}',
              style: TextStyle(
                color: theme.hintColor.withOpacity(0.8),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Quick Deposit Dialog
  void _showAddMoneyDialog(BuildContext context, GoalsController controller, GoalModel goal) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text(
            'Add Funds to ${goal.title}',
            style: TextStyle(color: theme.textTheme.titleLarge?.color, fontSize: 18),
          ),
          content: TextField(
            controller: controller.addMoneyController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              labelText: 'Enter Saved Amount (Rs.)',
              labelStyle: TextStyle(color: theme.hintColor),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.dividerColor)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2EA44F))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel', style: TextStyle(color: theme.hintColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2EA44F)),
              onPressed: () => controller.addSavings(goal.id),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}