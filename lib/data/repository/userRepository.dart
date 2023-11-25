import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  //
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> addUserName(
      {required String userId, required String name}) async {
    try {
      await _firebaseFirestore
          .collection("Users")
          .doc(userId)
          .set({'name': name});
    } catch (e) {
      throw e.toString();
    }
  }
}
