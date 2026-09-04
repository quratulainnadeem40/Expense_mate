import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';
import 'package:expense_mate/Feature/transactions/widgets/transaction_card.dart';
import 'package:expense_mate/core/constants/app_keys.dart';
import 'transaction_details_screen.dart';

class CategoryTransactionsScreen extends StatelessWidget {
  final String categoryName;

  const CategoryTransactionsScreen({
    super.key,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box(AppKeys.transactionsBox).listenable(),
        builder: (context, Box box, _) {
          final data = box.values.toList();
          
          double totalAmount = 0.0;
          bool isIncomeCategory = false;
          List<TransactionModel> filteredList = [];

          for (var item in data) {
            if (item is Map && item['category'] == categoryName) {
              final double amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
              final bool isIncome = item['type'] == 'Income';
              isIncomeCategory = isIncome;

              totalAmount += amount;

              filteredList.add(
                TransactionModel(
                  id: item['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  title: (item['note'] != null && item['note'].toString().isNotEmpty)
                      ? item['note'].toString()
                      : (item['category']?.toString() ?? 'General'),
                  amount: amount,
                  category: item['category']?.toString() ?? 'General',
                  date: item['date'] != null ? DateTime.parse(item['date'].toString()) : DateTime.now(),
                  isIncome: isIncome,
                ),
              );
            }
          }

          final reversedList = filteredList.reversed.toList();

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Total ($categoryName)',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${isIncomeCategory ? '+' : '-'}\$${totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isIncomeCategory ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${reversedList.length} Transactions',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: reversedList.isEmpty
                    ? const Center(
                        child: Text('No transactions found in this category.'),
                      )
                    : ListView.builder(
                        itemCount: reversedList.length,
                        itemBuilder: (context, index) {
                          final tx = reversedList[index];
                          return GestureDetector(
                            onTap: () {
                              Get.to(() => TransactionDetailsScreen(transaction: tx));
                            },
                            child: TransactionCard(
                              transaction: tx,
                              isDark: isDark,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}