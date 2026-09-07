import 'package:flutter/material.dart';
import '../model/goals_model.dart';

class GoalsCard extends StatelessWidget {
  final GoalModel goal;

  const GoalsCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              goal.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: goal.progress,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Saved: Rs. ${goal.savedAmount.toStringAsFixed(0)}'),
                Text('Target: Rs. ${goal.targetAmount.toStringAsFixed(0)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}