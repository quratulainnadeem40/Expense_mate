import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/budget_controller.dart';

class BudgetView extends GetView<BudgetController> {
  const BudgetView({Key? key}) : super(key: key);

  void _showEditLimitDialog(BuildContext context, String categoryName, double currentLimit) {
    final amountController = TextEditingController(text: currentLimit.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Set Limit for $categoryName'),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Monthly Limit',
              hintText: 'e.g., 20000',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final limit = double.tryParse(amountController.text.trim()) ?? currentLimit;
                controller.setCategoryLimit(categoryName, limit);
                Get.back();
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2B82FB)),
              child: const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showEditTotalBudgetDialog(BuildContext context, double currentTotalLimit) {
    final amountController = TextEditingController(text: currentTotalLimit.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Set Total Monthly Budget'),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Total Limit',
              hintText: 'e.g., 60000',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final totalLimit = double.tryParse(amountController.text.trim()) ?? currentTotalLimit;
                controller.setTotalBudget(totalLimit);
                Get.back();
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2B82FB)),
              child: const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      appBar: AppBar(
        title: const Text('Live Budget', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final budgets = controller.budgetList;

        if (budgets.isEmpty) {
          return const Center(child: Text('No categories found.'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F6ED),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Monthly Budget Spent',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF555B51),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                          onPressed: () => _showEditTotalBudgetDialog(
                            context,
                            controller.totalAllocated,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'RS ${controller.totalSpent.toStringAsFixed(0)} / RS ${controller.totalAllocated.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B82FB),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: controller.totalAllocated == 0
                            ? 0
                            : (controller.totalSpent / controller.totalAllocated).clamp(0.0, 1.0),
                        backgroundColor: const Color(0xFFD3E7CB),
                        color: const Color(0xFF4CAF50),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Category Budgets',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
              ),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: budgets.length,
                itemBuilder: (context, index) {
                  final item = budgets[index];
                  final progress = item.allocatedAmount == 0
                      ? 0.0
                      : (item.spentAmount / item.allocatedAmount).clamp(0.0, 1.0);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F6ED),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.categoryName,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                              onPressed: () => _showEditLimitDialog(context, item.categoryName, item.allocatedAmount),
                            )
                          ],
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: const Color(0xFFD3E7CB),
                            color: progress > 0.9 ? Colors.red : const Color(0xFF2B82FB),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Spent: RS ${item.spentAmount.toStringAsFixed(0)} / RS ${item.allocatedAmount.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF555B51)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}