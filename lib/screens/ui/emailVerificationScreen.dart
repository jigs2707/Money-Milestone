// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_milestone/app/routes.dart';
import 'package:money_milestone/cubits/currencyCubit.dart';
import 'package:money_milestone/data/repository/authRepository.dart';
import 'package:money_milestone/data/repository/hiveRepository.dart';
import 'package:money_milestone/data/repository/userRepository.dart';
import 'package:money_milestone/screens/widgets/customCircularProgressIndicator.dart';
import 'package:money_milestone/screens/widgets/customRoundedButton.dart';
import 'package:money_milestone/utils/constant.dart';
import 'package:money_milestone/utils/contextExtensions.dart';
import 'package:money_milestone/utils/languageString.dart';
import 'package:money_milestone/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key, required this.user});

  /// The newly-created (but unverified) Firebase user.
  final User user;

  static Route route(final RouteSettings routeSettings) {
    final user = routeSettings.arguments as User;
    return MaterialPageRoute(
      builder: (_) => EmailVerificationScreen(user: user),
    );
  }

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  bool _isResending = false;
  bool _isChecking = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final AuthRepository _authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ── Resend verification email ────────────────────────────────────────────
  Future<void> _resendEmail() async {
    setState(() => _isResending = true);
    try {
      await _authRepository.sendEmailVerification();
      if (!mounted) return;
      Utils.showMessage(
        context,
        LanguageStrings.lblVerificationMailSent,
        MessageType.success,
      );
    } catch (e) {
      if (!mounted) return;
      Utils.showMessage(context, e.toString(), MessageType.error);
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  // ── Check if user has verified and proceed ───────────────────────────────
  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);
    try {
      final bool verified = await _authRepository.isEmailVerified();
      if (!mounted) return;

      if (verified) {
        // Fully logged-in — persist session and go to home.
        final String username = await UserRepository()
            .getUserName(userId: widget.user.uid);
        HiveRepository.setUserLoggedIn = true;
        HiveRepository.setUsername = username;
        HiveRepository.setUserId = widget.user.uid;
        await context.read<CurrencyCubit>().loadCurrency();
        context.pushNamedAndRemoveUntil(Routes.homeScreen);
      } else {
        Utils.showMessage(
          context,
          LanguageStrings.lblPleaseVerifyYourMail,
          MessageType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      Utils.showMessage(context, e.toString(), MessageType.error);
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  // ── Back to login ────────────────────────────────────────────────────────
  Future<void> _backToLogin() async {
    await _authRepository.signOut();
    if (!mounted) return;
    context.pushReplacementNamed(Routes.logInScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xff8B6FFF),
          error: Color(0xffF87171),
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // ── Gradient background ──────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff6C47FF),
                    Color(0xff5A35EE),
                    Color(0xff3A22BB),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // ── Decorative blurred blob top-right ───────────────────────
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),

            // ── Decorative blurred blob bottom-left ─────────────────────
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),

            // ── Content ─────────────────────────────────────────────────
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // ── Back button ──────────────────────────────────────
                    GestureDetector(
                      onTap: _backToLogin,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.20)),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── App pill ─────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.28)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.savings_rounded,
                              color: Colors.white, size: 15),
                          const SizedBox(width: 6),
                          Text(
                            Constant.appName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Headline ─────────────────────────────────────────
                    const Text(
                      "Check your\nInbox 📬",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.2,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── Sub-headline ─────────────────────────────────────
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.70),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          height: 1.55,
                        ),
                        children: [
                          const TextSpan(
                              text:
                                  'We sent a verification link to\n'),
                          TextSpan(
                            text: widget.user.email ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Animated envelope card ───────────────────────────
                    Center(
                      child: ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(36),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xff8B6FFF).withValues(alpha: 0.4),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.mark_email_unread_rounded,
                            color: Colors.white,
                            size: 56,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Glass action card ────────────────────────────────
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.28),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Steps
                              _step('1', 'Open your email app'),
                              const SizedBox(height: 14),
                              _step('2',
                                  'Find the email from Money Milestone — check your inbox or spam folder'),
                              const SizedBox(height: 14),
                              _step('3', 'Tap the verification link'),
                              const SizedBox(height: 14),
                              _step('4',
                                  'Come back and tap "I\'ve Verified" below'),

                              const SizedBox(height: 18),

                              // ── Spam tip banner ──────────────────────
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        Colors.amber.withValues(alpha: 0.30),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Text('📁',
                                        style: TextStyle(fontSize: 14)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "Can't find it? Check your spam or junk folder — sometimes it ends up there.",
                                        style: TextStyle(
                                          color: Colors.amber
                                              .withValues(alpha: 0.90),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // ── "I've Verified" button ───────────────
                              CustomRoundedButton(
                                onTap: _isChecking ? null : _checkVerification,
                                titleColor: const Color(0xff6C47FF),
                                backgroundColor: Colors.white,
                                height: 54,
                                buttonTitle: "I've Verified ✓",
                                showBorder: false,
                                widthPercentage: 1,
                                child: _isChecking
                                    ? const CustomCircularProgressIndicator(
                                        color: Color(0xff6C47FF),
                                      )
                                    : null,
                              ),

                              const SizedBox(height: 14),

                              // ── Resend button ────────────────────────
                              CustomRoundedButton(
                                onTap: _isResending ? null : _resendEmail,
                                titleColor: Colors.white,
                                backgroundColor: Colors.white
                                    .withValues(alpha: 0.10),
                                height: 54,
                                buttonTitle: _isResending
                                    ? 'Sending…'
                                    : 'Resend Email',
                                showBorder: true,
                                borderColor: Colors.white
                                    .withValues(alpha: 0.30),
                                widthPercentage: 1,
                                child: _isResending
                                    ? const CustomCircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Wrong email note ─────────────────────────────────
                    Center(
                      child: GestureDetector(
                        onTap: _backToLogin,
                        child: RichText(
                          text: TextSpan(
                            text: 'Wrong email address? ',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.68),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            children: const [
                              TextSpan(
                                text: 'Go back →',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step row helper ──────────────────────────────────────────────────────
  Widget _step(String number, String label) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
