import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:money_milestone/data/model/goalModal.dart';
import 'package:money_milestone/data/repository/hiveRepository.dart';
import 'package:money_milestone/screens/ui/allBadgesScreen.dart';
import 'package:money_milestone/screens/widgets/badgeUnlockOverlay.dart';
import 'package:money_milestone/utils/app_colors_extension.dart';

class BadgesShelfWidget extends StatefulWidget {
  final List<GoalModel> goals;

  const BadgesShelfWidget({super.key, required this.goals});

  @override
  State<BadgesShelfWidget> createState() => _BadgesShelfWidgetState();
}

class _BadgesShelfWidgetState extends State<BadgesShelfWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _checkNewBadges());
  }

  @override
  void didUpdateWidget(BadgesShelfWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _checkNewBadges());
  }

  Future<void> _checkNewBadges() async {
    if (!mounted) return;
    final statuses = computeBadgeStatuses(widget.goals);

    final List<BadgeInfo> toShow = [];
    for (final s in statuses) {
      if (s.unlocked && !HiveRepository.isBadgeSeen(s.info.key)) {
        toShow.add(s.info);
        await HiveRepository.markBadgeSeen(s.info.key);
      }
    }

    if (toShow.isNotEmpty && mounted) {
      await showBadgeUnlockCelebration(context, toShow);
    }
  }

  Widget _buildShelfBadge(
      BuildContext context, BadgeStatus status) {
    final badge = status.info;
    final unlocked = status.unlocked;

    return Container(
      width: 82,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            height: 62,
            width: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: unlocked
                  ? LinearGradient(
                      colors: [
                        badge.color.withValues(alpha: 0.25),
                        badge.color.withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: unlocked ? null : context.colors.shimmerBaseColor,
              border: Border.all(
                color: unlocked
                    ? badge.color.withValues(alpha: 0.5)
                    : context.colors.lightGreyColor.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: unlocked
                  ? [
                      BoxShadow(
                        color: badge.color.withValues(alpha: 0.25),
                        blurRadius: 12,
                        spreadRadius: 1,
                      )
                    ]
                  : [],
            ),
            child: Icon(
              unlocked ? badge.icon : Icons.lock_outline_rounded,
              size: 26,
              color: unlocked
                  ? badge.color
                  : context.colors.lightGreyColor.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: unlocked
                  ? context.colors.blackColors
                  : context.colors.lightGreyColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            badge.reason,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              height: 1.4,
              color: context.colors.lightGreyColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statuses = computeBadgeStatuses(widget.goals);
    final unlockedCount = statuses.where((s) => s.unlocked).length;

    // Show first 4 in shelf; user taps "See All" for full list
    final shelfStatuses = statuses.take(4).toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: context.colors.cardGlassColor,
            border: Border.all(
                color: context.colors.cardBorderColor, width: 1.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: context.colors.goldColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color:
                                context.colors.goldColor.withValues(alpha: 0.3)),
                      ),
                      child: Icon(Icons.emoji_events_rounded,
                          color: context.colors.goldColor, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Trophy Case",
                      style: TextStyle(
                        color: context.colors.blackColors,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              AllBadgesScreen(goals: widget.goals),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.colors.accentColor
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                              color: context.colors.accentColor
                                  .withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$unlockedCount/${statuses.length}',
                              style: TextStyle(
                                color: context.colors.accentColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'See All',
                              style: TextStyle(
                                color: context.colors.accentColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(Icons.chevron_right_rounded,
                                size: 14,
                                color: context.colors.accentColor),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Shelf badges (first 4) ──────────────────────────────
              Stack(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Row(
                      children: [
                        ...shelfStatuses.map(
                            (s) => _buildShelfBadge(context, s)),
                        // Trailing spacer so last badge isn't flush
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),

                  // ── Left fade ────────────────────────────────────────
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: Container(
                        width: 24,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              context.colors.cardGlassColor,
                              context.colors.cardGlassColor
                                  .withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Right fade ───────────────────────────────────────
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: Container(
                        width: 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                              context.colors.cardGlassColor,
                              context.colors.cardGlassColor
                                  .withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
