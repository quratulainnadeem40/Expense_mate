import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../Core/constants/app_keys.dart';
import '../model/udhaar_model.dart';

enum UdhaarFilter { all, toReceive, toPay, settled }

class UdhaarController extends GetxController {
  static const String _entriesKey = 'udhaar_entries';

  final entries = <UdhaarEntry>[].obs;
  final filter = UdhaarFilter.all.obs;
  final searchQuery = ''.obs;

  Box get _box => Hive.box(AppKeys.udhaarBox);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  // ================================================================
  // STORAGE
  // ================================================================

  void load() {
    if (!Hive.isBoxOpen(AppKeys.udhaarBox)) return;

    final stored = _box.get(_entriesKey);
    if (stored is! List) return;

    try {
      entries.assignAll(
        stored
            .map((e) => UdhaarEntry.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
      _sort();
    } catch (_) {
      entries.clear();
    }
  }

  Future<void> _save() async {
    if (!Hive.isBoxOpen(AppKeys.udhaarBox)) return;
    await _box.put(_entriesKey, entries.map((e) => e.toMap()).toList());
  }

  void _sort() {
    // Open items first, then newest. A settled record sinking to the
    // bottom is what you want when the list gets long.
    entries.sort((a, b) {
      if (a.isSettled != b.isSettled) return a.isSettled ? 1 : -1;
      return b.date.compareTo(a.date);
    });
  }

  // ================================================================
  // TOTALS
  // ================================================================

  /// Money that should come back to you.
  double get totalToReceive => entries
      .where((e) => !e.isSettled && e.isLent)
      .fold(0.0, (sum, e) => sum + e.amount);

  /// Money you still have to return.
  double get totalToPay => entries
      .where((e) => !e.isSettled && !e.isLent)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get netBalance => totalToReceive - totalToPay;

  int get openCount => entries.where((e) => !e.isSettled).length;

  // ================================================================
  // GROUPED BY PERSON
  // ================================================================

  /// Entries rolled up per person, because what you actually want to
  /// know is "where do I stand with Ali", not every single line.
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
      // Anything still open outranks a cleared person.
      if (a.isClear != b.isClear) return a.isClear ? 1 : -1;
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

  List<UdhaarEntry> entriesFor(String personName) {
    final key = personName.trim().toLowerCase();

    return entries
        .where((e) => e.personName.trim().toLowerCase() == key)
        .toList();
  }

  // ================================================================
  // ACTIONS
  // ================================================================

  Future<void> addEntry({
    required String personName,
    required double amount,
    required bool isLent,
    required DateTime date,
    String phone = '',
    String note = '',
  }) async {
    entries.add(
      UdhaarEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        personName: personName.trim(),
        amount: amount,
        isLent: isLent,
        date: date,
        phone: phone.trim(),
        note: note.trim(),
      ),
    );

    _sort();
    await _save();
  }

  Future<void> updateEntry(UdhaarEntry updated) async {
    final index = entries.indexWhere((e) => e.id == updated.id);
    if (index == -1) return;

    entries[index] = updated;
    _sort();
    await _save();
  }

  Future<void> toggleSettled(String id) async {
    final index = entries.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final current = entries[index];

    entries[index] = current.copyWith(
      isSettled: !current.isSettled,
      settledOn: current.isSettled ? null : DateTime.now(),
      clearSettledOn: current.isSettled,
    );

    _sort();
    await _save();
  }

  /// Closes everything still open with one person in a single step.
  Future<void> settlePerson(String personName) async {
    final key = personName.trim().toLowerCase();
    final now = DateTime.now();

    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];

      if (entry.personName.trim().toLowerCase() == key && !entry.isSettled) {
        entries[i] = entry.copyWith(isSettled: true, settledOn: now);
      }
    }

    _sort();
    await _save();
  }

  Future<void> deleteEntry(String id) async {
    entries.removeWhere((e) => e.id == id);
    await _save();
  }

  Future<void> deletePerson(String personName) async {
    final key = personName.trim().toLowerCase();
    entries.removeWhere((e) => e.personName.trim().toLowerCase() == key);
    await _save();
  }

  void setFilter(UdhaarFilter value) => filter.value = value;

  void setSearch(String value) => searchQuery.value = value;
}
