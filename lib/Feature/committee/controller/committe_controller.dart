import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../Core/constants/app_keys.dart';
import '../../../Core/Database/app_database.dart';
import '../../../Core/Database/database_provider.dart';
import '../../../Core/Database/repositories/committee_local_repository.dart';
import '../../../Core/Database/repositories/sync_queue_repository.dart';
import '../../../Core/Database/sync/sync_manager.dart';
class CommitteeController extends GetxController {
  static final CommitteeController instance = CommitteeController();

  CommitteeController() {
  _loadCommittees();
  unawaited(_initializeLocalSync());
}

  Box get _storage => Hive.box(AppKeys.committeesBox);

  static const String _committeesKey = 'saved_committees';
  final CommitteeLocalRepository _localRepository =
    CommitteeLocalRepository(DatabaseProvider.instance.database);

final SyncQueueRepository _syncQueueRepository =
    SyncQueueRepository(DatabaseProvider.instance.database);

  // --------------------------------------------------
  // ALL COMMITTEES
  // --------------------------------------------------

  final committees = <Map<String, dynamic>>[].obs;
  final RxnString activeCommitteeId = RxnString();

  int _nextId = 1;

  // --------------------------------------------------
  // CURRENT COMMITTEE
  // --------------------------------------------------

  final committeeName = ''.obs;
  final monthlyContribution = 0.0.obs;
  final totalMembers = 0.obs;
  final duration = 0.obs;
  final durationUnit = 'Months'.obs;
  final startDate = Rxn<DateTime>();
  final endingDate = Rxn<DateTime>();
  final allocationMode = 'sequence'.obs;

  final members = <Map<String, dynamic>>[].obs;
  final payments = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  // Key: YYYY-MM, value: selected receiving member name.
  final receivingSelections = <String, String>{}.obs;

  bool get hasCommittee => committeeName.value.trim().isNotEmpty;

  

String? get _currentUserId {
  return Supabase.instance.client.auth.currentUser?.id;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();

  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}

int _toInt(dynamic value) {
  if (value is num) return value.toInt();

  return int.tryParse(value?.toString() ?? '') ?? 0;
}

List<dynamic> _asList(dynamic value) {
  if (value is List) return value;

  if (value is String && value.isNotEmpty) {
    try {
      final decoded = jsonDecode(value);

      if (decoded is List) return decoded;
    } catch (_) {
      // Invalid JSON: return an empty list.
    }
  }

  return <dynamic>[];
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  if (value is String && value.isNotEmpty) {
    try {
      final decoded = jsonDecode(value);

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      // Invalid JSON: return an empty map.
    }
  }

  return <String, dynamic>{};
}

Map<String, dynamic> _toRemotePayload(
  Map<String, dynamic> committee,
  String userId,
) {
  final DateTime now = DateTime.now();

  final DateTime createdAt =
      _parseDate(committee['createdAt'] ?? committee['created_at']) ?? now;

  final DateTime start =
      _parseDate(committee['startDate'] ?? committee['start_date']) ?? now;

  final DateTime ending =
      _parseDate(committee['endingDate'] ?? committee['ending_date']) ?? now;

  return {
    'id': committee['id'].toString(),
    'user_id': userId,
    'name': committee['name']?.toString() ?? '',
    'contribution': _toDouble(committee['contribution']),
    'member_count': _toInt(
      committee['memberCount'] ?? committee['member_count'] ??
          committee['membersCount'],
    ),
    'duration': _toInt(committee['duration']),
    'unit': committee['unit']?.toString() ??
        committee['durationUnit']?.toString() ??
        'Months',
    'start_date': start.toIso8601String(),
    'ending_date': ending.toIso8601String(),
    'allocation_mode':
        committee['allocationMode']?.toString() ?? 'sequence',
    'members': _encodeValue(_asList(committee['members'])),
    'payments': _encodeValue(_asList(committee['payments'])),
    'receiving_selections': _encodeValue(
      _asMap(
        committee['receivingSelections'] ??
            committee['receiving_selections'],
      ),
    ),
    'created_at': createdAt.toIso8601String(),
    'updated_at': now.toIso8601String(),
  };
}

LocalCommitteesCompanion _toLocalCompanion(
  Map<String, dynamic> committee,
  String userId,
) {
  final DateTime now = DateTime.now();

  final DateTime createdAt =
      _parseDate(committee['createdAt'] ?? committee['created_at']) ?? now;

  final DateTime start =
      _parseDate(committee['startDate'] ?? committee['start_date']) ?? now;

  final DateTime ending =
      _parseDate(committee['endingDate'] ?? committee['ending_date']) ?? now;

  final List<dynamic> savedMembers = _asList(committee['members']);

  final List<dynamic> savedPayments = _asList(committee['payments']);

  final Map<String, dynamic> savedSelections = _asMap(
    committee['receivingSelections'] ?? committee['receiving_selections'],
  );

  return LocalCommitteesCompanion(
    id: drift.Value(committee['id'].toString()),
    userId: drift.Value(userId),
    name: drift.Value(committee['name']?.toString() ?? ''),
    contribution: drift.Value(_toDouble(committee['contribution'])),
    memberCount: drift.Value(
      _toInt(
        committee['memberCount'] ??
            committee['member_count'] ??
            committee['membersCount'],
      ),
    ),
    duration: drift.Value(_toInt(committee['duration'])),
    unit: drift.Value(
      committee['unit']?.toString() ??
          committee['durationUnit']?.toString() ??
          'Months',
    ),
    startDate: drift.Value(start),
    endingDate: drift.Value(ending),
    allocationMode: drift.Value(
      committee['allocationMode']?.toString() ?? 'sequence',
    ),
    membersJson: drift.Value(jsonEncode(_encodeValue(savedMembers))),
    paymentsJson: drift.Value(jsonEncode(_encodeValue(savedPayments))),
    receivingSelectionsJson: drift.Value(
      jsonEncode(_encodeValue(savedSelections)),
    ),
    createdAt: drift.Value(createdAt),
    updatedAt: drift.Value(now),
    version: const drift.Value(1),
    isDeleted: const drift.Value(false),
  );
}

Future<void> _saveCommitteeLocallyAndQueue(
  Map<String, dynamic> committee,
) async {
  final String? userId = _currentUserId;

  if (userId == null || userId.isEmpty) {
    return;
  }

  final String committeeId = committee['id']?.toString() ?? '';

  if (committeeId.isEmpty) return;

  try {
    final existing = await _localRepository.getCommitteeById(committeeId);

    final companion = _toLocalCompanion(committee, userId);

    final String operation;

    if (existing == null) {
      await _localRepository.insertCommittee(companion);
      operation = 'insert';
    } else {
      await _localRepository.updateCommittee(committeeId, companion);
      operation = 'update';
    }

    await _syncQueueRepository.enqueue(
      userId: userId,
      entityTable: 'committees',
      recordId: committeeId,
      operation: operation,
      payload: _toRemotePayload(committee, userId),
    );

    _triggerCommitteeSync();
  } catch (e) {
    print('COMMITTEE LOCAL SAVE ERROR: $e');
  }
}
  // --------------------------------------------------
  // USERNAME HELPERS
  // --------------------------------------------------

  String _normaliseUsername(String username) {
    return username.trim().toLowerCase();
  }

  bool isUsernameTaken(
    String username, {
    int? excludingMemberIndex,
  }) {
    final String normalizedUsername =
        _normaliseUsername(username);

    if (normalizedUsername.isEmpty) {
      return false;
    }

    // Check current committee members.
    for (final entry in members.asMap().entries) {
      if (excludingMemberIndex != null &&
          entry.key == excludingMemberIndex) {
        continue;
      }

      final String existingUsername = _normaliseUsername(
        entry.value['username']?.toString() ?? '',
      );

      if (existingUsername.isNotEmpty &&
          existingUsername == normalizedUsername) {
        return true;
      }
    }

    // Check members saved in other committees.
    for (final committee in committees) {
      final String committeeId =
          committee['id']?.toString() ?? '';

      if (activeCommitteeId.value != null &&
          committeeId == activeCommitteeId.value) {
        continue;
      }

      final dynamic savedMembers = committee['members'];

      if (savedMembers is! List) {
        continue;
      }

      for (final savedMember in savedMembers) {
        if (savedMember is! Map) {
          continue;
        }

        final String existingUsername = _normaliseUsername(
          savedMember['username']?.toString() ?? '',
        );

        if (existingUsername.isNotEmpty &&
            existingUsername == normalizedUsername) {
          return true;
        }
      }
    }

    return false;
  }

void _triggerCommitteeSync() {
  if (!Get.isRegistered<SyncManager>()) {
    print(
      'COMMITTEE SYNC: SyncManager is not registered. '
      'The queued operation will wait for the sync process.',
    );
    return;
  }

  unawaited(_runCommitteeSync());
}

Future<void> _runCommitteeSync() async {
  try {
    await Get.find<SyncManager>().sync();

    print('COMMITTEE SYNC: Sync completed.');
  } catch (e) {
    print('COMMITTEE SYNC ERROR: $e');
  }
}

Future<void> _initializeLocalSync() async {
  final String? userId = _currentUserId;

  if (userId == null || userId.isEmpty) {
    print('COMMITTEE SYNC: No authenticated user.');
    return;
  }

  try {
    isLoading.value = true;

    // Migrate existing Hive committees without deleting Hive data.
    for (final committee in committees.toList()) {
      final String id = committee['id']?.toString() ?? '';

      if (id.isEmpty) continue;

      final existing = await _localRepository.getCommitteeById(id);

      if (existing == null) {
        await _localRepository.insertCommittee(
          _toLocalCompanion(committee, userId),
        );

        await _syncQueueRepository.enqueue(
          userId: userId,
          entityTable: 'committees',
          recordId: id,
          operation: 'insert',
          payload: _toRemotePayload(committee, userId),
        );

        print('COMMITTEE MIGRATED TO DRIFT: $id');
      }
    }

    // Upload pending changes and download remote committees.
    if (Get.isRegistered<SyncManager>()) {
      await Get.find<SyncManager>().sync();
    }

    // Load synced/local records into the existing UI collection.
    await _refreshCommitteesFromLocal(userId);
  } catch (e) {
    print('COMMITTEE INITIALIZATION ERROR: $e');
  } finally {
    isLoading.value = false;
  }
}

Map<String, dynamic> _localRowToMap(LocalCommittee row) {
  final List<dynamic> restoredPayments = _asList(row.paymentsJson)
      .map((item) {
        if (item is! Map) return item;

        final payment = Map<String, dynamic>.from(item);

        payment['paymentDate'] = _parseDate(payment['paymentDate']);

        return payment;
      })
      .toList();

  return {
    'id': row.id,
    'name': row.name,
    'contribution': row.contribution,
    'memberCount': row.memberCount,
    'duration': row.duration,
    'unit': row.unit,
    'startDate': row.startDate,
    'endingDate': row.endingDate,
    'allocationMode': row.allocationMode,
    'members': _asList(row.membersJson),
    'payments': restoredPayments,
    'receivingSelections': _asMap(row.receivingSelectionsJson),
  };
}

Future<void> _refreshCommitteesFromLocal(String userId) async {
  final localRecords = await _localRepository.getCommittees(userId);

  // Keep existing Hive records if a local read returns no records.
  if (localRecords.isEmpty) return;

  final Map<String, Map<String, dynamic>> merged = {};

  // Keep current records first so Hive-only data is not discarded.
  for (final committee in committees) {
    final String id = committee['id']?.toString() ?? '';

    if (id.isNotEmpty) {
      merged[id] = Map<String, dynamic>.from(committee);
    }
  }

  // Local DB records are the synced/local database representation.
  for (final row in localRecords) {
    merged[row.id] = _localRowToMap(row);
  }

  committees.assignAll(merged.values.toList());

  final String? previousActiveId = activeCommitteeId.value;

  final Map<String, dynamic>? active = committees.firstWhereOrNull(
    (committee) => committee['id']?.toString() == previousActiveId,
  );

  if (active != null) {
    _loadCommittee(active);
  } else if (committees.isNotEmpty) {
    _loadCommittee(committees.first);
  }

  _persistCommittees();
}
  // --------------------------------------------------
  // LOAD SAVED COMMITTEES
  // --------------------------------------------------

  void _loadCommittees() {
    final dynamic storedValue = _storage.get(_committeesKey);

    if (storedValue is! String || storedValue.isEmpty) {
      return;
    }

    final dynamic decodedValue = jsonDecode(storedValue);

    if (decodedValue is! List) {
      return;
    }

    committees.assignAll(
      decodedValue.map((item) {
        final Map<String, dynamic> committee =
            Map<String, dynamic>.from(item as Map);

        committee['startDate'] =
            _parseDate(committee['startDate']);

        committee['endingDate'] =
            _parseDate(committee['endingDate']);

        final dynamic savedPayments = committee['payments'];

        if (savedPayments is List) {
          committee['payments'] = savedPayments.map((payment) {
            final Map<String, dynamic> restored =
                Map<String, dynamic>.from(payment as Map);

            restored['paymentDate'] =
                _parseDate(restored['paymentDate']);

            return restored;
          }).toList();
        }

        // Restore saved spinner selections.
        final dynamic savedSelections =
            committee['receivingSelections'];

        if (savedSelections is Map) {
          committee['receivingSelections'] =
              savedSelections.map(
            (key, value) =>
                MapEntry(key.toString(), value.toString()),
          );
        } else {
          committee['receivingSelections'] =
              <String, String>{};
        }

        // Old members without a slot value remain compatible.
        final dynamic savedMembers = committee['members'];

        if (savedMembers is List) {
          committee['members'] = savedMembers.map((item) {
            final Map<String, dynamic> member =
                Map<String, dynamic>.from(item as Map);

            final int savedSlot = int.tryParse(
                  member['slot']?.toString() ?? '1',
                ) ??
                1;

            member['slot'] = savedSlot < 1 ? 1 : savedSlot;

            return member;
          }).toList();
        }

        return committee;
      }).toList(),
    );

    if (committees.isNotEmpty) {
      final dynamic savedActiveId =
          _storage.get('active_committee_id');

      final String? activeId = savedActiveId?.toString();

      final Map<String, dynamic>? activeCommittee =
          committees.firstWhereOrNull(
        (committee) =>
            committee['id']?.toString() == activeId,
      );

      _loadCommittee(activeCommittee ?? committees.first);
    }
  }

  // --------------------------------------------------
  // PERSISTENCE
  // --------------------------------------------------

  void _persistCommittees() {
    _storage.put(
      _committeesKey,
      jsonEncode(committees.map(_encodeValue).toList()),
    );

    _storage.put('active_committee_id', activeCommitteeId.value);
  }

  dynamic _encodeValue(dynamic value) {
    if (value is DateTime) {
      return value.toIso8601String();
    }

    if (value is Map) {
      return value.map(
        (key, item) =>
            MapEntry(key.toString(), _encodeValue(item)),
      );
    }

    if (value is Iterable) {
      return value.map(_encodeValue).toList();
    }

    return value;
  }

  // --------------------------------------------------
  // GENERAL HELPERS
  // --------------------------------------------------

  String _newId() {
    return '${DateTime.now().microsecondsSinceEpoch}_${_nextId++}';
  }

  Map<String, dynamic> _copyMap(
    Map<String, dynamic> source,
  ) {
    return Map<String, dynamic>.from(source);
  }

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }

  Map<String, dynamic> _currentCommitteeSnapshot() {
    return {
      'id': activeCommitteeId.value,
      'name': committeeName.value,
      'contribution': monthlyContribution.value,
      'memberCount': totalMembers.value,
      'duration': duration.value,
      'unit': durationUnit.value,
      'startDate': startDate.value,
      'endingDate': endingDate.value,
      'allocationMode': allocationMode.value,
      'members': members
          .map((member) => _copyMap(member))
          .toList(),
      'payments': payments
          .map((payment) => _copyMap(payment))
          .toList(),
      'receivingSelections':
          Map<String, String>.from(receivingSelections),
    };
  }

  void _saveActiveCommittee() {
  final String? id = activeCommitteeId.value;

  if (id == null || id.isEmpty || !hasCommittee) {
    return;
  }

  final int index = committees.indexWhere(
    (committee) => committee['id']?.toString() == id,
  );

  final Map<String, dynamic> snapshot = _currentCommitteeSnapshot();

  if (index == -1) {
    committees.add(snapshot);
  } else {
    committees[index] = snapshot;
  }

  committees.refresh();

  // Keep existing Hive persistence.
  _persistCommittees();

  // Save to Drift and enqueue Supabase sync.
  unawaited(_saveCommitteeLocallyAndQueue(snapshot));
}
  // --------------------------------------------------
  // ADD COMMITTEE
  // --------------------------------------------------

  String addCommittee({
    required String name,
    required double contribution,
    required int memberCount,
    required int committeeDuration,
    required String unit,
    required DateTime committeeStartDate,
    required DateTime committeeEndingDate,
  }) {
    _saveActiveCommittee();

    final String id = _newId();

    final Map<String, dynamic> newCommittee = {
      'id': id,
      'name': name.trim(),
      'contribution': contribution,
      'memberCount': memberCount,
      'duration': committeeDuration,
      'unit': unit,
      'startDate': committeeStartDate,
      'endingDate': committeeEndingDate,
      'allocationMode': 'sequence',
      'members': <Map<String, dynamic>>[],
      'payments': <Map<String, dynamic>>[],
      'receivingSelections': <String, String>{},
    };

    committees.add(newCommittee);
    committees.refresh();

    _loadCommittee(newCommittee);
_persistCommittees();

unawaited(_saveCommitteeLocallyAndQueue(newCommittee));

return id;

  }

  // --------------------------------------------------
  // SELECT COMMITTEE
  // --------------------------------------------------

  bool selectCommittee(String id) {
    final int index = committees.indexWhere(
      (committee) => committee['id']?.toString() == id,
    );

    if (index == -1) return false;

    _saveActiveCommittee();
    _loadCommittee(committees[index]);

    return true;
  }

  void _loadCommittee(Map<String, dynamic> committee) {
    activeCommitteeId.value = committee['id']?.toString();

    committeeName.value =
        committee['name']?.toString() ?? '';

    monthlyContribution.value = double.tryParse(
          committee['contribution']?.toString() ?? '0',
        ) ??
        0;

    totalMembers.value = int.tryParse(
          (committee['memberCount'] ??
                  committee['membersCount'] ??
                  '0')
              .toString(),
        ) ??
        0;

    duration.value = int.tryParse(
          committee['duration']?.toString() ?? '0',
        ) ??
        0;

    durationUnit.value =
        committee['unit']?.toString() ??
        committee['durationUnit']?.toString() ??
        'Months';

    startDate.value = _parseDate(committee['startDate']);
    endingDate.value = _parseDate(committee['endingDate']);

    final String savedAllocationMode =
        committee['allocationMode']?.toString() ?? 'sequence';

    allocationMode.value =
        savedAllocationMode == 'spin' ? 'spin' : 'sequence';

    final dynamic savedMembers = committee['members'];
    final dynamic savedPayments = committee['payments'];
    final dynamic savedSelections =
        committee['receivingSelections'];

    members.assignAll(
      savedMembers is List
          ? savedMembers
              .whereType<Map>()
              .map((item) {
                final Map<String, dynamic> member =
                    Map<String, dynamic>.from(item);

                final int savedSlot = int.tryParse(
                      member['slot']?.toString() ?? '1',
                    ) ??
                    1;

                member['slot'] = savedSlot < 1 ? 1 : savedSlot;

                return member;
              })
              .toList()
          : <Map<String, dynamic>>[],
    );

    payments.assignAll(
      savedPayments is List
          ? savedPayments
              .whereType<Map>()
              .map(
                (item) => Map<String, dynamic>.from(item),
              )
              .toList()
          : <Map<String, dynamic>>[],
    );

    receivingSelections.assignAll(
      savedSelections is Map
          ? savedSelections.map(
              (key, value) =>
                  MapEntry(key.toString(), value.toString()),
            )
          : <String, String>{},
    );

    members.refresh();
    payments.refresh();
    receivingSelections.refresh();
  }

  // --------------------------------------------------
  // SLOT HELPERS
  // --------------------------------------------------

  int getMemberSlotCount(Map<String, dynamic> member) {
    final int slot = int.tryParse(
          member['slot']?.toString() ?? '1',
        ) ??
        1;

    return slot < 1 ? 1 : slot;
  }

  // Each slot creates a spinner entry, not a duplicate saved member.
  List<Map<String, dynamic>> get receivingSlotMembers {
    final List<Map<String, dynamic>> result = [];

    for (final member in members) {
      final String name =
          member['name']?.toString().trim() ?? '';

      if (name.isEmpty) continue;

      final int slotCount = getMemberSlotCount(member);

      for (int i = 0; i < slotCount; i++) {
        result.add({
          ...Map<String, dynamic>.from(member),
          'slotPosition': i + 1,
        });
      }
    }

    return result;
  }

  // --------------------------------------------------
  // ADD MEMBER
  // --------------------------------------------------

  bool addMember({
    required String name,
    required String fatherName,
    required String phone,
    required double contribution,
    String username = '',
    int slot = 1,
  }) {
    if (!hasCommittee) return false;

    if (totalMembers.value > 0 &&
        members.length >= totalMembers.value) {
      return false;
    }

    final String memberName = name.trim();
    final String fatherHusbandName = fatherName.trim();
    final String memberUsername = username.trim();

    if (memberName.isEmpty ||
        fatherHusbandName.isEmpty ||
        memberUsername.isEmpty ||
        slot < 1) {
      return false;
    }

    if (isUsernameTaken(memberUsername)) {
      return false;
    }

    final bool alreadyExists = members.any((member) {
      final String existingName =
          member['name']?.toString().trim() ?? '';

      final String existingFatherName =
          (member['fatherHusbandName'] ??
                  member['fatherName'] ??
                  '')
              .toString()
              .trim();

      return existingName.toLowerCase() ==
              memberName.toLowerCase() &&
          existingFatherName.toLowerCase() ==
              fatherHusbandName.toLowerCase();
    });

    if (alreadyExists) return false;

    members.add({
      'name': memberName,
      'username': memberUsername,
      'fatherName': fatherHusbandName,
      'fatherHusbandName': fatherHusbandName,
      'phone': phone.trim(),
      'contribution': contribution,
      'slot': slot,
      'paymentStatus': 'Pending',
    });

    members.refresh();
    _saveActiveCommittee();

    return true;
  }

  // --------------------------------------------------
  // UPDATE MEMBER
  // --------------------------------------------------

  bool updateMember({
    required int index,
    required String name,
    required String fatherName,
    required String phone,
    required double contribution,
    String? username,
    int? slot,
  }) {
    if (index < 0 || index >= members.length) {
      return false;
    }

    final Map<String, dynamic> oldMember = members[index];

    final String memberName = name.trim();
    final String fatherHusbandName = fatherName.trim();

    final String memberUsername =
        (username ?? oldMember['username']?.toString() ?? '')
            .trim();

    final int memberSlot = slot ??
        int.tryParse(oldMember['slot']?.toString() ?? '1') ??
        1;

    if (memberName.isEmpty ||
        fatherHusbandName.isEmpty ||
        memberUsername.isEmpty ||
        memberSlot < 1) {
      return false;
    }

    if (isUsernameTaken(
      memberUsername,
      excludingMemberIndex: index,
    )) {
      return false;
    }

    final bool alreadyExists =
        members.asMap().entries.any((entry) {
      if (entry.key == index) return false;

      final Map<String, dynamic> member = entry.value;

      final String existingName =
          member['name']?.toString().trim() ?? '';

      final String existingFatherName =
          (member['fatherHusbandName'] ??
                  member['fatherName'] ??
                  '')
              .toString()
              .trim();

      return existingName.toLowerCase() ==
              memberName.toLowerCase() &&
          existingFatherName.toLowerCase() ==
              fatherHusbandName.toLowerCase();
    });

    if (alreadyExists) return false;

    members[index] = {
      ...oldMember,
      'name': memberName,
      'username': memberUsername,
      'fatherName': fatherHusbandName,
      'fatherHusbandName': fatherHusbandName,
      'phone': phone.trim(),
      'contribution': contribution,
      'slot': memberSlot,
      'paymentStatus': oldMember['paymentStatus'] ?? 'Pending',
    };

    members.refresh();
    _saveActiveCommittee();

    return true;
  }

  // --------------------------------------------------
  // DELETE MEMBER
  // --------------------------------------------------

  void deleteMember(int index) {
    if (index < 0 || index >= members.length) return;

    final String deletedName =
        members[index]['name']?.toString() ?? '';

    members.removeAt(index);

    payments.removeWhere(
      (payment) =>
          payment['memberName']?.toString() == deletedName,
    );

    // Remove saved selections for the deleted member.
    receivingSelections.removeWhere(
      (key, value) => value == deletedName,
    );

    members.refresh();
    payments.refresh();
    receivingSelections.refresh();

    _saveActiveCommittee();
  }

  // --------------------------------------------------
  // PAYMENTS
  // --------------------------------------------------

  void addPayment({
    required String memberName,
    required double amount,
    required String status,
    DateTime? paymentDate,
    String? note,
  }) {
    final Map<String, dynamic> payment = {
      'memberName': memberName.trim(),
      'amount': amount,
      'status': status,
    };

    if (paymentDate != null) {
      payment['paymentDate'] = paymentDate;
    }

    if (note != null) {
      payment['note'] = note;
    }

    payments.add(payment);
    payments.refresh();

    _saveActiveCommittee();
  }

  void markPaymentReceived(int index) {
    if (index < 0 || index >= payments.length) return;

    payments[index]['status'] = 'Received';
    payments[index]['paymentDate'] = DateTime.now();
    payments[index]['note'] =
        'Monthly contribution received.';

    _updateMemberPaymentStatus(
      payments[index]['memberName'],
      'Received',
    );

    payments.refresh();
    _saveActiveCommittee();
  }

  void updatePaymentsStatus(
    Iterable<int> indices,
    String status,
  ) {
    final String normalizedStatus = status.toLowerCase();

    if (!{'received', 'pending', 'overdue'}
        .contains(normalizedStatus)) {
      return;
    }

    final String savedStatus = switch (normalizedStatus) {
      'received' => 'Received',
      'pending' => 'Pending',
      'overdue' => 'Overdue',
      _ => status,
    };

    final Set<int> validIndices = indices
        .where(
          (index) => index >= 0 && index < payments.length,
        )
        .toSet();

    if (validIndices.isEmpty) return;

    for (final int index in validIndices) {
      final Map<String, dynamic> payment = payments[index];

      payment['status'] = savedStatus;

      switch (normalizedStatus) {
        case 'received':
          payment['paymentDate'] = DateTime.now();
          payment['note'] =
              'Monthly contribution received.';
          break;
        case 'pending':
          payment.remove('paymentDate');
          payment['note'] = 'Payment is still pending.';
          break;
        case 'overdue':
          payment['note'] =
              'Payment due date has passed.';
          break;
      }

      _updateMemberPaymentStatus(
        payment['memberName'],
        savedStatus,
      );
    }

    payments.refresh();
    _saveActiveCommittee();
  }

  void markPaymentPending(int index) {
    if (index < 0 || index >= payments.length) return;

    payments[index]['status'] = 'Pending';
    payments[index]['note'] = 'Payment is still pending.';
    payments[index].remove('paymentDate');

    _updateMemberPaymentStatus(
      payments[index]['memberName'],
      'Pending',
    );

    payments.refresh();
    _saveActiveCommittee();
  }

  void markPaymentOverdue(int index) {
    if (index < 0 || index >= payments.length) return;

    payments[index]['status'] = 'Overdue';
    payments[index]['note'] =
        'Payment due date has passed.';

    _updateMemberPaymentStatus(
      payments[index]['memberName'],
      'Overdue',
    );

    payments.refresh();
    _saveActiveCommittee();
  }

  void _updateMemberPaymentStatus(
    dynamic memberName,
    String status,
  ) {
    final String name = memberName?.toString() ?? '';

    for (int i = 0; i < members.length; i++) {
      if (members[i]['name']?.toString() == name) {
        members[i]['paymentStatus'] = status;
      }
    }

    members.refresh();
  }

  // --------------------------------------------------
  // COMMITTEE CALCULATIONS
  // --------------------------------------------------

  double get totalPool =>
      monthlyContribution.value * totalMembers.value;

  double get monthlyCommitteeAmount => totalPool;

  double get durationInMonths {
    if (duration.value <= 0) return 0;

    switch (durationUnit.value.toLowerCase()) {
      case 'year':
      case 'years':
        return duration.value * 12;

      case 'week':
      case 'weeks':
        return duration.value / 4.345;

      case 'day':
      case 'days':
        return duration.value / 30;

      case 'month':
      case 'months':
      default:
        return duration.value.toDouble();
    }
  }

  double get totalDurationAmount {
    if (duration.value <= 0) return 0;
    return totalPool * duration.value;
  }

  // --------------------------------------------------
  // RECEIVING SCHEDULE
  // --------------------------------------------------

  List<Map<String, dynamic>> get receivingSchedule {
    final List<Map<String, dynamic>> result = [];

    final List<Map<String, dynamic>> slotMembers =
        receivingSlotMembers;

    if (!hasCommittee ||
        slotMembers.isEmpty ||
        durationInMonths <= 0 ||
        startDate.value == null) {
      return result;
    }

    final int months = durationInMonths.ceil();

    for (int i = 0; i < months; i++) {
      final DateTime firstDay = startDate.value!;

      final DateTime targetMonth = DateTime(
        firstDay.year,
        firstDay.month + i,
        1,
      );

      final int lastDay = DateTime(
        targetMonth.year,
        targetMonth.month + 1,
        0,
      ).day;

      final DateTime receivingDate = DateTime(
        targetMonth.year,
        targetMonth.month,
        firstDay.day > lastDay ? lastDay : firstDay.day,
      );

      final String defaultMember =
          slotMembers[i % slotMembers.length]['name']
                  ?.toString() ??
              'Member';

      final String? savedMember =
          getReceivingSelection(receivingDate);

      final bool savedMemberExists =
          savedMember != null &&
          members.any(
            (member) =>
                member['name']?.toString().trim() ==
                savedMember,
          );

      result.add({
        'month': receivingDate.month,
        'year': receivingDate.year,
        'date': receivingDate,
        'memberName':
            savedMemberExists ? savedMember : defaultMember,
        'amount': totalPool,
        'status': 'Upcoming',
      });
    }

    return result;
  }

  void updateReceivingStatus(int index, String status) {
    // Kept for compatibility with existing screens.
  }

  // --------------------------------------------------
  // SAVE AND READ SPINNER SELECTIONS
  // --------------------------------------------------

  String receivingMonthKey(DateTime date) {
    final String month =
        date.month.toString().padLeft(2, '0');

    return '${date.year}-$month';
  }

  String? getReceivingSelection(DateTime date) {
    return receivingSelections[receivingMonthKey(date)];
  }

  void saveReceivingSelection({
    required DateTime date,
    required String memberName,
  }) {
    final String name = memberName.trim();

    if (name.isEmpty) return;

    final bool memberExists = members.any(
      (member) =>
          (member['name']?.toString().trim() ?? '') == name,
    );

    if (!memberExists) return;

    receivingSelections[receivingMonthKey(date)] = name;
    receivingSelections.refresh();

    _saveActiveCommittee();
  }

  void saveReceivingSelectionForCommittee({
    required String committeeId,
    required DateTime date,
    required String memberName,
  }) {
    final String name = memberName.trim();

    final Map<String, dynamic>? committee =
        committees.firstWhereOrNull(
      (item) => item['id']?.toString() == committeeId,
    );

    if (name.isEmpty || committee == null) return;

    final dynamic savedMembers = committee['members'];

    final bool memberExists = savedMembers is List &&
        savedMembers.whereType<Map>().any(
          (member) =>
              member['name']?.toString().trim() == name,
        );

    if (!memberExists) return;

    final dynamic savedSelections =
        committee['receivingSelections'];

    final Map<String, String> selections =
        savedSelections is Map
            ? savedSelections.map(
                (key, value) => MapEntry(
                  key.toString(),
                  value.toString(),
                ),
              )
            : <String, String>{};

    selections[receivingMonthKey(date)] = name;
    committee['receivingSelections'] = selections;
    committees.refresh();

    if (activeCommitteeId.value == committeeId) {
      receivingSelections.assignAll(selections);
      _saveActiveCommittee();
   } else {
  _persistCommittees();

  unawaited(_saveCommitteeLocallyAndQueue(committee));
}
  }

  void setCommitteeAllocationMode({
    required String committeeId,
    required String mode,
  }) {
    if (mode != 'sequence' && mode != 'spin') return;

    final Map<String, dynamic>? committee =
        committees.firstWhereOrNull(
      (item) => item['id']?.toString() == committeeId,
    );

    if (committee == null) return;

    committee['allocationMode'] = mode;

    if (activeCommitteeId.value == committeeId) {
      allocationMode.value = mode;
      _saveActiveCommittee();
   } else {
  committees.refresh();
  _persistCommittees();

  unawaited(_saveCommitteeLocallyAndQueue(committee));
}
  }

  // --------------------------------------------------
  // EDIT CURRENT COMMITTEE
  // --------------------------------------------------

  void updateCurrentCommittee({
    required String name,
    required double contribution,
    required int memberCount,
    required int committeeDuration,
    required String unit,
    required DateTime committeeStartDate,
    required DateTime committeeEndingDate,
  }) {
    committeeName.value = name.trim();
    monthlyContribution.value = contribution;
    totalMembers.value = memberCount;
    duration.value = committeeDuration;
    durationUnit.value = unit;
    startDate.value = committeeStartDate;
    endingDate.value = committeeEndingDate;

    members.refresh();
    payments.refresh();

    _saveActiveCommittee();
  }

  // --------------------------------------------------
  // CLEAR SELECTED COMMITTEE
  // --------------------------------------------------

 void clearCommittee() {
  final String? id = activeCommitteeId.value;

  if (id != null && id.isNotEmpty) {
    unawaited(_deleteCommitteeLocallyAndQueue(id));

    committees.removeWhere(
      (committee) => committee['id']?.toString() == id,
    );

    committees.refresh();
  }

  // Keep the rest of your existing clearCommittee() method unchanged.
    activeCommitteeId.value = null;
    committeeName.value = '';
    monthlyContribution.value = 0;
    totalMembers.value = 0;
    duration.value = 0;
    durationUnit.value = 'Months';
    startDate.value = null;
    endingDate.value = null;

    members.clear();
    payments.clear();
    receivingSelections.clear();

    members.refresh();
    payments.refresh();
    receivingSelections.refresh();

    _persistCommittees();
  }

  Future<void> _deleteCommitteeLocallyAndQueue(String committeeId) async {
  final String? userId = _currentUserId;

  if (userId == null || userId.isEmpty) return;

  try {
    final existing = await _localRepository.getCommitteeById(committeeId);

    if (existing != null) {
      await _localRepository.softDeleteCommittee(committeeId);
    }

    await _syncQueueRepository.enqueue(
      userId: userId,
      entityTable: 'committees',
      recordId: committeeId,
      operation: 'delete',
      payload: {
        'id': committeeId,
        'user_id': userId,
      },
    );

    _triggerCommitteeSync();
  } catch (e) {
    print('COMMITTEE DELETE ERROR: $e');
  }
}
}
