
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

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Re-authenticates the current user (required before sensitive operations).
  Future<void> reAuthenticate({required String password}) async {
    final user = _firebaseAuth.currentUser!;
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(cred);
  }

  /// Updates the current user's password (call [reAuthenticate] first).
  Future<void> updatePassword({required String newPassword}) async {
    final user = _firebaseAuth.currentUser!;
    await user.updatePassword(newPassword);
  }

  Future<void> sendEmailVerification() async {
    User user = _firebaseAuth.currentUser!;
    await user.sendEmailVerification();
  }

  /// Reloads the Firebase user from the server so [emailVerified] is fresh.
  Future<void> reloadUser() async {
    User user = _firebaseAuth.currentUser!;
    await user.reload();
  }

  Future<bool> isEmailVerified() async {
    // Always reload to get the latest verification status from the server.
    await reloadUser();
    User user = _firebaseAuth.currentUser!;
    return user.emailVerified;
  }
}
