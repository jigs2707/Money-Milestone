// ignore_for_file: avoid_print
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:money_milestone/data/repository/hiveRepository.dart';
import 'package:money_milestone/data/repository/userRepository.dart';
import 'package:money_milestone/utils/notificationService.dart';

/// Registers this device's FCM token against the signed-in user so the admin
/// panel can push announcements to them.
///
/// Supabase path: users.fcm_token (+ fcm_updated_at)
///
/// One token per user: a second device overwrites the first, which is what the
/// single-column schema allows. Multi-device delivery would need its own table.
class PushTokenService {
  PushTokenService._();
  static final PushTokenService instance = PushTokenService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final UserRepository _userRepository = UserRepository();
  bool _listenersAttached = false;

  /// Call on app open, once a user id is available. Best-effort: push
  /// registration must never block or break the app launch.
  Future<void> register() async {
    final userId = HiveRepository.getUserId;
    if (userId == null || userId.isEmpty) return;

    try {
      // iOS issues no token until the user grants permission. On Android the
      // POST_NOTIFICATIONS prompt is owned by NotificationService.
      await _messaging.requestPermission();

      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) await _save(userId, token);

      if (!_listenersAttached) {
        _listenersAttached = true;

        // Tokens rotate (reinstall, restore, cache clear) — keep the row fresh.
        _messaging.onTokenRefresh.listen((refreshed) {
          final uid = HiveRepository.getUserId;
          if (uid != null && uid.isNotEmpty) _save(uid, refreshed);
        });

        // FCM only draws notifications itself while the app is backgrounded.
        FirebaseMessaging.onMessage.listen((message) {
          final notification = message.notification;
          if (notification == null) return;
          NotificationService.instance.showNow(
            title: notification.title ?? '',
            body: notification.body ?? '',
          );
        });
      }
    } catch (_) {
      // Offline, no Play Services, or permission denied — try again next open.
    }
  }

  Future<void> _save(String userId, String token) async {
    try {
      await _userRepository.saveFcmToken(userId: userId, token: token);
    } catch (_) {
      // Best-effort; the next app open retries.
    }
  }
}
