import 'package:expense_mate/Core/utils/formatters.dart';
import 'package:expense_mate/Feature/Categories/controller/categories_controller.dart';
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryHistoryScreen extends StatelessWidget {
  const CategoryHistoryScreen({super.key});

  String _categoryName(
    TransactionModel transaction,
    CategoriesController categoriesController,
  ) {
    if (transaction.customCategoryName.trim().isNotEmpty) {
      return transaction.customCategoryName.trim();
    }

    final category = categoriesController.categoryList.firstWhereOrNull(
      (category) => category.linkedIds.any(
        (id) =>
            id.trim().toLowerCase() ==
            transaction.categoryId.trim().toLowerCase(),
      ),
    );
    return category?.name ?? transaction.displayCategoryFallback;
  }

  @override
  Widget build(BuildContext context) {
    final transactionsController = Get.find<TransactionsController>();
    final categoriesController = Get.find<CategoriesController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? Colors.white : const Color(0xFF1F2937);
    final secondaryText = isDark ? Colors.white70 : const Color(0xFF667085);
    final background = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF7F9F8);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back'.tr,
          icon: Icon(Icons.arrow_back, color: primaryText),
          onPressed: Get.back,
        ),
        title: Text(
          'Category History'.tr,
          style: TextStyle(color: primaryText, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (transactionsController.isLoading.value &&
            transactionsController.transactions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = transactionsController.transactions.toList()
          ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

        if (transactions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 56,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No category history yet'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Transactions from all categories will appear here.'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: secondaryText),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: transactionsController.loadTransactions,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final isIncome = transaction.isIncome;
              final color = isIncome
                  ? const Color(0xFF2E9D59)
                  : const Color(0xFFE25555);
              final categoryName = _categoryName(
                transaction,
                categoriesController,
              );
              final title = transaction.title.trim().isNotEmpty
                  ? transaction.title.trim().toLowerCase() ==
                          categoryName.trim().toLowerCase()
                      ? categoryName.tr
                      : transaction.title.trim()
                  : categoryName.tr;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.12),
                      child: Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${categoryName.tr} • '
                            '${Formatters.formatDate(transaction.transactionDate)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${isIncome ? '+' : '-'}'
                      '${Formatters.formatCurrency(transaction.amount)}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
