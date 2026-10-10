import 'package:get/get.dart';

class CommitteeController extends GetxController {
  static final CommitteeController instance =
      CommitteeController();

  // --------------------------------------------------
  // COMMITTEE INFORMATION
  // --------------------------------------------------

  final committeeName = ''.obs;

  final monthlyContribution = 0.0.obs;

  final totalMembers = 0.obs;

  final duration = 0.obs;

  final durationUnit = 'Months'.obs;

  final startDate = Rxn<DateTime>();

  final endingDate = Rxn<DateTime>();

  // --------------------------------------------------
  // MEMBERS
  // --------------------------------------------------

  // No dummy members.
  // Members will only appear when the user adds them.
  final members = <Map<String, dynamic>>[].obs;

  // --------------------------------------------------
  // PAYMENTS
  // --------------------------------------------------

  // No dummy payments.
  // Payments will only appear for actual members.
  final payments = <Map<String, dynamic>>[].obs;

  final isLoading = false.obs;

  // --------------------------------------------------
  // CHECK WHETHER COMMITTEE EXISTS
  // --------------------------------------------------

  bool get hasCommittee {
    return committeeName.value.trim().isNotEmpty;
  }

  // --------------------------------------------------
  // SAVE COMMITTEE
  // --------------------------------------------------

  void addCommittee({
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

    // New committee starts with no members
    // and no payments.
    members.clear();
    payments.clear();

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
    // Committee must exist first.
    if (!hasCommittee) {
      return false;
    }

    // HARD MEMBER LIMIT
    if (totalMembers.value > 0 &&
        members.length >= totalMembers.value) {
      return false;
    }

    final String memberName = name.trim();
    final String fatherHusbandName =
        fatherName.trim();

    // Prevent exact duplicate member.
    final bool alreadyExists = members.any(
      (member) {
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

    if (alreadyExists) {
      return false;
    }

    members.add({
      'name': memberName,

      // Both keys are kept for compatibility
      // with existing code.
      'fatherName': fatherHusbandName,
      'fatherHusbandName': fatherHusbandName,

      'phone': phone.trim(),

      'contribution': contribution,

      'paymentStatus': 'Pending',
    });

    members.refresh();

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

    final String fatherHusbandName =
        fatherName.trim();

    // Prevent duplicate with another member.
    final bool alreadyExists = members.asMap().entries.any(
      (entry) {
        final int existingIndex = entry.key;

        if (existingIndex == index) {
          return false;
        }

        final Map<String, dynamic> member =
            entry.value;

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

    if (alreadyExists) {
      return false;
    }

    final Map<String, dynamic> oldMember =
        members[index];

    members[index] = {
      'name': memberName,
      'fatherName': fatherHusbandName,
      'fatherHusbandName': fatherHusbandName,
      'phone': phone.trim(),
      'contribution': contribution,

      // Keep existing payment status.
      'paymentStatus':
          oldMember['paymentStatus'] ?? 'Pending',
    };

    members.refresh();

    return true;
  }

  // --------------------------------------------------
  // DELETE MEMBER
  // --------------------------------------------------

  void deleteMember(int index) {
    if (index < 0 || index >= members.length) {
      return;
    }

    final String? deletedMemberName =
        members[index]['name']?.toString();

    members.removeAt(index);

    // Remove payments belonging to deleted member.
    if (deletedMemberName != null &&
        deletedMemberName.trim().isNotEmpty) {
      payments.removeWhere(
        (payment) =>
            payment['memberName']?.toString() ==
            deletedMemberName,
      );

      payments.refresh();
    }

    members.refresh();
  }

  // --------------------------------------------------
  // PAYMENT
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
  }

  // --------------------------------------------------
  // MARK PAYMENT RECEIVED
  // --------------------------------------------------

  void markPaymentReceived(int index) {
    if (index < 0 || index >= payments.length) {
      return;
    }

    payments[index]['status'] = 'Received';

    payments[index]['paymentDate'] =
        DateTime.now();

    payments[index]['note'] =
        'Monthly contribution received.';

    payments.refresh();

    _updateMemberPaymentStatus(
      payments[index]['memberName'],
      'Received',
    );
  }

  // --------------------------------------------------
  // MARK PAYMENT PENDING
  // --------------------------------------------------

  void markPaymentPending(int index) {
    if (index < 0 || index >= payments.length) {
      return;
    }

    payments[index]['status'] = 'Pending';

    payments[index]['note'] =
        'Payment is still pending.';

    payments[index].remove('paymentDate');

    payments.refresh();

    _updateMemberPaymentStatus(
      payments[index]['memberName'],
      'Pending',
    );
  }

  // --------------------------------------------------
  // MARK PAYMENT OVERDUE
  // --------------------------------------------------

  void markPaymentOverdue(int index) {
    if (index < 0 || index >= payments.length) {
      return;
    }

    payments[index]['status'] = 'Overdue';

    payments[index]['note'] =
        'Payment due date has passed.';

    payments.refresh();

    _updateMemberPaymentStatus(
      payments[index]['memberName'],
      'Overdue',
    );
  }

  // --------------------------------------------------
  // UPDATE MEMBER PAYMENT STATUS
  // --------------------------------------------------

  void _updateMemberPaymentStatus(
    dynamic memberName,
    String status,
  ) {
    final String name =
        memberName?.toString() ?? '';

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

  // Monthly contribution of one member × total members.
  double get totalPool {
    return monthlyContribution.value *
        totalMembers.value;
  }

  // Same as Total Committee Amount.
  double get monthlyCommitteeAmount {
    return totalPool;
  }

  // --------------------------------------------------
  // DURATION IN MONTHS
  // --------------------------------------------------

  double get durationInMonths {
    if (duration.value <= 0) {
      return 0;
    }

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

  // --------------------------------------------------
  // TOTAL AMOUNT FOR COMPLETE DURATION
  // --------------------------------------------------

  double get totalDurationAmount {
    return totalPool * durationInMonths;
  }

  // --------------------------------------------------
  // RECEIVING SCHEDULE
  // --------------------------------------------------

  // Schedule is generated only when:
  // 1. Committee exists
  // 2. Real members have been added
  // 3. Duration exists
  // 4. Start date exists
  //
  // No dummy members are used here.

  List<Map<String, dynamic>> get receivingSchedule {
    final List<Map<String, dynamic>> result = [];

    if (!hasCommittee ||
        members.isEmpty ||
        durationInMonths <= 0 ||
        startDate.value == null) {
      return result;
    }

    final int months =
        durationInMonths.ceil();

    for (int i = 0; i < months; i++) {
      final DateTime receivingDate = DateTime(
        startDate.value!.year,
        startDate.value!.month + i,
        startDate.value!.day,
      );

      final Map<String, dynamic> member =
          members[i % members.length];

      result.add({
        'month': receivingDate.month,
        'year': receivingDate.year,
        'date': receivingDate,
        'memberName':
            member['name']?.toString() ?? 'Member',
        'amount': totalPool,
        'status': 'Upcoming',
      });
    }

    return result;
  }

  // --------------------------------------------------
  // UPDATE RECEIVING SCHEDULE STATUS
  // --------------------------------------------------

  void updateReceivingStatus(
    int index,
    String status,
  ) {
    // The schedule is generated dynamically,
    // so its permanent status is not stored here.
    //
    // This method is kept so existing code can call
    // it without breaking.
  }

  // --------------------------------------------------
  // CLEAR COMMITTEE
  // --------------------------------------------------

  void clearCommittee() {
    committeeName.value = '';

    monthlyContribution.value = 0.0;

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