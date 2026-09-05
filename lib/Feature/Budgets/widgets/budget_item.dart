import 'package:flutter/material.dart';
import '../model/budget_model.dart';

class BudgetItem extends StatelessWidget {
  final BudgetModel budget;

  const BudgetItem({Key? key, required this.budget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        title: Text(budget.categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: budget.progress,
              color: budget.progress > 0.85 ? Colors.red : Colors.blue,
            ),
            const SizedBox(height: 4),
            Text('Spent: RS ${budget.spentAmount.toStringAsFixed(0)} / RS ${budget.allocatedAmount.toStringAsFixed(0)}'),
          ],
        ),
      ),
    );
  }
}