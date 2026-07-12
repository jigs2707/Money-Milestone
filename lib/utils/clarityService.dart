// ignore_for_file: avoid_print

import 'package:clarity_flutter/clarity_flutter.dart';

/// Centralised wrapper around the Microsoft Clarity Flutter SDK.
///
/// Clarity SDK methods return bool (success indicator) and are synchronous.
/// All methods here are void — the bool result is intentionally discarded
/// because Clarity queues events internally and retries on failure.
class ClarityService {
  ClarityService._();

  // ── User identity ─────────────────────────────────────────────────────────

  /// Ties all subsequent Clarity sessions to [userId] so you can filter
  /// session recordings by specific users in the Clarity dashboard.
  static void setUserId(String userId) {
    Clarity.setCustomUserId(userId);
  }

  // ── Screen names ──────────────────────────────────────────────────────────

  /// Labels the current screen in session recordings.
  /// Call from initState so it fires once per screen visit.
  static void setScreen(String name) {
    Clarity.setCurrentScreenName(name);
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  static void logLogin() => Clarity.sendCustomEvent('user_logged_in');

  static void logSignUp() => Clarity.sendCustomEvent('user_signed_up');

  static void logLogout() => Clarity.sendCustomEvent('user_logged_out');

  static void logPasswordReset() =>
      Clarity.sendCustomEvent('password_reset_requested');

  static void logPasswordChanged() =>
      Clarity.sendCustomEvent('password_changed');

  static void logEmailVerificationSent() =>
      Clarity.sendCustomEvent('email_verification_sent');

  // ── Goals ─────────────────────────────────────────────────────────────────

  static void logGoalCreated({
    required String goalName,
    required double amount,
  }) =>
      Clarity.sendCustomEvent('goal_created');

  static void logGoalViewed({required String goalName}) =>
      Clarity.sendCustomEvent('goal_viewed');

  static void logGoalUpdated({required String goalName}) =>
      Clarity.sendCustomEvent('goal_updated');

  static void logGoalDeleted({required String goalName}) =>
      Clarity.sendCustomEvent('goal_deleted');

  static void logGoalCompleted({required String goalName}) =>
      Clarity.sendCustomEvent('goal_completed');

  // ── Transactions ──────────────────────────────────────────────────────────

  static void logDeposit({required double amount}) =>
      Clarity.sendCustomEvent('deposit_made');

  static void logWithdrawal({required double amount}) =>
      Clarity.sendCustomEvent('withdrawal_made');

  // ── Gamification ──────────────────────────────────────────────────────────

  /// [badgeName] appended so each badge shows as its own event
  /// (e.g. "badge_unlocked_achiever") in the Clarity event filter.
  static void logBadgeUnlocked({required String badgeName}) =>
      Clarity.sendCustomEvent(
          'badge_unlocked_${badgeName.toLowerCase().replaceAll(' ', '_')}');

  static void logStreakContinued({required int days}) =>
      Clarity.sendCustomEvent('streak_continued');

  static void logStreakReset() => Clarity.sendCustomEvent('streak_reset');

  // ── Settings ──────────────────────────────────────────────────────────────

  /// Currency code appended so "currency_changed_usd" is searchable.
  static void logCurrencyChanged({required String code}) =>
      Clarity.sendCustomEvent('currency_changed_${code.toLowerCase()}');

  static void logThemeToggled({required bool isDark}) =>
      Clarity.sendCustomEvent(
          isDark ? 'theme_switched_to_dark' : 'theme_switched_to_light');

  // ── Ads ───────────────────────────────────────────────────────────────────

  static void logInterstitialAdShown() =>
      Clarity.sendCustomEvent('ad_interstitial_shown');

  static void logAppOpenAdShown() =>
      Clarity.sendCustomEvent('ad_app_open_shown');

  // ── App lifecycle ─────────────────────────────────────────────────────────

  static void logAppOpened() => Clarity.sendCustomEvent('app_opened');

  static void logAppResumedFromBackground() =>
      Clarity.sendCustomEvent('app_resumed_from_background');

  // ── Categories ────────────────────────────────────────────────────────────

  static void logCategoryAssigned({required String categoryName}) =>
      Clarity.sendCustomEvent(
          'category_assigned_${categoryName.toLowerCase().replaceAll(' ', '_')}');

  static void logCategoryCreated({required String categoryName}) =>
      Clarity.sendCustomEvent('category_created');

  static void logGoalFilterApplied({required String filter}) =>
      Clarity.sendCustomEvent('goal_filter_$filter');
}
