class CommitteePaymentModel {
  final String id;
  final String committeeId;
  final String memberId;
  final String memberName;
  final double amount;
  final DateTime paymentDate;
  final String status;
  final String? note;

  CommitteePaymentModel({
    required this.id,
    required this.committeeId,
    required this.memberId,
    required this.memberName,
    required this.amount,
    required this.paymentDate,
    required this.status,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'committeeId': committeeId,
      'memberId': memberId,
      'memberName': memberName,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'status': status,
      'note': note,
    };
  }

  factory CommitteePaymentModel.fromMap(Map<String, dynamic> map) {
    return CommitteePaymentModel(
      id: map['id'] ?? '',
      committeeId: map['committeeId'] ?? '',
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      paymentDate: DateTime.parse(
        map['paymentDate'] ?? DateTime.now().toIso8601String(),
      ),
      status: map['status'] ?? 'Pending',
      note: map['note'],
    );
  }

  CommitteePaymentModel copyWith({
    String? id,
    String? committeeId,
    String? memberId,
    String? memberName,
    double? amount,
    DateTime? paymentDate,
    String? status,
    String? note,
  }) {
    return CommitteePaymentModel(
      id: id ?? this.id,
      committeeId: committeeId ?? this.committeeId,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }
}