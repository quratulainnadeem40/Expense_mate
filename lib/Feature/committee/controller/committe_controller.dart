
import 'dart:convert';

import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../Core/constants/app_keys.dart';

class CommitteeController extends GetxController {
  static final CommitteeController instance = CommitteeController();

  CommitteeController() {
    _loadCommittees();
  }

  Box get _storage => Hive.box(AppKeys.committeesBox);

  static const String _committeesKey = 'saved_committees';

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

  final members = <Map<String, dynamic>>[].obs;
  final payments = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  // Key: YYYY-MM, value: selected receiving member name.
  final receivingSelections = <String, String>{}.obs;

  bool get hasCommittee => committeeName.value.trim().isNotEmpty;

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
            (key, value) => MapEntry(
              key.toString(),
              value.toString(),
            ),
          );
        } else {
          committee['receivingSelections'] =
              <String, String>{};
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
      jsonEncode(
        committees.map(_encodeValue).toList(),
      ),
    );

    _storage.put(
      'active_committee_id',
      activeCommitteeId.value,
    );
  }

  dynamic _encodeValue(dynamic value) {
    if (value is DateTime) {
      return value.toIso8601String();
    }

    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(
          key.toString(),
          _encodeValue(item),
        ),
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

    final Map<String, dynamic> snapshot =
        _currentCommitteeSnapshot();

    if (index == -1) {
      committees.add(snapshot);
    } else {
      committees[index] = snapshot;
    }

    committees.refresh();
    _persistCommittees();
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
      'members': <Map<String, dynamic>>[],
      'payments': <Map<String, dynamic>>[],
      'receivingSelections': <String, String>{},
    };

    committees.add(newCommittee);
    committees.refresh();

    _loadCommittee(newCommittee);
    _persistCommittees();

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
    activeCommitteeId.value =
        committee['id']?.toString();

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

    final dynamic savedMembers = committee['members'];
    final dynamic savedPayments = committee['payments'];
    final dynamic savedSelections =
        committee['receivingSelections'];

    members.assignAll(
      savedMembers is List
          ? savedMembers
              .whereType<Map>()
              .map(
                (item) => Map<String, dynamic>.from(item),
              )
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
              (key, value) => MapEntry(
                key.toString(),
                value.toString(),
              ),
            )
          : <String, String>{},
    );

    members.refresh();
    payments.refresh();
    receivingSelections.refresh();
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
        memberUsername.isEmpty) {
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

    if (memberName.isEmpty ||
        fatherHusbandName.isEmpty ||
        memberUsername.isEmpty) {
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
      'paymentStatus':
          oldMember['paymentStatus'] ?? 'Pending',
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

  void markPaymentPending(int index) {
    if (index < 0 || index >= payments.length) return;

    payments[index]['status'] = 'Pending';
    payments[index]['note'] =
        'Payment is still pending.';
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

  double get totalDurationAmount =>
      totalPool * durationInMonths;

  // --------------------------------------------------
  // RECEIVING SCHEDULE
  // --------------------------------------------------

  List<Map<String, dynamic>> get receivingSchedule {
    final List<Map<String, dynamic>> result = [];

    if (!hasCommittee ||
        members.isEmpty ||
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
        firstDay.day > lastDay
            ? lastDay
            : firstDay.day,
      );

      final String defaultMember =
          members[i % members.length]['name']
              ?.toString() ??
          'Member';

      final String? savedMember =
          getReceivingSelection(receivingDate);

      final bool savedMemberExists = savedMember != null &&
          members.any(
            (member) =>
                member['name']?.toString().trim() ==
                savedMember,
          );

      result.add({
        'month': receivingDate.month,
        'year': receivingDate.year,
        'date': receivingDate,
        'memberName': savedMemberExists
            ? savedMember
            : defaultMember,
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

    if (id != null) {
      committees.removeWhere(
        (committee) => committee['id']?.toString() == id,
      );
      committees.refresh();
    }

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
}
