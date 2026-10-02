
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_mate/Feature/Categories/controller/categories_controller.dart';
import 'package:expense_mate/Feature/reports/controller/report_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportView extends StatelessWidget {
  ReportView({super.key});

  final ReportController controller =
      Get.isRegistered<ReportController>()
          ? Get.find<ReportController>()
          : Get.put(ReportController());

  String formatAmount(double amount) {
    final bool isNegative = amount < 0;
    final int rounded = amount.abs().round();

    final String value = rounded.toString();
    final StringBuffer result = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      final int positionFromEnd = value.length - i;

      result.write(value[i]);

      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        result.write(',');
      }
    }

    return isNegative ? '-${result.toString()}' : result.toString();
  }

  String formatPercentage(double percentage) {
    if (percentage == percentage.roundToDouble()) {
      return '${percentage.toInt()}%';
    }

    return '${percentage.toStringAsFixed(2)}%';
  }

  String getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }

  Color getCategoryColor(
    String categoryName,
    CategoriesController categoriesController,
  ) {
    final category =
        categoriesController.categoryList.firstWhereOrNull(
      (item) =>
          item.name.trim().toLowerCase() ==
          categoryName.trim().toLowerCase(),
    );

    if (category != null) {
      return Color(category.colorValue);
    }

    const fallbackColors = [
      Color(0xFF2EA44F),
      Color(0xFF2196F3),
      Color(0xFFFF9800),
      Color(0xFF9C27B0),
      Color(0xFFE53935),
      Color(0xFF00ACC1),
      Color(0xFF795548),
      Color(0xFF607D8B),
      Color(0xFFF06292),
      Color(0xFF7E57C2),
    ];

    final int index =
        categoryName.codeUnits.fold<int>(
              0,
              (previous, element) => previous + element,
            ) %
            fallbackColors.length;

    return fallbackColors[index];
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final bool isDarkMode = theme.brightness == Brightness.dark;

    final Color backgroundColor = theme.scaffoldBackgroundColor;

    final Color cardColor = theme.cardColor;

    final Color textColor =
        isDarkMode ? Colors.white : Colors.black87;

    final Color mutedTextColor =
        isDarkMode ? Colors.white70 : Colors.black54;

    final Color borderColor =
        isDarkMode ? Colors.white24 : Colors.black12;

    final CategoriesController categoriesController =
        Get.isRegistered<CategoriesController>()
            ? Get.find<CategoriesController>()
            : Get.put(CategoriesController());

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: Obx(() {
        final double income = controller.totalIncome;

        final double expense = controller.totalExpense;

        final double balance = controller.totalBalance;

        final Map<String, double> categoryData =
            controller.expenseCategories;

        final Map<int, double> monthlyData =
            controller.monthlyExpenses;

        return RefreshIndicator(
          onRefresh: controller.refreshReports,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              40,
            ),
            children: [
              // ==================================================
              // MONTH FILTER
              // ==================================================

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Months',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PopupMenuButton<int>(
                    color: cardColor,
                    onSelected: controller.setMonthFilter,
                    itemBuilder: (context) {
                      return List.generate(
                        12,
                        (index) {
                          final int month = index + 1;

                          return PopupMenuItem<int>(
                            value: month,
                            child: Text(
                              getMonthName(month),
                              style: TextStyle(
                                color: textColor,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: borderColor,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.selectedMonth.value == null
                                ? 'Select Month'
                                : getMonthName(
                                    controller.selectedMonth.value!,
                                  ),
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: mutedTextColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ==================================================
              // SUMMARY CARDS
              // ==================================================

              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      title: 'Total Income',
                      amount: income,
                      icon: Icons.arrow_downward,
                      iconColor: Colors.green,
                      cardColor: cardColor,
                      textColor: textColor,
                      mutedTextColor: mutedTextColor,
                      borderColor: borderColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _summaryCard(
                      title: 'Total Expense',
                      amount: expense,
                      icon: Icons.arrow_upward,
                      iconColor: Colors.red,
                      cardColor: cardColor,
                      textColor: textColor,
                      mutedTextColor: mutedTextColor,
                      borderColor: borderColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _balanceCard(
                balance: balance,
                cardColor: cardColor,
                textColor: textColor,
                mutedTextColor: mutedTextColor,
                borderColor: borderColor,
              ),

              const SizedBox(height: 24),

              // ==================================================
              // INCOME VS EXPENSE
              // ==================================================

              _sectionTitle(
                'Income vs Expense',
                textColor,
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  22,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: borderColor,
                  ),
                ),
                child: income == 0 && expense == 0
                    ? _emptyMessage(
                        'No income or expense data available',
                        mutedTextColor,
                      )
                    : SizedBox(
                        height: 280,
                        child: BarChart(
                          BarChartData(
                            alignment:
                                BarChartAlignment.spaceAround,
                            maxY: _maxChartValue(
                              income,
                              expense,
                            ),
                            borderData: FlBorderData(
                              show: false,
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                            ),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: false,
                                ),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: false,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 55,
                                  getTitlesWidget:
                                      (value, meta) {
                                    return Text(
                                      formatAmount(value),
                                      style: TextStyle(
                                        color: mutedTextColor,
                                        fontSize: 11,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 35,
                                  getTitlesWidget:
                                      (value, meta) {
                                    final String title =
                                        value.toInt() == 0
                                            ? 'Income'
                                            : 'Expense';

                                    return SideTitleWidget(
                                      meta: meta,
                                      space: 10,
                                      child: Text(
                                        title,
                                        textAlign:
                                            TextAlign.center,
                                        maxLines: 1,
                                        softWrap: false,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 13,
                                          fontWeight:
                                              FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData:
                                  BarTouchTooltipData(
                                getTooltipItem: (
                                  group,
                                  groupIndex,
                                  rod,
                                  rodIndex,
                                ) {
                                  final String label =
                                      group.x == 0
                                          ? 'Income'
                                          : 'Expense';

                                  return BarTooltipItem(
                                    '$label\nPKR ${formatAmount(rod.toY)}',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                            barGroups: [
                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(
                                    toY: income,
                                    color: Colors.green,
                                    width: 42,
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 1,
                                barRods: [
                                  BarChartRodData(
                                    toY: expense,
                                    color: Colors.red,
                                    width: 42,
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // EXPENSE CATEGORIES
              // ==================================================

              _sectionTitle(
                'Expense Categories',
                textColor,
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: borderColor,
                  ),
                ),
                child: categoryData.isEmpty
                    ? _emptyMessage(
                        'No expense categories yet.\nAdd an expense with a category to see the graph.',
                        mutedTextColor,
                      )
                    : Column(
                        children: [
                          SizedBox(
                            height: 300,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 58,
                                sections: categoryData.entries
                                    .map(
                                  (entry) {
                                    final double percentage =
                                        expense > 0
                                            ? (entry.value / expense) *
                                                100
                                            : 0;

                                    final Color categoryColor =
                                        getCategoryColor(
                                      entry.key,
                                      categoriesController,
                                    );

                                    return PieChartSectionData(
                                      value: entry.value,
                                      color: categoryColor,
                                      radius: 92,
                                      title: formatPercentage(
                                        percentage,
                                      ),
                                      titleStyle:
                                          const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(12),
                              border: Border.all(
                                color: borderColor,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Expense',
                                  style: TextStyle(
                                    color: mutedTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'PKR ${formatAmount(expense)}',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          ...categoryData.entries.map(
                            (entry) {
                              final double percentage =
                                  expense > 0
                                      ? (entry.value / expense) * 100
                                      : 0;

                              final Color categoryColor =
                                  getCategoryColor(
                                entry.key,
                                categoriesController,
                              );

                              return Container(
                                margin: const EdgeInsets.only(
                                  bottom: 10,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 11,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  border: Border.all(
                                    color: borderColor,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 13,
                                      height: 13,
                                      decoration: BoxDecoration(
                                        color: categoryColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        entry.key,
                                        overflow:
                                            TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: textColor,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'PKR ${formatAmount(entry.value)}',
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight:
                                            FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 55,
                                      child: Text(
                                        formatPercentage(
                                          percentage,
                                        ),
                                        textAlign:
                                            TextAlign.right,
                                        style: TextStyle(
                                          color: mutedTextColor,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // MONTHLY EXPENSES
              // ==================================================

              _sectionTitle(
                'Monthly Expenses',
                textColor,
              ),

              const SizedBox(height: 10),

              // Extra top spacing keeps the monthly graph
              // comfortably away from the bottom navigation area.
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: borderColor,
                  ),
                ),
                child: monthlyData.values.every(
                  (value) => value == 0,
                )
                    ? _emptyMessage(
                        'No monthly expense data available',
                        mutedTextColor,
                      )
                    : SizedBox(
                        height: 300,
                        child: LineChart(
                          LineChartData(
                            minX: 1,
                            maxX: 12,
                            minY: 0,
                            maxY: _monthlyMax(monthlyData),
                            gridData: FlGridData(
                              show: true,
                            ),
                            borderData: FlBorderData(
                              show: false,
                            ),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: false,
                                ),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: false,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 55,
                                  getTitlesWidget:
                                      (value, meta) {
                                    return Text(
                                      formatAmount(value),
                                      style: TextStyle(
                                        color: mutedTextColor,
                                        fontSize: 10,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  getTitlesWidget:
                                      (value, meta) {
                                    final int month =
                                        value.toInt();

                                    if (month < 1 ||
                                        month > 12) {
                                      return const SizedBox
                                          .shrink();
                                    }

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(
                                        top: 8,
                                      ),
                                      child: Text(
                                        getMonthName(month)
                                            .substring(0, 3),
                                        style: TextStyle(
                                          color: mutedTextColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            lineTouchData: LineTouchData(
                              enabled: true,
                              touchTooltipData:
                                  LineTouchTooltipData(
                                getTooltipItems: (spots) {
                                  return spots.map(
                                    (spot) {
                                      return LineTooltipItem(
                                        '${getMonthName(spot.x.toInt())}\nPKR ${formatAmount(spot.y)}',
                                        const TextStyle(
                                          color: Colors.white,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ).toList();
                                },
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: List.generate(
                                  12,
                                  (index) {
                                    final int month =
                                        index + 1;

                                    return FlSpot(
                                      month.toDouble(),
                                      monthlyData[month] ?? 0,
                                    );
                                  },
                                ),
                                isCurved: true,
                                barWidth: 3,
                                dotData: const FlDotData(
                                  show: true,
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  // ==========================================================
  // SUMMARY CARD
  // ==========================================================

  Widget _summaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color iconColor,
    required Color cardColor,
    required Color textColor,
    required Color mutedTextColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: mutedTextColor,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'PKR ${formatAmount(amount)}',
            style: TextStyle(
              color: textColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BALANCE CARD
  // ==========================================================

  Widget _balanceCard({
    required double balance,
    required Color cardColor,
    required Color textColor,
    required Color mutedTextColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Icon(
            balance >= 0
                ? Icons.account_balance_wallet_outlined
                : Icons.warning_amber_rounded,
            color: balance >= 0 ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Remaining Balance',
                  style: TextStyle(
                    color: mutedTextColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PKR ${formatAmount(balance.abs())}',
                  style: TextStyle(
                    color:
                        balance >= 0 ? textColor : Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SECTION TITLE
  // ==========================================================

  Widget _sectionTitle(
    String title,
    Color textColor,
  ) {
    return Text(
      title,
      style: TextStyle(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ==========================================================
  // EMPTY MESSAGE
  // ==========================================================

  Widget _emptyMessage(
    String message,
    Color mutedTextColor,
  ) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: mutedTextColor,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // BAR CHART MAX
  // ==========================================================

  double _maxChartValue(
    double income,
    double expense,
  ) {
    final double maximum =
        income > expense ? income : expense;

    if (maximum <= 0) {
      return 100;
    }

    return maximum * 1.25;
  }

  // ==========================================================
  // MONTHLY CHART MAX
  // ==========================================================

  double _monthlyMax(
    Map<int, double> data,
  ) {
    double maximum = 0;

    for (final value in data.values) {
      if (value > maximum) {
        maximum = value;
      }
    }

    if (maximum <= 0) {
      return 100;
    }

    return maximum * 1.25;
  }
}


