import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:money_milestone/data/model/goalModal.dart';
import 'package:money_milestone/utils/databaseHelper.dart';

class GoalRepository {
  final _db = Supabase.instance.client;

  Future<void> addGoal({required GoalModel goalDetails, required String userId}) async {
    try {
      await _db.from(DatabaseHelper.goalsCollectionName).insert({
        'user_id': userId,
        ...goalDetails.toJson(),
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> updateGoal({required GoalModel goalDetails, required String userId}) async {
    try {
      await _db
          .from(DatabaseHelper.goalsCollectionName)
          .update(goalDetails.toJson())
          .eq('id', goalDetails.id!);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> deleteGoal({required GoalModel goalDetails, required String userId}) async {
    try {
      await _db
          .from(DatabaseHelper.goalsCollectionName)
          .delete()
          .eq('id', goalDetails.id!);
    } catch (e) {
      throw e.toString();
    }
  }
}
