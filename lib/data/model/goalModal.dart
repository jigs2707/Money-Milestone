import 'package:money_milestone/utils/databaseHelper.dart';

class GoalModel {
  GoalModel({
    required this.id,
    required this.goalName,
    required this.goalAmount,
    required this.goalDate,
    required this.goalSavedAmount,
  });

  GoalModel.fromJson(final Map<String?, dynamic> json) {
    id = json["id"] ?? '';
    goalName = json[DatabaseHelper.goalNameKey] ?? '';
    goalDate = json[DatabaseHelper.goalDate] ?? '';
    goalSavedAmount = json[DatabaseHelper.goalSavedAmount] ?? '';
    goalAmount = json[DatabaseHelper.goalAmountKey] ?? '';
  }

  Map<String, dynamic> toJson() =>
      {
        DatabaseHelper.goalNameKey: goalName,
        DatabaseHelper.goalSavedAmount: goalSavedAmount,
        DatabaseHelper.goalDate: goalDate,
        DatabaseHelper.goalAmountKey: goalAmount
      };

  GoalModel copyWith({
    String? amount
  }) {
    return GoalModel(id: id,
        goalName: goalName,
        goalAmount: goalAmount,
        goalDate: goalDate,
        goalSavedAmount: amount);
  }

  String? id;
  String? goalName;
  String? goalDate;
  String? goalAmount;
  String? goalSavedAmount;
}
