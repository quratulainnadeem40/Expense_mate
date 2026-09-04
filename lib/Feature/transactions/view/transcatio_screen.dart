import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';
import 'package:expense_mate/core/constants/app_keys.dart';
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
      body: ValueListenableBuilder(
        valueListenable: Hive.box(AppKeys.transactionsBox).listenable(),
        builder: (context, Box box, _) {
          final data = box.values.toList();
          
          double totalIncome = 0.0;
          double totalExpense = 0.0;
          List<TransactionModel> transactionsList = [];

          for (var item in data) {
            if (item is Map) {
              final double amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
              final bool isIncome = item['type'] == 'Income';

              if (isIncome) {
                totalIncome += amount;
              } else {
                totalExpense += amount;
              }

              transactionsList.add(
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

          // Reverse to show latest transactions on top
          final reversedList = transactionsList.reversed.toList();

          return Column(
            children: [
              // Summary Header Box
              Container(
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
                          '\$${totalIncome.toStringAsFixed(2)}',
                          style: const TextStyle(
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
                          '\$${totalExpense.toStringAsFixed(2)}',
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

              // Transactions List
              Expanded(
                child: reversedList.isEmpty
                    ? Center(
                        child: Text(
                          'No transactions found.',
                          style: AppTextStyles.bodyLarge(isDark),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: reversedList.length,
                        itemBuilder: (context, index) {
                          final tx = reversedList[index];
                          return TransactionCard(
                            transaction: tx,
                            isDark: isDark,
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