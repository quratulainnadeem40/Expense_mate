class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final int colorValue;
  final bool isDefault;

  /// A displayed category can represent both income and expense records.
  final String type;

  /// All database category IDs represented by this displayed category.
  final List<String> linkedIds;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.isDefault,
    this.type = 'expense',
    List<String>? linkedIds,
  }) : linkedIds = List<String>.unmodifiable(
         linkedIds == null || linkedIds.isEmpty ? [id] : linkedIds,
       );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'colorValue': colorValue,
    'isDefault': isDefault,
    'type': type,
    'linkedIds': linkedIds,
  };

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final rawIds = json['linkedIds'];

    return CategoryModel(
      id: id,
      name: json['name']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'category',
      colorValue: json['colorValue'] is int
          ? json['colorValue'] as int
          : int.tryParse(json['colorValue']?.toString() ?? '') ?? 0,
      isDefault: json['isDefault'] == true,
      type: json['type']?.toString().toLowerCase() ?? 'expense',
      linkedIds: rawIds is List
          ? rawIds.map((value) => value.toString()).toList()
          : [id],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CategoryModel &&
        other.name.trim().toLowerCase() == name.trim().toLowerCase();
  }

  @override
  int get hashCode => name.trim().toLowerCase().hashCode;
}
