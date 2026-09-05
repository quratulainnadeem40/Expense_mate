import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/budget_controller.dart';

class BudgetSummaryCard extends GetView<BudgetController> {
  const BudgetSummaryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      double progress = controller.totalAllocated > 0
          ? (controller.totalSpent / controller.totalAllocated).clamp(0.0, 1.0)
          : 0.0;

      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Total Monthly Budget',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'RS ${controller.totalSpent.toStringAsFixed(0)} / RS ${controller.totalAllocated.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
                color: progress > 0.9 ? Colors.red : Colors.green,
              ),
            ],
          ),
        ),
      );
    });
  }
}