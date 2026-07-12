import 'package:money_milestone/utils/databaseHelper.dart';

class GoalModel {
  GoalModel({
    required this.id,
    required this.goalName,
    required this.goalAmount,
    required this.goalDate,
    required this.goalSavedAmount,
    this.categoryId,
  });

  GoalModel.fromJson(final Map<String?, dynamic> json) {
    id = json["id"] ?? '';
    goalName = json[DatabaseHelper.goalNameKey] ?? '';
    goalDate = json[DatabaseHelper.goalDate] ?? '';
    goalSavedAmount = json[DatabaseHelper.goalSavedAmount] ?? '';
    goalAmount = json[DatabaseHelper.goalAmountKey] ?? '';
    categoryId = json[DatabaseHelper.goalCategoryKey] as String?;
  }

  Map<String, dynamic> toJson() {
    final map = {
      DatabaseHelper.goalNameKey: goalName,
      DatabaseHelper.goalSavedAmount: goalSavedAmount,
      DatabaseHelper.goalDate: goalDate,
      DatabaseHelper.goalAmountKey: goalAmount,
    };
    if (categoryId != null) map[DatabaseHelper.goalCategoryKey] = categoryId;
    return map;
  }

  GoalModel copyWith({String? amount, String? categoryId}) {
    return GoalModel(
      id: id,
      goalName: goalName,
      goalAmount: goalAmount,
      goalDate: goalDate,
      goalSavedAmount: amount ?? goalSavedAmount,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  String? id;
  String? goalName;
  String? goalDate;
  String? goalAmount;
  String? goalSavedAmount;
  String? categoryId;
}
