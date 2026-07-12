// ignore_for_file: avoid_print
import 'package:hive/hive.dart';

class NotificationPrefs {
  static const String boxName = 'notificationsBox';
  static Box get _box => Hive.box(boxName);

  // Daily savings reminder
  static bool get isDailyEnabled => _box.get('daily_enabled', defaultValue: true);
  static set isDailyEnabled(bool v) => _box.put('daily_enabled', v);
  static int get dailyHour => _box.get('daily_hour', defaultValue: 9);
  static set dailyHour(int v) => _box.put('daily_hour', v);
  static int get dailyMinute => _box.get('daily_minute', defaultValue: 0);
  static set dailyMinute(int v) => _box.put('daily_minute', v);

  // Weekly progress report
  static bool get isWeeklyEnabled => _box.get('weekly_enabled', defaultValue: true);
  static set isWeeklyEnabled(bool v) => _box.put('weekly_enabled', v);

  // Streak reminder
  static bool get isStreakEnabled => _box.get('streak_enabled', defaultValue: true);
  static set isStreakEnabled(bool v) => _box.put('streak_enabled', v);
  static int get streakHour => _box.get('streak_hour', defaultValue: 20);
  static set streakHour(int v) => _box.put('streak_hour', v);
  static int get streakMinute => _box.get('streak_minute', defaultValue: 0);
  static set streakMinute(int v) => _box.put('streak_minute', v);

  // Morning motivation
  static bool get isMotivationEnabled => _box.get('motivation_enabled', defaultValue: false);
  static set isMotivationEnabled(bool v) => _box.put('motivation_enabled', v);

  // Goal deadline alerts
  static bool get isDeadlineEnabled => _box.get('deadline_enabled', defaultValue: true);
  static set isDeadlineEnabled(bool v) => _box.put('deadline_enabled', v);

  // Milestone alerts
  static bool get isMilestoneEnabled => _box.get('milestone_enabled', defaultValue: true);
  static set isMilestoneEnabled(bool v) => _box.put('milestone_enabled', v);

  // Goal completion
  static bool get isCompletionEnabled => _box.get('completion_enabled', defaultValue: true);
  static set isCompletionEnabled(bool v) => _box.put('completion_enabled', v);
}
