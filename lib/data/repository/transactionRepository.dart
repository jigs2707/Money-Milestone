import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_milestone/data/model/transactionModel.dart';
import 'package:money_milestone/utils/databaseHelper.dart';

class TransactionRepository {
//
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> addAmountTransaction(
      {required TransactionModel transactionDetails,
      required String userId,
        required String goalId,
      }) async {
    try {
      //
      await _firebaseFirestore
          .collection(DatabaseHelper.transactionsCollectionName)
          .doc(userId)
          .collection(goalId)
          .add(transactionDetails.toJson());
      //
    } catch (e) {
      throw e.toString();
    }
  }
}
