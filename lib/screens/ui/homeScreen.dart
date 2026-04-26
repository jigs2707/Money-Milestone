// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart' hide Constant;
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:money_milestone/app/routes.dart';
import 'package:money_milestone/cubits/addGoalCubit.dart';
import 'package:money_milestone/cubits/deleteGoalCubit.dart';
import 'package:money_milestone/cubits/updateGoalCubit.dart';
import 'package:money_milestone/data/model/goalModal.dart';
import 'package:flutter/material.dart';
import 'package:money_milestone/data/repository/goalRepository.dart';
import 'package:money_milestone/data/repository/hiveRepository.dart';
import 'package:money_milestone/screens/widgets/addGoalDialog.dart';
import 'package:money_milestone/screens/widgets/bannerAdWidget.dart';
import 'package:money_milestone/screens/widgets/customRoundedButton.dart';
import 'package:money_milestone/screens/widgets/customTweenAnimation.dart';
import 'package:money_milestone/screens/widgets/customerShimmerWidget.dart';
import 'package:money_milestone/screens/widgets/badgesShelfWidget.dart';
import 'package:money_milestone/screens/widgets/backgroundWidget.dart';
import 'package:money_milestone/utils/app_colors_extension.dart';
import 'package:money_milestone/utils/constant.dart';
import 'package:money_milestone/utils/contextExtensions.dart';
import 'package:money_milestone/utils/databaseHelper.dart';
import 'package:money_milestone/utils/assets.dart';
import 'package:money_milestone/utils/languageString.dart';
import 'package:money_milestone/utils/stringExtensions.dart';
import 'package:money_milestone/screens/widgets/fadeSlideIn.dart';
import 'package:money_milestone/cubits/currencyCubit.dart';
import 'package:money_milestone/screens/widgets/currencyPickerSheet.dart';
import 'package:money_milestone/utils/utils.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static Route route(final RouteSettings routeSettings) {
    return MaterialPageRoute(
      builder: (final _) => BlocProvider(
          create: (BuildContext context) => DeleteGoalCubit(GoalRepository()),
          child: HomeScreen()),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  Stream<QuerySnapshot>? _goalsStream;

  final databaseReference = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    String userId = HiveRepository.getUserId ?? "";

    _goalsStream = FirebaseFirestore.instance
        .collection(DatabaseHelper.goalsCollectionName)
        .doc(userId)
        .collection(userId)
        .snapshots();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ── Goal card ─────────────────────────────────────────────────────────────
  Widget _getGoalDetailsWidget(GoalModel goalDetails) {
    double savedAmount = double.parse(goalDetails.goalSavedAmount ?? "0");
    double totalAmount = double.parse(goalDetails.goalAmount.toString());
    double goalPercentage = (savedAmount * 100) / totalAmount;
    final pct = goalPercentage.clamp(0, 100);

    Color progressColor;
    Color progressBg;
    if (pct >= 70) {
      progressColor = context.colors.greenColor;
      progressBg = context.colors.greenColor.withValues(alpha: 0.15);
    } else if (pct >= 40) {
      progressColor = context.colors.goldColor;
      progressBg = context.colors.goldColor.withValues(alpha: 0.15);
    } else {
      progressColor = context.colors.redColor;
      progressBg = context.colors.redColor.withValues(alpha: 0.15);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          context.pushNamed(Routes.goalDetailsScreen, arguments: {
            "goalDetails": goalDetails,
          });
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.cardGlassColor,
                border: Border.all(
                  color: context.colors.cardBorderColor,
                  width: 1.2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 10, 0),
                    child: Row(
                      children: [
                        // Icon pill
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                context.colors.accentColor.withValues(alpha: 0.18),
                                context.colors.accentColor.withValues(alpha: 0.08),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: context.colors.accentColor.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Icon(
                            Icons.flag_rounded,
                            color: context.colors.accentColor,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            goalDetails.goalName.toString(),
                            style: TextStyle(
                              color: context.colors.blackColors,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton(
                          color: context.colors.isDarkMode
                              ? const Color(0xff1C2135)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: context.colors.accentColor.withValues(alpha: 0.2),
                            ),
                          ),
                          padding: EdgeInsets.zero,
                          iconSize: 22,
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              onTap: () => _showAddGoalDialog(goalDetails),
                              value: 1,
                              child: Row(
                                children: [
                                  Icon(Icons.edit_rounded,
                                      size: 16,
                                      color: context.colors.accentColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    LanguageStrings.lblEdit,
                                    style: TextStyle(
                                        color: context.colors.blackColors,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              onTap: () {
                                String userId = HiveRepository.getUserId ?? "";
                                context.read<DeleteGoalCubit>().deleteGoal(
                                    goalDetails: goalDetails, userId: userId);
                              },
                              value: 2,
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outlined,
                                      size: 16, color: context.colors.redColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    LanguageStrings.lblDelete,
                                    style: TextStyle(
                                        color: context.colors.redColor,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          child: Icon(
                            Icons.more_vert_rounded,
                            color: context.colors.lightGreyColor,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress bar + percent
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomTweenAnimation(
                            curve: Curves.easeOut,
                            beginValue: 0,
                            endValue: (pct / 100).toDouble(),
                            durationInSeconds:
                                Constant.goalPercentageAnimationDuration,
                            builder: (context, value, _) => ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: LinearProgressIndicator(
                                borderRadius: BorderRadius.circular(100),
                                backgroundColor: progressBg,
                                value: value,
                                color: progressColor,
                                minHeight: 8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: progressColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${pct.toStringAsFixed(0)}%",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: progressColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Saved / target / date row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
                    child: Row(
                      children: [
                        _infoChip(
                          icon: Icons.account_balance_wallet_outlined,
                          label:
                              "${(goalDetails.goalSavedAmount ?? "0").toString().currency()} / ${goalDetails.goalAmount.toString().currency()}",
                        ),
                        const Spacer(),
                        _infoChip(
                          icon: Icons.calendar_today_outlined,
                          label: DateFormat(Constant.dateFormat).format(
                              DateTime.parse(
                                  goalDetails.goalDate.toString())),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoChip({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 13, color: context.colors.lightGreyColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: context.colors.lightGreyColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────
  Widget _setYourFirstGoalWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colors.accentColor.withValues(alpha: 0.12),
                  context.colors.accentColor.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                  color: context.colors.accentColor.withValues(alpha: 0.2)),
            ),
            child: Lottie.asset(
              Assets.noGoalAnimation,
              height: 140,
              width: 140,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            LanguageStrings.lblSetYourGoal,
            style: TextStyle(
              color: context.colors.blackColors,
              fontWeight: FontWeight.w800,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              LanguageStrings.lblSetYourGoalDescription,
              style: TextStyle(
                color: context.colors.lightGreyColor,
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 28),
          CustomRoundedButton(
            onTap: () => _showAddGoalDialog(),
            titleColor: context.colors.whiteColors,
            buttonTitle: LanguageStrings.lblAddGoal,
            showBorder: false,
            widthPercentage: 0.6,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showAddGoalDialog([GoalModel? goalDetails]) {
    Utils.showPremiumSheet(
        context: context,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => AddGoalCubit(GoalRepository()),
            ),
            BlocProvider(
              create: (context) => UpdateGoalCubit(GoalRepository()),
            )
          ],
          child: AddGoalDialog(goalDetails: goalDetails),
        ));
  }

  // ── Summary header card ────────────────────────────────────────────────────
  Widget _summaryCard(List<GoalModel> goals) {
    double totalTarget = goals.fold(
        0, (s, g) => s + (double.tryParse(g.goalAmount.toString()) ?? 0));
    double totalSaved = goals.fold(
        0,
        (s, g) =>
            s + (double.tryParse(g.goalSavedAmount.toString()) ?? 0));
    double overallPct =
        totalTarget > 0 ? (totalSaved * 100) / totalTarget : 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: context.colors.isDarkMode
                  ? [
                      const Color(0xff2A1F6A).withValues(alpha: 0.85),
                      const Color(0xff1C1545).withValues(alpha: 0.85),
                    ]
                  : [
                      const Color(0xff6C47FF),
                      const Color(0xff5A35EE),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff6C47FF).withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bar_chart_rounded,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          "${goals.length} Goal${goals.length == 1 ? '' : 's'}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${overallPct.toStringAsFixed(0)}% overall",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                "Total Saved",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                totalSaved.toString().currency(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 14),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: (overallPct / 100).clamp(0, 1).toDouble(),
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  color: context.colors.goldColor,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Target: ${totalTarget.toString().currency()}",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "Left: ${(totalTarget - totalSaved).toString().currency()}",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      bottomNavigationBar: BannerAdWidget(),
      appBar: _buildAppBar(),
      body: BackgroundWidget(
        child: SafeArea(
          child: BlocListener<DeleteGoalCubit, DeleteGoalState>(
            listener: (context, state) {
              if (state is DeleteGoalFailure) {
                Utils.showMessage(
                    context, state.errorMessage, MessageType.error);
              } else if (state is DeleteGoalSuccess) {
                Utils.showMessage(
                    context,
                    LanguageStrings.lblGoalDeletedSuccessfully,
                    MessageType.success);
              }
            },
            child: BlocBuilder<CurrencyCubit, CurrencyState>(
              builder: (context, currencyState) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Greeting row ──────────────────────────────────
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 0),
                        child: _greetingRow(),
                  ),
                  const SizedBox(height: 22),

                  // ── Stream ────────────────────────────────────────
                  StreamBuilder(
                    stream: _goalsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasError) {
                          return _errorWidget();
                        }
                        if (snapshot.hasData) {
                          List<DocumentSnapshot?> goalsData =
                              snapshot.data!.docs;

                          if (goalsData.isNotEmpty) {
                            List<GoalModel> parsedGoals = [];
                            for (var doc in goalsData) {
                              Map<String, dynamic> data =
                                  Map.from(doc!.data() as Map<String, dynamic>);
                              data["id"] = doc.id;
                              parsedGoals.add(GoalModel.fromJson(data));
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Summary card
                                FadeSlideIn(
                                  delay: const Duration(milliseconds: 80),
                                  child: _summaryCard(parsedGoals),
                                ),
                                const SizedBox(height: 20),

                                // Badges
                                FadeSlideIn(
                                  delay: const Duration(milliseconds: 160),
                                  child: BadgesShelfWidget(goals: parsedGoals),
                                ),
                                const SizedBox(height: 4),

                                // Section header
                                FadeSlideIn(
                                  delay: const Duration(milliseconds: 220),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        LanguageStrings.lblMyGoals,
                                        style: TextStyle(
                                          color: context.colors.blackColors,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 20,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const Spacer(),
                                      _addGoalPill(),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Goal cards — staggered
                                ...List.generate(parsedGoals.length, (i) {
                                  return FadeSlideIn(
                                    delay: Duration(milliseconds: 280 + i * 60),
                                    offset: 16,
                                    child: _getGoalDetailsWidget(parsedGoals[i]),
                                  );
                                }),
                              ],
                            );
                          } else {
                            return _setYourFirstGoalWidget();
                          }
                        } else {
                          return _setYourFirstGoalWidget();
                        }
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Column(
                            children: List.generate(
                                Constant.numberOfShimmerLoadingWidget,
                                (index) => CustomShimmerLoadingWidget(
                                      height: 120,
                                      margin:
                                          const EdgeInsets.symmetric(vertical: 7),
                                    )).toList());
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ],
              ),
            );
           },
          ),
         ),
        ),
      ),
    );
  }

  Widget _greetingRow() {
    final username = HiveRepository.getUsername ?? "";
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome back 👋",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.colors.lightGreyColor,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              username.isEmpty ? "Saver" : username,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: context.colors.blackColors,
                letterSpacing: -0.8,
              ),
            ),
          ],
        ),
        const Spacer(),
        // ── Streak Pill (taps to profile) ─────────────────────────
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection(DatabaseHelper.usersCollectionName)
              .doc(HiveRepository.getUserId ?? "")
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.exists) {
              final data =
                  snapshot.data!.data() as Map<String, dynamic>? ?? {};
              final int streak = data[DatabaseHelper.currentStreakKey] ?? 0;
              if (streak > 0) {
                return GestureDetector(
                  onTap: () => context.pushNamed(Routes.profileScreen),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 7),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("🔥",
                            style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Text(
                          "$streak day${streak == 1 ? '' : 's'}",
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }
            return const SizedBox.shrink();
          },
        ),
        // ── Currency button ────────────────────────────────────────
        BlocBuilder<CurrencyCubit, CurrencyState>(
          builder: (ctx, state) => GestureDetector(
            onTap: () => showCurrencyPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: context.colors.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: context.colors.accentColor.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.currency.symbol,
                    style: TextStyle(
                      color: context.colors.accentColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    state.currency.code,
                    style: TextStyle(
                      color: context.colors.accentColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // ── Avatar (taps to profile) ───────────────────────────────
        GestureDetector(
          onTap: () => context.pushNamed(Routes.profileScreen),
          child: Container(
            width: 48,
            height: 48,
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
                  color: context.colors.accentColor.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                username.trim().isEmpty
                    ? "U"
                    : username.trim()[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _addGoalPill() {
    return GestureDetector(
      onTap: () => _showAddGoalDialog(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.colors.accentColor,
              context.colors.gradiantBottomColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: context.colors.accentColor.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add_rounded, color: Colors.white, size: 16),
            SizedBox(width: 4),
            Text(
              "Add Goal",
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          "Something went wrong. Please try again.",
          style: TextStyle(color: context.colors.redColor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colors.accentColor,
                  context.colors.gradiantBottomColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.savings_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            Constant.appName,
            style: TextStyle(
              color: context.colors.blackColors,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }

}
