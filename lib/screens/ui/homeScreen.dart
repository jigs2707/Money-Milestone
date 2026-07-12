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
import 'package:money_milestone/cubits/categoryCubit.dart';
import 'package:money_milestone/data/model/goalCategoryModel.dart';
import 'package:money_milestone/data/repository/categoryRepository.dart';
import 'package:money_milestone/utils/adService.dart';
import 'package:money_milestone/utils/clarityService.dart';
import 'package:money_milestone/utils/goalCategories.dart';
import 'package:money_milestone/utils/sessionTracker.dart';
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
import 'package:money_milestone/utils/notificationService.dart';
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
  late final CategoryCubit _categoryCubit;
  String _statusFilter = 'all';
  Set<String> _categoryFilters = {};
  String _sortKey = 'default';

  bool get _hasActiveFilter =>
      _categoryFilters.isNotEmpty || _sortKey != 'default';

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

    _categoryCubit = CategoryCubit(CategoryRepository(), userId);

    // Log this app open in Firestore + Clarity for retention analytics
    SessionTracker.instance.logAppOpen();
    ClarityService.setScreen('Home');
    ClarityService.logAppOpened();

    // Ask for notification permission on first launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), _maybeRequestNotificationPermission);
    });
  }

  Future<void> _maybeRequestNotificationPermission() async {
    if (!mounted) return;
    final enabled = await NotificationService.instance.areNotificationsEnabled();
    if (!enabled) {
      _showNotificationPermissionSheet();
      return;
    }
    if (!HiveRepository.hasShownNotifPermissionPrompt) {
      await HiveRepository.markNotifPermissionPromptShown();
      final granted = await NotificationService.instance.requestPermission();
      if (!granted && mounted) _showNotificationPermissionSheet();
    }
  }

  void _showNotificationPermissionSheet() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _NotificationPermissionSheet(),
    );
  }

  @override
  void dispose() {
    _categoryCubit.close();
    super.dispose();
  }

  // ── Goal card ─────────────────────────────────────────────────────────────
  Widget _getGoalDetailsWidget(
    GoalModel goalDetails, {
    List<GoalCategoryModel> customCategories = const [],
  }) {
    double savedAmount = double.parse(goalDetails.goalSavedAmount ?? "0");
    double totalAmount = double.parse(goalDetails.goalAmount.toString());
    double goalPercentage = (savedAmount * 100) / totalAmount;
    final pct = goalPercentage.clamp(0, 100);
    final category = GoalCategories.find(
      goalDetails.categoryId,
      customs: customCategories,
    );

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
        onTap: () {
          AdService.instance.showInterstitialOnEveryNthTap(threshold: 5);
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
                        // Category icon pill
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: category.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: category.color.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Icon(
                            category.icon,
                            color: category.color,
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
                            // Reschedule goal deadline notifications whenever goals update
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              NotificationService.instance.scheduleAll(parsedGoals);
                            });

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
                                const SizedBox(height: 12),

                                // Filter / sort bar
                                FadeSlideIn(
                                  delay: const Duration(milliseconds: 260),
                                  offset: 10,
                                  child: BlocBuilder<CategoryCubit, CategoryState>(
                                    bloc: _categoryCubit,
                                    builder: (_, catState) {
                                      final customs = catState is CategoryLoaded
                                          ? catState.customCategories
                                          : <GoalCategoryModel>[];
                                      return _buildFilterBar(
                                          parsedGoals, customs);
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Goal cards — filtered, staggered, banners every 3rd
                                BlocBuilder<CategoryCubit, CategoryState>(
                                  bloc: _categoryCubit,
                                  builder: (_, catState) {
                                    final customs = catState is CategoryLoaded
                                        ? catState.customCategories
                                        : <GoalCategoryModel>[];
                                    final filtered =
                                        _filterGoals(parsedGoals);
                                    if (filtered.isEmpty) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: Center(
                                          child: Text(
                                            'No goals match this filter',
                                            style: TextStyle(
                                              color:
                                                  context.colors.lightGreyColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return Column(
                                      children: List.generate(filtered.length,
                                          (i) {
                                        return Column(
                                          children: [
                                            FadeSlideIn(
                                              delay: Duration(
                                                  milliseconds: 280 + i * 60),
                                              offset: 16,
                                              child: _getGoalDetailsWidget(
                                                filtered[i],
                                                customCategories: customs,
                                              ),
                                            ),
                                            if ((i + 1) % 3 == 0 &&
                                                i + 1 < filtered.length)
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 14),
                                                child: BannerAdWidget(),
                                              ),
                                          ],
                                        );
                                      }),
                                    );
                                  },
                                ),
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

  // ── Filter bar ────────────────────────────────────────────────────────────
  Widget _buildFilterBar(
      List<GoalModel> goals, List<GoalCategoryModel> customs) {
    const statusChips = [
      ('all', 'All'),
      ('pending', 'Pending'),
      ('completed', 'Completed'),
    ];

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              itemCount: statusChips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final (key, label) = statusChips[i];
                final isSelected = _statusFilter == key;
                return GestureDetector(
                  onTap: () {
                    if (_statusFilter == key) return;
                    setState(() => _statusFilter = key);
                    ClarityService.logGoalFilterApplied(filter: key);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    height: 36,
                    alignment: Alignment.center,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.colors.accentColor
                              .withValues(alpha: 0.15)
                          : context.colors.cardGlassColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? context.colors.accentColor
                                .withValues(alpha: 0.5)
                            : context.colors.cardBorderColor,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? context.colors.accentColor
                            : context.colors.lightGreyColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Advanced filter/sort button
        GestureDetector(
          onTap: () => _showGoalFilterSheet(goals, customs),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: 36,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: _hasActiveFilter
                  ? context.colors.accentColor.withValues(alpha: 0.15)
                  : context.colors.cardGlassColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _hasActiveFilter
                    ? context.colors.accentColor.withValues(alpha: 0.5)
                    : context.colors.cardBorderColor,
                width: _hasActiveFilter ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 16,
                  color: _hasActiveFilter
                      ? context.colors.accentColor
                      : context.colors.lightGreyColor,
                ),
                if (_hasActiveFilter) ...[
                  const SizedBox(width: 5),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: context.colors.accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Filter sheet ──────────────────────────────────────────────────────────
  void _showGoalFilterSheet(
      List<GoalModel> goals, List<GoalCategoryModel> customs) {
    final Set<String> sheetCategories = Set.from(_categoryFilters);
    String sheetSort = _sortKey;

    final usedCategoryIds = goals.map((g) => g.categoryId).toSet();
    final availableCategories = GoalCategories.all(customs: customs)
        .where((c) => usedCategoryIds.contains(c.id))
        .toList();

    const sortOptions = [
      ('default', Icons.list_rounded, 'Default order'),
      ('pct_asc', Icons.trending_up_rounded, '% Progress: Low → High'),
      ('pct_desc', Icons.trending_down_rounded, '% Progress: High → Low'),
      ('days_asc', Icons.timer_rounded, 'Remaining Days: Fewest first'),
      ('days_desc', Icons.hourglass_top_rounded, 'Remaining Days: Most first'),
      ('amount_asc', Icons.south_rounded, 'Amount: Low → High'),
      ('amount_desc', Icons.north_rounded, 'Amount: High → Low'),
    ];

    Utils.showPremiumSheet(
      context: context,
      child: StatefulBuilder(
        builder: (ctx, setSheet) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────
                Row(
                  children: [
                    Text(
                      'Filter & Sort',
                      style: TextStyle(
                        color: ctx.colors.blackColors,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const Spacer(),
                    if (sheetCategories.isNotEmpty || sheetSort != 'default')
                      GestureDetector(
                        onTap: () => setSheet(() {
                          sheetCategories.clear();
                          sheetSort = 'default';
                        }),
                        child: Text(
                          'Reset',
                          style: TextStyle(
                            color: ctx.colors.accentColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),

                // ── Category ─────────────────────────────────────────
                if (availableCategories.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _filterSheetLabel(ctx, Icons.category_outlined,
                      'Category  •  select one or more'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableCategories.map((c) {
                      final isSel = sheetCategories.contains(c.id);
                      return _filterSheetChip(
                        ctx,
                        label: c.name,
                        icon: c.icon,
                        isSelected: isSel,
                        color: c.color,
                        onTap: () => setSheet(() {
                          if (isSel) {
                            sheetCategories.remove(c.id);
                          } else {
                            sheetCategories.add(c.id);
                          }
                        }),
                      );
                    }).toList(),
                  ),
                ],

                // ── Sort By ──────────────────────────────────────────
                const SizedBox(height: 20),
                _filterSheetLabel(ctx, Icons.sort_rounded, 'Sort By'),
                const SizedBox(height: 10),
                ...sortOptions.map((opt) {
                  final (key, icon, label) = opt;
                  final isSelected = sheetSort == key;
                  return GestureDetector(
                    onTap: () => setSheet(() => sheetSort = key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ctx.colors.accentColor.withValues(alpha: 0.1)
                            : ctx.colors.cardGlassColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? ctx.colors.accentColor.withValues(alpha: 0.4)
                              : ctx.colors.cardBorderColor,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(icon,
                              size: 16,
                              color: isSelected
                                  ? ctx.colors.accentColor
                                  : ctx.colors.lightGreyColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? ctx.colors.blackColors
                                    : ctx.colors.lightGreyColor,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_rounded,
                                size: 16, color: ctx.colors.accentColor),
                        ],
                      ),
                    ),
                  );
                }),

                // ── Apply ─────────────────────────────────────────────
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _categoryFilters = Set.from(sheetCategories);
                      _sortKey = sheetSort;
                    });
                    ClarityService.logGoalFilterApplied(
                        filter: '${sheetCategories.join(",")}_$sheetSort');
                    Navigator.of(ctx).pop();
                  },
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ctx.colors.accentColor,
                          ctx.colors.gradiantBottomColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: ctx.colors.accentColor.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Apply Filters',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _filterSheetLabel(BuildContext ctx, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: ctx.colors.lightGreyColor),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: ctx.colors.lightGreyColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }

  Widget _filterSheetChip(
    BuildContext ctx, {
    required String label,
    IconData? icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.12)
              : ctx.colors.cardGlassColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.5)
                : ctx.colors.cardBorderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 13,
                  color: isSelected ? color : ctx.colors.lightGreyColor),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : ctx.colors.lightGreyColor,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(Icons.check_rounded, size: 11, color: color),
            ],
          ],
        ),
      ),
    );
  }

  // ── Goal list filtering + sorting ─────────────────────────────────────────
  List<GoalModel> _filterGoals(List<GoalModel> goals) {
    var result = goals.toList();

    // Status
    if (_statusFilter == 'pending') {
      result = result.where((g) => _goalPct(g) < 100).toList();
    } else if (_statusFilter == 'completed') {
      result = result.where((g) => _goalPct(g) >= 100).toList();
    }

    // Category (multi-select — empty set means all)
    if (_categoryFilters.isNotEmpty) {
      result = result
          .where((g) => _categoryFilters.contains(g.categoryId))
          .toList();
    }

    // Sort
    switch (_sortKey) {
      case 'pct_asc':
        result.sort((a, b) => _goalPct(a).compareTo(_goalPct(b)));
      case 'pct_desc':
        result.sort((a, b) => _goalPct(b).compareTo(_goalPct(a)));
      case 'days_asc':
        result.sort((a, b) => _goalDaysLeft(a).compareTo(_goalDaysLeft(b)));
      case 'days_desc':
        result.sort((a, b) => _goalDaysLeft(b).compareTo(_goalDaysLeft(a)));
      case 'amount_asc':
        result.sort((a, b) => _goalAmount(a).compareTo(_goalAmount(b)));
      case 'amount_desc':
        result.sort((a, b) => _goalAmount(b).compareTo(_goalAmount(a)));
    }

    return result;
  }

  double _goalPct(GoalModel g) {
    final saved = double.tryParse(g.goalSavedAmount ?? '0') ?? 0;
    final total = double.tryParse(g.goalAmount ?? '0') ?? 1;
    return (saved / total) * 100;
  }

  int _goalDaysLeft(GoalModel g) {
    if (g.goalDate == null || g.goalDate!.isEmpty) return 9999;
    try {
      final target = DateTime.parse('${g.goalDate} 00:00:00');
      return target.difference(DateTime.now()).inDays;
    } catch (_) {
      return 9999;
    }
  }

  double _goalAmount(GoalModel g) =>
      double.tryParse(g.goalAmount ?? '0') ?? 0;

  Widget _greetingRow() {
    final username = HiveRepository.getUsername ?? "";
    return Row(
      children: [
        Expanded(
          child: Column(
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

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

// ── Notification permission bottom sheet ────────────────────────────────────
class _NotificationPermissionSheet extends StatelessWidget {
  const _NotificationPermissionSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.isDarkMode
            ? const Color(0xff141829)
            : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: context.colors.accentColor.withValues(alpha: 0.18),
          width: 1.2,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: context.colors.lightGreyColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),

          // Bell icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colors.accentColor.withValues(alpha: 0.18),
                  context.colors.accentColor.withValues(alpha: 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: context.colors.accentColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              color: context.colors.accentColor,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),

          // Headline
          Text(
            'Stay on Track with Notifications',
            style: TextStyle(
              color: context.colors.blackColors,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // Body
          Text(
            'Get gentle reminders to save daily, celebrate milestones, and never miss a goal deadline — all on your terms.',
            style: TextStyle(
              color: context.colors.lightGreyColor,
              fontSize: 14,
              height: 1.55,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Benefits list
          _benefit(context, Icons.savings_rounded, context.colors.accentColor,
              'Daily savings reminders'),
          const SizedBox(height: 10),
          _benefit(context, Icons.flag_rounded, const Color(0xff9C27B0),
              'Goal milestone celebrations'),
          const SizedBox(height: 10),
          _benefit(context, Icons.timer_rounded, Colors.orange,
              'Deadline alerts so you never miss'),
          const SizedBox(height: 10),
          _benefit(context, Icons.local_fire_department_rounded,
              Colors.deepOrange, 'Streak reminders to keep momentum'),
          const SizedBox(height: 28),

          // Enable button
          GestureDetector(
            onTap: () async {
              Navigator.of(context).pop();
              await NotificationService.instance.requestPermission();
              await HiveRepository.markNotifPermissionPromptShown();
            },
            child: Container(
              height: 54,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colors.accentColor,
                    context.colors.gradiantBottomColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.accentColor.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_active_rounded,
                        color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Enable Notifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Not now
          GestureDetector(
            onTap: () async {
              Navigator.of(context).pop();
              await HiveRepository.markNotifPermissionPromptShown();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Not Now',
                style: TextStyle(
                  color: context.colors.lightGreyColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefit(
      BuildContext context, IconData icon, Color color, String label) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: context.colors.blackColors,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
