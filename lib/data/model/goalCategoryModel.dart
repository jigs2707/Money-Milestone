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
        'codePoint': icon.codePoint,
        'fontFamily': icon.fontFamily ?? 'MaterialIcons',
        'colorValue': color.toARGB32(),
        'isCustom': isCustom,
      };

  factory GoalCategoryModel.fromFirestore(
          String id, Map<String, dynamic> json) =>
      GoalCategoryModel(
        id: id,
        name: json['name'] as String,
        icon: IconData(
          json['codePoint'] as int,
          fontFamily: json['fontFamily'] as String? ?? 'MaterialIcons',
        ),
        color: Color(json['colorValue'] as int),
        isCustom: json['isCustom'] as bool? ?? true,
      );
}
