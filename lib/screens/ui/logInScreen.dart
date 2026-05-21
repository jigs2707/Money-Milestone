// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_milestone/app/routes.dart';
import 'package:money_milestone/cubits/logInCubit.dart';
import 'package:money_milestone/cubits/currencyCubit.dart';
import 'package:money_milestone/data/repository/authRepository.dart';
import 'package:money_milestone/data/repository/hiveRepository.dart';
import 'package:money_milestone/data/repository/userRepository.dart';
import 'package:money_milestone/screens/widgets/customCircularProgressIndicator.dart';
import 'package:money_milestone/screens/widgets/customRoundedButton.dart';
import 'package:money_milestone/screens/widgets/customTextFormfield.dart';
import 'package:money_milestone/utils/app_colors_extension.dart';
import 'package:money_milestone/utils/constant.dart';
import 'package:money_milestone/utils/contextExtensions.dart';
import 'package:money_milestone/utils/languageString.dart';
import 'package:flutter/material.dart';
import 'package:money_milestone/utils/stringExtensions.dart';
import 'package:money_milestone/utils/utils.dart';

// ignore: must_be_immutable
class LogInScreen extends StatefulWidget {
  LogInScreen({super.key});

  static Route route(final RouteSettings routeSettings) => MaterialPageRoute(
        builder: (final _) => BlocProvider<LogInCubit>(
            create: (final _) => LogInCubit(AuthRepository()),
            child: LogInScreen()),
      );

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordFocusNode.dispose();
    _passwordController.dispose();
    super.dispose();
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
            // ── Gradient background ──────────────────────────────
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

            // ── Scrollable content ────────────────────────────────
            SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Hero section ──────────────────────────
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
                              "Welcome\nBack 👋",
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
                              "Your savings journey continues.\nLog in to track your goals.",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.70),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                height: 1.55,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Stats pills
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _statPill("🎯", "Set Goals"),
                                _statPill("💰", "Save Daily"),
                                _statPill("🏆", "Achieve More"),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Glass form card ───────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ClipRRect(
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
                                  const Text(
                                    "Sign in to your account",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Email
                                  CustomTextFormField(
                                    backgroundColor:
                                        Colors.white.withValues(alpha: 0.10),
                                    hintTextColor:
                                        Colors.white.withValues(alpha: 0.45),
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
                                    textInputType: TextInputType.emailAddress,
                                    validator: (email) {
                                      if (email != null && email.isNotEmpty) {
                                        return null;
                                      }
                                      return LanguageStrings.lblEnterDetails;
                                    },
                                  ),
                                  const SizedBox(height: 14),

                                  // Password
                                  CustomTextFormField(
                                    backgroundColor:
                                        Colors.white.withValues(alpha: 0.10),
                                    hintTextColor:
                                        Colors.white.withValues(alpha: 0.45),
                                    labelStyle: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.75),
                                        fontSize: 13),
                                    controller: _passwordController,
                                    hintText:
                                        LanguageStrings.lblEnterYourPassword,
                                    isPswd: true,
                                    labelText: LanguageStrings.lblPassword,
                                    textInputAction: TextInputAction.done,
                                    textInputType: TextInputType.text,
                                    validator: (password) {
                                      if (password != null &&
                                          password.isNotEmpty) {
                                        return null;
                                      }
                                      return LanguageStrings.lblEnterDetails;
                                    },
                                  ),
                                  const SizedBox(height: 10),

                                  // ── Forgot password link ─────────────
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: _showForgotPasswordSheet,
                                      child: Text(
                                        LanguageStrings.lblForgotPassword,
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.80),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          decoration:
                                              TextDecoration.underline,
                                          decorationColor: Colors.white
                                              .withValues(alpha: 0.50),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // Login button
                                  BlocConsumer<LogInCubit, LogInState>(
                                    listener: (context, state) async {
                                      if (state is LogInSuccess) {
                                        String username =
                                            await UserRepository().getUserName(
                                                userId: state.userData.uid);
                                        HiveRepository.setUserLoggedIn = true;
                                        HiveRepository.setUsername = username;
                                        HiveRepository.setUserId =
                                            state.userData.uid;
                                        await context
                                            .read<CurrencyCubit>()
                                            .loadCurrency();
                                        context.pushReplacementNamed(
                                            Routes.homeScreen);
                                      } else if (state is LogInFailure) {
                                        Utils.showMessage(
                                            context,
                                            state.errorMessage
                                                .getFirebaseError(),
                                            MessageType.error);
                                      }
                                    },
                                    builder: (context, state) {
                                      Widget? child;
                                      if (state is LogInProgress) {
                                        child =
                                            const CustomCircularProgressIndicator(
                                          color: Color(0xff6C47FF),
                                        );
                                      }
                                      return CustomRoundedButton(
                                        onTap: () {
                                          if (!_formKey.currentState!
                                              .validate()) return;
                                          Utils.removeFocus();
                                          context.read<LogInCubit>().doLogIn(
                                                email: _emailController.text
                                                    .trim(),
                                                password: _passwordController
                                                    .text
                                                    .trim(),
                                              );
                                        },
                                        titleColor: const Color(0xff6C47FF),
                                        backgroundColor: Colors.white,
                                        height: 54,
                                        buttonTitle: LanguageStrings.lblLogin,
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

                      // ── Sign up link ──────────────────────────
                      const SizedBox(height: 24),
                      Center(
                        child: GestureDetector(
                          onTap: () => context.pushNamed(Routes.signUpScreen),
                          child: RichText(
                            text: TextSpan(
                              text: "New here? ",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.68),
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                              ),
                              children: const [
                                TextSpan(
                                  text: "Create Account →",
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

  // ── Forgot password bottom sheet ─────────────────────────────────────────
  void _showForgotPasswordSheet() {
    final TextEditingController resetEmailController =
        TextEditingController(text: _emailController.text.trim());
    final AuthRepository authRepo = AuthRepository();
    bool isSending = false;

    Utils.showPremiumSheet(
      context: context,
      child: StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 8,
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  LanguageStrings.lblResetPassword,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  LanguageStrings.lblEnterEmailToReset,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),

                // Email field
                CustomTextFormField(
                  backgroundColor: Colors.white.withValues(alpha: 0.10),
                  hintTextColor: Colors.white.withValues(alpha: 0.45),
                  labelStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 13),
                  controller: resetEmailController,
                  hintText: LanguageStrings.lblEnterYourEmail,
                  labelText: LanguageStrings.lblEmail,
                  textInputAction: TextInputAction.done,
                  textInputType: TextInputType.emailAddress,
                  validator: null,
                ),
                const SizedBox(height: 22),

                // Send button
                CustomRoundedButton(
                  onTap: isSending
                      ? null
                      : () async {
                          final email = resetEmailController.text.trim();
                          if (email.isEmpty) {
                            Utils.showMessage(
                              sheetCtx,
                              LanguageStrings.lblEnterDetails,
                              MessageType.error,
                            );
                            return;
                          }
                          setSheetState(() => isSending = true);
                          try {
                            await authRepo.sendPasswordResetEmail(
                                email: email);
                            if (!sheetCtx.mounted) return;
                            Navigator.pop(sheetCtx);
                            Utils.showMessage(
                              context,
                              LanguageStrings.lblPasswordResetEmailSent,
                              MessageType.success,
                            );
                          } catch (e) {
                            if (!sheetCtx.mounted) return;
                            Utils.showMessage(
                              sheetCtx,
                              e.toString().getFirebaseError(),
                              MessageType.error,
                            );
                          } finally {
                            if (sheetCtx.mounted) {
                              setSheetState(() => isSending = false);
                            }
                          }
                        },
                  height: 52,
                  buttonTitle: LanguageStrings.lblResetPassword,
                  showBorder: false,
                  widthPercentage: 1,
                  radius: 16,
                  child: isSending
                      ? const CustomCircularProgressIndicator()
                      : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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
