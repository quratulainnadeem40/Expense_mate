class CommitteeMemberModel {
  final String id;
  final String committeeId;
  final String name;
  final String fatherHusbandName;
  final String phone;
  final double contribution;
  final String paymentStatus;

  CommitteeMemberModel({
    required this.id,
    required this.committeeId,
    required this.name,
    required this.fatherHusbandName,
    required this.phone,
    required this.contribution,
    required this.paymentStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'committeeId': committeeId,
      'name': name,
      'fatherHusbandName': fatherHusbandName,
      'phone': phone,
      'contribution': contribution,
      'paymentStatus': paymentStatus,
    };
  }

  factory CommitteeMemberModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return CommitteeMemberModel(
      id: map['id']?.toString() ?? '',
      committeeId:
          map['committeeId']?.toString() ?? '',
      name:
          map['name']?.toString() ?? '',
      fatherHusbandName:
          map['fatherHusbandName']
                  ?.toString() ??
              map['fatherName']
                  ?.toString() ??
              '',
      phone:
          map['phone']?.toString() ?? '',
      contribution:
          (map['contribution'] ?? 0)
              .toDouble(),
      paymentStatus:
          map['paymentStatus']
                  ?.toString() ??
              'Pending',
    );
  }

  CommitteeMemberModel copyWith({
    String? id,
    String? committeeId,
    String? name,
    String? fatherHusbandName,
    String? phone,
    double? contribution,
    String? paymentStatus,
  }) {
    return CommitteeMemberModel(
      id: id ?? this.id,
      committeeId:
          committeeId ?? this.committeeId,
      name: name ?? this.name,
      fatherHusbandName:
          fatherHusbandName ??
              this.fatherHusbandName,
      phone:
          phone ?? this.phone,
      contribution:
          contribution ??
              this.contribution,
      paymentStatus:
          paymentStatus ??
              this.paymentStatus,
    );
  }
}