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
      return ((userData.data() as Map<String, dynamic>)["name"] ?? '');
    } catch (e) {
      throw e.toString();
    }
  }

  /// Returns the saved ISO 4217 currency code for this user, or 'USD' if none.
  Future<String> getCurrencyCode({required String userId}) async {
    try {
      final doc = await _firebaseFirestore
          .collection(DatabaseHelper.usersCollectionName)
          .doc(userId)
          .get();
      final data = doc.data() as Map<String, dynamic>?;
      return data?[DatabaseHelper.currencyKey] ?? 'USD';
    } catch (_) {
      return 'USD';
    }
  }

  /// Persists the selected currency code to the user's Firestore document.
  Future<void> saveCurrencyCode(
      {required String userId, required String code}) async {
    try {
      await _firebaseFirestore
          .collection(DatabaseHelper.usersCollectionName)
          .doc(userId)
          .set({DatabaseHelper.currencyKey: code}, SetOptions(merge: true));
    } catch (e) {
      throw e.toString();
    }
  }

  /// Updates the user's savings streak based on their last deposit date.
  Future<void> updateStreak({required String userId}) async {
    try {
      final docRef = _firebaseFirestore
          .collection(DatabaseHelper.usersCollectionName)
          .doc(userId);
          
      final doc = await docRef.get();
      final data = doc.data() as Map<String, dynamic>? ?? {};

      int currentStreak = data[DatabaseHelper.currentStreakKey] ?? 0;
      int longestStreak = data[DatabaseHelper.longestStreakKey] ?? 0;
      String? lastDepositStr = data[DatabaseHelper.lastDepositDateKey];

      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);

      if (lastDepositStr == null) {
        // First deposit ever
        currentStreak = 1;
        longestStreak = 1;
      } else {
        DateTime lastDeposit = DateTime.parse(lastDepositStr);
        DateTime lastDate =
            DateTime(lastDeposit.year, lastDeposit.month, lastDeposit.day);
            
        int difference = today.difference(lastDate).inDays;

        if (difference == 1) {
          // Deposited yesterday, streak continues!
          currentStreak += 1;
          if (currentStreak > longestStreak) {
            longestStreak = currentStreak;
          }
        } else if (difference > 1) {
          // Missed a day or more, streak resets
          currentStreak = 1;
        } else if (difference == 0) {
          // Already deposited today, streak stays the same
        }
      }

      await docRef.set({
        DatabaseHelper.currentStreakKey: currentStreak,
        DatabaseHelper.longestStreakKey: longestStreak,
        DatabaseHelper.lastDepositDateKey: today.toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw e.toString();
    }
  }
}
