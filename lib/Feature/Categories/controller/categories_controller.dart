
import 'dart:async';

import 'package:expense_mate/Core/Database/repository_provider.dart';
import 'package:expense_mate/Core/Database/sync/sync_manager.dart';
import 'package:expense_mate/Feature/Categories/model/categories_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class CategoriesController extends GetxController {
  static const List<String> protectedCategoryOrder = [
    'education',
    'food',
    'bills',
    'transport',
    'health',
  ];

  final SupabaseClient _supabase = Supabase.instance.client;

  final wallets = <dynamic>[].obs;

  final categoryList = <CategoryModel>[].obs;
  final categoryCounts = <String, int>{}.obs;
  final categoryTotals = <String, double>{}.obs;

  final isLoading = false.obs;

  bool _backfilledCustomCategories = false;

  final RepositoryProvider _repositories = RepositoryProvider.instance;

  User? get currentUser => _supabase.auth.currentUser;

  // ==========================================================
  // CATEGORY HELPERS
  // ==========================================================

  static String _normalizeCategoryName(String? name) {
    return (name ?? '')
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static bool isProtectedCategoryName(String? name) {
    return protectedCategoryOrder.contains(
      _normalizeCategoryName(name),
    );
  }

  String _generateUuid() {
    return const Uuid().v4();
  }

  bool _isValidUuid(String value) {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-'
      r'[0-9a-fA-F]{4}-'
      r'[1-5][0-9a-fA-F]{3}-'
      r'[89abAB][0-9a-fA-F]{3}-'
      r'[0-9a-fA-F]{12}$',
    );

    return uuidRegex.hasMatch(value);
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

  // ==========================================================
  // FIND CATEGORY BY NAME
  // ==========================================================

Future<CategoryModel?> findCategoryByName(
  String name, {
  String? type,
}) async {
  final normalizedName = _normalizeCategoryName(name);

  if (normalizedName.isEmpty) return null;

  final normalizedType = type?.trim().toLowerCase();

  bool matchesType(CategoryModel category) {
    if (normalizedType == null || normalizedType == 'both') {
      return true;
    }

    final categoryType = category.type.trim().toLowerCase();

    // Grouped categories are usable for both transaction types.
    return categoryType == normalizedType ||
        categoryType == 'both';
  }

  // First search the visible, grouped categories.
  final visibleMatch = categoryList.firstWhereOrNull(
    (category) =>
        _normalizeCategoryName(category.name) == normalizedName &&
        matchesType(category),
  );

  if (visibleMatch != null) {
    return visibleMatch;
  }

  final user = currentUser;
  if (user == null) return null;

  final localCategories =
      await _repositories.categories.getCategories(user.id);

  final matches = localCategories.where((category) {
    return _normalizeCategoryName(category.name) == normalizedName &&
        (normalizedType == null ||
            normalizedType == 'both' ||
            category.type.trim().toLowerCase() == normalizedType);
  }).toList();

  if (matches.isEmpty) return null;

  final first = matches.first;

  final linkedIds = matches
      .map((category) => category.id)
      .where((id) => id.isNotEmpty)
      .toSet()
      .toList();

  return CategoryModel(
    id: first.id,
    name: first.name,
    icon: first.icon ?? 'category',
    colorValue: _parseColor(first.color),
    isDefault: isProtectedCategoryName(first.name),
    type: matches.map((c) => c.type.toLowerCase()).toSet().length > 1
        ? 'both'
        : first.type,
    linkedIds: linkedIds.isEmpty ? [first.id] : linkedIds,
  );
}


  // ==========================================================
  // CATEGORY ORDER
  // ==========================================================

  static int compareCategoryOrder(
    CategoryModel a,
    CategoryModel b,
  ) {
    final aProtected = isProtectedCategoryName(a.name);
    final bProtected = isProtectedCategoryName(b.name);

    if (aProtected && !bProtected) {
      return -1;
    }

    if (!aProtected && bProtected) {
      return 1;
    }

    if (aProtected && bProtected) {
      final aIndex = protectedCategoryOrder.indexOf(
        _normalizeCategoryName(a.name),
      );

      final bIndex = protectedCategoryOrder.indexOf(
        _normalizeCategoryName(b.name),
      );

      return aIndex.compareTo(bIndex);
    }

    return a.name.toLowerCase().compareTo(
          b.name.toLowerCase(),
        );
  }

  static List<String> filterDeletableCategoryIds(
    List<String> ids,
    Set<String> idsInUseByTransactions,
  ) {
    return ids
        .where((id) => !idsInUseByTransactions.contains(id))
        .toList();
  }

  // ==========================================================
  // VISIBLE CATEGORIES
  // ==========================================================

  static List<Map<String, dynamic>> filterVisibleCategories(
    List<dynamic> rawCategories,
  ) {
    final grouped = <String, Map<String, dynamic>>{};

    for (final item in rawCategories) {
      if (item is! Map) {
        continue;
      }

      final name = (item['name']?.toString() ?? '').trim();
      final normalizedName = _normalizeCategoryName(name);

      final type = (item['type']?.toString() ?? 'expense')
          .trim()
          .toLowerCase();

      if (normalizedName.isEmpty) {
        continue;
      }

      if (type != 'income' && type != 'expense') {
        continue;
      }

      final id = item['id']?.toString() ?? '';
      final existing = grouped[normalizedName];

      if (existing == null) {
        final category = Map<String, dynamic>.from(item);

        category['name'] = name;
        category['type'] = 'both';
        category['ids'] = <String>[
          if (id.isNotEmpty) id,
        ];

        grouped[normalizedName] = category;
      } else {
        final ids = List<String>.from(
          existing['ids'] as List<String>,
        );

        if (id.isNotEmpty && !ids.contains(id)) {
          ids.add(id);
        }

        existing['ids'] = ids;
        existing['type'] = 'both';

        // Prefer a real UUID over a virtual default ID.
        final existingId = existing['id']?.toString() ?? '';

        if (existingId.startsWith('default_') &&
            id.isNotEmpty &&
            !id.startsWith('default_')) {
          existing['id'] = id;
          existing['icon'] = item['icon'];
          existing['color'] = item['color'];
        }

        existing['isDefault'] =
            existing['isDefault'] == true ||
            item['isDefault'] == true;
      }
    }

    final protectedItems = <Map<String, dynamic>>[];
    final customItems = <Map<String, dynamic>>[];

    for (final category in grouped.values) {
      final normalizedName = _normalizeCategoryName(
        category['name']?.toString(),
      );

      if (protectedCategoryOrder.contains(normalizedName)) {
        protectedItems.add(category);
      } else {
        customItems.add(category);
      }
    }

    customItems.sort((a, b) {
      return (a['name']?.toString() ?? '')
          .toLowerCase()
          .compareTo(
            (b['name']?.toString() ?? '').toLowerCase(),
          );
    });

    final ordered = <Map<String, dynamic>>[];

    // Keep protected categories in the requested order.
    for (final categoryName in protectedCategoryOrder) {
      final matches = protectedItems.where(
        (item) =>
            _normalizeCategoryName(item['name']?.toString()) ==
            categoryName,
      );

      if (matches.isNotEmpty) {
        ordered.addAll(matches);
      } else {
        ordered.add({
          'id': 'default_$categoryName',
          'name': _defaultDisplayName(categoryName),
          'icon': categoryName,
          'color': _defaultColorValue(categoryName),
          'isDefault': true,
          'type': 'both',
          'ids': <String>[],
        });
      }
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
        if (categoryName.isEmpty) {
          return '';
        }

        return categoryName[0].toUpperCase() +
            categoryName.substring(1);
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

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  // ==========================================================
  // FETCH CATEGORIES
  // ==========================================================

  Future<void> fetchCategories() async {
    final user = currentUser;

    if (user == null) {
      categoryList.clear();
      categoryCounts.clear();
      categoryTotals.clear();
      return;
    }

    try {
      if (categoryList.isEmpty) {
        isLoading.value = true;
      }

      await _loadFromLocal(user.id);

      isLoading.value = false;

      // Sync runs in the background; local data remains available.
      unawaited(_syncAndReload(user.id));
    } catch (e) {
      debugPrint('Unable to fetch categories: $e');
      isLoading.value = false;
      _showError('Unable to load categories.');
    }
  }

  Future<void> _syncAndReload(String userId) async {
    try {
      if (!Get.isRegistered<SyncManager>()) {
        return;
      }

      await Get.find<SyncManager>().sync();
      await _loadFromLocal(userId);
    } catch (e) {
      debugPrint('Category background sync/reload failed: $e');
    }
  }

  // ==========================================================
  // LOAD FROM LOCAL DATABASE
  // ==========================================================

  Future<void> _loadFromLocal(String userId) async {
    final localCategories =
        await _repositories.categories.getCategories(userId);

    debugPrint('===== LOCAL CATEGORIES =====');

    for (final category in localCategories) {
      debugPrint(
        'CATEGORY => id=${category.id}, '
        'name=${category.name}, '
        'type=${category.type}, '
        'isDeleted=${category.isDeleted}',
      );
    }

    debugPrint('============================');

    final localTransactions =
        await _repositories.transactions.getTransactions(userId);

        debugPrint('===== TRANSACTION COUNT DEBUG =====');

for (final transaction in localTransactions) {
  debugPrint(
    'TRANSACTION => '
    'id=${transaction.id}, '
    'categoryId=${transaction.categoryId}, '
    'type=${transaction.type}',
  );
}

debugPrint('===================================');

    final rawCategories = <Map<String, dynamic>>[];

    for (final category in localCategories) {
      rawCategories.add({
        'id': category.id,
        'name': category.name,
        'icon': category.icon,
        'color': category.color,
        'type': category.type,
        'isDefault': isProtectedCategoryName(category.name),
      });
    }

    final visibleData = filterVisibleCategories(rawCategories);

    final categories = <CategoryModel>[];
    final countsMap = <String, int>{};
    final totalsMap = <String, double>{};

    for (final item in visibleData) {
      final rawName = item['name']?.toString() ?? '';
      final normalizedName = _normalizeCategoryName(rawName);

      final categoryId =
          item['id']?.toString() ?? 'default_$normalizedName';

      final linkedIds = (item['ids'] as List<dynamic>? ?? [])
          .map((id) => id.toString())
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      if (linkedIds.isEmpty &&
          !categoryId.startsWith('default_')) {
        linkedIds.add(categoryId);
      }

      int count = 0;

final linkedIdSet = linkedIds.toSet();

for (final transaction in localTransactions) {
  final transactionCategoryId =
      transaction.categoryId?.trim();

  if (transactionCategoryId == null ||
      transactionCategoryId.isEmpty) {
    continue;
  }

  // Count transactions linked to this visible category.
  if (linkedIdSet.contains(transactionCategoryId)) {
    count++;
    continue;
  }

  // Fallback for transactions linked to another local category
  // with the same normalized name.
  final matchingLocalCategory =
      localCategories.firstWhereOrNull(
    (localCategory) =>
        localCategory.id == transactionCategoryId,
  );

  if (matchingLocalCategory != null &&
      _normalizeCategoryName(matchingLocalCategory.name) ==
          normalizedName) {
    count++;
  }
}

countsMap[categoryId] = count;
totalsMap[categoryId] = 0.0;

      categories.add(
        CategoryModel(
          id: categoryId,
          name: rawName,
          icon: item['icon']?.toString() ?? normalizedName,
          colorValue: _parseColor(item['color']),
          isDefault: isProtectedCategoryName(rawName),
          type: 'both',
          linkedIds: linkedIds.isEmpty
              ? [categoryId]
              : linkedIds,
        ),
      );
    }

    categories.sort(compareCategoryOrder);

    categoryCounts.assignAll(countsMap);
    categoryTotals.assignAll(totalsMap);
    categoryList.assignAll(categories);
    debugPrint('===== VISIBLE CATEGORY DEBUG =====');

for (final category in categoryList) {
  debugPrint(
    'name=${category.name}, '
    'id=${category.id}, '
    'type=${category.type}, '
    'linkedIds=${category.linkedIds}',
  );
}

debugPrint('==================================');

    if (!_backfilledCustomCategories) {
      _backfilledCustomCategories = true;
      unawaited(
        _createMissingCustomCategories(localTransactions),
      );
    }
  }

  Future<void> _createMissingCustomCategories(
    List<dynamic> localTransactions,
  ) async {
    // The current local transaction model does not expose a supported
    // free-text category field, so no automatic backfill is performed.
    // Existing transactions and categories remain untouched.
    return;
  }

  // ==========================================================
  // CATEGORY COUNT / TOTAL
  // ==========================================================

  int getCategoryCount(String categoryId) {
    return categoryCounts[categoryId] ?? 0;
  }

  double getCategoryTotal(String categoryId) {
    return categoryTotals[categoryId] ?? 0.0;
  }

  // ==========================================================
  // ADD CATEGORY
  // ==========================================================

  Future<void> addCategory(
    CategoryModel category, {
    bool closeDialog = true,
  }) async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return;
    }

    final trimmedName = category.name.trim();
    final normalizedName = _normalizeCategoryName(trimmedName);

    if (normalizedName.isEmpty) {
      _showError('Please enter category name.');
      return;
    }

    final normalizedType = category.type.trim().toLowerCase();

    if (normalizedType != 'income' &&
        normalizedType != 'expense') {
      _showError('Invalid category type.');
      return;
    }

    try {
      // Same name means the same visible category, regardless of type.
      final existingCategory =
          await findCategoryByName(trimmedName);

      if (existingCategory != null) {
        if (closeDialog && (Get.isDialogOpen ?? false)) {
          Get.back();
        }
        return;
      }

      // Check local storage as well, including categories that might
      // not yet be reflected in the visible list.
      final localCategories =
          await _repositories.categories.getCategories(user.id);

      final localDuplicate = localCategories.firstWhereOrNull(
        (item) =>
            _normalizeCategoryName(item.name) == normalizedName,
      );

      if (localDuplicate != null) {
        await _loadFromLocal(user.id);

        if (closeDialog && (Get.isDialogOpen ?? false)) {
          Get.back();
        }
        return;
      }

      final oldId = category.id.trim();

      final categoryId =
          _isValidUuid(oldId) ? oldId : _generateUuid();

      final colorHex =
          category.colorValue.toRadixString(16).padLeft(8, '0');

      // Local-first creation. Repository handles persistence and queueing.
      await _repositories.categorySync.createCategory(
        userId: user.id,
        id: categoryId,
        name: trimmedName,
        type: normalizedType,
        icon: category.icon,
        color: colorHex,
      );

      // Rebuild grouped categories and linked IDs immediately.
      await _loadFromLocal(user.id);

      if (closeDialog && (Get.isDialogOpen ?? false)) {
        Get.back();
      }

      Future<void>.delayed(
        const Duration(milliseconds: 300),
        _syncInBackground,
      );
    } catch (e) {
      debugPrint('Unable to add category: $e');
      _showError('Unable to add category.');
    }
  }

  // ==========================================================
  // DELETE SINGLE CATEGORY
  // ==========================================================

  Future<void> deleteCategory(String id) async {
    await deleteCategories([id]);
  }

  // ==========================================================
  // DELETE MULTIPLE CATEGORIES
  // ==========================================================

  Future<void> deleteCategories(List<String> ids) async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return;
    }

    if (ids.isEmpty) {
      return;
    }

    final selectedCategories = categoryList
        .where((category) => ids.contains(category.id))
        .toList();

    final protectedIds = selectedCategories
        .where((category) => category.isDefault)
        .map((category) => category.id)
        .toList();

    if (protectedIds.isNotEmpty) {
      _showError('Default categories cannot be deleted.');
      return;
    }

    try {
      isLoading.value = true;

      // Expand grouped category IDs so every underlying duplicate record
      // is handled consistently. Only IDs explicitly requested by the UI
      // and their linked IDs are included.
      final idsToDelete = <String>{...ids};

      for (final category in selectedCategories) {
        idsToDelete.addAll(category.linkedIds);
      }

      final localTransactions =
          await _repositories.transactions.getTransactions(user.id);

      final transactionsToDelete = localTransactions.where((transaction) {
        final categoryId = transaction.categoryId;
        return categoryId != null &&
            idsToDelete.contains(categoryId);
      }).toList();

      for (final transaction in transactionsToDelete) {
        await _repositories.transactionSync.deleteTransaction(
          userId: user.id,
          id: transaction.id,
        );
      }

      for (final categoryId in idsToDelete) {
        // Virtual default IDs must never be sent to the database.
        if (categoryId.startsWith('default_')) {
          continue;
        }

        await _repositories.categorySync.deleteCategory(
          userId: user.id,
          id: categoryId,
        );
      }

      categoryList.removeWhere(
        (category) =>
            idsToDelete.contains(category.id) ||
            category.linkedIds.any(idsToDelete.contains),
      );

      for (final categoryId in idsToDelete) {
        categoryCounts.remove(categoryId);
        categoryTotals.remove(categoryId);
      }

      categoryCounts.refresh();
      categoryTotals.refresh();
      categoryList.sort(compareCategoryOrder);

      _syncInBackground();
    } catch (e) {
      debugPrint('Unable to delete categories: $e');
      _showError('Unable to delete category.');
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================
  // BACKGROUND SYNC
  // ==========================================================

  void _syncInBackground() {
    try {
      if (Get.isRegistered<SyncManager>()) {
        unawaited(Get.find<SyncManager>().sync());
      }
    } catch (e) {
      debugPrint('Category background sync failed: $e');
    }
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  void _showError(String message) {
    // Intentionally no Get.snackbar() due to the previously observed
    // GetX snackbar animation initialization issue.
    debugPrint('CategoriesController: $message');
  }
}

