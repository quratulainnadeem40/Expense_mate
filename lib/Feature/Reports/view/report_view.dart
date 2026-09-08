import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

// Package Import Format
import 'package:expense_mate/Feature/Reports/controller/report_controller.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ReportController controller = Get.find<ReportController>();
    final theme = Theme.of(context);

    // Color Palette for Chart Categories
    final List<Color> categoryColors = [
      const Color(0xFF2EA44F),
      const Color(0xFFE55353),
      const Color(0xFF3399FF),
      const Color(0xFFF9B115),
      const Color(0xFF9C27B0),
      const Color(0xFF00BCD4),
      const Color(0xFFFF9800),
      const Color(0xFF673AB7),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Live Reports & Analytics'),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransactionBottomSheet(context, controller),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Entry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2EA44F),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Total Summary Cards
            Obx(
              () => Card(
                elevation: 2,
                color: theme.cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('Total Income', style: TextStyle(color: theme.hintColor, fontSize: 13)),
                          const SizedBox(height: 6),
                          Text(
                            'PKR ${controller.totalIncome.value.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(height: 35, width: 1, color: theme.dividerColor),
                      Column(
                        children: [
                          Text('Total Expenses', style: TextStyle(color: theme.hintColor, fontSize: 13)),
                          const SizedBox(height: 6),
                          Text(
                            'PKR ${controller.totalExpense.value.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 2. Clear Graph Breakdown Analysis
            Obx(() {
              if (controller.totalExpense.value > 0) {
                final breakdown = controller.categoryBreakdown;
                final categoriesList = breakdown.keys.toList();

                return Card(
                  color: theme.cardColor,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expense Breakdown Analysis',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Dynamic Chart
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 3,
                              centerSpaceRadius: 45,
                              sections: categoriesList.asMap().entries.map((entry) {
                                final index = entry.key;
                                final catName = entry.value;
                                final amount = breakdown[catName] ?? 0.0;
                                final percentage = ((amount / controller.totalExpense.value) * 100);

                                return PieChartSectionData(
                                  value: amount,
                                  title: '${percentage.toStringAsFixed(0)}%',
                                  radius: 55,
                                  titleStyle: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  color: categoryColors[index % categoryColors.length],
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Categories Clear Indicator Legend List
                        Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          children: categoriesList.asMap().entries.map((entry) {
                            final index = entry.key;
                            final catName = entry.value;
                            final amount = breakdown[catName] ?? 0.0;
                            final color = categoryColors[index % categoryColors.length];

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: color.withOpacity(0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(radius: 5, backgroundColor: color),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$catName: PKR ${amount.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: theme.textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            const SizedBox(height: 20),

            // 3. Transactions List
            Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 12),

            Obx(() {
              if (controller.transactions.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'No entries added yet.',
                      style: TextStyle(color: theme.hintColor),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.transactions.length,
                itemBuilder: (context, index) {
                  final item = controller.transactions[index];
                  return Card(
                    color: theme.cardColor,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: item.isIncome ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                        child: Icon(
                          item.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                          color: item.isIncome ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      subtitle: Text(
                        '${item.category} • ${item.date}',
                        style: TextStyle(fontSize: 12, color: theme.hintColor),
                      ),
                      trailing: Text(
                        '${item.isIncome ? "+" : "-"} PKR ${item.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: item.isIncome ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  // BottomSheet with Custom Category Field
  void _showAddTransactionBottomSheet(BuildContext context, ReportController controller) {
    final theme = Theme.of(context);
    final categories = ['Food & Dining', 'Shopping', 'Bills', 'Salary', 'Entertainment', 'General', '+ Add Custom Category'];
    final customCategoryController = TextEditingController();
    var isCustomSelected = false.obs;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Record',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.titleController,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  labelText: 'Title (e.g. Salary, Grocery)',
                  labelStyle: TextStyle(color: theme.hintColor),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.dividerColor)),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF2EA44F))),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  labelText: 'Amount (PKR)',
                  labelStyle: TextStyle(color: theme.hintColor),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.dividerColor)),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF2EA44F))),
                ),
              ),
              const SizedBox(height: 12),
              
              // Category Selection Dropdown
              Obx(
                () => DropdownButtonFormField<String>(
                  value: categories.contains(controller.selectedCategory.value)
                      ? controller.selectedCategory.value
                      : categories.first,
                  dropdownColor: theme.cardColor,
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(color: theme.hintColor),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.dividerColor)),
                    focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF2EA44F))),
                  ),
                  items: categories
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (val) {
                    if (val == '+ Add Custom Category') {
                      isCustomSelected.value = true;
                    } else if (val != null) {
                      isCustomSelected.value = false;
                      controller.selectedCategory.value = val;
                    }
                  },
                ),
              ),

              // Custom Category Input Field
              Obx(() {
                if (isCustomSelected.value) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: TextField(
                      controller: customCategoryController,
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                      decoration: InputDecoration(
                        labelText: 'Enter Custom Category Name',
                        labelStyle: TextStyle(color: theme.hintColor),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.dividerColor)),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF2EA44F))),
                      ),
                      onChanged: (val) {
                        if (val.trim().isNotEmpty) {
                          controller.selectedCategory.value = val.trim();
                        }
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () => controller.addTransaction(true),
                      child: const Text('Add Income', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => controller.addTransaction(false),
                      child: const Text('Add Expense', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}