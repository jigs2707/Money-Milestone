
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<User> logIn({required String email, required String password}) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      return result.user!;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<User> signUp({required String email, required String password}) async {
    try {
      UserCredential result = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return result.user!;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<User> getCurrentUser() async {
    User user = _firebaseAuth.currentUser!;
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    User user = _firebaseAuth.currentUser!;
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    User user = _firebaseAuth.currentUser!;
    return user.emailVerified;
  }
}
