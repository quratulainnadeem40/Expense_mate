import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ✅ Package imports use karein relative imports (../) ki jagah
import 'package:expense_mate/Feature/goals/controller/goals_controller.dart';
import 'package:expense_mate/Feature/goals/widgets/goals_card.dart';

class GoalsView extends GetView<GoalsController> {
  const GoalsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Goals'),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2EA44F),
        onPressed: () => _showAddGoalBottomSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.goals.isEmpty) {
          return Center(
            child: Text(
              'No Goals Found\nTap "+" to create a goal.',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.hintColor, fontSize: 16),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.goals.length,
          itemBuilder: (context, index) {
            final goal = controller.goals[index];
            return GoalsCard(goal: goal);
          },
        );
      }),
    );
  }

  void _showAddGoalBottomSheet(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Goal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.titleController,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  labelText: 'Goal Title',
                  labelStyle: TextStyle(color: theme.hintColor),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.dividerColor)),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF2EA44F))),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.targetController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  labelText: 'Target Amount (Rs.)',
                  labelStyle: TextStyle(color: theme.hintColor),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.dividerColor)),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF2EA44F))),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.savedController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  labelText: 'Initial Saved Amount (Optional)',
                  labelStyle: TextStyle(color: theme.hintColor),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.dividerColor)),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF2EA44F))),
                ),
              ),
              const SizedBox(height: 12),
              Obx(() => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  controller.selectedDate.value == null
                      ? 'Select Target Date'
                      : 'Target Date: ${controller.selectedDate.value!.day}/${controller.selectedDate.value!.month}/${controller.selectedDate.value!.year}',
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                ),
                trailing: const Icon(Icons.calendar_today, color: Color(0xFF2EA44F)),
                onTap: () => controller.pickDate(context),
              )),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2EA44F)),
                  onPressed: () => controller.submitNewGoal(context),
                  child: const Text('Save Goal', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}