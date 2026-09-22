import 'package:expense_mate/Feature/Categories/controller/categories_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default categories stay protected while custom categories remain available', () {
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
    expect(CategoriesController.isProtectedCategoryName('Entertainment'), isFalse);
  });

  test('delete guard keeps category IDs that are still linked to transactions', () {
    final safeIds = CategoriesController.filterDeletableCategoryIds(
      ['cat-1', 'cat-2', 'cat-3'],
      {'cat-2'},
    );

    expect(safeIds, ['cat-1', 'cat-3']);
  });
}
