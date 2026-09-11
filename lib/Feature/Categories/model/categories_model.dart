class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final int colorValue;
  final bool isDefault;
  final String type;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.isDefault,
    this.type = 'expense',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'colorValue': colorValue,
        'isDefault': isDefault,
        'type': type,
      };

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        icon: json['icon']?.toString() ?? 'category',
        colorValue: json['colorValue'] is int
            ? json['colorValue'] as int
            : int.tryParse(json['colorValue']?.toString() ?? '') ?? 0,
        isDefault: json['isDefault'] == true,
        type: json['type']?.toString().toLowerCase() ?? 'expense',
      );
}