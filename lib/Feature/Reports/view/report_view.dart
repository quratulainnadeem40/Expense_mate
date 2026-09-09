import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expense_mate/Feature/Reports/controller/report_controller.dart';
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';

class ReportsView extends GetView<ReportController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Shared controller instances
    final controller = Get.find<ReportController>();
    final txController = Get.find<TransactionsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Reports & Analytics'),
        centerTitle: true,
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Totals Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Total Income',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'PKR ${controller.totalIncome.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                      Column(
                        children: [
                          const Text(
                            'Total Expenses',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'PKR ${controller.totalExpense.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Recent Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Transaction List
              controller.transactions.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'No entries added yet.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.transactions.length,
                      itemBuilder: (context, index) {
                        final tx = controller.transactions[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              tx.isIncome
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: tx.isIncome ? Colors.green : Colors.red,
                            ),
                            title: Text(tx.title),
                            subtitle: Text(
                              '${tx.category} • ${tx.date.day}/${tx.date.month}/${tx.date.year}',
                            ),
                            trailing: Text(
                              '${tx.isIncome ? '+' : '-'} PKR ${tx.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: tx.isIncome ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEntryBottomSheet(context, txController),
        label: const Text('Add Entry'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAddEntryBottomSheet(
      BuildContext context, TransactionsController txController) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Transaction',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        _submitTransaction(
                          txController: txController,
                          titleCtrl: titleCtrl,
                          amountCtrl: amountCtrl,
                          isIncome: true,
                        );
                      },
                      child: const Text('Add Income'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        _submitTransaction(
                          txController: txController,
                          titleCtrl: titleCtrl,
                          amountCtrl: amountCtrl,
                          isIncome: false,
                        );
                      },
                      child: const Text('Add Expense'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitTransaction({
    required TransactionsController txController,
    required TextEditingController titleCtrl,
    required TextEditingController amountCtrl,
    required bool isIncome,
  }) {
    final title = titleCtrl.text.trim();
    final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;

    if (title.isEmpty || amount <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid title and amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final newTx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      category: 'General',
      date: DateTime.now(),
      isIncome: isIncome,
    );

    // Save to Hive persistent DB & trigger auto-sync
    txController.addTransaction(newTx);

    if (Get.isBottomSheetOpen ?? false) {
      Get.back();
    }
  }
}