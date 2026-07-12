// ignore_for_file: avoid_print
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:money_milestone/data/model/goalModal.dart';
import 'package:money_milestone/utils/notificationPrefs.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // ── Fixed notification IDs ─────────────────────────────────────────────────
  static const int _idDaily = 1;
  static const int _idWeekly = 2;
  static const int _idStreak = 3;
  static const int _idMotivation = 4;

  // Per-goal offset constants
  static const int _offsetDeadline7 = 0;
  static const int _offsetDeadline3 = 1;
  static const int _offsetDeadline1 = 2;
  static const int _offsetDeadlineToday = 3;
  static const int _offsetMilestone25 = 10;
  static const int _offsetMilestone50 = 11;
  static const int _offsetMilestone75 = 12;
  static const int _offsetMilestone90 = 13;
  static const int _offsetCompletion = 20;

  static const _motivationMessages = [
    'Small steps every day lead to big savings! 💪',
    'Your future self will thank you for saving today 🌟',
    'Every deposit brings you closer to your dream 🎯',
    'Consistency beats intensity — save a little every day 📈',
    'You are building financial freedom, one goal at a time 🏆',
    'Great things take time. Keep going! ⏳',
    'Money saved today is freedom earned tomorrow 🔑',
    "You're doing amazing! Check your progress 💰",
  ];

  // ── Init ───────────────────────────────────────────────────────────────────
  Future<void> init() async {
    if (_initialized) return;
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
    _initialized = true;
  }

  // ── Permission ─────────────────────────────────────────────────────────────
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final bool? granted = await android?.requestNotificationsPermission();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
    return granted ?? true;
  }

  Future<bool> areNotificationsEnabled() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    return await android?.areNotificationsEnabled() ?? true;
  }

  // ── Master reschedule ──────────────────────────────────────────────────────
  Future<void> scheduleAll(List<GoalModel> goals) async {
    await _scheduleDailyReminder();
    await _scheduleWeeklyReport();
    await _scheduleStreakReminder();
    await _scheduleMorningMotivation();
    await _scheduleAllGoalDeadlines(goals);
  }

  // ── Daily savings reminder ─────────────────────────────────────────────────
  Future<void> _scheduleDailyReminder() async {
    await _plugin.cancel(_idDaily);
    if (!NotificationPrefs.isDailyEnabled) return;
    final time = _nextDailyTime(
        NotificationPrefs.dailyHour, NotificationPrefs.dailyMinute);
    await _plugin.zonedSchedule(
      _idDaily,
      '💰 Time to save!',
      'Every little bit adds up. Make a deposit towards your goals today.',
      time,
      _details(channelId: 'reminders', channelName: 'Reminders'),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ── Weekly progress report (Sundays) ──────────────────────────────────────
  Future<void> _scheduleWeeklyReport() async {
    await _plugin.cancel(_idWeekly);
    if (!NotificationPrefs.isWeeklyEnabled) return;
    final time = _nextWeeklyTime(DateTime.sunday, 9, 0);
    await _plugin.zonedSchedule(
      _idWeekly,
      '📊 Weekly savings check-in',
      'See how your goals are progressing this week!',
      time,
      _details(channelId: 'reminders', channelName: 'Reminders'),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  // ── Streak reminder ────────────────────────────────────────────────────────
  Future<void> _scheduleStreakReminder() async {
    await _plugin.cancel(_idStreak);
    if (!NotificationPrefs.isStreakEnabled) return;
    final time = _nextDailyTime(
        NotificationPrefs.streakHour, NotificationPrefs.streakMinute);
    await _plugin.zonedSchedule(
      _idStreak,
      '🔥 Keep your streak alive!',
      'Make a deposit today to maintain your savings streak.',
      time,
      _details(channelId: 'reminders', channelName: 'Reminders'),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ── Morning motivation ─────────────────────────────────────────────────────
  Future<void> _scheduleMorningMotivation() async {
    await _plugin.cancel(_idMotivation);
    if (!NotificationPrefs.isMotivationEnabled) return;
    final idx = DateTime.now().weekday % _motivationMessages.length;
    final time = _nextDailyTime(8, 0);
    await _plugin.zonedSchedule(
      _idMotivation,
      '🌅 Good morning, saver!',
      _motivationMessages[idx],
      time,
      _details(
          channelId: 'motivation',
          channelName: 'Motivation',
          importance: Importance.defaultImportance),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ── Goal deadline notifications ────────────────────────────────────────────
  Future<void> _scheduleAllGoalDeadlines(List<GoalModel> goals) async {
    if (!NotificationPrefs.isDeadlineEnabled) {
      for (final g in goals) {
        await cancelGoalNotifications(g.id ?? '');
      }
      return;
    }
    for (final goal in goals) {
      await scheduleGoalDeadlineNotifications(goal);
    }
  }

  Future<void> scheduleGoalDeadlineNotifications(GoalModel goal) async {
    final id = goal.id ?? '';
    if (id.isEmpty || goal.goalDate == null) return;

    final saved = double.tryParse(goal.goalSavedAmount ?? '0') ?? 0;
    final total = double.tryParse(goal.goalAmount ?? '0') ?? 1;
    if (saved >= total) {
      await cancelGoalDeadlineNotifications(id);
      return;
    }

    DateTime deadline;
    try {
      deadline = DateTime.parse('${goal.goalDate} 00:00:00');
    } catch (_) {
      return;
    }

    final now = DateTime.now();
    final name = goal.goalName ?? 'your goal';

    Future<void> maybeSchedule(
        int offset, String title, String body, DateTime when) async {
      final notifId = _goalNotifId(id, offset);
      await _plugin.cancel(notifId);
      if (when.isAfter(now)) {
        await _plugin.zonedSchedule(
          notifId,
          title,
          body,
          tz.TZDateTime.from(when, tz.local),
          _details(channelId: 'goal_alerts', channelName: 'Goal Alerts'),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }

    await maybeSchedule(_offsetDeadline7, '⏳ 7 days left!',
        '$name is due in 7 days. Keep saving!',
        deadline.subtract(const Duration(days: 7)));

    await maybeSchedule(_offsetDeadline3, '🚨 3 days left!',
        'Push harder for $name — only 3 days to go!',
        deadline.subtract(const Duration(days: 3)));

    await maybeSchedule(_offsetDeadline1, '⚡ Final day tomorrow!',
        "Tomorrow is the last day to hit $name. Give it all you've got!",
        deadline.subtract(const Duration(days: 1)));

    await maybeSchedule(_offsetDeadlineToday, '🎯 Today is the day!',
        '$name deadline is TODAY. Make your final deposit now!', deadline);
  }

  // ── Cancel helpers ─────────────────────────────────────────────────────────
  Future<void> cancelGoalDeadlineNotifications(String goalId) async {
    await _plugin.cancel(_goalNotifId(goalId, _offsetDeadline7));
    await _plugin.cancel(_goalNotifId(goalId, _offsetDeadline3));
    await _plugin.cancel(_goalNotifId(goalId, _offsetDeadline1));
    await _plugin.cancel(_goalNotifId(goalId, _offsetDeadlineToday));
  }

  Future<void> cancelGoalNotifications(String goalId) async {
    await cancelGoalDeadlineNotifications(goalId);
    await _plugin.cancel(_goalNotifId(goalId, _offsetMilestone25));
    await _plugin.cancel(_goalNotifId(goalId, _offsetMilestone50));
    await _plugin.cancel(_goalNotifId(goalId, _offsetMilestone75));
    await _plugin.cancel(_goalNotifId(goalId, _offsetMilestone90));
    await _plugin.cancel(_goalNotifId(goalId, _offsetCompletion));
  }

  Future<void> cancelAll() async => await _plugin.cancelAll();

  // ── Instant notifications ──────────────────────────────────────────────────
  Future<void> showMilestoneNotification(
      GoalModel goal, int milestonePercent) async {
    if (!NotificationPrefs.isMilestoneEnabled) return;
    final id = goal.id ?? '';
    final name = goal.goalName ?? 'your goal';
    late int offset;
    late String title, body;

    switch (milestonePercent) {
      case 25:
        offset = _offsetMilestone25;
        title = '🎯 25% milestone reached!';
        body = "You're a quarter of the way to $name. Keep it up!";
      case 50:
        offset = _offsetMilestone50;
        title = '🏃 Halfway there!';
        body = "You're 50% done with $name. Amazing progress!";
      case 75:
        offset = _offsetMilestone75;
        title = '🔥 75% done!';
        body = 'Almost there on $name. Just 25% left to go!';
      case 90:
        offset = _offsetMilestone90;
        title = '⭐ So close!';
        body = '90% done on $name. One final push!';
      default:
        return;
    }

    await _plugin.show(
      _goalNotifId(id, offset),
      title,
      body,
      _details(channelId: 'goal_alerts', channelName: 'Goal Alerts'),
    );
  }

  Future<void> showCompletionNotification(GoalModel goal) async {
    if (!NotificationPrefs.isCompletionEnabled) return;
    final name = goal.goalName ?? 'your goal';
    await _plugin.show(
      _goalNotifId(goal.id ?? '', _offsetCompletion),
      '🎉 Goal complete!',
      '$name is fully funded! Time to celebrate — and set the next one!',
      _details(channelId: 'goal_alerts', channelName: 'Goal Alerts'),
    );
    await cancelGoalDeadlineNotifications(goal.id ?? '');
  }

  // ── Private helpers ────────────────────────────────────────────────────────
  int _goalNotifId(String goalId, int offset) {
    return (goalId.hashCode.abs() % 9000000) + 1000 + offset;
  }

  tz.TZDateTime _nextDailyTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var t =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (t.isBefore(now)) t = t.add(const Duration(days: 1));
    return t;
  }

  tz.TZDateTime _nextWeeklyTime(int weekday, int hour, int minute) {
    var t = _nextDailyTime(hour, minute);
    while (t.weekday != weekday) {
      t = t.add(const Duration(days: 1));
    }
    return t;
  }

  NotificationDetails _details({
    required String channelId,
    required String channelName,
    Importance importance = Importance.high,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'Money Milestone — goal savings notifications',
        importance: importance,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }
}
