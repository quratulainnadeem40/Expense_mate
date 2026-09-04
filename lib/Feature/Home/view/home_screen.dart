import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';
import '../widgets/balance_card.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello, Alex'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadDashboardData(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BalanceCard(
              totalBalance: controller.totalBalance,
              totalIncome: controller.totalIncome,
              totalExpense: controller.totalExpense,
            ),
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    Get.find<HomeController>().changePage(1);
                  },
                  child: const Text(
                    'See All',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Expanded(
              child: Obx(() {
                if (controller.recentTransactions.isEmpty) {
                  return const Center(child: Text('No transactions yet.'));
                }
                return ListView.builder(
                  itemCount: controller.recentTransactions.length,
                  itemBuilder: (context, index) {
                    final tx = controller.recentTransactions[index];
                    final isIncome = tx['type'] == 'Income';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isIncome ? Colors.green : Colors.red,
                        ),
                        title: Text(tx['title'] ?? 'Transaction'),
                        subtitle: Text(tx['category'] ?? 'General'),
                        trailing: Text(
                          '${isIncome ? '+' : '-'}\$${(tx['amount'] ?? 0.0).toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isIncome ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}