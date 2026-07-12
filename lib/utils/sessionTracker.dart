// ignore_for_file: avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:money_milestone/data/repository/hiveRepository.dart';
import 'package:money_milestone/utils/clarityService.dart';
import 'package:money_milestone/utils/databaseHelper.dart';

/// Tracks user app-open events in Firestore.
///
/// Two event types are recorded:
///   • "app_open"           – first HomeScreen initState after launch / re-login
///   • "background_resume"  – user brings the app back from the background
///
/// Firestore path: app_sessions/{auto-id}
/// Fields: user_id, opened_at, date (YYYY-MM-DD), type, platform
class SessionTracker with WidgetsBindingObserver {
  SessionTracker._();
  static final SessionTracker instance = SessionTracker._();

  bool _initialized = false;

  /// Call once in main() to register the lifecycle observer.
  void init() {
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addObserver(this);
  }

  /// Call from HomeScreen.initState() — fires on every authenticated app open.
  Future<void> logAppOpen() => _write(type: 'app_open');

  /// Fires automatically when the user brings the app back from background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _write(type: 'background_resume');
    }
  }

  Future<void> _write({required String type}) async {
    try {
      final userId = HiveRepository.getUserId;
      if (userId == null || userId.isEmpty) return;

      final now = DateTime.now();
      final date =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final platform = Platform.isAndroid ? 'android' : 'ios';

      await FirebaseFirestore.instance
          .collection(DatabaseHelper.appSessionsCollection)
          .add({
        DatabaseHelper.sessionUserId: userId,
        DatabaseHelper.sessionOpenedAt: FieldValue.serverTimestamp(),
        DatabaseHelper.sessionDate: date,
        DatabaseHelper.sessionType: type,
        DatabaseHelper.sessionPlatform: platform,
      });

      if (type == 'app_open') {
        ClarityService.logAppOpened();
      } else {
        ClarityService.logAppResumedFromBackground();
      }
      print('SessionTracker: logged $type for $userId on $date');
    } catch (e) {
      // Never block the UI for analytics failures
      print('SessionTracker: failed to log session – $e');
    }
  }
}
