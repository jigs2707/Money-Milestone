import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_milestone/data/model/goalCategoryModel.dart';
import 'package:money_milestone/utils/databaseHelper.dart';

class CategoryRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<GoalCategoryModel>> watchCategories(String userId) {
    return _db
        .collection(DatabaseHelper.usersCollectionName)
        .doc(userId)
        .collection(DatabaseHelper.categoriesCollection)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => GoalCategoryModel.fromFirestore(d.id, d.data()))
            .toList());
  }

  Future<void> addCategory(
      String userId, GoalCategoryModel category) async {
    await _db
        .collection(DatabaseHelper.usersCollectionName)
        .doc(userId)
        .collection(DatabaseHelper.categoriesCollection)
        .add(category.toJson());
  }

  Future<void> deleteCategory(String userId, String categoryId) async {
    await _db
        .collection(DatabaseHelper.usersCollectionName)
        .doc(userId)
        .collection(DatabaseHelper.categoriesCollection)
        .doc(categoryId)
        .delete();
  }
}
