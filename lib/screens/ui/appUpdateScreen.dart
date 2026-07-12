// ignore_for_file: file_names

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:money_milestone/app/routes.dart';
import 'package:money_milestone/data/repository/hiveRepository.dart';
import 'package:money_milestone/utils/app_colors_extension.dart';
import 'package:money_milestone/utils/constant.dart';
import 'package:money_milestone/utils/contextExtensions.dart';
import 'package:money_milestone/screens/widgets/customRoundedButton.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full-screen app-update gate shown when the Firestore version is higher
/// than the installed version.
///
/// [isForceUpdate] — if true, only "Update Now" is shown (no dismiss).
/// [latestVersion] — the new version string from Firestore.
/// [storeUrl]      — the URL to open (Play Store / App Store).
class AppUpdateScreen extends StatelessWidget {
  final bool isForceUpdate;
  final String latestVersion;
  final String storeUrl;

  const AppUpdateScreen({
    super.key,
    required this.isForceUpdate,
    required this.latestVersion,
    required this.storeUrl,
  });

  static Route route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map<String, dynamic>;
    return MaterialPageRoute(
      builder: (_) => AppUpdateScreen(
        isForceUpdate: args['isForceUpdate'] as bool,
        latestVersion: args['latestVersion'] as String,
        storeUrl: args['storeUrl'] as String,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return PopScope(
      canPop: !isForceUpdate,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: context.colors.isDarkMode
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
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // ── Mesh blobs ───────────────────────────────────────
              Positioned(
                top: -80,
                right: -60,
                child: _blob(
                  context.colors.isDarkMode
                      ? const Color(0xff6C47FF).withValues(alpha: 0.22)
                      : const Color(0xff6C47FF).withValues(alpha: 0.12),
                  280,
                ),
              ),
              Positioned(
                bottom: -100,
                left: -50,
                child: _blob(
                  context.colors.isDarkMode
                      ? const Color(0xff4B32CC).withValues(alpha: 0.28)
                      : const Color(0xff8B6FFF).withValues(alpha: 0.10),
                  320,
                ),
              ),
              // Full-screen blur
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Container(color: Colors.transparent),
                ),
              ),

              // ── Content ──────────────────────────────────────────
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // Rocket icon
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              context.colors.accentColor
                                  .withValues(alpha: 0.22),
                              context.colors.accentColor
                                  .withValues(alpha: 0.06),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: context.colors.accentColor
                                .withValues(alpha: 0.35),
                            width: 1.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: context.colors.accentColor
                                  .withValues(alpha: 0.18),
                              blurRadius: 32,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '🚀',
                            style: TextStyle(fontSize: 48),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Title
                      Text(
                        isForceUpdate
                            ? 'Update Required'
                            : 'New Update Available',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.colors.blackColors,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                          height: 1.15,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Subtitle
                      Text(
                        isForceUpdate
                            ? 'A critical update is available. Please update to continue using ${Constant.appName}.'
                            : 'A new version of ${Constant.appName} is available with exciting improvements and bug fixes.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.colors.lightGreyColor,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Version pill
                      _glassVersionPill(context),

                      const Spacer(flex: 3),

                      // ── Buttons ──────────────────────────────────
                      CustomRoundedButton(
                        onTap: () => _openStore(),
                        height: 54,
                        buttonTitle: 'Update Now',
                        showBorder: false,
                        widthPercentage: 1,
                        radius: 16,
                      ),

                      if (!isForceUpdate) ...[
                        const SizedBox(height: 12),
                        CustomRoundedButton(
                          onTap: () {
                            if (HiveRepository.isUserLoggedIn) {
                              context.pushReplacementNamed(Routes.homeScreen);
                            } else {
                              context.pushReplacementNamed(Routes.logInScreen);
                            }
                          },
                          height: 54,
                          buttonTitle: 'Not Now',
                          backgroundColor: Colors.transparent,
                          titleColor: context.colors.lightGreyColor,
                          showBorder: true,
                          borderColor: context.colors.lightGreyColor
                              .withValues(alpha: 0.3),
                          widthPercentage: 1,
                          radius: 16,
                        ),
                      ],

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _glassVersionPill(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: context.colors.cardGlassColor,
            border:
                Border.all(color: context.colors.cardBorderColor, width: 1.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _versionColumn(
                context,
                label: 'Current',
                version: Constant.appVersion,
                color: context.colors.lightGreyColor,
              ),
              Container(
                width: 1,
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color:
                    context.colors.lightGreyColor.withValues(alpha: 0.2),
              ),
              _versionColumn(
                context,
                label: 'Latest',
                version: latestVersion,
                color: context.colors.accentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _versionColumn(
    BuildContext context, {
    required String label,
    required String version,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.colors.lightGreyColor,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'v$version',
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _blob(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  Future<void> _openStore() async {
    final uri = Uri.parse(storeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
