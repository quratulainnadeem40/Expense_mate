
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import '../widgets/transaction_card.dart';

class TransactionsView extends GetView<TransactionsController> {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transactions',
          style: AppTextStyles.headingMedium(isDark),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        // ----------------------------------------------------------
        // LOADING
        // ----------------------------------------------------------

        if (controller.isLoading.value &&
            controller.transactions.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // ----------------------------------------------------------
        // TRANSACTIONS
        // ----------------------------------------------------------

        final transactions = controller.transactions;

        // ----------------------------------------------------------
        // EMPTY STATE
        // ----------------------------------------------------------

        if (transactions.isEmpty) {
          return Column(
            children: [
              _summaryCard(
                context: context,
                isDark: isDark,
                income: 0,
                expense: 0,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'No transactions found.',
                    style: AppTextStyles.bodyLarge(isDark),
                  ),
                ),
              ),
            ],
          );
        }

        // ----------------------------------------------------------
        // TRANSACTION LIST
        // ----------------------------------------------------------

        return RefreshIndicator(
          onRefresh: controller.loadTransactions,
          child: Column(
            children: [
              // ----------------------------------------------------
              // SUMMARY
              // ----------------------------------------------------

              _summaryCard(
                context: context,
                isDark: isDark,
                income: controller.totalIncome,
                expense: controller.totalExpense,
              ),

              // ----------------------------------------------------
              // LIST
              // ----------------------------------------------------

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];

                    return TransactionCard(
                      transaction: transaction,
                      isDark: isDark,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ==============================================================
  // SUMMARY CARD
  // ==============================================================

  Widget _summaryCard({
    required BuildContext context,
    required bool isDark,
    required double income,
    required double expense,
  }) {
    return Container(
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
          // --------------------------------------------------------
          // INCOME
          // --------------------------------------------------------

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Income',
                style: AppTextStyles.bodyMedium(isDark),
              ),
              const SizedBox(height: 4),
              Text(
                'PKR ${income.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          // --------------------------------------------------------
          // DIVIDER
          // --------------------------------------------------------

          Container(
            height: 30,
            width: 1,
            color: Colors.grey.withOpacity(0.4),
          ),

          // --------------------------------------------------------
          // EXPENSE
          // --------------------------------------------------------

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Expense',
                style: AppTextStyles.bodyMedium(isDark),
              ),
              const SizedBox(height: 4),
              Text(
                'PKR ${expense.toStringAsFixed(2)}',
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
    );
  }
}

