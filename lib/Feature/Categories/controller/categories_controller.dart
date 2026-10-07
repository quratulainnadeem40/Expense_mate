import 'dart:async';
import 'dart:math';

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

  /// Old transactions stored a typed-in category as free text instead of
  /// pointing at a category record. They are turned into real categories
  /// once per app run so those records are not left stranded.
  bool _backfilledCustomCategories = false;

  final RepositoryProvider _repositories =
      RepositoryProvider.instance;

  User? get currentUser => _supabase.auth.currentUser;

  // ==========================================================
  // CATEGORY HELPERS
  // ==========================================================

  static String _normalizeCategoryName(String? name) {
    return (name ?? '').trim().toLowerCase().replaceAll(
          RegExp(r'\s+'),
          ' ',
        );
  }

  static bool isProtectedCategoryName(String? name) {
    return protectedCategoryOrder.contains(
      _normalizeCategoryName(name),
    );
  }

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

    return a.name
        .toLowerCase()
        .compareTo(b.name.toLowerCase());
  }

  static List<String> filterDeletableCategoryIds(
    List<String> ids,
    Set<String> idsInUseByTransactions,
  ) {
    return ids
        .where(
          (id) => !idsInUseByTransactions.contains(id),
        )
        .toList();
  }

  // ==========================================================
  // VISIBLE CATEGORIES
  // ==========================================================

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

      final normalizedName =
          _normalizeCategoryName(name);

      if (normalizedName.isEmpty ||
          seen.contains(normalizedName)) {
        continue;
      }

      seen.add(normalizedName);

      if (protectedCategoryOrder.contains(
        normalizedName,
      )) {
        protectedItems.add(
          Map<String, dynamic>.from(item),
        );
      } else {
        customItems.add(
          Map<String, dynamic>.from(item),
        );
      }
    }

    customItems.sort(
      (a, b) {
        return _normalizeCategoryName(
          a['name']?.toString() ?? '',
        ).compareTo(
          _normalizeCategoryName(
            b['name']?.toString() ?? '',
          ),
        );
      },
    );

    final ordered = <Map<String, dynamic>>[];

    for (final categoryName
        in protectedCategoryOrder) {
      final match = protectedItems.firstWhereOrNull(
        (item) =>
            _normalizeCategoryName(
              item['name']?.toString() ?? '',
            ) ==
            categoryName,
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

  static String _defaultDisplayName(
    String categoryName,
  ) {
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

  static int _defaultColorValue(
    String categoryName,
  ) {
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
      // Spinner only when there is nothing on screen yet. On a revisit
      // the old list stays and is replaced quietly.
      if (categoryList.isEmpty) isLoading.value = true;

      // ------------------------------------------------------
      // 1. Local SQLite first. This is what the user sees.
      // ------------------------------------------------------

      await _loadFromLocal(user.id);

      // Local data is ready, so stop blocking here. The cloud sync used
      // to be awaited with the spinner still up, which is why the
      // categories took so long to appear.
      isLoading.value = false;

      // ------------------------------------------------------
      // 2. Cloud sync, off the loading path.
      // ------------------------------------------------------

      unawaited(_syncAndReload(user.id));
    } catch (_) {
      isLoading.value = false;
      _showError(
        'Unable to load categories.',
      );
    }
  }

  /// Syncs with the cloud and then refreshes the list, without holding
  /// up the screen.
  ///
  /// Separate from _syncInBackground() further down, which only pushes
  /// queued changes and is used after add and delete.
  Future<void> _syncAndReload(String userId) async {
    try {
      if (!Get.isRegistered<SyncManager>()) return;

      await Get.find<SyncManager>().sync();
      await _loadFromLocal(userId);
    } catch (_) {
      // Offline or cloud failure is fine; local data is already shown.
    }
  }

  // ==========================================================
  // LOAD FROM LOCAL DATABASE
  // ==========================================================

  Future<void> _loadFromLocal(
    String userId,
  ) async {
    final localCategories =
        await _repositories.categories
            .getCategories(userId);
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
        await _repositories.transactions
            .getTransactions(userId);

    final rawCategories =
        <Map<String, dynamic>>[];

    for (final category in localCategories) {
      rawCategories.add({
        'id': category.id,
        'name': category.name,
        'icon': category.icon,
        'color': category.color,
        'type': category.type,
        'isDefault':
            isProtectedCategoryName(category.name),
      });
    }

    final visibleData =
        filterVisibleCategories(rawCategories);

    final countsMap = <String, int>{};

    // ----------------------------------------------------------
    // Count transactions locally.
    // ----------------------------------------------------------

    for (final category in visibleData) {
      final categoryId =
          category['id']?.toString() ?? '';

      if (categoryId.isEmpty) {
        continue;
      }

      // Virtual protected categories have IDs such as
      // default_food. Their real transactions use the real
      // Supabase category ID, so count by category name below.
      final categoryName =
          _normalizeCategoryName(
        category['name']?.toString(),
      );

      int count = 0;

      for (final transaction
          in localTransactions) {
        final transactionCategoryId =
            transaction.categoryId;

        if (transactionCategoryId == null ||
            transactionCategoryId.isEmpty) {
          continue;
        }

        if (transactionCategoryId ==
            categoryId) {
          count++;
          continue;
        }

        // For protected virtual category IDs, resolve the
        // category through the local category record.
        final matchingLocalCategory =
            localCategories.firstWhereOrNull(
          (localCategory) =>
              localCategory.id ==
              transactionCategoryId,
        );

        if (matchingLocalCategory != null &&
            _normalizeCategoryName(
                  matchingLocalCategory.name,
                ) ==
                categoryName) {
          count++;
        }
      }

      countsMap[categoryId] = count;
    }

    final categories = <CategoryModel>[];

    for (final item in visibleData) {
      final rawName =
          item['name']?.toString() ?? '';

      final normalizedName =
          _normalizeCategoryName(rawName);

      final categoryId =
          item['id']?.toString() ??
              'default_$normalizedName';

      categories.add(
        CategoryModel(
          id: categoryId,
          name: rawName,
          icon:
              item['icon']?.toString() ??
                  normalizedName,
          colorValue:
              _parseColor(item['color']),
          isDefault:
              isProtectedCategoryName(rawName),
          type:
              item['type']
                      ?.toString()
                      .toLowerCase() ??
                  'expense',
        ),
      );
    }

    categories.sort(compareCategoryOrder);

    categoryCounts.assignAll(countsMap);
    categoryList.assignAll(categories);

    if (!_backfilledCustomCategories) {
      _backfilledCustomCategories = true;
      unawaited(_createMissingCustomCategories(localTransactions));
    }
  }

  /// Creates a category for every typed-in name found in transactions
  /// that has no category of its own yet.
  Future<void> _createMissingCustomCategories(
    List<dynamic> localTransactions,
  ) async {
    final existing = categoryList
        .map((category) => _normalizeCategoryName(category.name))
        .toSet();

    final missing = <String, String>{};

    for (final transaction in localTransactions) {
      final raw = (transaction.customCategory ?? '').toString().trim();
      if (raw.isEmpty) continue;

      final key = _normalizeCategoryName(raw);
      if (key.isEmpty || existing.contains(key)) continue;

      // Keep the first spelling the user actually typed.
      missing.putIfAbsent(key, () => raw);
    }

    if (missing.isEmpty) return;

    for (final name in missing.values) {
      await addCategory(
        CategoryModel(
          id: '',
          name: name,
          icon: 'other',
          colorValue: 0xFF2E7D32,
          isDefault: false,
          type: 'expense',
        ),
        closeDialog: false,
      );
    }
  }

  // ==========================================================
  // CATEGORY COUNT
  // ==========================================================

  int getCategoryCount(
    String categoryId,
  ) {
    return categoryCounts[categoryId] ?? 0;
  }

  double getCategoryTotal(
    String categoryId,
  ) {
    return categoryTotals[categoryId] ?? 0;
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

  if (trimmedName.isEmpty) {
    _showError('Please enter category name.');
    return;
  }

  try {
    isLoading.value = true;

   // ------------------------------------------------------
// Generate/use local UUID
// ------------------------------------------------------

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

final oldId = category.id.trim();

final categoryId = _isValidUuid(oldId)
    ? oldId
    : _generateUuid();

final colorHex = category.colorValue
    .toRadixString(16)
    .padLeft(8, '0');
    // ------------------------------------------------------
    // LOCAL FIRST
    // ------------------------------------------------------

    await _repositories.categorySync.createCategory(
      userId: user.id,
      id: categoryId,
      name: trimmedName,
      type: category.type,
      icon: category.icon,
      color: colorHex,
    );

    // ------------------------------------------------------
    // Update UI immediately
    // ------------------------------------------------------

    final newCategory = CategoryModel(
      id: categoryId,
      name: trimmedName,
      icon: category.icon,
      colorValue: category.colorValue,
      isDefault: false,
      type: category.type.toLowerCase(),
    );

    if (!categoryList.any(
      (item) => item.id == categoryId,
    )) {
      categoryList.add(newCategory);
    }

    categoryList.sort(compareCategoryOrder);

    categoryCounts[categoryId] = 0;

    // ------------------------------------------------------
    // IMPORTANT
    //
    // Do NOT start SyncManager while the custom dialog
    // is still transitioning back to AddTransactionDialog.
    // ------------------------------------------------------

    if (closeDialog && (Get.isDialogOpen ?? false)) {
      Get.back();
    }

    // ------------------------------------------------------
    // Start cloud sync AFTER the local/UI operation.
    // ------------------------------------------------------

    Future<void>.delayed(
      const Duration(milliseconds: 300),
      _syncInBackground,
    );
  } catch (e) {
    _showError(
      'Unable to add category.',
    );
  } finally {
    isLoading.value = false;
  }
}
  // ==========================================================
  // DELETE SINGLE CATEGORY
  // ==========================================================

  Future<void> deleteCategory(
    String id,
  ) async {
    await deleteCategories([id]);
  }

  // ==========================================================
  // DELETE MULTIPLE CATEGORIES
  // ==========================================================

  Future<void> deleteCategories(
    List<String> ids,
  ) async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return;
    }

    if (ids.isEmpty) {
      return;
    }

    // --------------------------------------------------------
    // Remove protected/default categories from deletion.
    // --------------------------------------------------------

    final selectedCategories =
        categoryList
            .where(
              (category) =>
                  ids.contains(category.id),
            )
            .toList();

    final protectedIds =
        selectedCategories
            .where(
              (category) =>
                  category.isDefault,
            )
            .map(
              (category) => category.id,
            )
            .toList();

    if (protectedIds.isNotEmpty) {
      _showError(
        'Default categories cannot be deleted.',
      );
      return;
    }

    try {
      isLoading.value = true;

      final idsToDelete =
          ids.toSet().toList();

      // ------------------------------------------------------
      // Find transactions belonging to these categories.
      // ------------------------------------------------------

      final localTransactions =
          await _repositories.transactions
              .getTransactions(user.id);

      final transactionsToDelete =
          localTransactions
              .where(
                (transaction) =>
                    transaction.categoryId !=
                        null &&
                    idsToDelete.contains(
                      transaction.categoryId,
                    ),
              )
              .toList();

      // ------------------------------------------------------
      // LOCAL FIRST:
      //
      // Delete related transactions through the same sync
      // queue system before deleting their categories.
      // ------------------------------------------------------

      for (final transaction
          in transactionsToDelete) {
        await _repositories
            .transactionSync
            .deleteTransaction(
          userId: user.id,
          id: transaction.id,
        );
      }

      // ------------------------------------------------------
      // Delete categories locally and queue cloud deletes.
      // ------------------------------------------------------

      for (final categoryId
          in idsToDelete) {
        await _repositories.categorySync
            .deleteCategory(
          userId: user.id,
          id: categoryId,
        );
      }

      // ------------------------------------------------------
      // Update UI immediately.
      // ------------------------------------------------------

      categoryList.removeWhere(
        (category) =>
            idsToDelete.contains(category.id),
      );

      for (final categoryId
          in idsToDelete) {
        categoryCounts.remove(
          categoryId,
        );
      }

      categoryList.sort(
        compareCategoryOrder,
      );

      // ------------------------------------------------------
      // Background synchronization.
      // ------------------------------------------------------

      _syncInBackground();
    } catch (_) {
      _showError(
        'Unable to delete category.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================
  // COLOR PARSER
  // ==========================================================

  int _parseColor(
    dynamic value,
  ) {
    if (value == null) {
      return 0xFF757575;
    }

    if (value is int) {
      return value;
    }

    String hex =
        value.toString()
            .replaceAll('#', '')
            .trim();

    if (hex.startsWith('0x')) {
      hex = hex.substring(2);
    }

    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    return int.tryParse(
          hex,
          radix: 16,
        ) ??
        0xFF757575;
  }

  // ==========================================================
  // BACKGROUND SYNC
  // ==========================================================

  void _syncInBackground() {
    try {
      if (Get.isRegistered<SyncManager>()) {
        unawaited(
          Get.find<SyncManager>().sync(),
        );
      }
    } catch (_) {
      // Local changes are already safely stored in SQLite.
      //
      // SyncManager will retry queued operations later.
    }
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  void _showError(
    String message,
  ) {
    // Do not use Get.snackbar().
    //
    // GetX snackbar previously caused:
    // LateInitializationError:
    // Field '_animation' has not been initialized.
    //
    // The controller remains independent from UI feedback.
  }

  // ==========================================================
  // UUID
  // ==========================================================

   // ==========================================================
  // UUID
  // ==========================================================

  String _generateUuid() {
    return const Uuid().v4();
  }

}