import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:expense_mate/Core/utils/formatters.dart';
import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';
import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final bool isDark;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: transaction.isIncome
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                child: Icon(
                  transaction.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: transaction.isIncome ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.title, style: AppTextStyles.bodyLarge(isDark)),
                  const SizedBox(height: 2),
                  Text(
                    '${transaction.category} • ${Formatters.formatDate(transaction.date)}',
                    style: AppTextStyles.caption(isDark),
                  ),
                ],
              ),
            ],
          ),
          Text(
            '${transaction.isIncome ? '+' : '-'}${Formatters.formatCurrency(transaction.amount)}',
            style: TextStyle(
              color: transaction.isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}