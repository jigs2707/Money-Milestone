import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:money_milestone/data/model/goalModal.dart';
import 'package:money_milestone/utils/app_colors_extension.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Badge model
// ─────────────────────────────────────────────────────────────────────────────

class BadgeInfo {
  final String key;
  final String title;
  final String reason;        // short, shown in trophy case shelf
  final String fullReason;    // detailed, shown in celebration & all-badges screen
  final String celebration;
  final IconData icon;
  final Color color;

  const BadgeInfo({
    required this.key,
    required this.title,
    required this.reason,
    required this.fullReason,
    required this.celebration,
    required this.icon,
    required this.color,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Badge status (computed from live goals data)
// ─────────────────────────────────────────────────────────────────────────────

class BadgeStatus {
  final BadgeInfo info;
  final bool unlocked;
  final double progress;       // 0.0 → 1.0
  final String progressLabel;  // e.g. "₹340 / ₹1,000"

  const BadgeStatus({
    required this.info,
    required this.unlocked,
    required this.progress,
    required this.progressLabel,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// All badge definitions — 12 badges
// ─────────────────────────────────────────────────────────────────────────────

const List<BadgeInfo> allBadges = [
  BadgeInfo(
    key: 'first_step',
    title: 'First Step',
    reason: 'Started a goal',
    fullReason: 'Create your very first savings goal to unlock this badge.',
    celebration:
        'Every big journey starts with a single step. You\'ve taken yours! 🚀',
    icon: Icons.flag_rounded,
    color: Color(0xff6C47FF),
  ),

  BadgeInfo(
    key: 'halfway',
    title: 'Halfway There',
    reason: 'Reach 50% on a goal',
    fullReason: 'Get any one of your goals to at least 50% completion.',
    celebration:
        'You\'re halfway to the finish line — the best is yet to come! 🎯',
    icon: Icons.trending_up_rounded,
    color: Color(0xffF5A623),
  ),
  BadgeInfo(
    key: 'achiever',
    title: 'Achiever',
    reason: 'Complete a goal',
    fullReason: 'Fully fund any one savings goal to 100%.',
    celebration:
        'You set a goal and CRUSHED it. You\'re a true money milestone achiever! 🏆',
    icon: Icons.military_tech_rounded,
    color: Color(0xffF472B6),
  ),
  BadgeInfo(
    key: 'goal_collector',
    title: 'Goal Collector',
    reason: 'Create 3+ goals',
    fullReason: 'Have 3 or more goals active at the same time.',
    celebration:
        'More goals = more wins! You\'re building a savings empire! 💼',
    icon: Icons.collections_bookmark_rounded,
    color: Color(0xff38BDF8),
  ),

  BadgeInfo(
    key: 'diversified',
    title: 'Diversified',
    reason: 'Manage 5+ goals',
    fullReason: 'Maintain 5 or more savings goals simultaneously.',
    celebration:
        'A true strategic saver! You\'ve mastered the art of goal diversification! 🎯',
    icon: Icons.dashboard_rounded,
    color: Color(0xff22D3EE),
  ),
  BadgeInfo(
    key: 'hat_trick',
    title: 'Hat Trick',
    reason: 'Complete 3 goals',
    fullReason: 'Successfully complete 3 separate savings goals.',
    celebration:
        'Three goals down! You\'re on fire! Keep this incredible streak going! 🔥',
    icon: Icons.workspace_premium_rounded,
    color: Color(0xffFB7185),
  ),

  BadgeInfo(
    key: 'early_bird',
    title: 'Early Bird',
    reason: 'Finish before deadline',
    fullReason:
        'Complete a savings goal before its target date to earn this badge.',
    celebration:
        'Ahead of schedule! Time is on your side when you\'re this disciplined! ⚡',
    icon: Icons.alarm_on_rounded,
    color: Color(0xff4ADE80),
  ),
  BadgeInfo(
    key: 'on_a_roll',
    title: 'On a Roll',
    reason: '2 goals at 75%+',
    fullReason: 'Have 2 or more goals simultaneously above 75% progress.',
    celebration:
        'You\'re on a roll! Multiple finish lines are in sight! 🚀',
    icon: Icons.local_fire_department_rounded,
    color: Color(0xffF97316),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Compute statuses from live goals data
// ─────────────────────────────────────────────────────────────────────────────

List<BadgeStatus> computeBadgeStatuses(List<GoalModel> goals) {

  final int completedCount = goals.where((g) {
    final saved = double.tryParse(g.goalSavedAmount?.toString() ?? '0') ?? 0;
    final total = double.tryParse(g.goalAmount?.toString() ?? '1') ?? 1;
    return total > 0 && saved >= total;
  }).length;

  final double maxGoalPct = goals.isEmpty
      ? 0
      : goals.map((g) {
          final saved =
              double.tryParse(g.goalSavedAmount?.toString() ?? '0') ?? 0;
          final total =
              double.tryParse(g.goalAmount?.toString() ?? '1') ?? 1;
          return total > 0 ? saved / total : 0.0;
        }).reduce((a, b) => a > b ? a : b);


  final int count75pct = goals.where((g) {
    final saved = double.tryParse(g.goalSavedAmount?.toString() ?? '0') ?? 0;
    final total = double.tryParse(g.goalAmount?.toString() ?? '1') ?? 1;
    return total > 0 && saved / total >= 0.75;
  }).length;

  final bool hasEarlyBird = goals.any((g) {
    final saved = double.tryParse(g.goalSavedAmount?.toString() ?? '0') ?? 0;
    final total = double.tryParse(g.goalAmount?.toString() ?? '1') ?? 1;
    if (total <= 0 || saved < total) return false;
    final date = _parseGoalDate(g.goalDate);
    return date != null && !DateTime.now().isAfter(date);
  });

  return allBadges.map((badge) {
    switch (badge.key) {
      case 'first_step':
        final prog = goals.isNotEmpty ? 1.0 : 0.0;
        return BadgeStatus(
            info: badge,
            unlocked: goals.isNotEmpty,
            progress: prog,
            progressLabel: '${goals.length.clamp(0, 1)} / 1 goal created');



      case 'halfway':
        final best = (maxGoalPct * 100).clamp(0, 50);
        return BadgeStatus(
            info: badge,
            unlocked: maxGoalPct >= 0.5,
            progress: (maxGoalPct / 0.5).clamp(0, 1).toDouble(),
            progressLabel: '${best.toStringAsFixed(0)}% / 50%');

      case 'achiever':
        return BadgeStatus(
            info: badge,
            unlocked: completedCount >= 1,
            progress:
                completedCount >= 1 ? 1.0 : maxGoalPct.clamp(0, 1).toDouble(),
            progressLabel: completedCount >= 1
                ? 'Goal completed! 🎉'
                : '${(maxGoalPct * 100).clamp(0, 100).toStringAsFixed(0)}% / 100%');

      case 'goal_collector':
        return BadgeStatus(
            info: badge,
            unlocked: goals.length >= 3,
            progress: (goals.length / 3).clamp(0, 1).toDouble(),
            progressLabel: '${goals.length.clamp(0, 3)} / 3 goals');


      case 'diversified':
        return BadgeStatus(
            info: badge,
            unlocked: goals.length >= 5,
            progress: (goals.length / 5).clamp(0, 1).toDouble(),
            progressLabel: '${goals.length.clamp(0, 5)} / 5 goals');

      case 'hat_trick':
        return BadgeStatus(
            info: badge,
            unlocked: completedCount >= 3,
            progress: (completedCount / 3).clamp(0, 1).toDouble(),
            progressLabel: '$completedCount / 3 goals completed');


      case 'early_bird':
        return BadgeStatus(
            info: badge,
            unlocked: hasEarlyBird,
            progress: hasEarlyBird ? 1.0 : 0.0,
            progressLabel: hasEarlyBird
                ? 'Completed before deadline! ⚡'
                : 'Finish a goal before its target date');

      case 'on_a_roll':
        return BadgeStatus(
            info: badge,
            unlocked: count75pct >= 2,
            progress: (count75pct / 2).clamp(0, 1).toDouble(),
            progressLabel: '${count75pct.clamp(0, 2)} / 2 goals at 75%+');

      default:
        return BadgeStatus(
            info: badge, unlocked: false, progress: 0, progressLabel: '');
    }
  }).toList();
}

DateTime? _parseGoalDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return null;
  try {
    final parts = dateStr.split('/');
    if (parts.length != 3) return null;
    return DateTime(
        int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
  } catch (_) {
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Overlay entry point
// ─────────────────────────────────────────────────────────────────────────────

Future<void> showBadgeUnlockCelebration(
  BuildContext context,
  List<BadgeInfo> newlyUnlocked,
) async {
  for (final badge in newlyUnlocked) {
    if (!context.mounted) return;
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.72),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (ctx, anim, _) => _BadgeCelebrationSheet(badge: badge),
      transitionBuilder: (ctx, anim, _, child) => FadeTransition(
        opacity:
            CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween(begin: 0.85, end: 1.0).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          ),
          child: child,
        ),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 200));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Celebration dialog
// ─────────────────────────────────────────────────────────────────────────────

class _BadgeCelebrationSheet extends StatefulWidget {
  const _BadgeCelebrationSheet({required this.badge});
  final BadgeInfo badge;

  @override
  State<_BadgeCelebrationSheet> createState() =>
      _BadgeCelebrationSheetState();
}

class _BadgeCelebrationSheetState extends State<_BadgeCelebrationSheet>
    with SingleTickerProviderStateMixin {
  late final ConfettiController _confetti;
  late final AnimationController _iconCtrl;
  late final Animation<double> _iconScale;
  late final Animation<double> _iconGlow;

  @override
  void initState() {
    super.initState();
    _confetti =
        ConfettiController(duration: const Duration(seconds: 3))..play();
    _iconCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
    _iconScale =
        CurvedAnimation(parent: _iconCtrl, curve: Curves.elasticOut);
    _iconGlow = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _iconCtrl, curve: const Interval(0.4, 1.0)));
  }

  @override
  void dispose() {
    _confetti.dispose();
    _iconCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badge = widget.badge;
    final isDark = context.colors.isDarkMode;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Card
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xff141829).withValues(alpha: 0.95)
                          : Colors.white.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                          color: badge.color.withValues(alpha: 0.35), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                            color: badge.color.withValues(alpha: 0.22),
                            blurRadius: 40,
                            spreadRadius: 4)
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon
                        AnimatedBuilder(
                          animation: _iconCtrl,
                          builder: (_, __) => Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: badge.color
                                      .withValues(alpha: 0.45 * _iconGlow.value),
                                  blurRadius: 40,
                                  spreadRadius: 8,
                                )
                              ],
                            ),
                            child: ScaleTransition(
                              scale: _iconScale,
                              child: Container(
                                width: 104,
                                height: 104,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      badge.color.withValues(alpha: 0.28),
                                      badge.color.withValues(alpha: 0.08)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                      color: badge.color.withValues(alpha: 0.5),
                                      width: 2),
                                ),
                                child: Icon(badge.icon,
                                    size: 48, color: badge.color),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: badge.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                                color: badge.color.withValues(alpha: 0.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_open_rounded,
                                  size: 12, color: badge.color),
                              const SizedBox(width: 5),
                              Text('BADGE UNLOCKED',
                                  style: TextStyle(
                                      color: badge.color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(badge.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: context.colors.blackColors,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.6)),
                        const SizedBox(height: 10),

                        // Reason box
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xff1C2135)
                                : const Color(0xffF4F5FF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(badge.fullReason,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: context.colors.lightGreyColor,
                                  fontSize: 13.5,
                                  height: 1.5)),
                        ),
                        const SizedBox(height: 12),

                        // Celebration
                        Text(badge.celebration,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: badge.color,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.4)),
                        const SizedBox(height: 28),

                        // CTA
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  badge.color,
                                  badge.color.withValues(alpha: 0.75)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                    color: badge.color.withValues(alpha: 0.38),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6))
                              ],
                            ),
                            child: const Center(
                              child: Text('Awesome! 🎉',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Confetti — on top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 28,
                maxBlastForce: 20,
                minBlastForce: 8,
                gravity: 0.3,
                shouldLoop: false,
                colors: const [
                  Color(0xff6C47FF),
                  Color(0xffF5A623),
                  Color(0xff34D399),
                  Colors.pink,
                  Colors.white,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
