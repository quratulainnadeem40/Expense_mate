import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:expense_mate/Core/Database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expense_mate/Core/Database/app_database.dart';

import '../../../Core/constants/app_keys.dart';
import '../../../Core/Database/database_provider.dart';
import '../../../Core/Database/repositories/udhaar_local_repository.dart';
import '../../../Core/Database/repositories/sync_queue_repository.dart';
import '../../../Core/Database/sync/sync_manager.dart';
import '../model/udhaar_model.dart';

enum UdhaarFilter { all, toReceive, toPay, settled }

class UdhaarController extends GetxController {
  static const String _entriesKey = 'udhaar_entries';

  final entries = <UdhaarEntry>[].obs;
  final filter = UdhaarFilter.all.obs;
  final searchQuery = ''.obs;

  Box get _box => Hive.box(AppKeys.udhaarBox);

  late final UdhaarLocalRepository _local;
  late final SyncQueueRepository _queue;

  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  @override
  void onInit() {
    super.onInit();

    final database = DatabaseProvider.instance.database;

    _local = UdhaarLocalRepository(database);
    _queue = SyncQueueRepository(database);

    unawaited(load());
  }

  // ================================================================
  // LOAD AND MIGRATE
  // ================================================================

  Future<void> load() async {
    if (!Hive.isBoxOpen(AppKeys.udhaarBox)) {
      return;
    }

    try {
      final stored = _box.get(_entriesKey);

      final hiveEntries = stored is List
          ? stored
                .whereType<Map>()
                .map(
                  (item) =>
                      UdhaarEntry.fromMap(Map<String, dynamic>.from(item)),
                )
                .toList()
          : <UdhaarEntry>[];

      final userId = _userId;

      // Without a signed-in user, retain the existing
      // Hive-based experience.
      if (userId == null) {
        entries.assignAll(hiveEntries);
        _sort();
        return;
      }

      // First migrate existing Hive records into Drift.
      await _migrateHiveEntries(userId: userId, hiveEntries: hiveEntries);

      // Drift is the source of truth for a signed-in user.
      final localEntries = await _local.getEntries(userId);

      entries.assignAll(localEntries.map(_fromLocal).toList());

      _sort();

      // Refresh from Supabase and reload Drift afterward.
      // Do not block the initial UI on network access.
      _refreshFromCloud();
    } catch (e, stackTrace) {
      // Keep the old data visible if local migration fails.
      debugPrint('Udhaar load failed: $e');
      debugPrint('$stackTrace');

      try {
        final stored = _box.get(_entriesKey);

        if (stored is List) {
          entries.assignAll(
            stored
                .whereType<Map>()
                .map(
                  (item) =>
                      UdhaarEntry.fromMap(Map<String, dynamic>.from(item)),
                )
                .toList(),
          );

          _sort();
        }
      } catch (fallbackError) {
        debugPrint('Udhaar Hive fallback failed: $fallbackError');
      }
    }
  }

  Future<void> _migrateHiveEntries({
    required String userId,
    required List<UdhaarEntry> hiveEntries,
  }) async {
    final marker = 'udhaar_migrated_user_$userId';

    // A successful migration is performed once per user.
    if (_box.get(marker) == true) {
      return;
    }

    for (final entry in hiveEntries) {
      final existing = await _local.getEntryById(entry.id);

      // Do not overwrite an existing Drift record.
      if (existing != null) {
        continue;
      }

      final now = DateTime.now();

      final companion = _toCompanion(
        entry: entry,
        userId: userId,
        createdAt: now,
        updatedAt: now,
      );

      await _local.insertEntry(companion);

      // Preserve the original Hive ID.
      await _enqueue(
        userId: userId,
        entry: entry,
        operation: 'insert',
        createdAt: now,
        updatedAt: now,
      );
    }

    // Set the marker only after every entry has been processed.
    await _box.put(marker, true);
  }

  Future<void> _refreshFromCloud() async {
    if (_userId == null) return;

    try {
      if (Get.isRegistered<SyncManager>()) {
        await Get.find<SyncManager>().sync();
      }

      final userId = _userId;

      // The account might have changed during the sync.
      if (userId == null) return;

      final localEntries = await _local.getEntries(userId);

      entries.assignAll(localEntries.map(_fromLocal).toList());

      _sort();
      await _save();
    } catch (e) {
      debugPrint('Udhaar cloud refresh failed: $e');
    }
  }

  // ================================================================
  // HIVE BACKUP
  // ================================================================

  Future<void> _save() async {
    if (!Hive.isBoxOpen(AppKeys.udhaarBox)) {
      return;
    }

    await _box.put(_entriesKey, entries.map((entry) => entry.toMap()).toList());
  }

  // ================================================================
  // DRIFT MAPPING
  // ================================================================

  UdhaarEntry _fromLocal(dynamic row) {
    return UdhaarEntry(
      id: row.id.toString(),
      personName: row.personName.toString(),
      amount: (row.amount as num).toDouble(),
      isLent: row.isLent as bool,
      date: row.entryDate as DateTime,
      phone: row.phone?.toString() ?? '',
      note: row.note?.toString() ?? '',
      isSettled: row.isSettled as bool,
      settledOn: row.settledOn as DateTime?,
    );
  }

  LocalUdhaarEntriesCompanion _toCompanion({
    required UdhaarEntry entry,
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return LocalUdhaarEntriesCompanion(
      id: drift.Value(entry.id),
      userId: drift.Value(userId),
      personName: drift.Value(entry.personName),
      phone: drift.Value(entry.phone),
      amount: drift.Value(entry.amount),
      isLent: drift.Value(entry.isLent),
      entryDate: drift.Value(entry.date),
      note: drift.Value(entry.note),
      isSettled: drift.Value(entry.isSettled),
      settledOn: drift.Value(entry.settledOn),
      createdAt: drift.Value(createdAt),
      updatedAt: drift.Value(updatedAt),
      version: const drift.Value(1),
      isDeleted: const drift.Value(false),
    );
  }

  Map<String, dynamic> _toRemotePayload({
    required UdhaarEntry entry,
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return {
      'id': entry.id,
      'user_id': userId,
      'person_name': entry.personName,
      'phone': entry.phone,
      'amount': entry.amount,
      'is_lent': entry.isLent,
      'entry_date': entry.date.toIso8601String(),
      'note': entry.note,
      'is_settled': entry.isSettled,
      'settled_on': entry.settledOn?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ================================================================
  // SAVE LOCALLY AND QUEUE SYNC
  // ================================================================

  Future<void> _persistEntry(
    UdhaarEntry entry, {
    required String operation,
  }) async {
    final userId = _userId;

    // Signed-out changes remain available in Hive.
    // They can be migrated when the user signs in.
    if (userId == null) {
      await _save();
      return;
    }

    final now = DateTime.now();
    final existing = await _local.getEntryById(entry.id);

    if (existing != null && existing.userId != userId) {
      throw StateError('This Udhaar entry belongs to another account.');
    }

    final createdAt = existing?.createdAt ?? now;

    final companion = _toCompanion(
      entry: entry,
      userId: userId,
      createdAt: createdAt,
      updatedAt: now,
    );

    if (existing == null) {
      await _local.insertEntry(companion);
    } else {
      await _local.updateEntry(entry.id, companion);
    }

    await _enqueue(
      userId: userId,
      entry: entry,
      operation: existing == null ? 'insert' : operation,
      createdAt: createdAt,
      updatedAt: now,
    );

    // Hive remains a backup for backward compatibility.
    await _save();

    // Attempt immediate sync if SyncManager is registered.
    _triggerSync();
  }

  Future<void> _enqueue({
    required String userId,
    required UdhaarEntry entry,
    required String operation,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) async {
    await _queue.enqueue(
      userId: userId,
      entityTable: 'udhaar_entries',
      recordId: entry.id,
      operation: operation,
      payload: _toRemotePayload(
        entry: entry,
        userId: userId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    );
  }

  void _triggerSync() {
    if (!Get.isRegistered<SyncManager>()) {
      return;
    }

    unawaited(
      Get.find<SyncManager>().sync().catchError((Object error) {
        debugPrint('Udhaar sync deferred: $error');
      }),
    );
  }

  // ================================================================
  // SORTING
  // ================================================================

  void _sort() {
    entries.sort((a, b) {
      if (a.isSettled != b.isSettled) {
        return a.isSettled ? 1 : -1;
      }

      return b.date.compareTo(a.date);
    });
  }

  // ================================================================
  // TOTALS
  // ================================================================

  double get totalToReceive => entries
      .where((e) => !e.isSettled && e.isLent)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get totalToPay => entries
      .where((e) => !e.isSettled && !e.isLent)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get netBalance => totalToReceive - totalToPay;

  int get openCount => entries.where((e) => !e.isSettled).length;

  // ================================================================
  // PEOPLE
  // ================================================================

  List<UdhaarPerson> get people {
    final grouped = <String, List<UdhaarEntry>>{};
    final phones = <String, String>{};

    for (final entry in entries) {
      final key = entry.personName.trim().toLowerCase();

      if (key.isEmpty) continue;

      grouped.putIfAbsent(key, () => []).add(entry);

      if (entry.phone.trim().isNotEmpty) {
        phones[key] = entry.phone.trim();
      }
    }

    final result = grouped.entries.map((item) {
      return UdhaarPerson(
        name: item.value.first.personName.trim(),
        phone: phones[item.key] ?? '',
        entries: item.value,
      );
    }).toList();

    result.sort((a, b) {
      if (a.isClear != b.isClear) {
        return a.isClear ? 1 : -1;
      }

      return b.lastActivity.compareTo(a.lastActivity);
    });

    return result;
  }

  List<UdhaarPerson> get visiblePeople {
    final query = searchQuery.value.trim().toLowerCase();

    return people.where((person) {
      if (query.isNotEmpty &&
          !person.name.toLowerCase().contains(query) &&
          !person.phone.contains(query)) {
        return false;
      }

      switch (filter.value) {
        case UdhaarFilter.toReceive:
          return !person.isClear && person.theyOweYou;
        case UdhaarFilter.toPay:
          return !person.isClear && !person.theyOweYou;
        case UdhaarFilter.settled:
          return person.isClear;
        case UdhaarFilter.all:
          return true;
      }
    }).toList();
  }

  int countFor(UdhaarFilter value) {
    final all = people;

    switch (value) {
      case UdhaarFilter.toReceive:
        return all.where((p) => !p.isClear && p.theyOweYou).length;
      case UdhaarFilter.toPay:
        return all.where((p) => !p.isClear && !p.theyOweYou).length;
      case UdhaarFilter.settled:
        return all.where((p) => p.isClear).length;
      case UdhaarFilter.all:
        return all.length;
    }
  }

  List<String> get knownNames =>
      people.map((p) => p.name).where((n) => n.isNotEmpty).toList();

  String phoneFor(String personName) {
    final key = personName.trim().toLowerCase();

    for (final person in people) {
      if (person.name.trim().toLowerCase() == key) {
        return person.phone;
      }
    }

    return '';
  }

  List<UdhaarEntry> entriesFor(String personName) {
    final key = personName.trim().toLowerCase();

    return entries
        .where((e) => e.personName.trim().toLowerCase() == key)
        .toList();
  }

  // ================================================================
  // ADD
  // ================================================================

  Future<void> addEntry({
    required String personName,
    required double amount,
    required bool isLent,
    required DateTime date,
    String phone = '',
    String note = '',
  }) async {
    final entry = UdhaarEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      personName: personName.trim(),
      amount: amount,
      isLent: isLent,
      date: date,
      phone: phone.trim(),
      note: note.trim(),
    );

    // Show the change immediately.
    entries.add(entry);
    _sort();

    try {
      await _persistEntry(entry, operation: 'insert');
    } catch (e) {
      entries.removeWhere((item) => item.id == entry.id);
      _sort();
      await _save();
      rethrow;
    }
  }

  // ================================================================
  // UPDATE
  // ================================================================

  Future<void> updateEntry(UdhaarEntry updated) async {
    final index = entries.indexWhere((e) => e.id == updated.id);

    if (index == -1) return;

    final previous = entries[index];

    entries[index] = updated;
    _sort();

    try {
      await _persistEntry(updated, operation: 'update');
    } catch (e) {
      entries[indexWhere(updated.id)] = previous;
      _sort();
      await _save();
      rethrow;
    }
  }

  int indexWhere(String id) => entries.indexWhere((entry) => entry.id == id);

  // ================================================================
  // SETTLEMENT
  // ================================================================

  Future<void> toggleSettled(String id) async {
    final index = entries.indexWhere((e) => e.id == id);

    if (index == -1) return;

    final current = entries[index];

    final updated = current.copyWith(
      isSettled: !current.isSettled,
      settledOn: current.isSettled ? null : DateTime.now(),
      clearSettledOn: current.isSettled,
    );

    entries[index] = updated;
    _sort();

    try {
      await _persistEntry(updated, operation: 'update');
    } catch (e) {
      entries.add(current);
      entries.removeWhere(
        (entry) => entry.id == updated.id && entry != current,
      );
      _sort();
      await _save();
      rethrow;
    }
  }

  Future<void> settlePerson(String personName) async {
    final key = personName.trim().toLowerCase();
    final now = DateTime.now();

    final previous = <String, UdhaarEntry>{};
    final updatedEntries = <UdhaarEntry>[];

    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];

      if (entry.personName.trim().toLowerCase() == key && !entry.isSettled) {
        previous[entry.id] = entry;

        final updated = entry.copyWith(isSettled: true, settledOn: now);

        entries[i] = updated;
        updatedEntries.add(updated);
      }
    }

    _sort();

    try {
      for (final entry in updatedEntries) {
        await _persistEntry(entry, operation: 'update');
      }
    } catch (e) {
      for (var i = 0; i < entries.length; i++) {
        final old = previous[entries[i].id];

        if (old != null) {
          entries[i] = old;
        }
      }

      _sort();
      await _save();
      rethrow;
    }
  }

  // ================================================================
  // DELETE
  // ================================================================

  Future<void> deleteEntry(String id) async {
    final index = entries.indexWhere((e) => e.id == id);

    if (index == -1) return;

    final entry = entries[index];
    final userId = _userId;

    if (userId == null) {
      entries.removeAt(index);
      await _save();
      return;
    }

    // Queue the delete before removing the local record.
    // This keeps the original payload available for sync.
    final now = DateTime.now();

    await _enqueue(
      userId: userId,
      entry: entry,
      operation: 'delete',
      createdAt: now,
      updatedAt: now,
    );

    await _local.softDeleteEntry(id);

    entries.removeWhere((item) => item.id == id);
    await _save();

    _triggerSync();
  }

  Future<void> deletePerson(String personName) async {
    final key = personName.trim().toLowerCase();

    final personEntries = entries
        .where((e) => e.personName.trim().toLowerCase() == key)
        .toList();

    for (final entry in personEntries) {
      await deleteEntry(entry.id);
    }
  }

  // ================================================================
  // FILTER AND SEARCH
  // ================================================================

  void setFilter(UdhaarFilter value) {
    filter.value = value;
  }

  void setSearch(String value) {
    searchQuery.value = value;
  }
}
