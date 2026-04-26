// ignore_for_file: file_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:money_milestone/app/routes.dart';
import 'package:money_milestone/data/repository/hiveRepository.dart';
import 'package:money_milestone/utils/app_colors_extension.dart';
import 'package:money_milestone/utils/constant.dart';
import 'package:money_milestone/utils/contextExtensions.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({final Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();

  static Route route(final RouteSettings routeSettings) => MaterialPageRoute(
        builder: (final _) => SplashScreen(),
      );
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _iconScale;
  late final Animation<double> _iconOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _taglineOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Icon: scale from 0.4 → 1.0 with elastic bounce
    _iconScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
    );

    // Icon: fade in fast
    _iconOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    );

    // App name: slide up + fade after icon settles
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.72, curve: Curves.easeOut),
    ));

    _textOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.65, curve: Curves.easeIn),
    );

    // Tagline: fade in last
    _taglineOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 0.95, curve: Curves.easeIn),
    );

    _controller.forward();

    // Navigate after splash duration
    Future.delayed(
      Duration(seconds: Constant.splashScreenDuration),
      () {
        if (!mounted) return;
        if (HiveRepository.isUserLoggedIn) {
          context.pushReplacementNamed(Routes.homeScreen);
        } else {
          context.pushReplacementNamed(Routes.logInScreen);
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.colors.gradiantTopColor,
              context.colors.gradiantBottomColor,
              const Color(0xff3A22BB),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Animated icon ──────────────────────────────────────
            ScaleTransition(
              scale: _iconScale,
              child: FadeTransition(
                opacity: _iconOpacity,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: const Icon(
                    Icons.savings_rounded,
                    color: Colors.white,
                    size: 52,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── App name ──────────────────────────────────────────
            SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textOpacity,
                child: Text(
                  Constant.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 36,
                    letterSpacing: -1.0,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── Tagline ───────────────────────────────────────────
            FadeTransition(
              opacity: _taglineOpacity,
              child: Text(
                "Set. Track. Achieve.",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
