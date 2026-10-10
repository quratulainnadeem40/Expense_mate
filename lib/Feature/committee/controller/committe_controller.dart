
import 'package:get/get.dart';

class CommitteeController extends GetxController {
  static final CommitteeController instance =
      CommitteeController();

  // --------------------------------------------------
  // ALL COMMITTEES
  // --------------------------------------------------

  final committees = <Map<String, dynamic>>[].obs;

  final RxnString activeCommitteeId = RxnString();

  int _nextId = 1;

  // --------------------------------------------------
  // CURRENTLY SELECTED COMMITTEE
  // Existing screens can continue using these fields.
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

  bool get hasCommittee =>
      committeeName.value.trim().isNotEmpty;

  // --------------------------------------------------
  // HELPERS
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
    };
  }

  void _saveActiveCommittee() {
    final String? id = activeCommitteeId.value;

    if (id == null || id.isEmpty || !hasCommittee) {
      return;
    }

    final int index = committees.indexWhere(
      (committee) => committee['id'] == id,
    );

    final Map<String, dynamic> snapshot =
        _currentCommitteeSnapshot();

    if (index == -1) {
      committees.add(snapshot);
    } else {
      committees[index] = snapshot;
    }

    committees.refresh();
  }

  // --------------------------------------------------
  // ADD COMMITTEE
  // Every new committee receives its own ID and data.
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
    // Save the previously selected committee first.
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
    };

    committees.add(newCommittee);
    committees.refresh();

    // Open the newly created committee as active.
    _loadCommittee(newCommittee);

    return id;
  }

  // --------------------------------------------------
  // SELECT A COMMITTEE
  // --------------------------------------------------

  bool selectCommittee(String id) {
    final int index = committees.indexWhere(
      (committee) => committee['id'] == id,
    );

    if (index == -1) return false;

    // Save changes to the previously selected committee.
    _saveActiveCommittee();

    _loadCommittee(committees[index]);

    return true;
  }

  void _loadCommittee(
    Map<String, dynamic> committee,
  ) {
    activeCommitteeId.value =
        committee['id']?.toString();

    committeeName.value =
        committee['name']?.toString() ?? '';

    monthlyContribution.value =
        double.tryParse(
          committee['contribution']?.toString() ?? '0',
        ) ?? 0;

    totalMembers.value =
        int.tryParse(
          (committee['memberCount'] ??
                  committee['membersCount'] ??
                  '0')
              .toString(),
        ) ?? 0;

    duration.value =
        int.tryParse(
          committee['duration']?.toString() ?? '0',
        ) ?? 0;

    durationUnit.value =
        committee['unit']?.toString() ??
            committee['durationUnit']?.toString() ??
            'Months';

    startDate.value = _parseDate(
      committee['startDate'],
    );

    endingDate.value = _parseDate(
      committee['endingDate'],
    );

    final dynamic savedMembers = committee['members'];
    final dynamic savedPayments = committee['payments'];

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

    members.refresh();
    payments.refresh();
  }

  // --------------------------------------------------
  // ADD MEMBER
  // --------------------------------------------------

  bool addMember({
    required String name,
    required String fatherName,
    required String phone,
    required double contribution,
  }) {
    if (!hasCommittee) return false;

    if (totalMembers.value > 0 &&
        members.length >= totalMembers.value) {
      return false;
    }

    final String memberName = name.trim();
    final String fatherHusbandName = fatherName.trim();

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
  }) {
    if (index < 0 || index >= members.length) {
      return false;
    }

    final String memberName = name.trim();
    final String fatherHusbandName = fatherName.trim();

    final bool alreadyExists = members.asMap().entries.any(
      (entry) {
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
      },
    );

    if (alreadyExists) return false;

    final Map<String, dynamic> oldMember = members[index];

    members[index] = {
      'name': memberName,
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

    members.refresh();
    payments.refresh();
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

      // Clamp the day to the last day of the target month.
      final DateTime targetMonth =
          DateTime(firstDay.year, firstDay.month + i, 1);

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

      final Map<String, dynamic> member =
          members[i % members.length];

      result.add({
        'month': receivingDate.month,
        'year': receivingDate.year,
        'date': receivingDate,
        'memberName': member['name']?.toString() ?? 'Member',
        'amount': totalPool,
        'status': 'Upcoming',
      });
    }

    return result;
  }

  void updateReceivingStatus(int index, String status) {
    // Kept for compatibility with existing screens.
    // Receiving schedule statuses are not persisted yet.
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
  // Other committees remain untouched.
  // --------------------------------------------------

  void clearCommittee() {
    final String? id = activeCommitteeId.value;

    if (id != null) {
      committees.removeWhere(
        (committee) => committee['id'] == id,
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

    members.refresh();
    payments.refresh();
  }
}
