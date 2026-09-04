class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final int colorValue;
  final bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.isDefault,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'colorValue': colorValue,
        'isDefault': isDefault,
      };

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'],
        name: json['name'],
        icon: json['icon'],
        colorValue: json['colorValue'],
        isDefault: json['isDefault'],
      );
}