import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ReportView extends StatelessWidget {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor =
        isDark ? const Color(0xff000000) : const Color(0xffF5F7FA);

    final cardColor =
        isDark ? const Color(0xff0A0A0A) : Colors.white;

    final textColor =
        isDark ? Colors.white : Colors.black;

    final secondaryTextColor =
        isDark ? Colors.white70 : Colors.grey;

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: Text(
          'Reports & Analytics',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: cardColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: textColor,
        ),
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