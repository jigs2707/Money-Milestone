import 'package:flutter/material.dart';
import 'package:money_milestone/data/model/goalCategoryModel.dart';

class GoalCategories {
  // ── Prebuilt categories ─────────────────────────────────────────────────────
  static const List<GoalCategoryModel> prebuilt = [
    GoalCategoryModel(
      id: 'other',
      name: 'Other',
      icon: Icons.folder_open_rounded,
      color: Color(0xff9E9E9E),
    ),
    GoalCategoryModel(
      id: 'travel',
      name: 'Travel',
      icon: Icons.flight_rounded,
      color: Color(0xff6C47FF),
    ),
    GoalCategoryModel(
      id: 'home',
      name: 'Home',
      icon: Icons.home_rounded,
      color: Color(0xff4CAF50),
    ),
    GoalCategoryModel(
      id: 'car',
      name: 'Car',
      icon: Icons.directions_car_rounded,
      color: Color(0xff2196F3),
    ),
    GoalCategoryModel(
      id: 'education',
      name: 'Education',
      icon: Icons.school_rounded,
      color: Color(0xff9C27B0),
    ),
    GoalCategoryModel(
      id: 'health',
      name: 'Health',
      icon: Icons.favorite_rounded,
      color: Color(0xffF44336),
    ),
    GoalCategoryModel(
      id: 'wedding',
      name: 'Wedding',
      icon: Icons.diamond_rounded,
      color: Color(0xffE91E63),
    ),
    GoalCategoryModel(
      id: 'emergency',
      name: 'Emergency',
      icon: Icons.emergency_rounded,
      color: Color(0xffFF5722),
    ),
    GoalCategoryModel(
      id: 'retirement',
      name: 'Retirement',
      icon: Icons.weekend_rounded,
      color: Color(0xff607D8B),
    ),
    GoalCategoryModel(
      id: 'gadgets',
      name: 'Gadgets',
      icon: Icons.devices_rounded,
      color: Color(0xff00BCD4),
    ),
    GoalCategoryModel(
      id: 'vacation',
      name: 'Vacation',
      icon: Icons.beach_access_rounded,
      color: Color(0xffFFC107),
    ),
    GoalCategoryModel(
      id: 'business',
      name: 'Business',
      icon: Icons.work_rounded,
      color: Color(0xff795548),
    ),
  ];

  // ── Icon palette for custom categories ─────────────────────────────────────
  static const List<IconData> availableIcons = [
    Icons.star_rounded,
    Icons.sports_soccer_rounded,
    Icons.music_note_rounded,
    Icons.camera_alt_rounded,
    Icons.pets_rounded,
    Icons.local_cafe_rounded,
    Icons.fitness_center_rounded,
    Icons.shopping_bag_rounded,
    Icons.restaurant_rounded,
    Icons.book_rounded,
    Icons.movie_rounded,
    Icons.palette_rounded,
    Icons.computer_rounded,
    Icons.savings_rounded,
    Icons.account_balance_rounded,
    Icons.card_giftcard_rounded,
    Icons.celebration_rounded,
    Icons.eco_rounded,
    Icons.local_hospital_rounded,
    Icons.flight_takeoff_rounded,
    Icons.anchor_rounded,
    Icons.build_rounded,
    Icons.child_care_rounded,
    Icons.volunteer_activism_rounded,
  ];

  // ── Color palette for custom categories ────────────────────────────────────
  static const List<Color> availableColors = [
    Color(0xff6C47FF),
    Color(0xff4CAF50),
    Color(0xff2196F3),
    Color(0xffF44336),
    Color(0xffE91E63),
    Color(0xffFF5722),
    Color(0xff9C27B0),
    Color(0xff00BCD4),
    Color(0xffFFC107),
    Color(0xff795548),
    Color(0xff607D8B),
    Color(0xffFF9800),
  ];

  // ── Lookup helpers ──────────────────────────────────────────────────────────
  static GoalCategoryModel find(
    String? id, {
    List<GoalCategoryModel> customs = const [],
  }) {
    if (id == null || id.isEmpty) return prebuilt.first;
    for (final c in prebuilt) {
      if (c.id == id) return c;
    }
    for (final c in customs) {
      if (c.id == id) return c;
    }
    return prebuilt.first; // fall back to "other"
  }

  static List<GoalCategoryModel> all(
          {List<GoalCategoryModel> customs = const []}) =>
      [...prebuilt, ...customs];
}
