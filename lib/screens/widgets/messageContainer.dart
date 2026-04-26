// ignore_for_file: non_constant_identifier_names

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:money_milestone/utils/app_colors_extension.dart';
import 'package:money_milestone/utils/constant.dart';

// ── Type → visuals map ────────────────────────────────────────────────────────

final Map<MessageType, Color> messageColors = {
  MessageType.success: const Color(0xff34D399),
  MessageType.error: const Color(0xffF87171),
  MessageType.warning: const Color(0xffFBBF24),
};

final Map<MessageType, IconData> messageIcon = {
  MessageType.success: Icons.check_circle_rounded,
  MessageType.error: Icons.cancel_rounded,
  MessageType.warning: Icons.warning_amber_rounded,
};

final Map<MessageType, String> messageLabel = {
  MessageType.success: "Success",
  MessageType.error: "Error",
  MessageType.warning: "Warning",
};

// ── Widget factory ────────────────────────────────────────────────────────────

Widget MessageContainer({
  required final BuildContext context,
  required final String text,
  required final MessageType type,
}) =>
    _PremiumToast(text: text, type: type);

// ── Premium toast widget ──────────────────────────────────────────────────────

class _PremiumToast extends StatefulWidget {
  const _PremiumToast({required this.text, required this.type});

  final String text;
  final MessageType type;

  @override
  State<_PremiumToast> createState() => _PremiumToastState();
}

class _PremiumToastState extends State<_PremiumToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..forward();

    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    // Reverse (slide back down) just before overlay removes it
    Future.delayed(
      Duration(
          milliseconds: Constant.messageDisplayDuration * 1000 - 420),
      () {
        if (mounted) _ctrl.reverse();
      },
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = messageColors[widget.type]!;
    final icon = messageIcon[widget.type]!;
    final label = messageLabel[widget.type]!;
    final isDark = context.colors.isDarkMode;

    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xff1A1F35).withValues(alpha: 0.88)
                      : Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Icon pill ────────────────────────────────────
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: accent.withValues(alpha: 0.3)),
                      ),
                      child: Icon(icon, color: accent, size: 20),
                    ),
                    const SizedBox(width: 12),

                    // ── Text ─────────────────────────────────────────
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.text,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.colors.blackColors
                                  .withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                              fontSize: 12.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Accent right strip ────────────────────────────
                    const SizedBox(width: 10),
                    Container(
                      width: 3,
                      height: 36,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
