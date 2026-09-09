import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expense_mate/Feature/reports/controller/report_controller.dart';
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';

class ReportsView extends GetView<ReportController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();
    final txController = Get.find<TransactionsController>();

    // Dynamic Theme Variables
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      // ✅ Dynamic Background Color
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Live Reports & Analytics'),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: Obx(() {
        final totalIncome = controller.totalIncome;
        final totalExpense = controller.totalExpense;
        final totalSum = totalIncome + totalExpense;

        final incomePct = totalSum > 0 ? (totalIncome / totalSum) : 0.0;
        final expensePct = totalSum > 0 ? (totalExpense / totalSum) : 0.0;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Totals Summary Card
              Card(
                elevation: 0,
                color: theme.cardColor, // ✅ Dynamic Card Color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Total Income',
                              style: TextStyle(
                                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'PKR ${totalIncome.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: theme.dividerColor, // ✅ Dynamic Divider Color
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Total Expenses',
                              style: TextStyle(
                                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'PKR ${totalExpense.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFFEB5757),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 2. Financial Breakdown
              Text(
                'Financial Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87, // ✅ Dynamic Text Color
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                color: theme.cardColor, // ✅ Dynamic Card Color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Income vs Expense Ratio",
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "Balance: PKR ${controller.totalBalance.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: isDarkMode ? Colors.white : Colors.black87, // ✅ Dynamic Text
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Linear Indicator Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          height: 10,
                          child: Row(
                            children: [
                              if (totalSum == 0)
                                Expanded(
                                  child: Container(
                                    color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                                  ),
                                )
                              else ...[
                                Expanded(
                                  flex: (incomePct * 100).round(),
                                  child: Container(color: const Color(0xFF4CAF50)),
                                ),
                                Expanded(
                                  flex: (expensePct * 100).round(),
                                  child: Container(color: const Color(0xFFEB5757)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Percentage Labels
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Income: ${(incomePct * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Expense: ${(expensePct * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Color(0xFFEB5757),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 3. Recent Transactions Section
              Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87, // ✅ Dynamic Text
                ),
              ),
              const SizedBox(height: 12),

              controller.transactions.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.cardColor, // ✅ Dynamic Container Background
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'No entries added yet.',
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.transactions.length,
                      itemBuilder: (context, index) {
                        final tx = controller.transactions[index];
                        final bool isIncome = tx.isIncome;

                        return Card(
                          elevation: 0,
                          color: theme.cardColor, // ✅ Dynamic List Item Card Color
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundColor: isIncome
                                  ? (isDarkMode ? const Color(0xFF1E382B) : const Color(0xFFEBF9EE))
                                  : (isDarkMode ? const Color(0xFF3B1E1E) : const Color(0xFFFDEEEE)),
                              child: Icon(
                                isIncome
                                    ? Icons.arrow_downward_rounded
                                    : Icons.arrow_upward_rounded,
                                color: isIncome
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFEB5757),
                                size: 18,
                              ),
                            ),
                            title: Text(
                              tx.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87, // ✅ Dynamic Title Color
                              ),
                            ),
                            subtitle: Text(
                              '${tx.category} • ${tx.date.day}/${tx.date.month}/${tx.date.year}',
                              style: TextStyle(
                                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                            trailing: Text(
                              '${isIncome ? '+' : '-'} PKR ${tx.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: isIncome
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFEB5757),
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
        label: const Text('Add Entry', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  void _showAddEntryBottomSheet(
    BuildContext context,
    TransactionsController txController,
  ) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor, // ✅ Dynamic Bottom Sheet Background Color
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Transaction',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: theme.hintColor),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.dividerColor)),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF4CAF50))),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: theme.hintColor),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.dividerColor)),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF4CAF50))),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                      ),
                      onPressed: () {
                        _submitTransaction(
                          txController: txController,
                          titleCtrl: titleCtrl,
                          amountCtrl: amountCtrl,
                          isIncome: true,
                        );
                      },
                      child: const Text('Add Income', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEB5757),
                      ),
                      onPressed: () {
                        _submitTransaction(
                          txController: txController,
                          titleCtrl: titleCtrl,
                          amountCtrl: amountCtrl,
                          isIncome: false,
                        );
                      },
                      child: const Text('Add Expense', style: TextStyle(color: Colors.white)),
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

    txController.addTransaction(newTx);

    if (Get.isBottomSheetOpen ?? false) {
      Get.back();
    }
  }
}