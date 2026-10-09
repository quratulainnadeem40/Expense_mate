/// One udhaar record: money lent to someone, or borrowed from them.
class UdhaarEntry {
  UdhaarEntry({
    required this.id,
    required this.personName,
    required this.amount,
    required this.isLent,
    required this.date,
    this.phone = '',
    this.note = '',
    this.isSettled = false,
    this.settledOn,
  });

  final String id;
  final String personName;
  final double amount;

  /// True when you gave the money out, false when you took it.
  ///
  /// One flag rather than two lists, because the same person can appear
  /// on both sides and the totals have to net out.
  final bool isLent;

  final DateTime date;
  final String phone;
  final String note;

  final bool isSettled;
  final DateTime? settledOn;

  /// Signed value: positive means it is coming back to you.
  double get signedAmount => isLent ? amount : -amount;

  int get daysOld => DateTime.now().difference(date).inDays;

  UdhaarEntry copyWith({
    String? personName,
    double? amount,
    bool? isLent,
    DateTime? date,
    String? phone,
    String? note,
    bool? isSettled,
    DateTime? settledOn,
    bool clearSettledOn = false,
  }) {
    return UdhaarEntry(
      id: id,
      personName: personName ?? this.personName,
      amount: amount ?? this.amount,
      isLent: isLent ?? this.isLent,
      date: date ?? this.date,
      phone: phone ?? this.phone,
      note: note ?? this.note,
      isSettled: isSettled ?? this.isSettled,
      settledOn: clearSettledOn ? null : (settledOn ?? this.settledOn),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'personName': personName,
        'amount': amount,
        'isLent': isLent,
        'date': date.toIso8601String(),
        'phone': phone,
        'note': note,
        'isSettled': isSettled,
        'settledOn': settledOn?.toIso8601String(),
      };

  factory UdhaarEntry.fromMap(Map<String, dynamic> map) {
    return UdhaarEntry(
      id: map['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      personName: map['personName']?.toString() ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      isLent: map['isLent'] == true,
      date: DateTime.tryParse(map['date']?.toString() ?? '') ??
          DateTime.now(),
      phone: map['phone']?.toString() ?? '',
      note: map['note']?.toString() ?? '',
      isSettled: map['isSettled'] == true,
      settledOn: DateTime.tryParse(map['settledOn']?.toString() ?? ''),
    );
  }
}

/// A person with everything outstanding between you and them rolled up.
class UdhaarPerson {
  UdhaarPerson({
    required this.name,
    required this.phone,
    required this.entries,
  });

  final String name;
  final String phone;
  final List<UdhaarEntry> entries;

  /// Positive means they owe you, negative means you owe them.
  double get net => entries
      .where((e) => !e.isSettled)
      .fold(0.0, (sum, e) => sum + e.signedAmount);

  bool get theyOweYou => net > 0;

  bool get isClear => net.abs() < 0.01;

  int get openCount => entries.where((e) => !e.isSettled).length;

  DateTime get lastActivity => entries
      .map((e) => e.date)
      .reduce((a, b) => a.isAfter(b) ? a : b);
}
