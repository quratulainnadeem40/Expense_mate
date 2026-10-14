import 'package:expense_mate/Feature/Categories/controller/categories_controller.dart';
import 'package:expense_mate/Feature/Categories/model/categories_model.dart';
import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'default categories stay protected while custom categories remain available',
    () {
      final visible = CategoriesController.filterVisibleCategories([
        {'id': '1', 'name': 'Education'},
        {'id': '2', 'name': 'Food'},
        {'id': '3', 'name': 'Bills'},
        {'id': '4', 'name': 'Transport'},
        {'id': '5', 'name': 'Health'},
        {'id': '6', 'name': 'Entertainment'},
        {'id': '7', 'name': 'Shopping'},
      ]);

      expect(
        visible
            .map((category) => (category['name'] as String).toLowerCase())
            .toList(),
        [
          'education',
          'food',
          'bills',
          'transport',
          'health',
          'entertainment',
          'shopping',
        ],
      );

      expect(CategoriesController.isProtectedCategoryName('Education'), isTrue);
      expect(
        CategoriesController.isProtectedCategoryName('Entertainment'),
        isFalse,
      );
    },
  );

  test(
    'delete guard keeps category IDs that are still linked to transactions',
    () {
      final safeIds = CategoriesController.filterDeletableCategoryIds(
        ['cat-1', 'cat-2', 'cat-3'],
        {'cat-2'},
      );

      expect(safeIds, ['cat-1', 'cat-3']);
    },
  );

  test('same category name is grouped across income and expense types', () {
    final visible = CategoriesController.filterVisibleCategories([
      {'id': 'fiverr-1', 'name': 'Fiverr', 'type': 'expense'},
      {'id': 'fiverr-2', 'name': '  fiverr  ', 'type': 'expense'},
      {'id': 'fiverr-income', 'name': 'FIVERR', 'type': 'income'},
    ]);

    final fiverrCategories = visible
        .where(
          (category) =>
              (category['name'] as String).trim().toLowerCase() == 'fiverr',
        )
        .toList();

    expect(fiverrCategories, hasLength(1));
    expect(fiverrCategories.single['type'], 'both');
    expect(
      fiverrCategories.single['ids'],
      containsAll(['fiverr-1', 'fiverr-2', 'fiverr-income']),
    );
  });

  test('income counterpart joins its existing default category row', () {
    final visible = CategoriesController.filterVisibleCategories([
      {'id': 'food-income', 'name': ' Food ', 'type': 'income'},
    ]);
    final foodCategories = visible
        .where(
          (category) =>
              (category['name'] as String).trim().toLowerCase() == 'food',
        )
        .toList();

    expect(foodCategories, hasLength(1));
    expect(foodCategories.single['type'], 'both');
    expect(
      foodCategories.single['ids'],
      containsAll(['food-income', 'default_food']),
    );
  });

  test('category totals separate income and expense across linked IDs', () {
    final totals = CategoriesController.calculateCategoryTotals(
      transactions: [
        TransactionModel(
          id: 'income',
          categoryId: 'income-category',
          title: 'Salary',
          amount: 50000,
          type: 'income',
          transactionDate: DateTime(2026, 10, 14),
        ),
        TransactionModel(
          id: 'expense',
          categoryId: 'expense-category',
          title: 'Purchase',
          amount: 10000,
          type: 'expense',
          transactionDate: DateTime(2026, 10, 14),
        ),
        TransactionModel(
          id: 'outside-period',
          categoryId: 'income-category',
          title: 'Previous cycle',
          amount: 2500,
          type: 'income',
          transactionDate: DateTime(2026, 9, 19),
        ),
        TransactionModel(
          id: 'other-category',
          categoryId: 'other-category',
          title: 'Unrelated',
          amount: 3000,
          type: 'expense',
          transactionDate: DateTime(2026, 10, 14),
        ),
      ],
      categoryIds: {'income-category', 'expense-category'},
      periodStart: DateTime(2026, 9, 20),
      periodEndExclusive: DateTime(2026, 10, 20),
    );

    expect(totals, {'income': 50000, 'expense': 10000});
  });

  test(
    'category totals return zero for a transaction type without activity',
    () {
      final totals = CategoriesController.calculateCategoryTotals(
        transactions: [
          TransactionModel(
            id: 'income',
            categoryId: 'salary',
            title: 'Salary',
            amount: 50000,
            type: 'income',
            transactionDate: DateTime(2026, 10, 14),
          ),
        ],
        categoryIds: {'salary'},
      );

      expect(totals['income'], 50000);
      expect(totals['expense'], 0);
    },
  );

  test(
    'manual reset excludes prior totals but includes later same-day entries',
    () {
      final totals = CategoriesController.calculateCategoryTotals(
        transactions: [
          TransactionModel(
            id: 'before-reset',
            categoryId: 'food',
            title: 'Before reset',
            amount: 1200,
            type: 'expense',
            transactionDate: DateTime(2026, 10, 14, 10),
            createdAt: DateTime(2026, 10, 14, 10),
          ),
          TransactionModel(
            id: 'after-reset',
            categoryId: 'food',
            title: 'After reset',
            amount: 300,
            type: 'expense',
            transactionDate: DateTime(2026, 10, 14),
            createdAt: DateTime(2026, 10, 14, 16),
          ),
          TransactionModel(
            id: 'older-date',
            categoryId: 'food',
            title: 'Older dated entry',
            amount: 500,
            type: 'income',
            transactionDate: DateTime(2026, 10, 13),
            createdAt: DateTime(2026, 10, 14, 17),
          ),
        ],
        categoryIds: {'food'},
        periodStart: DateTime(2026, 10, 14),
        periodEndExclusive: DateTime(2026, 10, 15),
        resetAt: DateTime(2026, 10, 14, 15),
      );

      expect(totals, {'income': 0, 'expense': 300});
    },
  );

  test(
    'only default categories show until a custom category has a transaction',
    () {
      final categories = [
        CategoryModel(
          id: 'default_food',
          name: 'Food',
          icon: 'food',
          colorValue: 0,
          isDefault: true,
          type: 'expense',
        ),
        CategoryModel(
          id: 'custom-id',
          name: 'Freelance',
          icon: 'work',
          colorValue: 0,
          isDefault: false,
          type: 'income',
          linkedIds: ['custom-id'],
        ),
      ];

      final visible = CategoriesController.filterCategoriesForDisplay(
        categories: categories,
        transactions: const [],
      );

      expect(visible.map((category) => category.name), ['Food']);
    },
  );

  test(
    'custom category appears when a transaction uses a linked category ID',
    () {
      final categories = [
        CategoryModel(
          id: 'income-category',
          name: 'Freelance',
          icon: 'work',
          colorValue: 0,
          isDefault: false,
          type: 'income',
          linkedIds: ['income-category', 'expense-category'],
        ),
      ];

      final visible = CategoriesController.filterCategoriesForDisplay(
        categories: categories,
        transactions: [
          TransactionModel(
            id: 'transaction',
            categoryId: 'expense-category',
            title: 'Design work',
            amount: 1500,
            type: 'expense',
          ),
        ],
      );

      expect(visible.map((category) => category.name), ['Freelance']);
    },
  );

  test('category cycle honors selected start and end dates', () {
    final period = CategoriesController.categoryCyclePeriod(
      now: DateTime(2026, 10, 14),
      startDay: 20,
    );

    expect(period.start, DateTime(2026, 9, 20));
    expect(period.end, DateTime(2026, 10, 19));
  });

  test('manual category reset starts a new cycle immediately', () {
    final period = CategoriesController.categoryCyclePeriod(
      now: DateTime(2026, 10, 14, 18),
      startDay: 20,
      manualResetDate: DateTime(2026, 10, 14, 16),
    );

    expect(period.start, DateTime(2026, 10, 14));
    expect(period.end, DateTime(2026, 10, 19));
  });

  test('manual category cycle does not roll over on the monthly start day', () {
    final period = CategoriesController.categoryCyclePeriod(
      now: DateTime(2026, 11, 1),
      startDay: 20,
      automatic: false,
      manualResetDate: DateTime(2026, 10, 14),
    );

    expect(period.start, DateTime(2026, 10, 14));
    expect(period.end, DateTime(2026, 11, 1));
  });

  test('automatic category cycle rolls over on the selected day', () {
    final period = CategoriesController.categoryCyclePeriod(
      now: DateTime(2026, 11, 20),
      startDay: 20,
      automatic: true,
      manualResetDate: DateTime(2026, 10, 14),
    );

    expect(period.start, DateTime(2026, 11, 20));
    expect(period.end, DateTime(2026, 12, 19));
  });

  test('category cycle clamps start dates to the last day of short months', () {
    final period = CategoriesController.categoryCyclePeriod(
      now: DateTime(2026, 2, 27),
      startDay: 31,
    );

    expect(period.start, DateTime(2026, 1, 31));
    expect(period.end, DateTime(2026, 2, 27));
  });

  test('default first-day cycle ends on each calendar month end', () {
    final periods = [
      (
        now: DateTime(2026, 2, 14),
        start: DateTime(2026, 2, 1),
        end: DateTime(2026, 2, 28),
      ),
      (
        now: DateTime(2028, 2, 14),
        start: DateTime(2028, 2, 1),
        end: DateTime(2028, 2, 29),
      ),
      (
        now: DateTime(2026, 4, 14),
        start: DateTime(2026, 4, 1),
        end: DateTime(2026, 4, 30),
      ),
      (
        now: DateTime(2026, 3, 14),
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 31),
      ),
    ];

    for (final expected in periods) {
      final period = CategoriesController.categoryCyclePeriod(
        now: expected.now,
        startDay: 1,
      );

      expect(period.start, expected.start);
      expect(period.end, expected.end);
    }
  });

  test('day 31 resets at February end then on March 31', () {
    final february = CategoriesController.categoryCyclePeriod(
      now: DateTime(2026, 2, 28),
      startDay: 31,
    );
    final march = CategoriesController.categoryCyclePeriod(
      now: DateTime(2026, 3, 31),
      startDay: 31,
    );

    expect(february.start, DateTime(2026, 2, 28));
    expect(february.end, DateTime(2026, 3, 30));
    expect(march.start, DateTime(2026, 3, 31));
    expect(march.end, DateTime(2026, 4, 29));
  });

  test('category fallback never displays a UUID', () {
    final uuidTransaction = TransactionModel(
      id: 'transaction',
      title: 'Purchase',
      amount: 1,
      categoryId: 'c95a4e1f-d6fd-4194-b681-fe31400157c7',
    );

    expect(uuidTransaction.displayCategoryFallback, 'Uncategorized');
    expect(uuidTransaction.category, 'Uncategorized');
    expect(
      TransactionModel.fallbackCategoryLabel(
        categoryId: 'c95a4e1f-d6fd-4194-b681-fe31400157c7',
      ),
      'Uncategorized',
    );
    expect(
      TransactionModel.fallbackCategoryLabel(
        categoryId: 'c95a4e1f-d6fd-4194-b681-fe31400157c7',
        customCategory: 'Food',
      ),
      'Food',
    );
    expect(
      TransactionModel.fallbackCategoryLabel(categoryId: 'Education'),
      'Education',
    );
  });
}
