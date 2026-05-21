// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_milestone/app/routes.dart';
import 'package:money_milestone/cubits/signUpCubit.dart';
import 'package:money_milestone/data/repository/authRepository.dart';
import 'package:money_milestone/screens/widgets/customCircularProgressIndicator.dart';
import 'package:money_milestone/screens/widgets/customRoundedButton.dart';
import 'package:money_milestone/screens/widgets/customTextFormfield.dart';
import 'package:money_milestone/utils/constant.dart';
import 'package:money_milestone/utils/contextExtensions.dart';
import 'package:money_milestone/utils/languageString.dart';
import 'package:flutter/material.dart';
import 'package:money_milestone/utils/stringExtensions.dart';
import 'package:money_milestone/utils/utils.dart';

// ignore: must_be_immutable
class SignUpScreen extends StatefulWidget {
  SignUpScreen({super.key});

  static Route route(final RouteSettings routeSettings) => MaterialPageRoute(
        builder: (final _) => BlocProvider<SignUpCubit>(
            create: (final _) => SignUpCubit(AuthRepository()),
            child: SignUpScreen()),
      );

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  // 0 = empty, 1 = weak, 2 = fair, 3 = good, 4 = strong
  int _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    setState(() {
      _passwordStrength = _calcStrength(_passwordController.text);
    });
  }

  /// Returns a score 0–4 based on which criteria are met.
  int _calcStrength(String pw) {
    if (pw.isEmpty) return 0;
    int score = 0;
    if (pw.length >= 8) score++;
    if (pw.contains(RegExp(r'[A-Z]'))) score++;
    if (pw.contains(RegExp(r'[0-9]'))) score++;
    if (pw.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>\-_=+\[\]\\/]'))) score++;
    return score;
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      // Force dark theme so TextFormField labels render white on the dark gradient
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
            // ── Deep gradient — slightly shifted hue vs login ──────
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

            // ── Scrollable content ─────────────────────────────────
            SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Hero section ────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // App pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 13, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white
                                        .withValues(alpha: 0.28)),
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
                            const SizedBox(height: 18),

                            // Headline
                            const Text(
                              "Create\nAccount ✨",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.2,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Sub-headline
                            Text(
                              "Set goals, save every day,\nachieve what matters most.",
                              style: TextStyle(
                                color:
                                    Colors.white.withValues(alpha: 0.70),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                height: 1.55,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Feature pills
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _statPill("🔥", "Build Streaks"),
                                _statPill("🏅", "Earn Badges"),
                                _statPill("📊", "Track Progress"),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Glass form card ──────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color:
                                    Colors.white.withValues(alpha: 0.13),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color:
                                      Colors.white.withValues(alpha: 0.28),
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Get started for free",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Name
                                  CustomTextFormField(
                                    backgroundColor: Colors.white
                                        .withValues(alpha: 0.10),
                                    hintTextColor: Colors.white
                                        .withValues(alpha: 0.45),
                                    labelStyle: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.75),
                                        fontSize: 13),
                                    controller: _nameController,
                                    hintText:
                                        LanguageStrings.lblEnterYourName,
                                    nextFocus: _emailFocusNode,
                                    labelText: LanguageStrings.lblName,
                                    textInputAction: TextInputAction.next,
                                    textInputType: TextInputType.text,
                                    validator: (name) {
                                      if (name != null &&
                                          name.isNotEmpty) return null;
                                      return LanguageStrings.lblEnterDetails;
                                    },
                                  ),
                                  const SizedBox(height: 12),

                                  // Email
                                  CustomTextFormField(
                                    backgroundColor: Colors.white
                                        .withValues(alpha: 0.10),
                                    hintTextColor: Colors.white
                                        .withValues(alpha: 0.45),
                                    labelStyle: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.75),
                                        fontSize: 13),
                                    controller: _emailController,
                                    hintText:
                                        LanguageStrings.lblEnterYourEmail,
                                    nextFocus: _passwordFocusNode,
                                    labelText: LanguageStrings.lblEmail,
                                    textInputAction: TextInputAction.next,
                                    textInputType:
                                        TextInputType.emailAddress,
                                    validator: (email) {
                                      if (email != null &&
                                          email.isNotEmpty) return null;
                                      return LanguageStrings.lblEnterDetails;
                                    },
                                  ),
                                  const SizedBox(height: 12),

                                  // Password
                                  CustomTextFormField(
                                    backgroundColor: Colors.white
                                        .withValues(alpha: 0.10),
                                    hintTextColor: Colors.white
                                        .withValues(alpha: 0.45),
                                    labelStyle: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.75),
                                        fontSize: 13),
                                    controller: _passwordController,
                                    hintText: LanguageStrings
                                        .lblEnterYourPassword,
                                    isPswd: true,
                                    nextFocus: _confirmPasswordFocusNode,
                                    labelText: LanguageStrings.lblPassword,
                                    textInputAction: TextInputAction.next,
                                    textInputType: TextInputType.text,
                                    validator: (password) {
                                      if (password == null ||
                                          password.isEmpty) {
                                        return LanguageStrings
                                            .lblEnterDetails;
                                      }
                                      if (password.length < 8) {
                                        return 'Password must be at least 8 characters';
                                      }
                                      if (!password.contains(
                                          RegExp(r'[A-Z]'))) {
                                        return 'Add at least one uppercase letter';
                                      }
                                      if (!password.contains(
                                          RegExp(r'[0-9]'))) {
                                        return 'Add at least one number';
                                      }
                                      if (!password.contains(RegExp(
                                          r'[!@#\$%^&*(),.?":{}|<>\-_=+\[\]\\/]'))) {
                                        return 'Add at least one special character';
                                      }
                                      return null;
                                    },
                                  ),

                                  // Strength meter
                                  if (_passwordStrength > 0) ..._buildStrengthMeter(),

                                  const SizedBox(height: 12),

                                  // Confirm Password
                                  CustomTextFormField(
                                    backgroundColor: Colors.white
                                        .withValues(alpha: 0.10),
                                    hintTextColor: Colors.white
                                        .withValues(alpha: 0.45),
                                    labelStyle: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.75),
                                        fontSize: 13),
                                    controller: _confirmPasswordController,
                                    hintText: LanguageStrings
                                        .lblEnterYourConfirmPassword,
                                    isPswd: true,
                                    labelText:
                                        LanguageStrings.lblConfirmPassword,
                                    textInputAction: TextInputAction.done,
                                    textInputType: TextInputType.text,
                                    validator: (confirmPassword) {
                                      if (confirmPassword != null &&
                                          confirmPassword
                                              .isNotEmpty) return null;
                                      return LanguageStrings.lblEnterDetails;
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Sign up button
                                  BlocConsumer<SignUpCubit, SignUpState>(
                                    listener: (context, state) async {
                                      if (state is SignUpEmailVerificationSent) {
                                        // Account created — navigate to
                                        // verification screen. Do NOT persist
                                        // the session yet; the user must
                                        // verify their email first.
                                        context.pushNamed(
                                          Routes.emailVerificationScreen,
                                          arguments: state.userData,
                                        );
                                      } else if (state is SignUpFailure) {
                                        Utils.showMessage(
                                            context,
                                            state.errorMessage
                                                .getFirebaseError(),
                                            MessageType.error);
                                      }
                                    },
                                    builder: (context, state) {
                                      Widget? child;
                                      if (state is SignUpProgress) {
                                        child =
                                            const CustomCircularProgressIndicator(
                                          color: Color(0xff6C47FF),
                                        );
                                      }
                                      return CustomRoundedButton(
                                        onTap: () {
                                          Utils.removeFocus();
                                          if (!_formKey.currentState!
                                              .validate()) return;
                                          if (_confirmPasswordController
                                                  .text
                                                  .trim() !=
                                              _passwordController.text
                                                  .trim()) {
                                            Utils.showMessage(
                                                context,
                                                LanguageStrings
                                                    .lblPasswordDoesNotMatch,
                                                MessageType.error);
                                            return;
                                          }
                                          context
                                              .read<SignUpCubit>()
                                              .signUp(
                                                email: _emailController
                                                    .text
                                                    .trim(),
                                                password:
                                                    _passwordController
                                                        .text
                                                        .trim(),
                                                name: _nameController.text
                                                    .trim(),
                                              );
                                        },
                                        titleColor: const Color(0xff6C47FF),
                                        backgroundColor: Colors.white,
                                        height: 54,
                                        buttonTitle:
                                            LanguageStrings.lblSignUp,
                                        showBorder: false,
                                        widthPercentage: 1,
                                        child: child,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ── Log in link ───────────────────────────────
                      const SizedBox(height: 28),
                      Center(
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: RichText(
                            text: TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(
                                color:
                                    Colors.white.withValues(alpha: 0.68),
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                              ),
                              children: const [
                                TextSpan(
                                  text: "Log In →",
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
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Password strength meter ──────────────────────────────────────────────
  List<Widget> _buildStrengthMeter() {
    const labels = ['Weak', 'Fair', 'Good', 'Strong'];
    const colors = [
      Color(0xffF87171), // red
      Color(0xffFBBF24), // amber
      Color(0xff34D399), // teal
      Color(0xff4ADE80), // green
    ];
    final s = _passwordStrength.clamp(1, 4);
    final barColor = colors[s - 1];
    final label = labels[s - 1];

    final pw = _passwordController.text;
    final has8 = pw.length >= 8;
    final hasUpper = pw.contains(RegExp(r'[A-Z]'));
    final hasNum = pw.contains(RegExp(r'[0-9]'));
    final hasSpecial = pw.contains(
        RegExp(r'[!@#\$%^&*(),.?":{}|<>\-_=+\[\]\\/]'));

    return [
      const SizedBox(height: 10),
      // ── Segmented bar ──
      Row(
        children: List.generate(4, (i) {
          final filled = i < s;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
              decoration: BoxDecoration(
                color: filled
                    ? barColor
                    : Colors.white.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          );
        }),
      ),
      const SizedBox(height: 6),
      // ── Label ──
      Align(
        alignment: Alignment.centerRight,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            label,
            key: ValueKey(label),
            style: TextStyle(
              color: barColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      // ── Requirement chips ──
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          _reqChip('8+ chars', has8),
          _reqChip('A–Z', hasUpper),
          _reqChip('0–9', hasNum),
          _reqChip('!@#…', hasSpecial),
        ],
      ),
    ];
  }

  Widget _reqChip(String label, bool met) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: met
            ? const Color(0xff4ADE80).withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: met
              ? const Color(0xff4ADE80).withValues(alpha: 0.50)
              : Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 11,
            color: met
                ? const Color(0xff4ADE80)
                : Colors.white.withValues(alpha: 0.45),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: met
                  ? const Color(0xff4ADE80)
                  : Colors.white.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
        ),
      );

  Widget _statPill(String emoji, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
}
