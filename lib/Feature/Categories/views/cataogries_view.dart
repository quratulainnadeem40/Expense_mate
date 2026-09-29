
import 'package:expense_mate/Feature/Bills_Reminders/view/bills_reminders_view.dart';
import 'package:expense_mate/Feature/Budgets/view/budget_view.dart';
import 'package:expense_mate/Feature/Categories/controller/categories_controller.dart';
import 'package:expense_mate/Feature/Categories/widgets/category_add_category_dialog.dart';
import 'package:expense_mate/Feature/Goals/view/goals_view.dart';
import 'package:expense_mate/Feature/Wallets/view/wallets_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  final CategoriesController controller =
      Get.put(CategoriesController());

  final Set<String> selectedCategories = {};
  bool isSelectionMode = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCategories();
    });
  }

  void _openAddCategoryDialog() {
    Get.dialog(
      const AddCategoryDialog(),
    );
  }

  void _toggleCategorySelection(String categoryId) {
    setState(() {
      if (selectedCategories.contains(categoryId)) {
        selectedCategories.remove(categoryId);
      } else {
        selectedCategories.add(categoryId);
      }

      isSelectionMode = selectedCategories.isNotEmpty;
    });
  }

  void _clearSelection() {
    setState(() {
      selectedCategories.clear();
      isSelectionMode = false;
    });
  }

  void _openCategoryTransactions(dynamic category) {
    Get.to(
      () => CategoryTransactionsScreen(
        categoryId: category.id.toString(),
        categoryName: category.name.toString(),
      ),
    );
  }

  String _formatAmount(double amount) {
    final value = amount.round().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      final positionFromEnd = value.length - i;

      buffer.write(value[i]);

      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }

    return 'Rs. $buffer';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        centerTitle: true,
        actions: [
          if (isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                for (final id in selectedCategories.toList()) {
                  await controller.deleteCategory(id);
                }

                _clearSelection();
              },
            ),
        ],
      ),

      // ============================================================
      // DRAWER
      // ============================================================

      endDrawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const UserAccountsDrawerHeader(
                accountName: Text('Expense Mate'),
                accountEmail: Text('Categories'),
                currentAccountPicture: CircleAvatar(
                  child: Icon(
                    Icons.person,
                    size: 32,
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text('Wallets'),
                onTap: () {
                  Get.back();
                  Get.to(
                    () => const WalletsView(),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.account_balance),
                title: const Text('Budgets'),
                onTap: () {
                  Get.back();
                  Get.to(
                    () => const BudgetView(),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('Goals'),
                onTap: () {
                  Get.back();
                  Get.to(
                    () => const GoalsView(),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text('Bills & Reminders'),
                onTap: () {
                  Get.back();
                  Get.to(
                    () => const BillsRemindersView(),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      // ============================================================
      // CATEGORIES LIST
      // ============================================================

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.categoryList.isEmpty) {
          return const Center(
            child: Text(
              'No categories found',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            140,
          ),
          itemCount: controller.categoryList.length,
          itemBuilder: (context, index) {
            final category = controller.categoryList[index];

            final bool isSelected =
                selectedCategories.contains(category.id);

            final int transactionCount =
                controller.getCategoryCount(category.id);

            final double totalAmount =
                controller.getCategoryTotal(category.id);

            return GestureDetector(
              onLongPress: () {
                _toggleCategorySelection(category.id);
              },
              onTap: () {
                if (isSelectionMode) {
                  _toggleCategorySelection(category.id);
                  return;
                }

                _openCategoryTransactions(category);
              },
              child: Container(
                margin: const EdgeInsets.only(
                  bottom: 12,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.green.withOpacity(0.12)
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Colors.green
                        : Colors.grey.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(
                          category.colorValue,
                        ).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _getCategoryIcon(
                          category.icon,
                        ),
                        color: Color(
                          category.colorValue,
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            '$transactionCount transactions',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            'Total: ${_formatAmount(totalAmount)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      )
                    else
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }),

      // ============================================================
      // ADD CATEGORY BUTTON
      // ============================================================

      floatingActionButton: isSelectionMode
          ? null
          : Padding(
              padding: const EdgeInsets.only(
                bottom: 12,
              ),
              child: FloatingActionButton(
                onPressed: _openAddCategoryDialog,
                child: const Icon(
                  Icons.add,
                ),
              ),
            ),
    );
  }

  // ============================================================
  // CATEGORY ICONS
  // ============================================================

  IconData _getCategoryIcon(String icon) {
    switch (icon.toLowerCase()) {
      case 'food':
        return Icons.restaurant;

      case 'transport':
        return Icons.directions_car;

      case 'shopping':
        return Icons.shopping_bag;

      case 'bills':
        return Icons.receipt_long;

      case 'education':
        return Icons.school;

      case 'health':
        return Icons.health_and_safety;

      case 'entertainment':
        return Icons.movie;

      case 'gift':
        return Icons.card_giftcard;

      case 'travel':
        return Icons.flight;

      case 'home':
        return Icons.home;

      case 'salary':
        return Icons.payments;

      case 'business':
        return Icons.business_center;

      default:
        return Icons.category;
    }
  }
}

// ============================================================
// CATEGORY TRANSACTIONS SCREEN
// ============================================================

class CategoryTransactionsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryTransactionsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryTransactionsScreen> createState() =>
      _CategoryTransactionsScreenState();
}

class _CategoryTransactionsScreenState
    extends State<CategoryTransactionsScreen> {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  bool isLoading = true;

  List<Map<String, dynamic>> transactions = [];

  double totalAmount = 0;

  @override
  void initState() {
    super.initState();

    _loadCategoryTransactions();
  }

  Future<void> _loadCategoryTransactions() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        return;
      }

      final response = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', user.id)
          .eq('category_id', widget.categoryId)
          .order(
            'transaction_date',
            ascending: false,
          );

      final loadedTransactions =
          List<Map<String, dynamic>>.from(response);

      double total = 0;

      for (final transaction in loadedTransactions) {
        final amount = transaction['amount'];

        if (amount is num) {
          total += amount.toDouble();
        } else {
          total +=
              double.tryParse(
                    amount
                            ?.toString()
                            .replaceAll(',', '') ??
                        '',
                  ) ??
                  0;
        }
      }

      if (!mounted) return;

      setState(() {
        transactions = loadedTransactions;
        totalAmount = total;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      Get.snackbar(
        'Error',
        'Unable to load category transactions',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ============================================================
  // AMOUNT FORMAT
  // ============================================================

  String _formatAmount(double amount) {
    final value = amount.round().toString();

    final buffer = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      final positionFromEnd = value.length - i;

      buffer.write(value[i]);

      if (positionFromEnd > 1 &&
          positionFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }

    return 'Rs. $buffer';
  }

  // ============================================================
  // SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName,
        ),
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // ==================================================
                // TOTAL CARD
                // ==================================================

                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        _formatAmount(totalAmount),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        '${transactions.length} transactions',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // ==================================================
                // TRANSACTIONS
                // ==================================================

                Expanded(
                  child: transactions.isEmpty
                      ? const Center(
                          child: Text(
                            'No transactions in this category',
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final transaction =
                                transactions[index];

                            final title =
                                transaction['title']
                                        ?.toString() ??
                                    'Transaction';

                            final amountValue =
                                transaction['amount'];

                            final double amount =
                                amountValue is num
                                    ? amountValue.toDouble()
                                    : double.tryParse(
                                          amountValue
                                                  ?.toString()
                                                  .replaceAll(
                                                    ',',
                                                    '',
                                                  ) ??
                                              '',
                                        ) ??
                                        0;

                            final type =
                                transaction['type']
                                        ?.toString()
                                        .toLowerCase() ??
                                    'expense';

                            final date =
                                transaction[
                                    'transaction_date'];

                            return Container(
                              margin: const EdgeInsets.only(
                                bottom: 10,
                              ),
                              padding: const EdgeInsets.all(
                                15,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .cardColor,
                                borderRadius:
                                    BorderRadius.circular(
                                  14,
                                ),
                                border: Border.all(
                                  color: Colors.grey
                                      .withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    child: Icon(
                                      type == 'income'
                                          ? Icons
                                              .arrow_downward
                                          : Icons
                                              .arrow_upward,
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          title,
                                          style:
                                              const TextStyle(
                                            fontWeight:
                                                FontWeight
                                                    .w600,
                                            fontSize: 15,
                                          ),
                                        ),

                                        const SizedBox(
                                          height: 5,
                                        ),

                                        if (date != null)
                                          Text(
                                            _formatDate(
                                              date.toString(),
                                            ),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors
                                                  .grey
                                                  .shade600,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  Text(
                                    '${type == 'income' ? '+' : '-'} ${_formatAmount(amount)}',
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 14,
                                      color: type == 'income'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(String value) {
    try {
      final date = DateTime.parse(value);

      final day =
          date.day.toString().padLeft(2, '0');

      final month =
          date.month.toString().padLeft(2, '0');

      final year =
          date.year.toString();

      return '$day/$month/$year';
    } catch (_) {
      return value;
    }
  }
}


