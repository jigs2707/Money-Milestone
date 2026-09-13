import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:money_milestone/data/model/transactionModel.dart';
import 'package:money_milestone/utils/databaseHelper.dart';

class TransactionRepository {
  final _db = Supabase.instance.client;

  Future<void> addAmountTransaction({
    required TransactionModel transactionDetails,
    required String userId,
    required String goalId,
  }) async {
    try {
      await _db.from(DatabaseHelper.transactionsCollectionName).insert({
        'user_id': userId,
        'goal_id': goalId,
        DatabaseHelper.transactionAmount: transactionDetails.transactionAmount,
        DatabaseHelper.transactionDate: transactionDetails.transactionDate,
        DatabaseHelper.transactionNote: transactionDetails.transactionNote,
        DatabaseHelper.transactionType: transactionDetails.transactionType,
      });
    } catch (e) {
      throw e.toString();
    }
  }
}
