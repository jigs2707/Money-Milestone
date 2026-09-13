import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:money_milestone/utils/databaseHelper.dart';

class UserRepository {
  final _db = Supabase.instance.client;

  Future<void> addUserName({required String userId, required String name}) async {
    try {
      await _db.from(DatabaseHelper.usersCollectionName).upsert(
        {'id': userId, DatabaseHelper.userNameKey: name},
        onConflict: 'id',
      );
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> getUserName({required String userId}) async {
    try {
      final data = await _db
          .from(DatabaseHelper.usersCollectionName)
          .select(DatabaseHelper.userNameKey)
          .eq('id', userId)
          .maybeSingle();
      return data?[DatabaseHelper.userNameKey] ?? '';
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> getCurrencyCode({required String userId}) async {
    try {
      final data = await _db
          .from(DatabaseHelper.usersCollectionName)
          .select(DatabaseHelper.currencyKey)
          .eq('id', userId)
          .maybeSingle();
      return data?[DatabaseHelper.currencyKey] ?? 'USD';
    } catch (_) {
      return 'USD';
    }
  }

  Future<void> saveCurrencyCode({required String userId, required String code}) async {
    try {
      await _db.from(DatabaseHelper.usersCollectionName).upsert(
        {'id': userId, DatabaseHelper.currencyKey: code},
        onConflict: 'id',
      );
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> updateStreak({required String userId}) async {
    try {
      final row = await _db
          .from(DatabaseHelper.usersCollectionName)
          .select()
          .eq('id', userId)
          .maybeSingle();

      final data = row ?? <String, dynamic>{};

      int currentStreak = data[DatabaseHelper.currentStreakKey] ?? 0;
      int longestStreak = data[DatabaseHelper.longestStreakKey] ?? 0;
      String? lastDepositStr = data[DatabaseHelper.lastDepositDateKey];

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (lastDepositStr == null) {
        currentStreak = 1;
        longestStreak = 1;
      } else {
        final lastDeposit = DateTime.parse(lastDepositStr);
        final lastDate = DateTime(lastDeposit.year, lastDeposit.month, lastDeposit.day);
        final difference = today.difference(lastDate).inDays;

        if (difference == 1) {
          currentStreak += 1;
          if (currentStreak > longestStreak) longestStreak = currentStreak;
        } else if (difference > 1) {
          currentStreak = 1;
        }
      }

      await _db.from(DatabaseHelper.usersCollectionName).upsert({
        'id': userId,
        DatabaseHelper.currentStreakKey: currentStreak,
        DatabaseHelper.longestStreakKey: longestStreak,
        DatabaseHelper.lastDepositDateKey: today.toIso8601String(),
      }, onConflict: 'id');
    } catch (e) {
      throw e.toString();
    }
  }
}
