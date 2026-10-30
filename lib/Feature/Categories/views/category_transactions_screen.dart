
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryTransactionsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String categoryType;
  final DateTime? periodStart;
  final DateTime? periodEnd;

  const CategoryTransactionsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryType,
    this.periodStart,
    this.periodEnd,
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
    return (name ?? '').trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatAmount(double amount) {
    final formatted = amount.round().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < formatted.length; i++) {
      if (i > 0 && (formatted.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(formatted[i]);
    }

    return 'Rs. ${buffer.toString()}';
  }

  String _normalizeType(dynamic type) {
    final normalized = type?.toString().trim().toLowerCase();
    return normalized == 'income' ? 'income' : 'expense';
  }

  bool _isInSelectedPeriod(Map<String, dynamic> transaction) {
    final start = widget.periodStart;
    final end = widget.periodEnd;

    if (start == null || end == null) return true;

    final date = DateTime.tryParse(
      transaction['transaction_date']?.toString() ??
          transaction['date']?.toString() ??
          '',
    );

    if (date == null) return false;

    final endExclusive = DateTime(end.year, end.month, end.day + 1);
    return !date.isBefore(start) && date.isBefore(endExclusive);
  }

  String _formatPeriod() {
    final start = widget.periodStart;
    final end = widget.periodEnd;

    if (start == null || end == null) return '';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    final formattedStart = '${start.day} ${months[start.month - 1].tr}';
    final formattedEnd = '${end.day} ${months[end.month - 1].tr}';

    return start.year == end.year
        ? '$formattedStart – $formattedEnd, ${end.year}'
        : '$formattedStart, ${start.year} – $formattedEnd, ${end.year}';
  }

  Future<List<Map<String, dynamic>>> _loadTransactions() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) return [];

    final normalizedCategoryName = _normalizeName(widget.categoryName);
    final matchingCategoryIds = <String>{widget.categoryId};

    final categoryResponse = await client
        .from('categories')
        .select('id, name, type')
        .eq('user_id', user.id);

    for (final item in categoryResponse) {
      final categoryName = item['name']?.toString();

      if (_normalizeName(categoryName) == normalizedCategoryName) {
        final id = item['id']?.toString();

        if (id != null && id.isNotEmpty) {
          matchingCategoryIds.add(id);
        }
      }
    }

    final results = <Map<String, dynamic>>[];
    final seenTransactionIds = <String>{};

    for (final categoryId in matchingCategoryIds) {
      final response = await client
          .from('transactions')
          .select()
          .eq('user_id', user.id)
          .eq('category_id', categoryId)
          .order('transaction_date', ascending: false);

      for (final row in response) {
        final transaction = Map<String, dynamic>.from(row);
        final transactionId = transaction['id']?.toString();

        if (transactionId == null) {
          results.add(transaction);
        } else if (seenTransactionIds.add(transactionId)) {
          results.add(transaction);
        }
      }
    }

    results.sort((a, b) {
      final dateA =
          DateTime.tryParse(a['transaction_date']?.toString() ?? '') ??
              DateTime(1970);

      final dateB =
          DateTime.tryParse(b['transaction_date']?.toString() ?? '') ??
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
      (sum, transaction) => sum + _parseAmount(transaction['amount']),
    );

    final sectionColor = isIncome ? Colors.green : Colors.red;

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
            border: Border.all(color: sectionColor.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: sectionColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                      color: sectionColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title.tr,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Total: @amount'.trParams({
                  'amount': _formatAmount(total),
                }),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: sectionColor,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                transactions.length == 1
                    ? '1 Transaction'.tr
                    : 'Transactions: @count'.trParams({
                        'count': transactions.length.toString(),
                      }),
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        ...transactions.map((transaction) {
          final amount = _parseAmount(transaction['amount']);

          final transactionTitle =
              transaction['title']?.toString().trim().isNotEmpty == true
                  ? transaction['title'].toString()
                  : widget.categoryName;

          final transactionDate = DateTime.tryParse(
            transaction['transaction_date']?.toString() ?? '',
          );

          final formattedDate = transactionDate == null
              ? ''
              : '${transactionDate.day.toString().padLeft(2, '0')}/'
                  '${transactionDate.month.toString().padLeft(2, '0')}/'
                  '${transactionDate.year}';

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E1E1E)
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: sectionColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    color: sectionColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transactionTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      if (formattedDate.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${isIncome ? '+' : '-'}${_formatAmount(amount)}',
                  style: TextStyle(
                    fontSize: 14,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.categoryName),
            if (widget.periodStart != null && widget.periodEnd != null)
              Text(
                _formatPeriod(),
                style: Theme.of(context).textTheme.labelSmall,
              ),
          ],
        ),
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
                  'Unable to load transactions.\n@error'.trParams({
                    'error': snapshot.error.toString(),
                  }),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }

          final allTransactions = (snapshot.data ?? [])
              .where(_isInSelectedPeriod)
              .toList();

          final incomeTransactions = allTransactions
              .where(
                (transaction) =>
                    _normalizeType(transaction['type']) == 'income',
              )
              .toList();

          final expenseTransactions = allTransactions
              .where(
                (transaction) =>
                    _normalizeType(transaction['type']) == 'expense',
              )
              .toList();

          final showIncome = incomeTransactions.isNotEmpty;
          final showExpense = expenseTransactions.isNotEmpty;

          if (!showIncome && !showExpense) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 60,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No transactions found for this category in the selected period.'
                          .tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final future = _loadTransactions();

              setState(() {
                _transactionsFuture = future;
              });

              await future;
            },
            child: ListView(
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
                if (showIncome && showExpense) const SizedBox(height: 16),
                if (showExpense)
                  _buildTransactionSection(
                    context: context,
                    title: 'Expense',
                    transactions: expenseTransactions,
                    isIncome: false,
                    isDark: isDark,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
