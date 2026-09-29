import 'package:fl_chart/fl_chart.dart';
import 'package:expense_mate/Feature/Budgets/bindings/budget_bindings.dart';
import 'package:expense_mate/Feature/Budgets/view/budget_view.dart';
import 'package:expense_mate/Feature/bills_reminders/binding/bills_reminders_binding.dart';
import 'package:expense_mate/Feature/bills_reminders/view/bills_reminders_view.dart';
import 'package:expense_mate/Feature/committee/view/committee_view.dart';
import 'package:expense_mate/Feature/goals/binding/goals_binding.dart';
import 'package:expense_mate/Feature/goals/view/goals_view.dart';
import 'package:expense_mate/Feature/settings/binding/settings_binding.dart';
import 'package:expense_mate/Feature/settings/controller/settings_controller.dart';
import 'package:expense_mate/Feature/settings/view/settings_view.dart';
import 'package:expense_mate/Feature/wallets/binding/wallets_binding.dart';
import 'package:expense_mate/Feature/wallets/view/wallets_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportView extends StatelessWidget {
  const ReportView({super.key});

  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  String get _userName {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      final nameFromMetaData =
          user.userMetadata?['full_name'] ?? user.userMetadata?['name'];

      if (nameFromMetaData != null &&
          nameFromMetaData.toString().isNotEmpty) {
        return nameFromMetaData.toString();
      }

      if (user.email != null && user.email!.contains('@')) {
        final emailPrefix = user.email!.split('@').first;
        return emailPrefix[0].toUpperCase() + emailPrefix.substring(1);
      }
    }

    return 'User';
  }

  void _closeDrawerAndNavigate(
    Widget Function() page, {
    Bindings? binding,
  }) {
    if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeEndDrawer();
    }

    Future.delayed(const Duration(milliseconds: 150), () {
      Get.to(page, binding: binding);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsController = Get.find<SettingsController>();

    final backgroundColor =
        isDark ? const Color(0xff000000) : const Color(0xffF5F7FA);

    final cardColor =
        isDark ? const Color(0xff0A0A0A) : Colors.white;

    final textColor =
        isDark ? Colors.white : Colors.black;

    final secondaryTextColor =
        isDark ? Colors.white70 : Colors.grey;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,

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
              backgroundColor: isDark
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
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  UserAccountsDrawerHeader(
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
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
                      final name = settingsController.profileName.value;
                      final firstLetter =
                          name.isNotEmpty ? name[0].toUpperCase() : 'U';

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
                      _userName,
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
                          iconColor: const Color(0xFF2B82FB),
                          title: 'Wallets',
                          subtitle: 'Manage your cash, bank and other wallets',
                          onTap: () => _closeDrawerAndNavigate(
                            () => const WalletsView(),
                            binding: WalletsBinding(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDrawerOption(
                          context: context,
                          icon: Icons.pie_chart_rounded,
                          iconColor: const Color(0xFFFF9800),
                          title: 'Budgets',
                          subtitle: 'Set and track monthly spending limits',
                          onTap: () => _closeDrawerAndNavigate(
                            () => const BudgetView(),
                            binding: BudgetBinding(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDrawerOption(
                          context: context,
                          icon: Icons.stars_rounded,
                          iconColor: const Color(0xFFE91E63),
                          title: 'Goals',
                          subtitle: 'Track your financial targets and savings',
                          onTap: () => _closeDrawerAndNavigate(
                            () => const GoalsView(),
                            binding: GoalsBinding(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDrawerOption(
                          context: context,
                          icon: Icons.notifications_active_rounded,
                          iconColor: const Color(0xFF9C27B0),
                          title: 'Bills & Reminders',
                          subtitle: 'Manage upcoming bills and reminders',
                          onTap: () => _closeDrawerAndNavigate(
                            () => const BillsRemindersView(),
                            binding: BillsRemindersBinding(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDrawerOption(
                          context: context,
                          icon: Icons.account_balance_rounded,
                          iconColor: const Color(0xFF4CAF50),
                          title: 'Digital Committee',
                          subtitle: 'Manage your committee and member payments',
                          onTap: () => _closeDrawerAndNavigate(
                            () => CommitteeView(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDrawerOption(
                          context: context,
                          icon: Icons.person_rounded,
                          iconColor: const Color(0xFF00BCD4),
                          title: 'Profile',
                          subtitle: 'Manage your profile and account settings',
                          onTap: () => _closeDrawerAndNavigate(
                            () => const SettingsView(),
                          ),
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

      appBar: AppBar(
        title: Text(
          'Reports & Analytics',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: false,
        backgroundColor: cardColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: textColor,
        ),
        actions: [
          IconButton(
            tooltip: 'Open navigation menu',
            icon: Icon(
              Icons.menu_rounded,
              size: 28,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    context: context,
                    title: 'Total Income',
                    amount: 'PKR 50,000',
                    icon: Icons.arrow_downward,
                    iconColor: Colors.green,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _summaryCard(
                    context: context,
                    title: 'Total Expense',
                    amount: 'PKR 20,000',
                    icon: Icons.arrow_upward,
                    iconColor: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20), 

            Text(
              'Income vs Expense',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 12),

            _chartContainer(
              context: context,
              child: SizedBox(
                height: 280,
                child: BarChart(
                  BarChartData(
                    maxY: 60000,

                    borderData: FlBorderData(
                      show: false,
                    ),

                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: isDark
                              ? Colors.white24
                              : Colors.black12,
                          strokeWidth: 1,
                        );
                      },
                    ),

                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 45,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: secondaryTextColor,
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
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            String title = '';

                            if (value == 0) {
                              title = 'Income';
                            } else if (value == 1) {
                              title = 'Expense';
                            }

                            return SideTitleWidget(
                              meta: meta,
                              space: 8,
                              child: Text(
                                title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

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
                    ),

                    alignment: BarChartAlignment.spaceAround,

                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: 50000,
                            width: 45,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      ),

                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: 20000,
                            width: 45,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            Text(
              'Expense Categories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 12),

            _chartContainer(
              context: context,
              child: Column(
                children: [

                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 45,

                        sections: [
                          PieChartSectionData(
                            value: 25,
                            title: 'Food',
                            radius: 70,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),

                          PieChartSectionData(
                            value: 15,
                            title: 'Transport',
                            radius: 70,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),

                          PieChartSectionData(
                            value: 20,
                            title: 'Shopping',
                            radius: 70,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),

                          PieChartSectionData(
                            value: 40,
                            title: 'Bills',
                            radius: 70,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 20,
                    runSpacing: 10,
                    children: const [
                      _Legend(
                        title: 'Food',
                        color: Colors.blue,
                      ),
                      _Legend(
                        title: 'Transport',
                        color: Colors.orange,
                      ),
                      _Legend(
                        title: 'Shopping',
                        color: Colors.green,
                      ),
                      _Legend(
                        title: 'Bills',
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Text(
              'Monthly Expenses',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 12),

            _chartContainer(
              context: context,
              child: SizedBox(
                height: 280,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: 5,
                    minY: 12000,
                    maxY: 22000,

                    borderData: FlBorderData(
                      show: false,
                    ),

                    gridData: FlGridData(
                      show: true,
                      drawHorizontalLine: true,
                      drawVerticalLine: true,

                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: isDark
                              ? Colors.white24
                              : Colors.black12,
                          strokeWidth: 1,
                        );
                      },

                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: isDark
                              ? Colors.white12
                              : Colors.black12,
                          strokeWidth: 1,
                        );
                      },
                    ),

                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 45,
                          interval: 2000,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 11,
                              ),
                            );
                          },
                        ),
                      ),

                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,

                          getTitlesWidget: (value, meta) {
                            const months = [
                              'Jan',
                              'Feb',
                              'Mar',
                              'Apr',
                              'May',
                              'Jun',
                            ];

                            if (value >= 0 &&
                                value < months.length) {
                              return SideTitleWidget(
                                meta: meta,
                                space: 8,
                                child: Text(
                                  months[value.toInt()],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: textColor,
                                  ),
                                ),
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                      ),

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
                    ),

                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 15000),
                          FlSpot(1, 18000),
                          FlSpot(2, 12000),
                          FlSpot(3, 22000),
                          FlSpot(4, 17000),
                          FlSpot(5, 20000),
                        ],
                        isCurved: false,
                        barWidth: 4,  

                        dotData: FlDotData(
                          show: true,
                          getDotPainter:
                              (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 5,
                              color: const Color(0xff11B5C9),
                              strokeWidth: 2,
                              strokeColor:
                                  const Color(0xff11B5C9),
                            );
                          },
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

            const SizedBox(height: 25),

            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),

                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.06),
                  ),
                ],
              ),

              child: Column(
                children: [
                  Text(
                    'Current Balance',
                    style: TextStyle(
                      fontSize: 16,
                      color: secondaryTextColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'PKR 30,000',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerOption({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                  child: Icon(icon, color: iconColor, size: 24),
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

  static Widget _summaryCard({
    required BuildContext context,
    required String title,
    required String amount,
    required IconData icon,
    required Color iconColor,
  }) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final cardColor =
        isDark ? const Color(0xff0A0A0A) : Colors.white;

    final textColor =
        isDark ? Colors.white : Colors.black;

    final secondaryTextColor =
        isDark ? Colors.white70 : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 28,
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: TextStyle(
              color: secondaryTextColor,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _chartContainer({
    required BuildContext context,
    required Widget child,
  }) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final cardColor =
        isDark ? const Color(0xff0A0A0A) : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),

      child: child,
    );
  }
}

class _Legend extends StatelessWidget {
  final String title;
  final Color color;

  const _Legend({
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
           shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 6),

        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
      ],
    );
  }
} 