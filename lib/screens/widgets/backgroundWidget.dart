import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:money_milestone/utils/app_colors_extension.dart';

class BackgroundWidget extends StatelessWidget {
  BackgroundWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = context.colors.isDarkMode;

    return Stack(
      children: [
        // ── Base fill ──────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xff0B0F1A),
                      const Color(0xff0D1228),
                      const Color(0xff111630),
                    ]
                  : [
                      const Color(0xffF0F2FF),
                      const Color(0xffEEF0FF),
                      const Color(0xffF5F3FF),
                    ],
            ),
          ),
        ),

        // ── Subtle mesh node 1 — top-left indigo ───────────────────
        Positioned(
          top: -60,
          left: -40,
          child: _meshBlob(
            isDark
                ? const Color(0xff6C47FF).withValues(alpha: 0.22)
                : const Color(0xff6C47FF).withValues(alpha: 0.12),
            260,
          ),
        ),

        // ── Mesh node 2 — upper-right gold ─────────────────────────
        Positioned(
          top: 80,
          right: -70,
          child: _meshBlob(
            isDark
                ? const Color(0xffF5A623).withValues(alpha: 0.10)
                : const Color(0xffF5A623).withValues(alpha: 0.07),
            200,
          ),
        ),

        // ── Mesh node 3 — bottom-right deep violet ─────────────────
        Positioned(
          bottom: -80,
          right: -50,
          child: _meshBlob(
            isDark
                ? const Color(0xff4B32CC).withValues(alpha: 0.28)
                : const Color(0xff8B6FFF).withValues(alpha: 0.10),
            300,
          ),
        ),

        // ── Mesh node 4 — bottom-left subtle ──────────────────────
        Positioned(
          bottom: 100,
          left: -60,
          child: _meshBlob(
            isDark
                ? const Color(0xff34D399).withValues(alpha: 0.08)
                : const Color(0xff6C47FF).withValues(alpha: 0.06),
            180,
          ),
        ),

        // ── Soft gaussian blur to blend nodes ─────────────────────
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(color: Colors.transparent),
          ),
        ),

        // ── Content ───────────────────────────────────────────────
        SizedBox.expand(child: child),
      ],
    );
  }

  Widget _meshBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
