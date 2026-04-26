// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_milestone/app/routes.dart';
import 'package:money_milestone/cubits/signUpCubit.dart';
import 'package:money_milestone/cubits/currencyCubit.dart';
import 'package:money_milestone/data/repository/authRepository.dart';
import 'package:money_milestone/data/repository/hiveRepository.dart';
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

  @override
  void dispose() {
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
                                      if (password != null &&
                                          password.isNotEmpty) return null;
                                      return LanguageStrings.lblEnterDetails;
                                    },
                                  ),
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
                                      if (state is SignUpSuccess) {
                                        HiveRepository.setUsername =
                                            _nameController.text
                                                .trim();
                                        HiveRepository.setUserLoggedIn =
                                            true;
                                        HiveRepository.setUserId =
                                            state.userData.uid;
                                        await context
                                            .read<CurrencyCubit>()
                                            .loadCurrency();
                                        context.pushNamedAndRemoveUntil(
                                            Routes.homeScreen);
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
