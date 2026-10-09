import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:expense_mate/Feature/reports/controller/report_controller.dart';

import 'package:expense_mate/Feature/Budgets/view/budget_view.dart';
import 'package:expense_mate/Feature/committee/view/committee_view.dart';
import 'package:expense_mate/Feature/wallets/binding/wallets_binding.dart';
import 'package:expense_mate/Feature/wallets/view/wallets_view.dart';
import 'package:expense_mate/Feature/goals/binding/goals_binding.dart';
import 'package:expense_mate/Feature/goals/view/goals_view.dart';
import 'package:expense_mate/Feature/bills_reminders/binding/bills_reminders_binding.dart';
import 'package:expense_mate/Feature/bills_reminders/view/bills_reminders_view.dart';
import 'package:expense_mate/Feature/settings/view/settings_view.dart';

class ReportView extends StatelessWidget {
  const ReportView({super.key});

  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  static const List<String> _months = [
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

  String _formatAmount(double amount) {
    return 'PKR ${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final ReportController controller =
        Get.isRegistered<ReportController>()
            ? Get.find<ReportController>()
            : Get.put(ReportController());

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ==========================================================
      // DRAWER
      // ==========================================================

      endDrawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),

              const SizedBox(height: 10),

              ListTile(
                leading: const Icon(
                  Icons.account_balance_wallet,
                ),
                title: const Text('Wallets'),
                onTap: () {
                  Navigator.of(context).pop();

                  Get.to(
                    () => const WalletsView(),
                    binding: WalletsBinding(),
                  );
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.account_balance,
                ),
                title: const Text('Budgets'),
                onTap: () {
                  Navigator.of(context).pop();

                  Get.to(
                    () => const BudgetView(),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('Goals'),
                onTap: () {
                  Navigator.of(context).pop();

                  Get.to(
                    () => const GoalsView(),
                    binding: GoalsBinding(),
                  );
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.notifications_active,
                ),
                title: const Text('Bills & Reminders'),
                onTap: () {
                  Navigator.of(context).pop();

                  Get.to(
                    () => const BillsRemindersView(),
                    binding: BillsRemindersBinding(),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.groups),
                title: const Text('Digital Committee'),
                onTap: () {
                  Navigator.of(context).pop();

                  Get.to(
                    () => const CommitteeView(),
                  );
                },
              ),

              const Spacer(),

              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.of(context).pop();

                  Get.to(
                    () => const SettingsView(),
                  );
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        title: const Text('Reports'),
        centerTitle: true,
        elevation: 0,
        backgroundColor:
            Theme.of(context).scaffoldBackgroundColor,
        foregroundColor:
            Theme.of(context).textTheme.bodyLarge?.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.refreshReports();
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: SafeArea(
        child: Obx(
          () {
            final double income =
                controller.totalIncome;

            final double expense =
                controller.totalExpense;

            final double balance =
                controller.totalBalance;

            final Map<String, double> categoryData =
                controller.expenseCategories;

            final Map<String, double> incomeCategoryData =
                controller.incomeCategories;

            final Map<int, double> monthlyData =
                controller.monthlyExpenses;

            final Map<int, double> monthlyIncomeData =
                controller.monthlyIncome;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                30,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // YEAR & MONTH FILTERS
                  // ==================================================

                  Row(
                    children: [
                      // ------------------------------------------------
                      // YEAR
                      // ------------------------------------------------

                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).cardColor,
                            borderRadius:
                                BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  Theme.of(context).dividerColor,
                            ),
                          ),
                          child: PopupMenuButton<int>(
                            tooltip: 'Select Year',
                            offset: const Offset(0, 50),
                            onSelected: (int year) {
                              controller.setYearFilter(year);
                            },
                            itemBuilder: (context) {
                              final List<int> years =
                                  controller.availableYears;

                              if (years.isEmpty) {
                                return [
                                  PopupMenuItem<int>(
                                    enabled: false,
                                    child: Text(
                                      DateTime.now()
                                          .year
                                          .toString(),
                                    ),
                                  ),
                                ];
                              }

                              return years.map(
                                (int year) {
                                  return PopupMenuItem<int>(
                                    value: year,
                                    child: Text(
                                      year.toString(),
                                    ),
                                  );
                                },
                              ).toList();
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 19,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      controller
                                              .selectedYear
                                              .value
                                              ?.toString() ??
                                          'Year',
                                      overflow:
                                          TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // ------------------------------------------------
                      // MONTH
                      // ------------------------------------------------

                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).cardColor,
                            borderRadius:
                                BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  Theme.of(context).dividerColor,
                            ),
                          ),
                          child: PopupMenuButton<int>(
                            tooltip: 'Select Month',
                            offset: const Offset(0, 50),
                            onSelected: (int month) {
                              controller.setMonthFilter(month);
                            },
                            itemBuilder: (context) {
                              return List.generate(
                                12,
                                (index) {
                                  final int month =
                                      index + 1;

                                  return PopupMenuItem<int>(
                                    value: month,
                                    child: Text(
                                      _months[index],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.date_range,
                                    size: 19,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      controller
                                                  .selectedMonth
                                                  .value !=
                                              null
                                          ? _months[
                                              controller
                                                      .selectedMonth
                                                      .value! -
                                                  1]
                                          : 'Month',
                                      overflow:
                                          TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // SELECTED FILTER INFORMATION
                  // ==================================================

                  if (controller.selectedYear.value != null ||
                      controller.selectedMonth.value != null)
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).cardColor,
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.filter_alt,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.selectedYear.value !=
                                          null &&
                                      controller.selectedMonth
                                              .value !=
                                          null
                                  ? '${_months[controller.selectedMonth.value! - 1]} ${controller.selectedYear.value}'
                                  : controller.selectedYear
                                              .value !=
                                          null
                                      ? 'Year ${controller.selectedYear.value}'
                                      : _months[
                                          controller
                                                  .selectedMonth
                                                  .value! -
                                              1],
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            visualDensity:
                                VisualDensity.compact,
                            icon: const Icon(
                              Icons.clear,
                              size: 19,
                            ),
                            onPressed: () {
                              controller.clearYearFilter();
                              controller.clearMonthFilter();
                            },
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // SUMMARY CARDS
                  // ==================================================

                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          context,
                          title: 'Total Income',
                          amount: income,
                          icon: Icons.arrow_downward,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summaryCard(
                          context,
                          title: 'Total Expense',
                          amount: expense,
                          icon: Icons.arrow_upward,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // REMAINING BALANCE
                  // ==================================================

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Remaining Balance',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatAmount(balance),
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // INCOME VS EXPENSE
                  // ==================================================

                  _sectionTitle(
                    context,
                    'Income vs Expense',
                  ),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    height: 300,
                    padding:
                        const EdgeInsets.fromLTRB(
                      12,
                      20,
                      20,
                      15,
                    ),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: BarChart(
                      BarChartData(
                        minY: 0,
                        maxY:
                            _barMax(income, expense),
                        gridData: FlGridData(
                          show: true,
                        ),
                        borderData:
                            FlBorderData(
                          show: false,
                        ),
                        barTouchData:
                            BarTouchData(
                          enabled: true,
                        ),
                        titlesData:
                            FlTitlesData(
                          topTitles:
                              const AxisTitles(
                            sideTitles:
                                SideTitles(
                              showTitles: false,
                            ),
                          ),
                          rightTitles:
                              const AxisTitles(
                            sideTitles:
                                SideTitles(
                              showTitles: false,
                            ),
                          ),
                          leftTitles:
                              AxisTitles(
                            sideTitles:
                                SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget:
                                  (value, meta) {
                                return Text(
                                  value
                                      .toInt()
                                      .toString(),
                                  style:
                                      const TextStyle(
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles:
                              AxisTitles(
                            sideTitles:
                                SideTitles(
                              showTitles: true,
                              reservedSize: 45,
                              getTitlesWidget:
                                  (value, meta) {
                                String text = '';

                                if (value.toInt() ==
                                    0) {
                                  text = 'Income';
                                } else if (value
                                        .toInt() ==
                                    1) {
                                  text = 'Expense';
                                }

                                return Padding(
                                  padding:
                                      const EdgeInsets
                                          .only(
                                    top: 12,
                                  ),
                                  child: Text(
                                    text,
                                    style:
                                        const TextStyle(
                                      fontSize: 12,
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barsSpace: 0,
                            barRods: [
                              BarChartRodData(
                                toY: income,
                                width: 38,
                                borderRadius:
                                    BorderRadius
                                        .circular(4),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barsSpace: 0,
                            barRods: [
                              BarChartRodData(
                                toY: expense,
                                width: 38,
                                borderRadius:
                                    BorderRadius
                                        .circular(4),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // EXPENSE CATEGORIES
                  // ==================================================

                  _sectionTitle(
                    context,
                    'Expense Categories',
                  ),

                  const SizedBox(height: 12),

                  _categoryChart(
                    context,
                    categoryData,
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // INCOME CATEGORIES
                  // ==================================================

                  _sectionTitle(
                    context,
                    'Income Categories',
                  ),

                  const SizedBox(height: 12),

                  _categoryChart(
                    context,
                    incomeCategoryData,
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // MONTHLY EXPENSES
                  // ==================================================

                  _sectionTitle(
                    context,
                    'Monthly Expenses',
                  ),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    height: 300,
                    padding:
                        const EdgeInsets.fromLTRB(
                      10,
                      20,
                      20,
                      15,
                    ),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: LineChart(
                      LineChartData(
                        minX: 1,
                        maxX: 12,
                        minY: 0,
                        maxY:
                            _lineMax(monthlyData),
                        gridData: FlGridData(
                          show: true,
                        ),
                        borderData:
                            FlBorderData(
                          show: false,
                        ),
                        titlesData:
                            FlTitlesData(
                          topTitles:
                              const AxisTitles(
                            sideTitles:
                                SideTitles(
                              showTitles: false,
                            ),
                          ),
                          rightTitles:
                              const AxisTitles(
                            sideTitles:
                                SideTitles(
                              showTitles: false,
                            ),
                          ),
                          leftTitles:
                              AxisTitles(
                            sideTitles:
                                SideTitles(
                              showTitles: true,
                              reservedSize: 48,
                              getTitlesWidget:
                                  (value, meta) {
                                return Text(
                                  value
                                      .toInt()
                                      .toString(),
                                  style:
                                      const TextStyle(
                                    fontSize: 9,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles:
                              AxisTitles(
                            sideTitles:
                                SideTitles(
                              showTitles: true,
                              interval: 1,
                              reservedSize: 32,
                              getTitlesWidget:
                                  (value, meta) {
                                final int month =
                                    value.toInt();

                                if (month < 1 ||
                                    month > 12) {
                                  return const SizedBox();
                                }

                                return Text(
                                  _months[
                                          month - 1]
                                      .substring(
                                          0, 3),
                                  style:
                                      const TextStyle(
                                    fontSize: 9,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots:
                                List.generate(
                              12,
                              (index) {
                                final int month =
                                    index + 1;

                                return FlSpot(
                                  month.toDouble(),
                                  monthlyData[
                                          month] ??
                                      0.0,
                                );
                              },
                            ),
                            isCurved: true,
                            barWidth: 3,
                            dotData:
                                FlDotData(
                              show: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // MONTHLY INCOME
                  // ==================================================

                  _sectionTitle(
                    context,
                    'Monthly Income',
                  ),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    height: 300,
                    padding:
                        const EdgeInsets.fromLTRB(
                      10,
                      20,
                      20,
                      15,
                    ),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: LineChart(
                      LineChartData(
                        minX: 1,
                        maxX: 12,
                        minY: 0,
                        maxY:
                            _lineMax(
                          monthlyIncomeData,
                        ),
                        gridData: FlGridData(
                          show: true,
                        ),
                        borderData:
                            FlBorderData(
                          show: false,
                        ),
                        titlesData:
                            FlTitlesData(
                          topTitles:
                              const AxisTitles(
                            sideTitles:
                                SideTitles(
                              showTitles: false,
                            ),
                          ),
                          rightTitles:
                              const AxisTitles(
                            sideTitles:
                                SideTitles(
                              showTitles: false,
                            ),
                          ),
                          leftTitles:
                              AxisTitles(
                            sideTitles:
                                SideTitles(
                              showTitles: true,
                              reservedSize: 48,
                              getTitlesWidget:
                                  (value, meta) {
                                return Text(
                                  value
                                      .toInt()
                                      .toString(),
                                  style:
                                      const TextStyle(
                                    fontSize: 9,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles:
                              AxisTitles(
                            sideTitles:
                                SideTitles(
                              showTitles: true,
                              interval: 1,
                              reservedSize: 32,
                              getTitlesWidget:
                                  (value, meta) {
                                final int month =
                                    value.toInt();

                                if (month < 1 ||
                                    month > 12) {
                                  return const SizedBox();
                                }

                                return Text(
                                  _months[
                                          month - 1]
                                      .substring(
                                          0, 3),
                                  style:
                                      const TextStyle(
                                    fontSize: 9,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots:
                                List.generate(
                              12,
                              (index) {
                                final int month =
                                    index + 1;

                                return FlSpot(
                                  month.toDouble(),
                                  monthlyIncomeData[
                                          month] ??
                                      0.0,
                                );
                              },
                            ),
                            isCurved: true,
                            barWidth: 3,
                            dotData:
                                FlDotData(
                              show: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================================
  // SUMMARY CARD
  // ==========================================================

  Widget _summaryCard(
    BuildContext context, {
    required String title,
    required double amount,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatAmount(amount),
            style: const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
            overflow:
                TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SECTION TITLE
  // ==========================================================

  Widget _sectionTitle(
    BuildContext context,
    String title,
  ) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(
            fontWeight:
                FontWeight.bold,
          ),
    );
  }

  // ==========================================================
  // BAR CHART MAX
  // ==========================================================

  double _barMax(
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
  // LINE CHART MAX
  // ==========================================================

  double _lineMax(
    Map<int, double> data,
  ) {
    double maximum = 0;

    for (final double value in data.values) {
      if (value > maximum) {
        maximum = value;
      }
    }

    if (maximum <= 0) {
      return 100;
    }

    return maximum * 1.25;
  }

  // ==========================================================
  // CATEGORY CHART
  // ==========================================================

  Widget _categoryChart(
    BuildContext context,
    Map<String, double> data,
  ) {
    if (data.isEmpty) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color:
              Theme.of(context).cardColor,
          borderRadius:
              BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No category data available',
          ),
        ),
      );
    }

    final double total =
        data.values.fold(
      0.0,
      (sum, value) => sum + value,
    );

    final List<MapEntry<String, double>>
        entries = data.entries.toList();

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            Theme.of(context).cardColor,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 230,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 45,
                sections:
                    List.generate(
                  entries.length,
                  (index) {
                    final double
                        percentage =
                        total == 0
                            ? 0
                            : (entries[index]
                                        .value /
                                    total) *
                                100;

                    return PieChartSectionData(
                      value:
                          entries[index].value,
                      title:
                          '${percentage.toStringAsFixed(1)}%',
                      radius: 80,
                      titleStyle:
                          const TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          ...List.generate(
            entries.length,
            (index) {
              final String name =
                  entries[index].key;

              final double amount =
                  entries[index].value;

              final double percentage =
                  total == 0
                      ? 0
                      : (amount / total) * 100;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,
                        color:
                            _categoryColor(
                                index),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        name,
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                        width: 12),
                    Text(
                      _formatAmount(amount),
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w600,
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
  }

  // ==========================================================
  // CATEGORY COLORS
  // ==========================================================

  Color _categoryColor(int index) {
    const List<Color> colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];

    return colors[
        index % colors.length];
  }
}