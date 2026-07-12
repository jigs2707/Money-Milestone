// ignore_for_file: use_build_context_synchronously
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:money_milestone/screens/widgets/backgroundWidget.dart';
import 'package:money_milestone/utils/app_colors_extension.dart';
import 'package:money_milestone/screens/widgets/notificationPermissionSheet.dart';
import 'package:money_milestone/utils/clarityService.dart';
import 'package:money_milestone/utils/notificationPrefs.dart';
import 'package:money_milestone/utils/notificationService.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  static Route route(RouteSettings s) =>
      MaterialPageRoute(builder: (_) => const NotificationPreferencesScreen());

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  bool _permissionGranted = true;

  @override
  void initState() {
    super.initState();
    ClarityService.setScreen('Notification Preferences');
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final ok = await NotificationService.instance.areNotificationsEnabled();
    if (mounted) {
      setState(() => _permissionGranted = ok);
      if (!ok) {
        // Small delay so the screen is fully visible before the sheet appears
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) showNotificationPermissionSheet(context);
        });
      }
    }
  }

  Future<void> _reschedule() async {
    await NotificationService.instance.scheduleAll([]);
  }

  Future<void> _pickTime({
    required int hour,
    required int minute,
    required void Function(int h, int m) onPicked,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
    );
    if (picked != null) {
      onPicked(picked.hour, picked.minute);
      _reschedule();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.colors.isDarkMode
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: context.colors.blackColors),
          ),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: context.colors.blackColors,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: BackgroundWidget(
        child: Stack(
          children: [
            Positioned(
              top: -60,
              left: -40,
              child: _blob(
                context.colors.accentColor.withValues(
                    alpha: context.colors.isDarkMode ? 0.22 : 0.12),
                260,
              ),
            ),
            Positioned(
              bottom: -80,
              right: -50,
              child: _blob(
                context.colors.accentColor.withValues(
                    alpha: context.colors.isDarkMode ? 0.28 : 0.10),
                300,
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(color: Colors.transparent),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Permission banner ──────────────────────────────
                    if (!_permissionGranted) ...[
                      _glassCard(
                        context,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                  Icons.notifications_off_rounded,
                                  color: Colors.orange,
                                  size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Notifications disabled',
                                    style: TextStyle(
                                      color: context.colors.blackColors,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Enable in system settings to receive alerts',
                                    style: TextStyle(
                                      color: context.colors.lightGreyColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Reminders ─────────────────────────────────────
                    _sectionLabel(context, 'Reminders'),
                    const SizedBox(height: 10),
                    _glassCard(
                      context,
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _toggleRow(
                            context,
                            icon: Icons.savings_rounded,
                            iconColor: context.colors.accentColor,
                            label: 'Daily Savings Reminder',
                            subtitle: 'A nudge to make a deposit every day',
                            value: NotificationPrefs.isDailyEnabled,
                            onChanged: (v) {
                              setState(
                                  () => NotificationPrefs.isDailyEnabled = v);
                              _reschedule();
                            },
                          ),
                          if (NotificationPrefs.isDailyEnabled) ...[
                            _divider(context),
                            _timePickerRow(
                              context,
                              icon: Icons.access_time_rounded,
                              label: 'Reminder Time',
                              hour: NotificationPrefs.dailyHour,
                              minute: NotificationPrefs.dailyMinute,
                              onTap: () => _pickTime(
                                hour: NotificationPrefs.dailyHour,
                                minute: NotificationPrefs.dailyMinute,
                                onPicked: (h, m) => setState(() {
                                  NotificationPrefs.dailyHour = h;
                                  NotificationPrefs.dailyMinute = m;
                                }),
                              ),
                            ),
                          ],
                          _divider(context),
                          _toggleRow(
                            context,
                            icon: Icons.bar_chart_rounded,
                            iconColor: const Color(0xff4CAF50),
                            label: 'Weekly Progress Report',
                            subtitle: 'Every Sunday — a summary of your week',
                            value: NotificationPrefs.isWeeklyEnabled,
                            onChanged: (v) {
                              setState(
                                  () => NotificationPrefs.isWeeklyEnabled = v);
                              _reschedule();
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Goal Alerts ───────────────────────────────────
                    _sectionLabel(context, 'Goal Alerts'),
                    const SizedBox(height: 10),
                    _glassCard(
                      context,
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _toggleRow(
                            context,
                            icon: Icons.timer_rounded,
                            iconColor: Colors.orange,
                            label: 'Deadline Alerts',
                            subtitle:
                                "7, 3, and 1 day warnings before each goal's due date",
                            value: NotificationPrefs.isDeadlineEnabled,
                            onChanged: (v) {
                              setState(() =>
                                  NotificationPrefs.isDeadlineEnabled = v);
                              _reschedule();
                            },
                          ),
                          _divider(context),
                          _toggleRow(
                            context,
                            icon: Icons.flag_rounded,
                            iconColor: const Color(0xff9C27B0),
                            label: 'Milestone Alerts',
                            subtitle: 'Celebrate hitting 25%, 50%, 75% & 90%',
                            value: NotificationPrefs.isMilestoneEnabled,
                            onChanged: (v) {
                              setState(() =>
                                  NotificationPrefs.isMilestoneEnabled = v);
                            },
                          ),
                          _divider(context),
                          _toggleRow(
                            context,
                            icon: Icons.emoji_events_rounded,
                            iconColor: const Color(0xffF5A623),
                            label: 'Goal Completion',
                            subtitle:
                                'A celebration notification when a goal is fully funded',
                            value: NotificationPrefs.isCompletionEnabled,
                            onChanged: (v) {
                              setState(() =>
                                  NotificationPrefs.isCompletionEnabled = v);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Motivation & Engagement ───────────────────────
                    _sectionLabel(context, 'Motivation & Engagement'),
                    const SizedBox(height: 10),
                    _glassCard(
                      context,
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _toggleRow(
                            context,
                            icon: Icons.wb_sunny_rounded,
                            iconColor: const Color(0xffFF9800),
                            label: 'Morning Motivation',
                            subtitle: 'A daily boost at 8 AM to start saving',
                            value: NotificationPrefs.isMotivationEnabled,
                            onChanged: (v) {
                              setState(() =>
                                  NotificationPrefs.isMotivationEnabled = v);
                              _reschedule();
                            },
                          ),
                          _divider(context),
                          _toggleRow(
                            context,
                            icon: Icons.local_fire_department_rounded,
                            iconColor: Colors.deepOrange,
                            label: 'Streak Reminder',
                            subtitle: "Don't break your savings streak!",
                            value: NotificationPrefs.isStreakEnabled,
                            onChanged: (v) {
                              setState(
                                  () => NotificationPrefs.isStreakEnabled = v);
                              _reschedule();
                            },
                          ),
                          if (NotificationPrefs.isStreakEnabled) ...[
                            _divider(context),
                            _timePickerRow(
                              context,
                              icon: Icons.access_time_rounded,
                              label: 'Streak Reminder Time',
                              hour: NotificationPrefs.streakHour,
                              minute: NotificationPrefs.streakMinute,
                              onTap: () => _pickTime(
                                hour: NotificationPrefs.streakHour,
                                minute: NotificationPrefs.streakMinute,
                                onPicked: (h, m) => setState(() {
                                  NotificationPrefs.streakHour = h;
                                  NotificationPrefs.streakMinute = m;
                                }),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Center(
                      child: Text(
                        'All notifications are local — no data leaves your device',
                        style: TextStyle(
                          color: context.colors.lightGreyColor
                              .withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Row builders ──────────────────────────────────────────────────────────
  Widget _toggleRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: context.colors.blackColors,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.colors.lightGreyColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: context.colors.accentColor,
          ),
        ],
      ),
    );
  }

  Widget _timePickerRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int hour,
    required int minute,
    required VoidCallback onTap,
  }) {
    final timeStr = TimeOfDay(hour: hour, minute: minute).format(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.colors.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17, color: context.colors.accentColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: context.colors.blackColors,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              timeStr,
              style: TextStyle(
                color: context.colors.accentColor,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: context.colors.lightGreyColor),
          ],
        ),
      ),
    );
  }

  Widget _divider(BuildContext context) => Divider(
        height: 1,
        indent: 54,
        color: context.colors.lightGreyColor.withValues(alpha: 0.12),
      );

  // ── Style helpers ─────────────────────────────────────────────────────────
  Widget _glassCard(BuildContext context,
      {required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: context.colors.cardGlassColor,
            border: Border.all(
                color: context.colors.cardBorderColor, width: 1.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: context.colors.lightGreyColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      );

  Widget _blob(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
