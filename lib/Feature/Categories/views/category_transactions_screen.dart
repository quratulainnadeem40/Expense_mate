import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryTransactionsScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;
  final String categoryType;

  const CategoryTransactionsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryType,
  });

  String _formatAmount(double amount) {
    final int roundedAmount = amount.round();
    final String formatted = roundedAmount.toString();
    final StringBuffer buffer = StringBuffer();

    for (int i = 0; i < formatted.length; i++) {
      if (i > 0 && (formatted.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(formatted[i]);
    }

    return 'Rs. ${buffer.toString()}';
  }

  Future<List<Map<String, dynamic>>> _loadTransactions() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return [];
    }

    final categoryResponse = await Supabase.instance.client
        .from('categories')
        .select('id, name, type')
        .eq('user_id', user.id);

    final normalizedName = _normalizeCategoryName(categoryName);
    final normalizedType = categoryType.trim().toLowerCase();
    final categoryIds = <String>{categoryId};

    for (final category in List<Map<String, dynamic>>.from(categoryResponse)) {
      if (_normalizeCategoryName(category['name']?.toString() ?? '') ==
              normalizedName &&
          (category['type']?.toString().trim().toLowerCase() ?? '') ==
              normalizedType) {
        final id = category['id']?.toString() ?? '';
        if (id.isNotEmpty) categoryIds.add(id);
      }
    }

    final response = await Supabase.instance.client
        .from('transactions')
        .select()
        .eq('user_id', user.id)
        .inFilter('category_id', categoryIds.toList())
        .order('transaction_date', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  String _normalizeCategoryName(String name) =>
      name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(categoryName), centerTitle: true),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Unable to load transactions.',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
            );
          }

          final transactions = snapshot.data ?? [];

          double totalAmount = 0;

          for (final transaction in transactions) {
            final amount = transaction['amount'];

            if (amount is num) {
              totalAmount += amount.toDouble();
            } else {
              totalAmount += double.tryParse(amount?.toString() ?? '') ?? 0;
            }
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      categoryName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatAmount(totalAmount),
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${transactions.length} Transactions',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: transactions.isEmpty
                    ? const Center(
                        child: Text('No transactions found in this category.'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];

                          final amountValue = transaction['amount'];

                          final double amount = amountValue is num
                              ? amountValue.toDouble()
                              : double.tryParse(
                                      amountValue?.toString() ?? '',
                                    ) ??
                                    0;

                          final String title =
                              transaction['title']?.toString() ?? categoryName;

                          final String type =
                              transaction['type']?.toString() ?? 'expense';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF0A0A0A)
                                  : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  type == 'income'
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatAmount(amount),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
