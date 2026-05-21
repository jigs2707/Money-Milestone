// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart' hide Constant;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money_milestone/app/routes.dart';
import 'package:money_milestone/cubits/currencyCubit.dart';
import 'package:money_milestone/cubits/themeCubit.dart';
import 'package:money_milestone/data/repository/authRepository.dart';
import 'package:money_milestone/data/repository/hiveRepository.dart';
import 'package:money_milestone/screens/widgets/currencyPickerSheet.dart';
import 'package:money_milestone/screens/widgets/customCircularProgressIndicator.dart';
import 'package:money_milestone/screens/widgets/customRoundedButton.dart';
import 'package:money_milestone/screens/widgets/customTextFormfield.dart';
import 'package:money_milestone/utils/app_colors_extension.dart';
import 'package:money_milestone/utils/constant.dart';
import 'package:money_milestone/utils/databaseHelper.dart';
import 'package:money_milestone/utils/languageString.dart';
import 'package:money_milestone/utils/stringExtensions.dart';
import 'package:money_milestone/utils/utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static Route route(final RouteSettings routeSettings) =>
      MaterialPageRoute(builder: (_) => const ProfileScreen());

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final username = HiveRepository.getUsername ?? '';
    final userId = HiveRepository.getUserId ?? '';
    final initial =
        username.trim().isEmpty ? 'U' : username.trim()[0].toUpperCase();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.colors.isDarkMode
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: context.colors.blackColors),
          ),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: context.colors.blackColors,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
              ),
            ),
          ),
          // Mesh blobs
          Positioned(
            top: -60,
            left: -40,
            child: _blob(
              context.colors.isDarkMode
                  ? const Color(0xff6C47FF).withValues(alpha: 0.22)
                  : const Color(0xff6C47FF).withValues(alpha: 0.12),
              260,
            ),
          ),
          Positioned(
            bottom: -80,
            right: -50,
            child: _blob(
              context.colors.isDarkMode
                  ? const Color(0xff4B32CC).withValues(alpha: 0.28)
                  : const Color(0xff8B6FFF).withValues(alpha: 0.10),
              300,
            ),
          ),
          // Full-screen blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(color: Colors.transparent),
            ),
          ),
          // Content
          SafeArea(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(DatabaseHelper.usersCollectionName)
                  .doc(userId)
                  .snapshots(),
              builder: (context, snap) {
                final data = (snap.hasData && snap.data!.exists)
                    ? snap.data!.data() as Map<String, dynamic>
                    : <String, dynamic>{};

                final int streak = data[DatabaseHelper.currentStreakKey] ?? 0;
                final int longest = data[DatabaseHelper.longestStreakKey] ?? 0;
                final String? lastDepositRaw =
                    data[DatabaseHelper.lastDepositDateKey];
                String lastDepositStr = '—';
                if (lastDepositRaw != null) {
                  try {
                    lastDepositStr = DateFormat('MMM d, yyyy')
                        .format(DateTime.parse(lastDepositRaw));
                  } catch (_) {}
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Profile header ──────────────────────────────
                      _glassCard(
                        context,
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    context.colors.gradiantTopColor,
                                    context.colors.gradiantBottomColor,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: context.colors.accentColor
                                        .withValues(alpha: 0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    username.isEmpty ? 'Saver' : username,
                                    style: TextStyle(
                                      color: context.colors.blackColors,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: context.colors.accentColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Money Milestone Member',
                                      style: TextStyle(
                                        color: context.colors.accentColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Streak card ──────────────────────────────────
                      _glassCard(
                        context,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.orange.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.orange
                                            .withValues(alpha: 0.25)),
                                  ),
                                  child: const Text('🔥',
                                      style: TextStyle(fontSize: 14)),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Savings Streak',
                                  style: TextStyle(
                                    color: context.colors.blackColors,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Stats row
                            Row(
                              children: [
                                Expanded(
                                  child: _streakStat(
                                    context,
                                    value: '$streak',
                                    label: 'Current Streak',
                                    color: Colors.orange,
                                    emoji: '🔥',
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 50,
                                  color: context.colors.lightGreyColor
                                      .withValues(alpha: 0.2),
                                ),
                                Expanded(
                                  child: _streakStat(
                                    context,
                                    value: '$longest',
                                    label: 'Best Ever',
                                    color: context.colors.goldColor,
                                    emoji: '🏆',
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 50,
                                  color: context.colors.lightGreyColor
                                      .withValues(alpha: 0.2),
                                ),
                                Expanded(
                                  child: _streakStat(
                                    context,
                                    value: lastDepositStr,
                                    label: 'Last Deposit',
                                    color: context.colors.accentColor,
                                    emoji: '📅',
                                    smallValue: true,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            Divider(
                                height: 1,
                                color: context.colors.lightGreyColor
                                    .withValues(alpha: 0.15)),
                            const SizedBox(height: 20),

                            // How it works
                            Text(
                              'How streaks work',
                              style: TextStyle(
                                color: context.colors.blackColors,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _howItWorksStep(context,
                                step: '1',
                                emoji: '💰',
                                title: 'Make a deposit',
                                desc: 'Add savings to any goal today.'),
                            const SizedBox(height: 10),
                            _howItWorksStep(context,
                                step: '2',
                                emoji: '📆',
                                title: 'Do it every day',
                                desc:
                                    'Each consecutive day keeps your streak alive.'),
                            const SizedBox(height: 10),
                            _howItWorksStep(context,
                                step: '3',
                                emoji: '⚠️',
                                title: "Don't miss a day",
                                desc:
                                    'Missing a full day resets your streak to 0.'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Settings ──────────────────────────────────────
                      _sectionLabel(context, 'Settings'),
                      const SizedBox(height: 10),
                      _glassCard(
                        context,
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            // Currency
                            BlocBuilder<CurrencyCubit, CurrencyState>(
                              builder: (ctx, state) {
                                return _settingRow(
                                  context,
                                  icon: Icons.currency_exchange_rounded,
                                  label: 'Currency',
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${state.currency.symbol}  ${state.currency.code}',
                                        style: TextStyle(
                                          color: context.colors.accentColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.chevron_right_rounded,
                                          size: 18,
                                          color: context.colors.lightGreyColor),
                                    ],
                                  ),
                                  onTap: () => showCurrencyPicker(context),
                                );
                              },
                            ),
                            Divider(
                                height: 1,
                                indent: 54,
                                color: context.colors.lightGreyColor
                                    .withValues(alpha: 0.12)),
                            // Theme
                            BlocBuilder<ThemeCubit, ThemeState>(
                              builder: (context, state) {
                                final isDark =
                                    context.read<ThemeCubit>().isDarkMode;
                                return _settingRow(
                                  context,
                                  icon: isDark
                                      ? Icons.light_mode_rounded
                                      : Icons.dark_mode_rounded,
                                  label: isDark ? 'Light Mode' : 'Dark Mode',
                                  trailing: Switch.adaptive(
                                    value: isDark,
                                    onChanged: (_) => context
                                        .read<ThemeCubit>()
                                        .toggleTheme(),
                                    activeColor: context.colors.accentColor,
                                  ),
                                  onTap: () =>
                                      context.read<ThemeCubit>().toggleTheme(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Account ───────────────────────────────────────
                      _sectionLabel(context, 'Account'),
                      const SizedBox(height: 10),
                      _glassCard(
                        context,
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            _settingRow(
                              context,
                              icon: Icons.lock_outline_rounded,
                              label: 'Change Password',
                              trailing: Icon(Icons.chevron_right_rounded,
                                  size: 18,
                                  color: context.colors.lightGreyColor),
                              onTap: () => _showChangePasswordSheet(context),
                            ),
                            Divider(
                                height: 1,
                                indent: 54,
                                color: context.colors.lightGreyColor
                                    .withValues(alpha: 0.12)),
                            _settingRow(
                              context,
                              icon: Icons.logout_rounded,
                              label: 'Log Out',
                              iconColor: context.colors.redColor,
                              labelColor: context.colors.redColor,
                              trailing: Icon(Icons.chevron_right_rounded,
                                  size: 18,
                                  color: context.colors.redColor
                                      .withValues(alpha: 0.5)),
                              onTap: () => _showLogoutSheet(context),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          '${Constant.appName} · v1.1.0',
                          style: TextStyle(
                            color: context.colors.lightGreyColor
                                .withValues(alpha: 0.5),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _glassCard(BuildContext context,
      {required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: context.colors.cardGlassColor,
            border:
                Border.all(color: context.colors.cardBorderColor, width: 1.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _streakStat(
    BuildContext context, {
    required String value,
    required String label,
    required Color color,
    required String emoji,
    bool smallValue = false,
  }) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: smallValue ? 12 : 24,
            letterSpacing: smallValue ? 0 : -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: context.colors.lightGreyColor,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _howItWorksStep(
    BuildContext context, {
    required String step,
    required String emoji,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: context.colors.accentColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
                color: context.colors.accentColor.withValues(alpha: 0.25)),
          ),
          child: Center(
            child: Text(
              step,
              style: TextStyle(
                color: context.colors.accentColor,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 5),
                  Text(
                    title,
                    style: TextStyle(
                      color: context.colors.blackColors,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  color: context.colors.lightGreyColor,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(BuildContext context, String label) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: context.colors.lightGreyColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      );

  Widget _settingRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Widget trailing,
    required VoidCallback onTap,
    Color? iconColor,
    Color? labelColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: (iconColor ?? context.colors.accentColor)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 17, color: iconColor ?? context.colors.accentColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: labelColor ?? context.colors.blackColors,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _blob(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  // ── Change Password sheet ─────────────────────────────────────────────
  void _showChangePasswordSheet(BuildContext context) {
    final currentPwCtrl = TextEditingController();
    final newPwCtrl = TextEditingController();
    final confirmPwCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final authRepo = AuthRepository();
    bool isLoading = false;

    Utils.showPremiumSheet(
      context: context,
      child: StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 8,
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    LanguageStrings.lblChangePassword,
                    style: TextStyle(
                      color: context.colors.blackColors,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Verify your current password, then set a new one.',
                    style: TextStyle(
                      color: context.colors.lightGreyColor,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Current password
                  CustomTextFormField(
                    controller: currentPwCtrl,
                    labelText: LanguageStrings.lblCurrentPassword,
                    hintText: LanguageStrings.lblEnterCurrentPassword,
                    isPswd: true,
                    textInputAction: TextInputAction.next,
                    textInputType: TextInputType.text,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return LanguageStrings.lblEnterDetails;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // New password
                  CustomTextFormField(
                    controller: newPwCtrl,
                    labelText: LanguageStrings.lblNewPassword,
                    hintText: LanguageStrings.lblEnterNewPassword,
                    isPswd: true,
                    textInputAction: TextInputAction.next,
                    textInputType: TextInputType.text,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return LanguageStrings.lblEnterDetails;
                      }
                      if (v.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      if (!v.contains(RegExp(r'[A-Z]'))) {
                        return 'Add at least one uppercase letter';
                      }
                      if (!v.contains(RegExp(r'[0-9]'))) {
                        return 'Add at least one number';
                      }
                      if (!v.contains(
                          RegExp(r'[!@#\$%^&*(),.?":{}|<>\-_=+\[\]\/\\]'))) {
                        return 'Add at least one special character';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Confirm new password
                  CustomTextFormField(
                    controller: confirmPwCtrl,
                    labelText: LanguageStrings.lblConfirmNewPassword,
                    hintText: LanguageStrings.lblEnterNewPassword,
                    isPswd: true,
                    textInputAction: TextInputAction.done,
                    textInputType: TextInputType.text,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return LanguageStrings.lblEnterDetails;
                      }
                      if (v != newPwCtrl.text) {
                        return LanguageStrings.lblPasswordDoesNotMatch;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Confirm button
                  CustomRoundedButton(
                    onTap: isLoading
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            setSheetState(() => isLoading = true);
                            try {
                              // Step 1: re-authenticate
                              await authRepo.reAuthenticate(
                                password: currentPwCtrl.text.trim(),
                              );
                              // Step 2: update password
                              await authRepo.updatePassword(
                                newPassword: newPwCtrl.text.trim(),
                              );
                              if (!sheetCtx.mounted) return;
                              Navigator.pop(sheetCtx);
                              Utils.showMessage(
                                context,
                                LanguageStrings.lblPasswordChangedSuccessfully,
                                MessageType.success,
                              );
                            } catch (e) {
                              if (!sheetCtx.mounted) return;
                              // Detect wrong-password from re-auth failure
                              final msg = e
                                      .toString()
                                      .contains('invalid-credential')
                                  ? LanguageStrings.lblIncorrectCurrentPassword
                                  : e.toString().getFirebaseError();
                              Utils.showMessage(
                                sheetCtx,
                                msg,
                                MessageType.error,
                              );
                            } finally {
                              if (sheetCtx.mounted) {
                                setSheetState(() => isLoading = false);
                              }
                            }
                          },
                    height: 52,
                    buttonTitle: LanguageStrings.lblChangePassword,
                    showBorder: false,
                    widthPercentage: 1,
                    radius: 16,
                    child: isLoading
                        ? const CustomCircularProgressIndicator()
                        : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLogoutSheet(BuildContext context) {
    Utils.showPremiumSheet(
      context: context,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.redColor.withValues(alpha: 0.10),
                border: Border.all(
                    color: context.colors.redColor.withValues(alpha: 0.20),
                    width: 1.5),
                boxShadow: [
                  BoxShadow(
                      color: context.colors.redColor.withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: 2)
                ],
              ),
              child: Icon(Icons.logout_rounded,
                  color: context.colors.redColor, size: 30),
            ),
            const SizedBox(height: 18),
            Text(
              'Log Out?',
              style: TextStyle(
                  color: context.colors.blackColors,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            Text(
              "You'll need to sign in again to access your savings goals.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: context.colors.lightGreyColor,
                  fontSize: 14,
                  height: 1.5),
            ),
            const SizedBox(height: 28),
            CustomRoundedButton(
              onTap: () {
                Navigator.of(context).pop(); // close sheet
                Navigator.of(context).pop(); // close profile
                AuthRepository().signOut().then((_) {
                  HiveRepository.clearBoxValues(
                      boxName: HiveRepository.authStatusBoxKey);
                  HiveRepository.clearBoxValues(
                      boxName: HiveRepository.userDetailBoxKey);
                  Navigator.of(context)
                      .pushReplacementNamed(Routes.logInScreen);
                });
              },
              height: 52,
              buttonTitle: 'Yes, Log Out',
              backgroundColor: context.colors.redColor,
              titleColor: Colors.white,
              showBorder: false,
              widthPercentage: 1,
              radius: 16,
            ),
            const SizedBox(height: 10),
            CustomRoundedButton(
              onTap: () => Navigator.of(context).pop(),
              height: 52,
              buttonTitle: 'Cancel',
              backgroundColor: Colors.transparent,
              titleColor: context.colors.lightGreyColor,
              showBorder: true,
              borderColor: context.colors.lightGreyColor.withValues(alpha: 0.3),
              widthPercentage: 1,
              radius: 16,
            ),
          ],
        ),
      ),
    );
  }
}
