
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:expense_mate/Feature/reports/controller/report_controller.dart';

import 'package:expense_mate/Feature/Budgets/bindings/budget_bindings.dart';
import 'package:expense_mate/Feature/Budgets/view/budget_view.dart';
import 'package:expense_mate/Feature/committee/view/committee_view.dart';
import 'package:expense_mate/Feature/wallets/binding/wallets_binding.dart';
import 'package:expense_mate/Feature/wallets/view/wallets_view.dart';
import 'package:expense_mate/Feature/goals/binding/goals_binding.dart';
import 'package:expense_mate/Feature/goals/view/goals_view.dart';
import 'package:expense_mate/Feature/bills_reminders/binding/bills_reminders_binding.dart';
import 'package:expense_mate/Feature/bills_reminders/view/bills_reminders_view.dart';
import 'package:expense_mate/Feature/settings/controller/settings_controller.dart';
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

    final SettingsController settingsController =
        Get.isRegistered<SettingsController>()
            ? Get.find<SettingsController>()
            : Get.put(SettingsController());

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,

      // ==========================================================
      // DRAWER
      // ==========================================================

      endDrawer: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(
            top: 12,
            bottom: 16,
            right: 12,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Drawer(
              elevation: 4,
              backgroundColor: isDarkMode
                  ? const Color(0xFF1E1E1E)
                  : const Color(0xFFF9FAFB),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 6,
                        right: 6,
                      ),
                      child: IconButton(
                        onPressed: () {
                          _scaffoldKey.currentState?.closeEndDrawer();
                        },
                        icon: Icon(
                          Icons.close,
                          size: 28,
                          color: isDarkMode
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  UserAccountsDrawerHeader(
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDarkMode
                            ? [
                                const Color(0xFF2E7D32),
                                const Color(0xFF1B5E20),
                              ]
                            : [
                                const Color(0xFF4CAF50),
                                const Color(0xFF388E3C),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    currentAccountPictureSize: const Size.square(64),
                    currentAccountPicture: Obx(() {
                      final imageUrl =
                          settingsController.profilePictureUrl.value;

                      final name =
                          settingsController.profileName.value;

                      final firstLetter = name.isNotEmpty
                          ? name[0].toUpperCase()
                          : 'U';

                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : null,
                          child: imageUrl.isEmpty
                              ? Text(
                                  firstLetter,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                )
                              : null,
                        ),
                      );
                    }),
                    accountName: Text(
                      Supabase
                              .instance
                              .client
                              .auth
                              .currentUser
                              ?.userMetadata?['full_name']
                              ?.toString() ??
                          Supabase
                              .instance
                              .client
                              .auth
                              .currentUser
                              ?.userMetadata?['name']
                              ?.toString() ??
                          'User',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    accountEmail: Text(
                      Supabase
                              .instance
                              .client
                              .auth
                              .currentUser
                              ?.email ??
                          '',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 16,
                      ),
                      children: [
                        _buildDrawerOption(
                          context: context,
                          icon: Icons.account_balance_wallet_rounded,
                          iconColor: const Color(0xFF3A5BA0),
                          emoji: '💳',
                          title: 'Wallets',
                          subtitle:
                              'Manage your cash, bank and other wallets',
                          onTap: () {
                            Navigator.of(context).pop();
                            Get.to(
                              () => const WalletsView(),
                              binding: WalletsBinding(),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildDrawerOption(
                          context: context,
                          icon: Icons.donut_small_rounded,
                          iconColor: const Color(0xFF2E7D32),
                          emoji: '📊',
                          title: 'Budgets',
                          subtitle:
                              'Set and track monthly spending limits',
                          onTap: () {
                            Navigator.of(context).pop();
                            Get.to(
                              () => const BudgetView(),
                              binding: BudgetBinding(),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildDrawerOption(
                          context: context,
                          icon: Icons.flag_rounded,
                          iconColor: const Color(0xFFB26A00),
                          emoji: '🎯',
                          title: 'Goals',
                          subtitle:
                              'Track your financial targets and savings',
                          onTap: () {
                            Navigator.of(context).pop();
                            Get.to(
                              () => const GoalsView(),
                              binding: GoalsBinding(),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildDrawerOption(
                          context: context,
                          icon: Icons.receipt_long_rounded,
                          iconColor: const Color(0xFF7A4EAB),
                          emoji: '🧾',
                          title: 'Bills & Reminders',
                          subtitle:
                              'Manage upcoming bills and reminders',
                          onTap: () {
                            Navigator.of(context).pop();
                            Get.to(
                              () => const BillsRemindersView(),
                              binding: BillsRemindersBinding(),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildDrawerOption(
                          context: context,
                          icon: Icons.groups_rounded,
                          iconColor: const Color(0xFF00695C),
                          emoji: '🤝',
                          title: 'Digital Committee',
                          subtitle:
                              'Manage your committee and member payments',
                          onTap: () {
                            Navigator.of(context).pop();
                            Get.to(
                              () => const CommitteeView(),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildDrawerOption(
                          context: context,
                          icon: Icons.person_rounded,
                          iconColor: const Color(0xFFF2C14E),
                          title: 'Profile',
                          subtitle:
                              'Manage your profile and account settings',
                          onTap: () {
                            Navigator.of(context).pop();
                            Get.to(
                              () => const SettingsView(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            final double income = controller.totalIncome;
            final double expense = controller.totalExpense;
            final double balance = controller.totalBalance;

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // YEAR & MONTH FILTERS
                  // ==================================================

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
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
                                      controller.selectedYear.value
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
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
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
                                  final int month = index + 1;

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
                                      controller.selectedMonth.value !=
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
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
                              controller.selectedYear.value != null &&
                                      controller.selectedMonth.value !=
                                          null
                                  ? '${_months[controller.selectedMonth.value! - 1]} ${controller.selectedYear.value}'
                                  : controller.selectedYear.value !=
                                          null
                                      ? 'Year ${controller.selectedYear.value}'
                                      : _months[
                                          controller
                                                  .selectedMonth
                                                  .value! -
                                              1],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
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
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
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
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatAmount(balance),
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
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
                    padding: const EdgeInsets.fromLTRB(
                      12,
                      20,
                      20,
                      15,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: BarChart(
                      BarChartData(
                        minY: 0,
                        maxY: _barMax(
                          income,
                          expense,
                        ),
                        gridData: FlGridData(
                          show: true,
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        barTouchData: BarTouchData(
                          enabled: true,
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
                              reservedSize: 50,
                              getTitlesWidget:
                                  (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 45,
                              getTitlesWidget:
                                  (value, meta) {
                                String text = '';

                                if (value.toInt() == 0) {
                                  text = 'Income';
                                } else if (value.toInt() == 1) {
                                  text = 'Expense';
                                }

                                return Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    top: 12,
                                  ),
                                  child: Text(
                                    text,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight:
                                          FontWeight.w600,
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
                                    BorderRadius.circular(4),
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
                                    BorderRadius.circular(4),
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
                    padding: const EdgeInsets.fromLTRB(
                      10,
                      20,
                      20,
                      15,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: LineChart(
                      LineChartData(
                        minX: 1,
                        maxX: 12,
                        minY: 0,

                        // IMPORTANT:
                        // The maximum Y value is exactly the
                        // highest actual expense amount.
                        maxY: _lineMax(monthlyData),

                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          verticalInterval: 1,
                          horizontalInterval:
                              _lineInterval(monthlyData),
                        ),

                        borderData: FlBorderData(
                          show: false,
                        ),

                        lineTouchData: LineTouchData(
                          enabled: true,
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
                              interval:
                                  _lineInterval(monthlyData),
                              getTitlesWidget:
                                  (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    fontSize: 9,
                                  ),
                                );
                              },
                            ),
                          ),

                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              reservedSize: 45,
                              getTitlesWidget:
                                  (value, meta) {
                                final int month =
                                    value.toInt();

                                if (month < 1 ||
                                    month > 12) {
                                  return const SizedBox.shrink();
                                }

                                return SideTitleWidget(
                                  meta: meta,
                                  space: 12,
                                  child: Text(
                                    _months[month - 1]
                                        .substring(0, 3),
                                    style: const TextStyle(
                                      fontSize: 9,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              12,
                              (index) {
                                final int month = index + 1;

                                // EXACT actual expense amount.
                                final double amount =
                                    monthlyData[month] ?? 0.0;

                                return FlSpot(
                                  month.toDouble(),
                                  amount,
                                );
                              },
                            ),
                            isCurved: false,
                            barWidth: 3,
                            dotData: const FlDotData(
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
                    padding: const EdgeInsets.fromLTRB(
                      10,
                      20,
                      20,
                      15,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: LineChart(
                      LineChartData(
                        minX: 1,
                        maxX: 12,
                        minY: 0,

                        // IMPORTANT:
                        // The maximum Y value is exactly the
                        // highest actual income amount.
                        maxY: _lineMax(monthlyIncomeData),

                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          verticalInterval: 1,
                          horizontalInterval:
                              _lineInterval(monthlyIncomeData),
                        ),

                        borderData: FlBorderData(
                          show: false,
                        ),

                        lineTouchData: LineTouchData(
                          enabled: true,
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
                              interval:
                                  _lineInterval(
                                monthlyIncomeData,
                              ),
                              getTitlesWidget:
                                  (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    fontSize: 9,
                                  ),
                                );
                              },
                            ),
                          ),

                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              reservedSize: 45,
                              getTitlesWidget:
                                  (value, meta) {
                                final int month =
                                    value.toInt();

                                if (month < 1 ||
                                    month > 12) {
                                  return const SizedBox.shrink();
                                }

                                return SideTitleWidget(
                                  meta: meta,
                                  space: 12,
                                  child: Text(
                                    _months[month - 1]
                                        .substring(0, 3),
                                    style: const TextStyle(
                                      fontSize: 9,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              12,
                              (index) {
                                final int month = index + 1;

                                // EXACT actual income amount.
                                final double amount =
                                    monthlyIncomeData[month] ??
                                        0.0;

                                return FlSpot(
                                  month.toDouble(),
                                  amount,
                                );
                              },
                            ),
                            isCurved: false,
                            barWidth: 3,
                            dotData: const FlDotData(
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatAmount(amount),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    BuildContext context,
    String title,
  ) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

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

  double _lineInterval(
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

    if (maximum <= 1000) {
      return 100;
    }

    if (maximum <= 5000) {
      return 500;
    }

    if (maximum <= 10000) {
      return 1000;
    }

    if (maximum <= 50000) {
      return 5000;
    }

    if (maximum <= 100000) {
      return 10000;
    }

    if (maximum <= 500000) {
      return 50000;
    }

    return 100000;
  }

  // ==============================================================
  // UPDATED LINE GRAPH MAXIMUM
  // ==============================================================

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

    // DO NOT add an extra interval.
    // The graph maximum must remain the actual highest amount.
    //
    // 10,000  -> maxY = 10,000
    // 15,000  -> maxY = 15,000
    // 50,000  -> maxY = 50,000
    // 100,000 -> maxY = 100,000
    return maximum;
  }

  Widget _categoryChart(
    BuildContext context,
    Map<String, double> data,
  ) {
    if (data.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No category data available',
          ),
        ),
      );
    }

    final double total = data.values.fold(
      0.0,
      (sum, value) => sum + value,
    );

    final List<MapEntry<String, double>> entries =
        data.entries.toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 230,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 45,
                sections: List.generate(
                  entries.length,
                  (index) {
                    final double percentage =
                        total == 0
                            ? 0
                            : (entries[index].value / total) * 100;

                    return PieChartSectionData(
                      value: entries[index].value,
                      title:
                          '${percentage.toStringAsFixed(1)}%',
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
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
              final String name = entries[index].key;
              final double amount = entries[index].value;

              final double percentage =
                  total == 0
                      ? 0
                      : (amount / total) * 100;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _categoryColor(index),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatAmount(amount),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
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

    return colors[index % colors.length];
  }

  Widget _buildDrawerOption({
    required BuildContext context,
    required IconData icon,
    String? emoji,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDarkMode =
        theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF2A2A2A)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              isDarkMode ? 0.2 : 0.04,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: emoji == null
                      ? Icon(
                          icon,
                          color: iconColor,
                          size: 24,
                        )
                      : Text(
                          emoji,
                          style: const TextStyle(
                            fontSize: 23,
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
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDarkMode
                              ? Colors.grey.shade400
                              : const Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDarkMode
                      ? Colors.grey.shade500
                      : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
