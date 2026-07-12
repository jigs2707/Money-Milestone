import 'package:firebase_analytics/firebase_analytics.dart';

/// Centralised wrapper around [FirebaseAnalytics].
///
/// All event names follow the snake_case convention required by Firebase.
/// Call these methods from cubits or widgets – never use [FirebaseAnalytics]
/// directly so that renaming / disabling analytics requires only one file change.
class AnalyticsService {
  AnalyticsService._();

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Returns the [FirebaseAnalyticsObserver] to wire into [MaterialApp].
  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ── Auth ─────────────────────────────────────────────────────────────────

  /// Fired when a user successfully logs in.
  static Future<void> logLogin() =>
      _analytics.logLogin(loginMethod: 'email');

  /// Fired when a new account is created.
  static Future<void> logSignUp() =>
      _analytics.logSignUp(signUpMethod: 'email');

  /// Fired when a password reset email is requested.
  static Future<void> logPasswordReset() =>
      _analytics.logEvent(name: 'password_reset_requested');

  /// Fired when the user changes their password from the profile screen.
  static Future<void> logPasswordChanged() =>
      _analytics.logEvent(name: 'password_changed');

  /// Fired when the user logs out.
  static Future<void> logLogout() =>
      _analytics.logEvent(name: 'logout');

  // ── Goals ─────────────────────────────────────────────────────────────────

  /// Fired when a new savings goal is created.
  static Future<void> logGoalCreated({
    required String goalName,
    required double goalAmount,
  }) =>
      _analytics.logEvent(
        name: 'goal_created',
        parameters: {
          'goal_name': goalName,
          'goal_amount': goalAmount,
        },
      );

  /// Fired when a goal is deleted.
  static Future<void> logGoalDeleted({required String goalName}) =>
      _analytics.logEvent(
        name: 'goal_deleted',
        parameters: {'goal_name': goalName},
      );

  /// Fired when a goal is edited / updated.
  static Future<void> logGoalUpdated({required String goalName}) =>
      _analytics.logEvent(
        name: 'goal_updated',
        parameters: {'goal_name': goalName},
      );

  /// Fired when a goal reaches 100 % completion.
  static Future<void> logGoalCompleted({
    required String goalName,
    required double goalAmount,
  }) =>
      _analytics.logEvent(
        name: 'goal_completed',
        parameters: {
          'goal_name': goalName,
          'goal_amount': goalAmount,
        },
      );

  // ── Transactions ──────────────────────────────────────────────────────────

  /// Fired when money is added to a goal.
  static Future<void> logDeposit({
    required double amount,
    required String goalId,
  }) =>
      _analytics.logEvent(
        name: 'deposit_made',
        parameters: {
          'amount': amount,
          'goal_id': goalId,
        },
      );

  /// Fired when money is withdrawn from a goal.
  static Future<void> logWithdrawal({
    required double amount,
    required String goalId,
  }) =>
      _analytics.logEvent(
        name: 'withdrawal_made',
        parameters: {
          'amount': amount,
          'goal_id': goalId,
        },
      );

  // ── Streak ────────────────────────────────────────────────────────────────

  /// Fired when a user's streak increments (deposit on a new day).
  static Future<void> logStreakContinued({required int streakDays}) =>
      _analytics.logEvent(
        name: 'streak_continued',
        parameters: {'streak_days': streakDays},
      );

  /// Fired when a user's streak resets due to a missed day.
  static Future<void> logStreakReset() =>
      _analytics.logEvent(name: 'streak_reset');

  // ── Settings ──────────────────────────────────────────────────────────────

  /// Fired when the user changes the app currency.
  static Future<void> logCurrencyChanged({required String currencyCode}) =>
      _analytics.logEvent(
        name: 'currency_changed',
        parameters: {'currency_code': currencyCode},
      );

  /// Fired when the user toggles dark / light mode.
  static Future<void> logThemeToggled({required bool isDark}) =>
      _analytics.logEvent(
        name: 'theme_toggled',
        parameters: {'is_dark_mode': isDark},
      );
}
