
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/expense_controller.dart';

class AddExpenseView extends GetView<ExpenseController> {
  const AddExpenseView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(
  () => Text(
    controller.isEditMode.value
        ? 'Edit Transaction'
        : 'Add Transaction',
  ),
),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // EXPENSE / INCOME TOGGLE
              // --------------------------------------------------

              Obx(
                () => Container(
                  height: 48,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.grey[850]
                        : const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.toggleType(true),
                          child: Container(
                            decoration: BoxDecoration(
                              color: controller.isExpense.value
                                  ? const Color(0xFF2EA44F)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Expense',
                              style: TextStyle(
                                color: controller.isExpense.value
                                    ? Colors.white
                                    : (isDark
                                        ? Colors.white70
                                        : Colors.black),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.toggleType(false),
                          child: Container(
                            decoration: BoxDecoration(
                              color: !controller.isExpense.value
                                  ? const Color(0xFF2EA44F)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Income',
                              style: TextStyle(
                                color: !controller.isExpense.value
                                    ? Colors.white
                                    : (isDark
                                        ? Colors.white70
                                        : Colors.black),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --------------------------------------------------
              // FORM
              // --------------------------------------------------

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ------------------------------------------------
                      // AMOUNT
                      // ------------------------------------------------

                      Text(
                        'Amount',
                        style: TextStyle(
                          color: theme.hintColor,
                          fontSize: 13,
                        ),
                      ),

                      TextField(
                        controller: controller.amountController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(
                            color: theme.hintColor,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.dividerColor,
                            ),
                          ),
                          focusedBorder:
                              const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF2EA44F),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ------------------------------------------------
                      // CATEGORY
                      // ------------------------------------------------

                      Text(
                        'Category',
                        style: TextStyle(
                          color: theme.hintColor,
                          fontSize: 13,
                        ),
                      ),

                      Obx(() {
                        final currentList =
                            controller.isExpense.value
                                ? controller.expenseCategories
                                : controller.incomeCategories;

                        if (currentList.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              'No categories available.',
                              style: TextStyle(
                                color: theme.hintColor,
                              ),
                            ),
                          );
                        }

                        return DropdownButtonFormField<String>(
                          value: currentList.any(
                            (category) =>
                                category.id ==
                                controller
                                    .selectedCategoryId.value,
                          )
                              ? controller.selectedCategoryId.value
                              : null,
                          dropdownColor: theme.cardColor,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: theme.iconTheme.color ??
                                Colors.grey,
                          ),
                          style: TextStyle(
                            color:
                                theme.textTheme.bodyLarge?.color,
                          ),
                          decoration: InputDecoration(
                            enabledBorder:
                                UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: theme.dividerColor,
                              ),
                            ),
                            focusedBorder:
                                const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF2EA44F),
                              ),
                            ),
                          ),
                          items: currentList.map<DropdownMenuItem<String>>(
                            (category) {
                              return DropdownMenuItem<String>(
                                value: category.id,
                                child: Text(
                                  category.name,
                                  style: TextStyle(
                                    color: theme.textTheme
                                        .bodyMedium
                                        ?.color,
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.selectedCategoryId.value =
                                  value;
                            }
                          },
                        );
                      }),

                      const SizedBox(height: 24),

                      // ------------------------------------------------
                      // WALLET
                      // ------------------------------------------------

                      Text(
                        'Wallet',
                        style: TextStyle(
                          color: theme.hintColor,
                          fontSize: 13,
                        ),
                      ),

                      Obx(() {
                        final wallets =
                            controller.walletsController.wallets;

                        if (wallets.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              'No wallets available. Please add a wallet first.',
                              style: TextStyle(
                                color: theme.hintColor,
                              ),
                            ),
                          );
                        }

                        return DropdownButtonFormField<String>(
                          value: wallets.any(
                            (wallet) =>
                                wallet.id ==
                                controller.selectedWalletId.value,
                          )
                              ? controller.selectedWalletId.value
                              : null,
                          dropdownColor: theme.cardColor,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: theme.iconTheme.color ??
                                Colors.grey,
                          ),
                          style: TextStyle(
                            color:
                                theme.textTheme.bodyLarge?.color,
                          ),
                          decoration: InputDecoration(
                            enabledBorder:
                                UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: theme.dividerColor,
                              ),
                            ),
                            focusedBorder:
                                const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF2EA44F),
                              ),
                            ),
                          ),
                          items: wallets.map<DropdownMenuItem<String>>(
                            (wallet) {
                              return DropdownMenuItem<String>(
                                value: wallet.id,
                                child: Row(
                                  children: [
                                    Icon(
                                      _walletIcon(wallet.type),
                                      size: 20,
                                      color: const Color(
                                        0xFF2EA44F,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      wallet.name,
                                      style: TextStyle(
                                        color: theme.textTheme
                                            .bodyMedium
                                            ?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.selectedWalletId.value =
                                  value;
                            }
                          },
                        );
                      }),

                      const SizedBox(height: 24),

                      // ------------------------------------------------
                      // NOTE
                      // ------------------------------------------------

                      Text(
                        'Note (Optional)',
                        style: TextStyle(
                          color: theme.hintColor,
                          fontSize: 13,
                        ),
                      ),

                      TextField(
                        controller: controller.noteController,
                        style: TextStyle(
                          color:
                              theme.textTheme.bodyLarge?.color,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g., Lunch with team',
                          hintStyle: TextStyle(
                            color: theme.hintColor,
                          ),
                          enabledBorder:
                              UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.dividerColor,
                            ),
                          ),
                          focusedBorder:
                              const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF2EA44F),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --------------------------------------------------
              // SAVE
              // --------------------------------------------------

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF2EA44F),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.saveExpense,
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        :  Obx(
    () => Text(
      controller.isEditMode.value ? 'Update' : 'Save',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // --------------------------------------------------
              // CANCEL
              // --------------------------------------------------

              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: theme.hintColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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

