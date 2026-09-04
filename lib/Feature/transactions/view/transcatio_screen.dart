import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/transaction_card.dart';


class TransactionsView extends GetView<TransactionsController> {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions', style: AppTextStyles.headingMedium(isDark)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Summary Header Box
          Obx(() => Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Income', style: AppTextStyles.bodyMedium(isDark)),
                        const SizedBox(height: 4),
                        Text(
                          '\$${controller.totalIncome.value.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.4)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Expense', style: AppTextStyles.bodyMedium(isDark)),
                        const SizedBox(height: 4),
                        Text(
                          '\$${controller.totalExpense.value.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
          
          // Transaction List
          Expanded(
            child: Obx(() {
              if (controller.transactionList.isEmpty) {
                return Center(
                  child: Text(
                    'No transactions found.',
                    style: AppTextStyles.bodyLarge(isDark),
                  ),
                );
              }
              return ListView.builder(
                itemCount: controller.transactionList.length,
                itemBuilder: (context, index) {
                  final tx = controller.transactionList[index];
                  return TransactionCard(transaction: tx, isDark: isDark);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}