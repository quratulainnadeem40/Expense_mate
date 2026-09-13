import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/expense_controller.dart';

class AddExpenseView extends GetView<ExpenseController> {
  const AddExpenseView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;

    const primaryGreen = Color(0xFF2EA44F);
    const expenseRed = Color(0xFFE53935);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.isEditMode.value
                ? 'Edit Transaction'
                : 'Add Transaction',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --------------------------------------------------
                    // EXPENSE / INCOME SEGMENTED TOGGLE
                    // --------------------------------------------------
                    Obx(() {
                      final isExpense = controller.isExpense.value;

                      return Container(
                        height: 50,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF252A2D)
                              : const Color(0xFFF0F2F5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => controller.toggleType(true),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: isExpense
                                        ? expenseRed
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: isExpense
                                        ? [
                                            BoxShadow(
                                              color: expenseRed.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_downward_rounded,
                                        size: 16,
                                        color: isExpense
                                            ? Colors.white
                                            : (isDark
                                                ? Colors.white60
                                                : Colors.black54),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Expense',
                                        style: TextStyle(
                                          color: isExpense
                                              ? Colors.white
                                              : (isDark
                                                  ? Colors.white60
                                                  : Colors.black87),
                                          fontWeight: isExpense
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => controller.toggleType(false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: !isExpense
                                        ? primaryGreen
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: !isExpense
                                        ? [
                                            BoxShadow(
                                              color: primaryGreen.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_upward_rounded,
                                        size: 16,
                                        color: !isExpense
                                            ? Colors.white
                                            : (isDark
                                                ? Colors.white60
                                                : Colors.black54),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Income',
                                        style: TextStyle(
                                          color: !isExpense
                                              ? Colors.white
                                              : (isDark
                                                  ? Colors.white60
                                                  : Colors.black87),
                                          fontWeight: !isExpense
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    // --------------------------------------------------
                    // AMOUNT FIELD (CARD STYLE)
                    // --------------------------------------------------
                    Obx(() {
                      final isExpense = controller.isExpense.value;
                      final currentColor =
                          isExpense ? expenseRed : primaryGreen;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E2421)
                              : currentColor.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: currentColor.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount',
                              style: TextStyle(
                                color: currentColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: controller.amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: currentColor,
                              ),
                              decoration: InputDecoration(
                                hintText: '0.00',
                                prefixText: 'PKR ',
                                prefixStyle: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: currentColor.withOpacity(0.7),
                                ),
                                hintStyle: TextStyle(
                                  color: currentColor.withOpacity(0.4),
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    // --------------------------------------------------
                    // CATEGORY DROPDOWN
                    // --------------------------------------------------
                    _buildFieldLabel(theme, 'Category'),
                    const SizedBox(height: 6),
                    Obx(() {
                      final currentList = controller.isExpense.value
                          ? controller.expenseCategories
                          : controller.incomeCategories;

                      if (currentList.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: _inputBoxDecoration(theme, isDark),
                          child: Text(
                            'No categories available.',
                            style: TextStyle(color: theme.hintColor),
                          ),
                        );
                      }

                      final selectedVal = currentList.any(
                        (c) => c.id == controller.selectedCategoryId.value,
                      )
                          ? controller.selectedCategoryId.value
                          : null;

                      return DropdownButtonFormField<String>(
                        value: selectedVal,
                        hint: Text(
                          'Select Category',
                          style: TextStyle(
                            color: theme.hintColor.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                        selectedItemBuilder: (BuildContext context) {
                          return currentList.map<Widget>((category) {
                            return Text(
                              category.name,
                              style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }).toList();
                        },
                        dropdownColor:
                            isDark ? const Color(0xFF252A2D) : Colors.white,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: theme.iconTheme.color ?? Colors.grey,
                        ),
                        decoration: _buildInputDecoration(theme, isDark),
                        items: currentList.map<DropdownMenuItem<String>>(
                          (category) {
                            return DropdownMenuItem<String>(
                              value: category.id,
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color,
                                ),
                              ),
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          controller.selectedCategoryId.value = value ?? '';
                        },
                      );
                    }),

                    const SizedBox(height: 16),

                    // --------------------------------------------------
                    // WALLET DROPDOWN
                    // --------------------------------------------------
                    _buildFieldLabel(theme, 'Wallet'),
                    const SizedBox(height: 6),
                    Obx(() {
                      final wallets = controller.walletsController.wallets;

                      if (wallets.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: _inputBoxDecoration(theme, isDark),
                          child: Text(
                            'No wallets available.',
                            style: TextStyle(color: theme.hintColor),
                          ),
                        );
                      }

                      final selectedWalletVal = wallets.any(
                        (w) => w.id == controller.selectedWalletId.value,
                      )
                          ? controller.selectedWalletId.value
                          : null;

                      return DropdownButtonFormField<String>(
                        value: selectedWalletVal,
                        hint: Text(
                          'Select Wallet',
                          style: TextStyle(
                            color: theme.hintColor.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                        selectedItemBuilder: (BuildContext context) {
                          return wallets.map<Widget>((wallet) {
                            return Text(
                              wallet.name,
                              style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }).toList();
                        },
                        dropdownColor:
                            isDark ? const Color(0xFF252A2D) : Colors.white,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: theme.iconTheme.color ?? Colors.grey,
                        ),
                        decoration: _buildInputDecoration(theme, isDark),
                        items: wallets.map<DropdownMenuItem<String>>(
                          (wallet) {
                            return DropdownMenuItem<String>(
                              value: wallet.id,
                              child: Row(
                                children: [
                                  Icon(
                                    _walletIcon(wallet.type),
                                    size: 18,
                                    color: primaryGreen,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    wallet.name,
                                    style: TextStyle(
                                      color:
                                          theme.textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          controller.selectedWalletId.value = value ?? '';
                        },
                      );
                    }),

                    const SizedBox(height: 16),

                    // --------------------------------------------------
                    // NOTE FIELD
                    // --------------------------------------------------
                    _buildFieldLabel(theme, 'Note (Optional)'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: controller.noteController,
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      decoration: _buildInputDecoration(theme, isDark).copyWith(
                        hintText: 'e.g., Lunch with team',
                        hintStyle: TextStyle(
                          color: theme.hintColor.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ], // <-- Scrollable Column children close HERE
                ),
              ),
            ),

            // --------------------------------------------------
            // ACTION BUTTONS (BOTTOM PINNED)
            // --------------------------------------------------
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          elevation: 2,
                          shadowColor: primaryGreen.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                if (controller
                                    .selectedCategoryId.value.isEmpty) {
                                  Get.snackbar(
                                    'Warning',
                                    'Please select a category',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                  return;
                                }
                                if (controller
                                    .selectedWalletId.value.isEmpty) {
                                  Get.snackbar(
                                    'Warning',
                                    'Please select a wallet',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                  return;
                                }
                                controller.saveExpense();
                              },
                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Obx(
                                () => Text(
                                  controller.isEditMode.value
                                      ? 'Update Transaction'
                                      : 'Save Transaction',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: theme.hintColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods & Styles
  Widget _buildFieldLabel(ThemeData theme, String title) {
    return Text(
      title,
      style: TextStyle(
        color: theme.hintColor,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _buildInputDecoration(ThemeData theme, bool isDark) {
    return InputDecoration(
      filled: true,
      fillColor: isDark ? const Color(0xFF252A2D) : const Color(0xFFF7F8FA),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF2EA44F),
          width: 1.5,
        ),
      ),
    );
  }

  BoxDecoration _inputBoxDecoration(ThemeData theme, bool isDark) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF252A2D) : const Color(0xFFF7F8FA),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
      ),
    );
  }

  IconData _walletIcon(String type) {
    switch (type) {
      case 'Bank Account':
        return Icons.account_balance;

      case 'JazzCash':
        return Icons.phone_android;

      case 'Easypaisa':
        return Icons.account_balance_wallet;

      case 'Credit Card':
        return Icons.credit_card;

      case 'Other':
        return Icons.wallet;

      case 'Cash':
      default:
        return Icons.payments;
    }
  }
}