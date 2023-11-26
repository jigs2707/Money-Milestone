import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_milestone/data/model/goalModal.dart';
import 'package:money_milestone/utils/databaseHelper.dart';

class GoalRepository {
//
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> addGoal(
      {required GoalModel goalDetails, required String userId}) async {
    try {
      //
      await _firebaseFirestore
          .collection(DatabaseHelper.goalsCollectionName)
          .doc(userId)
          .collection(userId)
          .add(goalDetails.toJson());
      //
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> updateGoal({
    required GoalModel goalDetails,
    required String userId,
  }) async {
    try {
      //
      await _firebaseFirestore
          .collection(DatabaseHelper.goalsCollectionName)
          .doc(userId)
          .collection(userId)
          .doc(goalDetails.id)
          .update(goalDetails.toJson());
      //
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> deleteGoal({
    required GoalModel goalDetails,
    required String userId,
  }) async {
    try {
      //
      await _firebaseFirestore
          .collection(DatabaseHelper.goalsCollectionName)
          .doc(userId)
          .collection(userId)
          .doc(goalDetails.id)
          .delete();
      //
    } catch (e) {
      throw e.toString();
    }
  }
}
