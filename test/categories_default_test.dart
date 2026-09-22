import 'package:expense_mate/Feature/Categories/controller/categories_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default categories are limited to the five protected built-ins', () {
    final visible = CategoriesController.filterVisibleCategories([
      {'name': 'Education'},
      {'name': 'Food'},
      {'name': 'Bills'},
      {'name': 'Transport'},
      {'name': 'Health'},
      {'name': 'Entertainment'},
      {'name': 'Shopping'},
    ]);

    expect(
      visible
          .map((category) => (category['name'] as String).toLowerCase())
          .toList(),
      ['education', 'food', 'bills', 'transport', 'health'],
    );

    expect(CategoriesController.isProtectedCategoryName('Education'), isTrue);
    expect(CategoriesController.isProtectedCategoryName('Entertainment'), isFalse);
  });
}
