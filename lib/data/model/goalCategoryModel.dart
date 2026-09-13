import 'package:flutter/material.dart';

class GoalCategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isCustom;

  const GoalCategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'code_point': icon.codePoint,
        'font_family': icon.fontFamily ?? 'MaterialIcons',
        'color_value': color.toARGB32(),
        'is_custom': isCustom,
      };

  factory GoalCategoryModel.fromMap(Map<String, dynamic> json) =>
      GoalCategoryModel(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: IconData(
          json['code_point'] as int,
          fontFamily: json['font_family'] as String? ?? 'MaterialIcons',
        ),
        color: Color(json['color_value'] as int),
        isCustom: json['is_custom'] as bool? ?? true,
      );
}
