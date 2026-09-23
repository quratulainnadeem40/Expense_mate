import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/budget_controller.dart';

class BudgetView extends StatefulWidget {
  const BudgetView({Key? key}) : super(key: key);

  @override
  State<BudgetView> createState() => _BudgetViewState();
}

class _BudgetViewState extends State<BudgetView> {
  final Set<String> _selectedCategoryIds = <String>{};
  bool _isSelectionMode = false;

  BudgetController get controller => Get.find<BudgetController>();

  Future<void> _showMonthlyLimitExceededDialog({
    required BuildContext context,
    required String categoryName,
    required double proposedLimit,
  }) async {
    final monthlyLimit = controller.customTotalBudget.value;
    if (monthlyLimit == null) return;

    final projectedTotal = controller.projectedAllocationAfterUpdate(
      categoryName,
      proposedLimit,
    );
    final amountOver = projectedTotal - monthlyLimit;

    final action = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly budget exceeded',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'This category would push your total monthly budget from RS ${monthlyLimit.toStringAsFixed(0)} to RS ${projectedTotal.toStringAsFixed(0)}.\n\nYou are over by RS ${amountOver.toStringAsFixed(0)}.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Get.back(result: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: const Text(
                          'Edit Monthly Limit',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (action == true) {
      final activeContext = Get.context;
      if (activeContext != null && activeContext.mounted) {
        _showEditTotalBudgetDialog(
          activeContext,
          controller.customTotalBudget.value ?? controller.totalAllocated,
        );
      }
    }
  }

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Custom Category',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'e.g., Travel',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  onTap: () {
                    if (amountController.text == '0') {
                      amountController.clear();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Monthly Limit',
                    hintText: 'e.g., 20000',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          final categoryName = nameController.text.trim();
                          final amount = double.tryParse(amountController.text.trim()) ?? 10000;

                          if (categoryName.isEmpty) {
                            Get.snackbar(
                              'Required',
                              'Please enter a category name.',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }

                          if (controller.customTotalBudget.value != null &&
                              controller.projectedAllocationAfterUpdate(
                                      categoryName,
                                      amount,
                                    ) >
                                    controller.customTotalBudget.value!) {
                            final parentContext = Get.context;
                            Get.back(result: false);
                            if (parentContext != null && parentContext.mounted) {
                              _showMonthlyLimitExceededDialog(
                                context: parentContext,
                                categoryName: categoryName,
                                proposedLimit: amount,
                              );
                            }
                            return;
                          }

                          controller.addNewBudget(categoryName, amount);
                          Get.back(result: true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                        ),
                        child: const Text(
                          'Add',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == true && context.mounted) {
      Get.snackbar(
        'Success',
        'Custom category added.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _deleteSelectedCategories() async {
    if (_selectedCategoryIds.isEmpty) {
      return;
    }

    final removableIds = _selectedCategoryIds
        .where(
          (id) => !controller.categoriesController.categoryList
              .any((category) => category.id == id && category.isDefault),
        )
        .toList();

    if (removableIds.isEmpty) {
      _selectedCategoryIds.clear();
      _isSelectionMode = false;
      Get.snackbar(
        'Protected',
        'Default categories cannot be deleted.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await controller.categoriesController.deleteCategories(removableIds);
    _selectedCategoryIds.clear();
    _isSelectionMode = false;
  }

  void _showDeleteOption(BuildContext context, String categoryId, bool isDefault) {
    if (isDefault) {
      Get.snackbar(
        'Protected',
        'This default category cannot be deleted.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final linkedTransactions =
            controller.categoriesController.getCategoryCount(categoryId);

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          backgroundColor: Colors.transparent,
          child: Container(
            width: 420,
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delete Category',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  linkedTransactions > 0
                      ? 'This will permanently delete this category and all related transaction data from the Transactions screen.\n\nDo you want to continue?'
                      : 'This will permanently delete this category.\n\nDo you want to continue?',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 42,
                      child: TextButton(
                        onPressed: () async {
                          Get.back();
                          await controller.categoriesController.deleteCategories([categoryId]);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFFE53935),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditLimitDialog(
    BuildContext context,
    String categoryName,
    double currentLimit,
  ) {
    final amountController = TextEditingController(
      text: currentLimit > 0 ? currentLimit.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set Limit for $categoryName',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  onTap: () {
                    if (amountController.text == '0') {
                      amountController.clear();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Monthly Limit',
                    hintText: 'e.g., 20000',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark ? Colors.white30 : Colors.black26,
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          final limit =
                              double.tryParse(amountController.text.trim()) ??
                                  currentLimit;

                          if (controller.customTotalBudget.value != null &&
                              controller.willExceedMonthlyBudget(
                                categoryName,
                                limit,
                              )) {
                            final parentContext = Get.context;
                            Get.back();
                            if (parentContext != null && parentContext.mounted) {
                              _showMonthlyLimitExceededDialog(
                                context: parentContext,
                                categoryName: categoryName,
                                proposedLimit: limit,
                              );
                            }
                            return;
                          }

                          controller.setCategoryLimit(categoryName, limit);
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                        ),
                        child: const Text(
                          'Update',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditTotalBudgetDialog(
    BuildContext context,
    double currentTotalLimit,
  ) {
    final amountController = TextEditingController(
      text: currentTotalLimit > 0 ? currentTotalLimit.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set Total Monthly Budget',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  onTap: () {
                    if (amountController.text == '0') {
                      amountController.clear();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Total Limit',
                    hintText: 'e.g., 60000',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark ? Colors.white30 : Colors.black26,
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          final totalLimit =
                              double.tryParse(amountController.text.trim()) ??
                                  currentTotalLimit;

                          controller.setTotalBudget(totalLimit);
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                        ),
                        child: const Text(
                          'Update',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Theme colors
    final backgroundColor = isDark
        ? const Color(0xFF080808)
        : const Color(0xFFF6F7F2);

    final cardColor = isDark
        ? const Color(0xFF1A1A1A)
        : const Color(0xFFF2F6ED);

    final primaryTextColor = isDark
        ? Colors.white
        : const Color(0xFF1E1E1E);

    final secondaryTextColor = isDark
        ? Colors.white70
        : const Color(0xFF555B51);

    final progressBackgroundColor = isDark
        ? const Color(0xFF303030)
        : const Color(0xFFD3E7CB);

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: Text(
          'Live Budget',
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark
            ? const Color(0xFF1A1A1A)
            : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: primaryTextColor,
          ),
          onPressed: () => Get.back(),
        ),
      ),

      body: Obx(() {
        final budgets = controller.budgetList;

        if (budgets.isEmpty) {
          return Center(
            child: Text(
              'No categories found.',
              style: TextStyle(
                color: secondaryTextColor,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ============================================================
              // TOTAL BUDGET CARD
              // ============================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Monthly Budget Spent',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: secondaryTextColor,
                          ),
                        ),

                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            size: 18,
                            color: isDark
                                ? Colors.white70
                                : Colors.grey,
                          ),
                          onPressed: () =>
                              _showEditTotalBudgetDialog(
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
                            : (controller.totalSpent /
                                    controller.totalAllocated)
                                .clamp(0.0, 1.0),
                        backgroundColor: progressBackgroundColor,
                        color: const Color(0xFF4CAF50),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ============================================================
              // CATEGORY TITLE
              // ============================================================

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Category Budgets',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  Row(
                    children: [
                      if (_isSelectionMode)
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE53935), Color(0xFFC62828)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.22),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: IconButton(
                            tooltip: 'Delete selected categories',
                            onPressed: _deleteSelectedCategories,
                            icon: const Icon(Icons.delete_outline_rounded),
                            color: Colors.white,
                          ),
                        )
                      else
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4CAF50).withOpacity(0.22),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: IconButton(
                            tooltip: 'Add category budget',
                            onPressed: () => _showAddCategoryDialog(context),
                            icon: const Icon(Icons.add_rounded),
                            color: Colors.white,
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (_isSelectionMode)
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.white12 : Colors.black12,
                            ),
                          ),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategoryIds.clear();
                                _isSelectionMode = false;
                              });
                            },
                            child: const Text('Done'),
                          ),
                        )
                      else
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.white12 : Colors.black12,
                            ),
                          ),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _isSelectionMode = true;
                              });
                            },
                            child: const Text('Select'),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ============================================================
              // CATEGORY BUDGETS
              // ============================================================

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: budgets.length,
                itemBuilder: (context, index) {
                  final item = budgets[index];
                  final category = controller.categoriesController.categoryList.firstWhere(
                    (element) => element.name.trim().toLowerCase() == item.categoryName.trim().toLowerCase(),
                    orElse: () => controller.categoriesController.categoryList.first,
                  );
                  final isProtected = category.isDefault;
                  final isSelected = _selectedCategoryIds.contains(category.id);

                  final progress = item.allocatedAmount == 0
                      ? 0.0
                      : (item.spentAmount / item.allocatedAmount)
                          .clamp(0.0, 1.0);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  if (_isSelectionMode && !isProtected)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Checkbox(
                                        value: isSelected,
                                        onChanged: (_) {
                                          setState(() {
                                            if (isSelected) {
                                              _selectedCategoryIds.remove(category.id);
                                            } else {
                                              _selectedCategoryIds.add(category.id);
                                            }
                                            if (_selectedCategoryIds.isEmpty) {
                                              _isSelectionMode = false;
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  Expanded(
                                    child: Text(
                                      item.categoryName,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: primaryTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_isSelectionMode)
                              const SizedBox.shrink()
                            else if (isProtected)
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: isDark ? Colors.white70 : Colors.grey,
                                ),
                                onPressed: () => _showEditLimitDialog(
                                  context,
                                  item.categoryName,
                                  item.allocatedAmount,
                                ),
                              )
                            else
                              PopupMenuButton<String>(
                                icon: Icon(
                                  Icons.more_vert_rounded,
                                  color: isDark ? Colors.white70 : Colors.grey,
                                ),
                                color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
                                elevation: 12,
                                shadowColor: Colors.black.withOpacity(0.12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  side: BorderSide(
                                    color: isDark ? Colors.white12 : Colors.black12,
                                  ),
                                ),
                                constraints: const BoxConstraints(minWidth: 180),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditLimitDialog(
                                      context,
                                      item.categoryName,
                                      item.allocatedAmount,
                                    );
                                  } else if (value == 'delete') {
                                    _showDeleteOption(context, category.id, false);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        const Icon(Icons.edit_outlined, size: 18),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Edit limit',
                                          style: TextStyle(
                                            color: isDark ? Colors.white : Colors.black87,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                                        const SizedBox(width: 10),
                                        const Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: progressBackgroundColor,
                            color: progress > 0.9 ? Colors.red : const Color(0xFF2B82FB),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Spent: RS ${item.spentAmount.toStringAsFixed(0)} / RS ${item.allocatedAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
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