import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecentTransactionsList extends StatelessWidget {
  final RxList<Map<dynamic, dynamic>> transactions;

  const RecentTransactionsList({
    Key? key,
    required this.transactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (transactions.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('No transactions yet.', style: TextStyle(color: Colors.grey)),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final tx = transactions[index];
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
    });
  }
}