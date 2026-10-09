import 'dart:math' as math;

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
    final ReportController controller = Get.isRegistered<ReportController>()
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
          margin: const EdgeInsets.only(top: 12, bottom: 16, right: 12),
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
                      padding: const EdgeInsets.only(top: 6, right: 6),
                      child: IconButton(
                        onPressed: () {
                          _scaffoldKey.currentState?.closeEndDrawer();
                        },
                        icon: Icon(
                          Icons.close,
                          size: 28,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  UserAccountsDrawerHeader(
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDarkMode
                            ? [const Color(0xFF2E7D32), const Color(0xFF1B5E20)]
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

                      final name = settingsController.profileName.value;

                      final firstLetter = name.isNotEmpty
                          ? name[0].toUpperCase()
                          : 'U';

                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
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
                      Supabase.instance.client.auth.currentUser?.email ?? '',
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
                          subtitle: 'Manage your cash, bank and other wallets',
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
                          subtitle: 'Set and track monthly spending limits',
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
                          subtitle: 'Track your financial targets and savings',
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
                          subtitle: 'Manage upcoming bills and reminders',
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
                          subtitle: 'Manage your committee and member payments',
                          onTap: () {
                            Navigator.of(context).pop();
                            Get.to(() => const CommitteeView());
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildDrawerOption(
                          context: context,
                          icon: Icons.person_rounded,
                          iconColor: const Color(0xFFF2C14E),
                          title: 'Profile',
                          subtitle: 'Manage your profile and account settings',
                          onTap: () {
                            Navigator.of(context).pop();
                            Get.to(() => const SettingsView());
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
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
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
        child: Obx(() {
          final double income = controller.totalIncome;
          final double expense = controller.totalExpense;
          final double balance = controller.totalBalance;

          final Map<String, double> categoryData = controller.expenseCategories;

          final Map<String, double> incomeCategoryData =
              controller.incomeCategories;

          final Map<int, double> monthlyData = controller.monthlyExpenses;

          final Map<int, double> monthlyIncomeData = controller.monthlyIncome;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
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
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: PopupMenuButton<int>(
                          tooltip: 'Select Year',
                          offset: const Offset(0, 50),
                          onSelected: (int year) {
                            controller.setYearFilter(year);
                          },
                          itemBuilder: (context) {
                            final List<int> years = controller.availableYears;

                            if (years.isEmpty) {
                              return [
                                PopupMenuItem<int>(
                                  enabled: false,
                                  child: Text(DateTime.now().year.toString()),
                                ),
                              ];
                            }

                            return years.map((int year) {
                              return PopupMenuItem<int>(
                                value: year,
                                child: Text(year.toString()),
                              );
                            }).toList();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 19),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    controller.selectedYear.value?.toString() ??
                                        'Year',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down),
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
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: PopupMenuButton<int>(
                          tooltip: 'Select Month',
                          offset: const Offset(0, 50),
                          onSelected: (int month) {
                            controller.setMonthFilter(month);
                          },
                          itemBuilder: (context) {
                            return List.generate(12, (index) {
                              final int month = index + 1;

                              return PopupMenuItem<int>(
                                value: month,
                                child: Text(_months[index]),
                              );
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Row(
                              children: [
                                const Icon(Icons.date_range, size: 19),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    controller.selectedMonth.value != null
                                        ? _months[controller
                                                  .selectedMonth
                                                  .value! -
                                              1]
                                        : 'Month',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down),
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_alt, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.selectedYear.value != null &&
                                    controller.selectedMonth.value != null
                                ? '${_months[controller.selectedMonth.value! - 1]} ${controller.selectedYear.value}'
                                : controller.selectedYear.value != null
                                ? 'Year ${controller.selectedYear.value}'
                                : _months[controller.selectedMonth.value! - 1],
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.clear, size: 19),
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
                        icon: Icons.south_west_rounded,
                        accentColor: const Color(0xFF16A085),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryCard(
                        context,
                        title: 'Total Expense',
                        amount: expense,
                        icon: Icons.north_east_rounded,
                        accentColor: const Color(0xFFE47745),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ==================================================
                // REMAINING BALANCE
                // ==================================================
                _balanceCard(context, balance: balance),

                const SizedBox(height: 24),

                // ==================================================
                // INCOME VS EXPENSE
                // ==================================================
                _sectionTitle(context, 'Income vs Expense'),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  height: 300,
                  padding: const EdgeInsets.fromLTRB(12, 20, 20, 15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: BarChart(
                    BarChartData(
                      minY: 0,
                      maxY: _barMax(income, expense),
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: _barInterval(income, expense),
                      ),
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final label = group.x == 0 ? 'Income' : 'Expense';
                            return BarTooltipItem(
                              '$label\nPKR ${rod.toY}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 68,
                            interval: _barInterval(income, expense),
                            getTitlesWidget: (value, meta) {
                              return Text(
                                _formatBarAxisValue(
                                  value,
                                  _barInterval(income, expense),
                                ),
                                style: const TextStyle(fontSize: 9),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 45,
                            getTitlesWidget: (value, meta) {
                              String text = '';

                              if (value.toInt() == 0) {
                                text = 'Income';
                              } else if (value.toInt() == 1) {
                                text = 'Expense';
                              }

                              return Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  text,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
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
                              borderRadius: BorderRadius.circular(4),
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
                              borderRadius: BorderRadius.circular(4),
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
                _sectionTitle(context, 'Expense Categories'),

                const SizedBox(height: 12),

                _categoryChart(context, categoryData, isIncome: false),

                const SizedBox(height: 28),

                // ==================================================
                // INCOME CATEGORIES
                // ==================================================
                _sectionTitle(context, 'Income Categories'),

                const SizedBox(height: 12),

                _categoryChart(context, incomeCategoryData, isIncome: true),

                const SizedBox(height: 28),

                // ==================================================
                // MONTHLY EXPENSES
                // ==================================================
                _sectionTitle(context, 'Monthly Expenses'),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  height: 300,
                  padding: const EdgeInsets.fromLTRB(10, 20, 20, 15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
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
                        horizontalInterval: _lineInterval(monthlyData),
                      ),

                      borderData: FlBorderData(show: false),

                      lineTouchData: LineTouchData(enabled: true),

                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),

                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),

                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 55,
                            interval: _lineInterval(monthlyData),
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 9),
                              );
                            },
                          ),
                        ),

                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 45,
                            getTitlesWidget: (value, meta) {
                              final int month = value.toInt();

                              if (month < 1 || month > 12) {
                                return const SizedBox.shrink();
                              }

                              return SideTitleWidget(
                                meta: meta,
                                space: 12,
                                child: Text(
                                  _months[month - 1].substring(0, 3),
                                  style: const TextStyle(fontSize: 9),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(12, (index) {
                            final int month = index + 1;

                            // EXACT actual expense amount.
                            final double amount = monthlyData[month] ?? 0.0;

                            return FlSpot(month.toDouble(), amount);
                          }),
                          isCurved: false,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ==================================================
                // MONTHLY INCOME
                // ==================================================
                _sectionTitle(context, 'Monthly Income'),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  height: 300,
                  padding: const EdgeInsets.fromLTRB(10, 20, 20, 15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: LineChart(
                    LineChartData(
                      minX: 1,
                      maxX: 12,
                      minY: 0,
                      maxY: _monthlyIncomeAxisMax(monthlyIncomeData),

                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        verticalInterval: 1,
                        horizontalInterval: _monthlyIncomeAxisInterval(
                          monthlyIncomeData,
                        ),
                      ),

                      borderData: FlBorderData(show: false),

                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final int month = spot.x.round();
                              final String monthName =
                                  month >= 1 && month <= _months.length
                                  ? _months[month - 1]
                                  : '';
                              return LineTooltipItem(
                                '$monthName\nPKR ${spot.y}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),

                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),

                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),

                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 68,
                            interval: _monthlyIncomeAxisInterval(
                              monthlyIncomeData,
                            ),
                            getTitlesWidget: (value, meta) {
                              return Text(
                                _formatMonthlyIncomeAxisValue(
                                  value,
                                  _monthlyIncomeAxisInterval(monthlyIncomeData),
                                ),
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.clip,
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 9),
                              );
                            },
                          ),
                        ),

                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 45,
                            getTitlesWidget: (value, meta) {
                              final int month = value.toInt();

                              if (month < 1 || month > 12) {
                                return const SizedBox.shrink();
                              }

                              return SideTitleWidget(
                                meta: meta,
                                space: 12,
                                child: Text(
                                  _months[month - 1].substring(0, 3),
                                  style: const TextStyle(fontSize: 9),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(12, (index) {
                            final int month = index + 1;

                            // EXACT actual income amount.
                            final double rawAmount =
                                monthlyIncomeData[month] ?? 0.0;
                            final double amount = rawAmount.isFinite
                                ? rawAmount
                                : 0;

                            return FlSpot(month.toDouble(), amount);
                          }),
                          isCurved: false,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _summaryCard(
    BuildContext context, {
    required String title,
    required double amount,
    required IconData icon,
    required Color accentColor,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withOpacity(isDarkMode ? 0.32 : 0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(isDarkMode ? 0.08 : 0.07),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(isDarkMode ? 0.18 : 0.11),
              borderRadius: BorderRadius.circular(13),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: accentColor),
          ),
          const SizedBox(height: 13),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.72),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _formatAmount(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceCard(BuildContext context, {required double balance}) {
    const fabGreen = Color(0xFF2EA44F);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: fabGreen,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: fabGreen.withOpacity(0.24),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Saved Balance',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.88),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _formatAmount(balance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.trending_up_rounded,
              color: Colors.white,
              size: 29,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  double _barMax(double income, double expense) {
    final double maximum = income > expense ? income : expense;
    final double interval = _barInterval(income, expense);

    if (maximum <= 0) {
      return 5 * interval;
    }

    final double paddedMaximum = maximum + maximum * 0.1;
    final double targetMaximum = paddedMaximum.isFinite
        ? paddedMaximum
        : maximum;
    final double roundedMaximum =
        (targetMaximum / interval).ceilToDouble() * interval;

    if (!roundedMaximum.isFinite || roundedMaximum < maximum) {
      return maximum;
    }

    return roundedMaximum;
  }

  double _barInterval(double income, double expense) {
    final double maximum = income > expense ? income : expense;

    if (maximum <= 0) {
      return 20;
    }

    final double roughInterval = maximum / 5;
    if (roughInterval == 0) {
      return maximum;
    }

    final int exponent = (math.log(roughInterval) / math.ln10).floor();
    final double magnitude = math.pow(10, exponent).toDouble();
    if (magnitude == 0 || !magnitude.isFinite) {
      return roughInterval;
    }
    final double normalized = roughInterval / magnitude;
    final double step = normalized <= 1
        ? 1
        : normalized <= 2
        ? 2
        : normalized <= 2.5
        ? 2.5
        : normalized <= 5
        ? 5
        : 10;

    final double interval = step * magnitude;
    return interval > 0 && interval.isFinite ? interval : roughInterval;
  }

  String _formatBarAxisValue(double value, double interval) {
    if (value == 0) {
      return '0';
    }

    final double absoluteValue = value.abs();
    if (absoluteValue < 0.001 || absoluteValue >= 1e15) {
      return value.toStringAsExponential(2);
    }

    if (absoluteValue >= 1e3) {
      final (double divisor, String suffix) = absoluteValue >= 1e12
          ? (1e12, 'T')
          : absoluteValue >= 1e9
          ? (1e9, 'B')
          : absoluteValue >= 1e6
          ? (1e6, 'M')
          : (1e3, 'K');
      final String scaled = (absoluteValue / divisor)
          .toStringAsFixed(2)
          .replaceFirst(RegExp(r'\.?0+$'), '');
      return '${value < 0 ? '-' : ''}$scaled$suffix';
    }

    final String intervalString = interval.toString();
    final int decimalPlaces = intervalString.contains('.')
        ? intervalString.split('.').last.length
        : 0;
    final List<String> parts = absoluteValue
        .toStringAsFixed(decimalPlaces)
        .split('.');
    final String digits = parts.first;
    final StringBuffer formatted = StringBuffer();

    for (int index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) {
        formatted.write(',');
      }
      formatted.write(digits[index]);
    }

    final String decimals = parts.length > 1 ? '.${parts.last}' : '';
    return '${value < 0 ? '-' : ''}$formatted$decimals';
  }

  double _lineInterval(Map<int, double> data) {
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

  double _lineMax(Map<int, double> data) {
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

  double _monthlyIncomeMaximum(Map<int, double> data) {
    double maximum = 0;
    for (final double amount in data.values) {
      if (amount.isFinite && amount > maximum) {
        maximum = amount;
      }
    }
    return maximum;
  }

  double _monthlyIncomeAxisInterval(Map<int, double> data) {
    final double maximum = _monthlyIncomeMaximum(data);
    if (maximum == 0) {
      return 1;
    }

    final double roughInterval = maximum / 5;
    if (roughInterval == 0 || !roughInterval.isFinite) {
      return maximum;
    }

    final int exponent = (math.log(roughInterval) / math.ln10).floor();
    final double magnitude = math.pow(10, exponent).toDouble();
    if (magnitude == 0 || !magnitude.isFinite) {
      return roughInterval;
    }

    final double normalized = roughInterval / magnitude;
    final double step = normalized <= 1
        ? 1
        : normalized <= 2
        ? 2
        : normalized <= 2.5
        ? 2.5
        : normalized <= 5
        ? 5
        : 10;
    final double interval = step * magnitude;
    return interval > 0 && interval.isFinite ? interval : roughInterval;
  }

  double _monthlyIncomeAxisMax(Map<int, double> data) {
    final double maximum = _monthlyIncomeMaximum(data);
    final double interval = _monthlyIncomeAxisInterval(data);
    if (maximum == 0) {
      return interval * 5;
    }

    final double target = maximum + interval * 0.5;
    final double safeTarget = target.isFinite ? target : maximum;
    final double roundedMax = (safeTarget / interval).ceilToDouble() * interval;
    if (!roundedMax.isFinite || roundedMax < maximum) {
      return maximum;
    }
    return roundedMax;
  }

  String _formatMonthlyIncomeAxisValue(double value, double interval) {
    if (value == 0) {
      return '0';
    }

    final double absoluteValue = value.abs();
    if (absoluteValue < 0.0001 || absoluteValue >= 1e15) {
      return value.toStringAsExponential(2);
    }

    if (absoluteValue >= 1000) {
      final (double divisor, String suffix) = absoluteValue >= 1e12
          ? (1e12, 'T')
          : absoluteValue >= 1e9
          ? (1e9, 'B')
          : absoluteValue >= 1e6
          ? (1e6, 'M')
          : (1e3, 'K');
      final String scaled = (absoluteValue / divisor)
          .toStringAsFixed(2)
          .replaceFirst(RegExp(r'\.?0+$'), '');
      return '${value < 0 ? '-' : ''}$scaled$suffix';
    }

    int decimalPlaces = 0;
    double scaledInterval = interval;
    while (decimalPlaces < 12 &&
        (scaledInterval - scaledInterval.round()).abs() >
            1e-9 * math.max(1, scaledInterval.abs())) {
      scaledInterval *= 10;
      decimalPlaces++;
    }

    final List<String> parts = absoluteValue
        .toStringAsFixed(decimalPlaces)
        .split('.');
    final String digits = parts.first;
    final StringBuffer formatted = StringBuffer();
    for (int index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) {
        formatted.write(',');
      }
      formatted.write(digits[index]);
    }

    final String decimals = parts.length > 1 ? '.${parts.last}' : '';
    return '${value < 0 ? '-' : ''}$formatted$decimals';
  }

  Widget _categoryChart(
    BuildContext context,
    Map<String, double> data, {
    required bool isIncome,
  }) {
    final entries = data.entries
        .where((entry) => entry.value.isFinite && entry.value > 0)
        .toList();

    if (entries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('No category data available')),
      );
    }

    final double largestAmount = entries.fold<double>(
      0,
      (largest, entry) => entry.value > largest ? entry.value : largest,
    );
    final List<double> normalizedAmounts = entries
        .map((entry) => entry.value / largestAmount)
        .toList();
    final double normalizedTotal = normalizedAmounts.fold(
      0.0,
      (sum, amount) => sum + amount,
    );
    final List<double> percentages = normalizedAmounts
        .map((amount) => (amount / normalizedTotal) * 100)
        .toList();

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
                sections: List.generate(entries.length, (index) {
                  final double percentage = percentages[index];
                  final Color color = _categoryColor(
                    index,
                    percentage: percentage,
                    isIncome: isIncome,
                  );
                  final Color labelColor = color.computeLuminance() > 0.36
                      ? const Color(0xFF142033)
                      : Colors.white;

                  return PieChartSectionData(
                    value: percentage,
                    color: color,
                    title: '${percentage.toStringAsFixed(1)}%',
                    radius: 80,
                    titleStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: labelColor,
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(entries.length, (index) {
            final String name = entries[index].key;
            final double amount = entries[index].value;
            final double percentage = percentages[index];
            final Color color = _categoryColor(
              index,
              percentage: percentage,
              isIncome: isIncome,
            );

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(name, overflow: TextOverflow.ellipsis)),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatAmount(amount),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _categoryColor(
    int index, {
    required double percentage,
    required bool isIncome,
  }) {
    const expenseColors = [
      Color(0xFF2563EB),
      Color(0xFFF59E0B),
      Color(0xFF10B981),
      Color(0xFFF43F5E),
      Color(0xFF7C3AED),
      Color(0xFF06B6D4),
      Color(0xFFDB2777),
      Color(0xFF84CC16),
    ];
    const incomeColors = [
      Color(0xFF8B5CF6),
      Color(0xFF0EA5E9),
      Color(0xFF22C55E),
      Color(0xFFEC4899),
      Color(0xFF6366F1),
      Color(0xFF14B8A6),
      Color(0xFFF97316),
      Color(0xFFA855F7),
    ];
    final colors = isIncome ? incomeColors : expenseColors;
    final Color baseColor = colors[index % colors.length];
    final double share = percentage.clamp(0, 100).toDouble() / 100;

    return Color.lerp(baseColor, Colors.black, share * 0.12)!;
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
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.04),
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: emoji == null
                      ? Icon(icon, color: iconColor, size: 24)
                      : Text(emoji, style: const TextStyle(fontSize: 23)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
