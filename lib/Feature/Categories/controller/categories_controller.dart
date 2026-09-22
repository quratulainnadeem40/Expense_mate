import 'package:expense_mate/Feature/Categories/model/categories_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoriesController extends GetxController {
  static const List<String> protectedCategoryOrder = [
    'education',
    'food',
    'bills',
    'transport',
    'health',
  ];

  final SupabaseClient _supabase = Supabase.instance.client;

  final categoryList = <CategoryModel>[].obs;
  final categoryCounts = <String, int>{}.obs;
  final isLoading = false.obs;

  User? get currentUser => _supabase.auth.currentUser;

  static String _normalizeCategoryName(String? name) {
    return (name ?? '').trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
  }

  static bool isProtectedCategoryName(String? name) {
    return protectedCategoryOrder.contains(_normalizeCategoryName(name));
  }

  static int compareCategoryOrder(CategoryModel a, CategoryModel b) {
    final aProtected = isProtectedCategoryName(a.name);
    final bProtected = isProtectedCategoryName(b.name);

    if (aProtected && !bProtected) {
      return -1;
    }
    if (!aProtected && bProtected) {
      return 1;
    }

    if (aProtected && bProtected) {
      final aIndex = protectedCategoryOrder.indexOf(_normalizeCategoryName(a.name));
      final bIndex = protectedCategoryOrder.indexOf(_normalizeCategoryName(b.name));
      return aIndex.compareTo(bIndex);
    }

    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }

  static List<String> filterDeletableCategoryIds(
    List<String> ids,
    Set<String> idsInUseByTransactions,
  ) {
    return ids.where((id) => !idsInUseByTransactions.contains(id)).toList();
  }

  static List<Map<String, dynamic>> filterVisibleCategories(
    List<dynamic> rawCategories,
  ) {
    final protectedItems = <Map<String, dynamic>>[];
    final customItems = <Map<String, dynamic>>[];
    final seen = <String>{};

    for (final item in rawCategories) {
      if (item is! Map) {
        continue;
      }

      final name = item['name']?.toString() ?? '';
      final normalizedName = _normalizeCategoryName(name);

      if (normalizedName.isEmpty || seen.contains(normalizedName)) {
        continue;
      }

      seen.add(normalizedName);

      if (protectedCategoryOrder.contains(normalizedName)) {
        protectedItems.add(item as Map<String, dynamic>);
      } else {
        customItems.add(item as Map<String, dynamic>);
      }
    }

    customItems.sort(
      (a, b) => (_normalizeCategoryName(a['name']?.toString() ?? '')).compareTo(
        _normalizeCategoryName(b['name']?.toString() ?? ''),
      ),
    );

    final ordered = <Map<String, dynamic>>[];

    for (final categoryName in protectedCategoryOrder) {
      final match = protectedItems.firstWhereOrNull(
        (item) =>
            _normalizeCategoryName(item['name']?.toString() ?? '') == categoryName,
      );

      if (match != null) {
        ordered.add(match);
        continue;
      }

      ordered.add({
        'id': 'default_$categoryName',
        'name': _defaultDisplayName(categoryName),
        'icon': categoryName,
        'color': _defaultColorValue(categoryName),
        'isDefault': true,
        'type': 'expense',
      });
    }

    ordered.addAll(customItems);
    return ordered;
  }

  static String _defaultDisplayName(String categoryName) {
    switch (categoryName) {
      case 'education':
        return 'Education';
      case 'food':
        return 'Food';
      case 'bills':
        return 'Bills';
      case 'transport':
        return 'Transport';
      case 'health':
        return 'Health';
      default:
        return categoryName[0].toUpperCase() + categoryName.substring(1);
    }
  }

  static int _defaultColorValue(String categoryName) {
    switch (categoryName) {
      case 'education':
        return 0xFF5C6BC0;
      case 'food':
        return 0xFFFF7043;
      case 'bills':
        return 0xFFFF9800;
      case 'transport':
        return 0xFF42A5F5;
      case 'health':
        return 0xFFE53935;
      default:
        return 0xFF757575;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final user = currentUser;

    if (user == null) {
      categoryList.clear();
      categoryCounts.clear();
      return;
    }

    try {
      isLoading.value = true;

      final response = await _supabase
          .from('categories')
          .select('*, transactions(count)')
          .eq('user_id', user.id)
          .order('name');

      final visibleData = filterVisibleCategories(response);
      final Map<String, int> countsMap = {};
      final categories = <CategoryModel>[];

      for (final item in visibleData) {
        final rawName = item['name']?.toString() ?? '';
        final normalizedName = _normalizeCategoryName(rawName);

        final String catId = item['id']?.toString() ?? 'default_$normalizedName';
        int count = 0;

        final transactions = item['transactions'];
        if (transactions is List && transactions.isNotEmpty) {
          count = (transactions.first['count'] as num?)?.toInt() ?? 0;
        }

        countsMap[catId] = count;

        categories.add(
          CategoryModel(
            id: catId,
            name: rawName,
            icon: item['icon']?.toString() ?? normalizedName,
            colorValue: _parseColor(item['color']),
            isDefault: isProtectedCategoryName(rawName),
            type: item['type']?.toString().toLowerCase() ?? 'expense',
          ),
        );
      }

      categoryCounts.assignAll(countsMap);
      categoryList.assignAll(categories);
      categoryList.sort(compareCategoryOrder);
    } on PostgrestException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Unable to load categories.');
    } finally {
      isLoading.value = false;
    }
  }

  int getCategoryCount(String categoryId) {
    return categoryCounts[categoryId] ?? 0;
  }

  Future<void> addCategory(CategoryModel category) async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return;
    }

    try {
      isLoading.value = true;

      final response = await _supabase
          .from('categories')
          .insert({
            'user_id': user.id,
            'name': category.name,
            'icon': category.icon,
            'color': category.colorValue.toRadixString(16).padLeft(8, '0'),
            'type': category.type,
          })
          .select()
          .single();

      final String newId = response['id'].toString();

      final newCategory = CategoryModel(
        id: newId,
        name: response['name']?.toString() ?? category.name,
        icon: response['icon']?.toString() ?? category.icon,
        colorValue: _parseColor(response['color']),
        isDefault: false,
        type: response['type']?.toString().toLowerCase() ?? 'expense',
      );

      categoryCounts[newId] = 0;
      categoryList.add(newCategory);
      categoryList.sort(compareCategoryOrder);

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Success',
        'Category added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on PostgrestException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Unable to add category.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCategory(String id) async {
    await deleteCategories([id]);
  }

  Future<void> deleteCategories(List<String> ids) async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return;
    }

    if (ids.isEmpty) {
      return;
    }

    final protectedIds = categoryList
        .where((category) => ids.contains(category.id) && category.isDefault)
        .map((category) => category.id)
        .toList();

    if (protectedIds.isNotEmpty) {
      Get.snackbar(
        'Protected',
        'Default categories cannot be deleted.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      final idsToDelete = ids.toSet().toList();

      if (idsToDelete.isNotEmpty) {
        await _supabase
            .from('transactions')
            .delete()
            .inFilter('category_id', idsToDelete)
            .eq('user_id', user.id);
      }

      await _supabase
          .from('categories')
          .delete()
          .inFilter('id', idsToDelete)
          .eq('user_id', user.id);

      final removedIds = idsToDelete;

      categoryList.removeWhere((category) => removedIds.contains(category.id));
      categoryList.sort(compareCategoryOrder);
      for (final id in removedIds) {
        categoryCounts.remove(id);
      }

      Get.snackbar(
        'Deleted',
        removedIds.length == 1
            ? 'Category deleted successfully'
            : '${removedIds.length} categories deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on PostgrestException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Unable to delete category.');
    } finally {
      isLoading.value = false;
    }
  }

  int _parseColor(dynamic value) {
    if (value == null) {
      return 0xFF757575;
    }

    if (value is int) {
      return value;
    }

    String hex = value.toString().replaceAll('#', '').trim();

    if (hex.startsWith('0x')) {
      hex = hex.substring(2);
    }

    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    return int.tryParse(hex, radix: 16) ?? 0xFF757575;
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      snackStyle: SnackStyle.FLOATING,
      backgroundColor: Colors.redAccent.withOpacity(0.8),
      colorText: Colors.white,
    );
  }
}
