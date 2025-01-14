import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_milestone/utils/databaseHelper.dart';

class UserRepository {
  //
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> addUserName(
      {required String userId, required String name}) async {
    try {
      await _firebaseFirestore
          .collection(DatabaseHelper.usersCollectionName)
          .doc(userId)
          .set({DatabaseHelper.userNameKey: name});
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> getUserName({
    required String userId,
  }) async {
    try {
      DocumentSnapshot userData = await _firebaseFirestore
          .collection(DatabaseHelper.usersCollectionName)
          .doc(userId)
          .get();
      return ((userData.data() as Map<String, dynamic>)["name"] ??'');
    } catch (e) {
      throw e.toString();
    }
  }
}
