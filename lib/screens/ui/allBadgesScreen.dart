import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:money_milestone/data/model/goalModal.dart';
import 'package:money_milestone/screens/widgets/badgeUnlockOverlay.dart';
import 'package:flutter/scheduler.dart';
import 'package:money_milestone/screens/widgets/bannerAdWidget.dart';
import 'package:money_milestone/utils/app_colors_extension.dart';
import 'package:money_milestone/utils/clarityService.dart';

class AllBadgesScreen extends StatelessWidget {
  final List<GoalModel> goals;

  const AllBadgesScreen({super.key, required this.goals});

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(
        (_) => ClarityService.setScreen('Badges'));

    final statuses = computeBadgeStatuses(goals);
    final unlockedCount = statuses.where((s) => s.unlocked).length;
    final total = statuses.length;
    final overallProgress = unlockedCount / total;
    final isDark = context.colors.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xff0B0F1A) : const Color(0xffF0F2FF),
      bottomNavigationBar: const BannerAdWidget(),
      // ── Fixed gradient AppBar ────────────────────────────────────────
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: context.colors.gradiantTopColor,
          elevation: 0,
        ),
      ),
      body: Column(
        children: [
          // ── Fixed header ─────────────────────────────────────────────
          _buildHeader(context, unlockedCount, total, overallProgress, isDark),
          // const SizedBox(height: 16),

          // ── Scrollable badge list ─────────────────────────────────────
          Expanded(
            child: ListView.builder(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: statuses.length,
              itemBuilder: (_, i) => _BadgeCard(status: statuses[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int unlocked, int total,
      double progress, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.gradiantTopColor,
            context.colors.gradiantBottomColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back row  (AppBar handles status bar space)
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          const Text(
            'Trophy Case',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Collect badges by reaching savings milestones',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 20),

          // Overall progress card
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.18)),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: '$unlocked',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            ),
                            TextSpan(
                              text: ' / $total',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ]),
                        ),
                        Text(
                          'badges unlocked',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 6,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.15),
                            color: const Color(0xffF5A623),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual badge card
// ─────────────────────────────────────────────────────────────────────────────

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.status});
  final BadgeStatus status;

  @override
  Widget build(BuildContext context) {
    final badge = status.info;
    final unlocked = status.unlocked;
    final isDark = context.colors.isDarkMode;
    final Color accentColor =
        unlocked ? badge.color : context.colors.lightGreyColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xff141829).withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: unlocked
              ? badge.color.withValues(alpha: 0.28)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.05)),
          width: 1.2,
        ),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: badge.color.withValues(alpha: 0.12),
                  blurRadius: 16,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: unlocked
                    ? LinearGradient(
                        colors: [
                          badge.color.withValues(alpha: 0.25),
                          badge.color.withValues(alpha: 0.07),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: unlocked ? null : context.colors.shimmerBaseColor,
                border: Border.all(
                  color: unlocked
                      ? badge.color.withValues(alpha: 0.45)
                      : context.colors.lightGreyColor.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: unlocked
                    ? [
                        BoxShadow(
                            color: badge.color.withValues(alpha: 0.22),
                            blurRadius: 12)
                      ]
                    : [],
              ),
              child: Icon(
                unlocked ? badge.icon : Icons.lock_outline_rounded,
                size: 24,
                color: unlocked
                    ? badge.color
                    : context.colors.lightGreyColor.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(width: 14),

            // Text + progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          badge.title,
                          style: TextStyle(
                            color: unlocked
                                ? context.colors.blackColors
                                : context.colors.lightGreyColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      if (unlocked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: badge.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                                color: badge.color.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  size: 10, color: badge.color),
                              const SizedBox(width: 4),
                              Text(
                                'UNLOCKED',
                                style: TextStyle(
                                  color: badge.color,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    badge.fullReason,
                    style: TextStyle(
                      color:
                          context.colors.lightGreyColor.withValues(alpha: 0.8),
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: status.progress,
                      minHeight: 6,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.07),
                      color: unlocked
                          ? accentColor
                          : accentColor.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    status.progressLabel,
                    style: TextStyle(
                      color: unlocked
                          ? accentColor
                          : context.colors.lightGreyColor
                              .withValues(alpha: 0.6),
                      fontSize: 11,
                      fontWeight: unlocked ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
