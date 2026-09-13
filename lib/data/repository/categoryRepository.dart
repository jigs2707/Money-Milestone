import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:money_milestone/data/model/goalCategoryModel.dart';
import 'package:money_milestone/utils/databaseHelper.dart';

class CategoryRepository {
  final _db = Supabase.instance.client;

  Stream<List<GoalCategoryModel>> watchCategories(String userId) {
    return _db
        .from(DatabaseHelper.categoriesCollection)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((rows) => rows.map((row) => GoalCategoryModel.fromMap(row)).toList());
  }

  Future<void> addCategory(String userId, GoalCategoryModel category) async {
    await _db.from(DatabaseHelper.categoriesCollection).insert({
      'user_id': userId,
      ...category.toJson(),
    });
  }

  Future<void> deleteCategory(String userId, String categoryId) async {
    await _db
        .from(DatabaseHelper.categoriesCollection)
        .delete()
        .eq('id', categoryId);
  }
}
