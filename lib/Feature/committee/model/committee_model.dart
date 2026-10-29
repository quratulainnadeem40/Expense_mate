class CommitteeModel {
  final String id;
  final String name;
  final double monthlyContribution;
  final int totalMembers;
  final DateTime startDate;
  final int durationMonths;
  final DateTime dueDate;

  CommitteeModel({
    required this.id,
    required this.name,
    required this.monthlyContribution,
    required this.totalMembers,
    required this.startDate,
    required this.durationMonths,
    required this.dueDate,
  });

  double get totalPool {
    return monthlyContribution * totalMembers;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'monthlyContribution': monthlyContribution,
      'totalMembers': totalMembers,
      'startDate': startDate.toIso8601String(),
      'durationMonths': durationMonths,
      'dueDate': dueDate.toIso8601String(),
    };
  }

  factory CommitteeModel.fromMap(Map<String, dynamic> map) {
    return CommitteeModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      monthlyContribution:
          (map['monthlyContribution'] ?? 0).toDouble(),
      totalMembers: map['totalMembers'] ?? 0,
      startDate: DateTime.parse(
        map['startDate'] ?? DateTime.now().toIso8601String(),
      ),
      durationMonths: map['durationMonths'] ?? 0,
      dueDate: DateTime.parse(
        map['dueDate'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}