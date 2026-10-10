import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryTransactionsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String categoryType;

  const CategoryTransactionsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryType,
  });

  @override
  State<CategoryTransactionsScreen> createState() =>
      _CategoryTransactionsScreenState();
}

class _CategoryTransactionsScreenState
    extends State<CategoryTransactionsScreen> {
  late Future<List<Map<String, dynamic>>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _loadTransactions();
  }

  String _normalizeName(String? name) {
    return (name ?? '')
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatAmount(double amount) {
    final roundedAmount = amount.round();
    final formatted = roundedAmount.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < formatted.length; i++) {
      if (i > 0 && (formatted.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(formatted[i]);
    }

    return 'Rs. ${buffer.toString()}';
  }

  Future<List<Map<String, dynamic>>> _loadTransactions() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) return [];

    // Load all categories for this user so duplicate names
    // with different IDs can be handled correctly.
    final categoryResponse = await client
        .from('categories')
        .select('id, name, type')
        .eq('user_id', user.id);

    final matchingCategoryIds = <String>{widget.categoryId};

    for (final item in categoryResponse) {
      final name = item['name']?.toString();

      if (_normalizeName(name) ==
          _normalizeName(widget.categoryName)) {
        final id = item['id']?.toString();

        if (id != null && id.isNotEmpty) {
          matchingCategoryIds.add(id);
        }
      }
    }

    // Query each matching ID separately to avoid relying on
    // backend-specific filtering behavior for a list of IDs.
    final results = <Map<String, dynamic>>[];
    final seenTransactionIds = <String>{};

    for (final id in matchingCategoryIds) {
      final response = await client
          .from('transactions')
          .select()
          .eq('user_id', user.id)
          .eq('category_id', id)
          .order('transaction_date', ascending: false);

      for (final row in response) {
        final transaction = Map<String, dynamic>.from(row);
        final transactionId = transaction['id']?.toString();

        if (transactionId == null ||
            seenTransactionIds.add(transactionId)) {
          results.add(transaction);
        }
      }
    }

    results.sort((a, b) {
      final dateA = DateTime.tryParse(
            a['transaction_date']?.toString() ?? '',
          ) ??
          DateTime(1970);

      final dateB = DateTime.tryParse(
            b['transaction_date']?.toString() ?? '',
          ) ??
          DateTime(1970);

      return dateB.compareTo(dateA);
    });

    return results;
  }

  Widget _buildTransactionSection({
    required BuildContext context,
    required String title,
    required List<Map<String, dynamic>> transactions,
    required bool isIncome,
    required bool isDark,
  }) {
    final total = transactions.fold<double>(
      0,
      (sum, transaction) =>
          sum + _parseAmount(transaction['amount']),
    );

    final sectionColor =
        isIncome ? Colors.green : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isIncome
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: sectionColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Total: ${_formatAmount(total)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: sectionColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${transactions.length} Transactions',
                style: TextStyle(
                  color: isDark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        if (transactions.isEmpty)
          Padding(
            padding: const EdgeInsets.only(
              left: 8,
              right: 8,
              bottom: 20,
            ),
            child: Text(
              'No ${title.toLowerCase()} transactions found.',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          )
        else
          ...transactions.map((transaction) {
            final amount = _parseAmount(transaction['amount']);
            final transactionTitle =
                transaction['title']?.toString() ??
                    widget.categoryName;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E1E1E)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    isIncome
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: sectionColor,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      transactionTitle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    _formatAmount(amount),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: sectionColor,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Unable to load transactions.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }

          final allTransactions = snapshot.data ?? [];

          final incomeTransactions = allTransactions.where((transaction) {
            final type = transaction['type']
                ?.toString()
                .trim()
                .toLowerCase();

            return type == 'income';
          }).toList();

          final expenseTransactions =
              allTransactions.where((transaction) {
            final type = transaction['type']
                ?.toString()
                .trim()
                .toLowerCase();

            return type != 'income';
          }).toList();

        
final showIncome = incomeTransactions.isNotEmpty;
final showExpense = expenseTransactions.isNotEmpty;

if (!showIncome && !showExpense) {
  return const Center(
    child: Text('No transactions found in this category.'),
  );
}

return ListView(
  padding: const EdgeInsets.all(16),
  children: [
    if (showIncome)
      _buildTransactionSection(
        context: context,
        title: 'Income',
        transactions: incomeTransactions,
        isIncome: true,
        isDark: isDark,
      ),

    if (showIncome && showExpense)
      const SizedBox(height: 12),

    if (showExpense)
      _buildTransactionSection(
        context: context,
        title: 'Expense',
        transactions: expenseTransactions,
        isIncome: false,
        isDark: isDark,
      ),
  ],
);


        },
      ),
    );
  }
}

