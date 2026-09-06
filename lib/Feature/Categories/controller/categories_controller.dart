import 'package:expense_mate/Feature/Categories/model/categories_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class CategoriesController extends GetxController {
  var categoryList = <CategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  void fetchCategories() {
    // Initial categories based on Expense Mate blueprint
    categoryList.value = [
      CategoryModel(id: '1', name: 'Food & Dining', icon: 'restaurant', colorValue: 0xFFE53935, isDefault: true),
      CategoryModel(id: '2', name: 'Transport', icon: 'directions_car', colorValue: 0xFF1E88E5, isDefault: true),
      CategoryModel(id: '3', name: 'Shopping', icon: 'shopping_bag', colorValue: 0xFF8E24AA, isDefault: true),
      CategoryModel(id: '4', name: 'Bills', icon: 'receipt_long', colorValue: 0xFFFB8C00, isDefault: true),
      CategoryModel(id: '5', name: 'Entertainment', icon: 'movie', colorValue: 0xFFE91E63, isDefault: true),
      CategoryModel(id: '6', name: 'Salary', icon: 'work', colorValue: 0xFF43A047, isDefault: true),
    ];
  }

  void addCategory(CategoryModel category) {
    categoryList.add(category);
  }

  void deleteCategory(String id) {
    categoryList.removeWhere((cat) => cat.id == id && !cat.isDefault);
  }
}