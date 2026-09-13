import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:money_milestone/data/repository/hiveRepository.dart';

/// Keeps unlocked badge keys in sync between Hive (local) and Supabase (remote).
///
/// Call [syncFromSupabase] once per login session before checking new badges.
/// Call [markUnlocked] whenever a badge is newly earned — it updates Hive
/// immediately and saves to Supabase in the background.
class BadgeRepository {
  BadgeRepository._();
  static final BadgeRepository instance = BadgeRepository._();

  final _db = Supabase.instance.client;
  static const _table = 'user_badges';

  String? _syncedUserId;

  /// Syncs badge state between Supabase and Hive.
  ///
  /// • First run on an existing device: pushes all local Hive keys to Supabase
  ///   so they are available on future device switches.
  /// • Device switch / fresh install: pulls Supabase keys into Hive so already-
  ///   celebrated badges don't fire the pop-up again.
  Future<void> syncFromSupabase(String userId) async {
    if (userId.isEmpty || _syncedUserId == userId) return;

    try {
      final rows = await _db
          .from(_table)
          .select('badge_key')
          .eq('user_id', userId);

      final remoteKeys =
          rows.map<String>((r) => r['badge_key'] as String).toSet();

      if (remoteKeys.isEmpty) {
        // First sync on this account — upload whatever is already in Hive
        final localKeys = HiveRepository.allSeenBadgeKeys;
        if (localKeys.isNotEmpty) {
          final rows = localKeys
              .map((k) => {'user_id': userId, 'badge_key': k})
              .toList();
          await _db.from(_table).upsert(rows,
              onConflict: 'user_id,badge_key');
        }
      } else {
        // Populate Hive from Supabase (covers device switches / fresh installs)
        for (final key in remoteKeys) {
          await HiveRepository.markBadgeSeen(key);
        }
      }

      _syncedUserId = userId;
    } catch (_) {
      // Network failure — fall through; Hive state is still usable
    }
  }

  /// Marks [badgeKey] as unlocked for [userId].
  /// Hive is updated synchronously; Supabase is written in the background.
  Future<void> markUnlocked(String userId, String badgeKey) async {
    await HiveRepository.markBadgeSeen(badgeKey);

    if (userId.isEmpty) return;
    unawaited(
      _db.from(_table).upsert(
        {'user_id': userId, 'badge_key': badgeKey},
        onConflict: 'user_id,badge_key',
      ).catchError((_) {}),
    );
  }

  /// Resets the in-memory sync guard (call on logout so the next user syncs fresh).
  void resetSync() => _syncedUserId = null;
}
