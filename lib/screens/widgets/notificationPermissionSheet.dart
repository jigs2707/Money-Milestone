// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:money_milestone/data/repository/hiveRepository.dart';
import 'package:money_milestone/utils/app_colors_extension.dart';
import 'package:money_milestone/utils/notificationService.dart';

/// Shows the notification permission bottom sheet.
/// Call this whenever you need to prompt the user to enable notifications.
Future<void> showNotificationPermissionSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const NotificationPermissionSheet(),
  );
}

class NotificationPermissionSheet extends StatelessWidget {
  const NotificationPermissionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.isDarkMode
            ? const Color(0xff141829)
            : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: context.colors.accentColor.withValues(alpha: 0.18),
          width: 1.2,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: context.colors.lightGreyColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),

          // Bell icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colors.accentColor.withValues(alpha: 0.18),
                  context.colors.accentColor.withValues(alpha: 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: context.colors.accentColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              color: context.colors.accentColor,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),

          // Headline
          Text(
            'Stay on Track with Notifications',
            style: TextStyle(
              color: context.colors.blackColors,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // Body
          Text(
            'Get gentle reminders to save daily, celebrate milestones, and never miss a goal deadline — all on your terms.',
            style: TextStyle(
              color: context.colors.lightGreyColor,
              fontSize: 14,
              height: 1.55,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Benefits list
          _benefit(context, Icons.savings_rounded, context.colors.accentColor,
              'Daily savings reminders'),
          const SizedBox(height: 10),
          _benefit(context, Icons.flag_rounded, const Color(0xff9C27B0),
              'Goal milestone celebrations'),
          const SizedBox(height: 10),
          _benefit(context, Icons.timer_rounded, Colors.orange,
              'Deadline alerts so you never miss'),
          const SizedBox(height: 10),
          _benefit(context, Icons.local_fire_department_rounded,
              Colors.deepOrange, 'Streak reminders to keep momentum'),
          const SizedBox(height: 28),

          // Enable button
          GestureDetector(
            onTap: () async {
              Navigator.of(context).pop();
              await NotificationService.instance.requestPermission();
              await HiveRepository.markNotifPermissionPromptShown();
            },
            child: Container(
              height: 54,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colors.accentColor,
                    context.colors.gradiantBottomColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.accentColor.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_active_rounded,
                        color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Enable Notifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Not now
          GestureDetector(
            onTap: () async {
              Navigator.of(context).pop();
              await HiveRepository.markNotifPermissionPromptShown();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Not Now',
                style: TextStyle(
                  color: context.colors.lightGreyColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefit(
      BuildContext context, IconData icon, Color color, String label) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: context.colors.blackColors,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
