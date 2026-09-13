import 'dart:ui';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:money_milestone/screens/widgets/backgroundWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import 'package:money_milestone/cubits/addOrWithdrawMoneyCubit.dart';
import 'package:money_milestone/cubits/updateGoalCubit.dart';
import 'package:money_milestone/data/model/goalModal.dart';
import 'package:money_milestone/data/model/transactionModel.dart';
import 'package:money_milestone/data/repository/goalRepository.dart';
import 'package:money_milestone/data/repository/transactionRepository.dart';
import 'package:money_milestone/screens/widgets/addOrWithdrawMonetDialogWidget.dart';
import 'package:money_milestone/screens/widgets/bannerAdWidget.dart';
import 'package:money_milestone/screens/widgets/progressChartWidget.dart';
import 'package:money_milestone/utils/adService.dart';
import 'package:money_milestone/utils/clarityService.dart';
import 'package:money_milestone/screens/widgets/customTweenAnimation.dart';
import 'package:money_milestone/screens/widgets/customerShimmerWidget.dart';
import 'package:money_milestone/screens/widgets/fadeSlideIn.dart';
import 'package:money_milestone/utils/app_colors_extension.dart';
import 'package:money_milestone/utils/constant.dart';
import 'package:money_milestone/utils/databaseHelper.dart';
import 'package:money_milestone/utils/languageString.dart';
import 'package:money_milestone/utils/stringExtensions.dart';
import 'package:money_milestone/utils/utils.dart';

class GoalDetailsScreen extends StatefulWidget {
  GoalModel goalDetails;

  GoalDetailsScreen({
    super.key,
    required this.goalDetails,
  });

  static Route route(final RouteSettings routeSettings) {
    Map<String, dynamic> arguments =
        routeSettings.arguments as Map<String, dynamic>;
    return MaterialPageRoute(
      builder: (final _) => GoalDetailsScreen(
        goalDetails: arguments["goalDetails"],
      ),
    );
  }

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen>
    with SingleTickerProviderStateMixin {
  Stream<List<Map<String, dynamic>>>? _transactionsStream;

  double _goalPercentage = 0.0;
  late ConfettiController _confettiController;

  @override
  void initState() {
    _transactionsStream = Supabase.instance.client
        .from(DatabaseHelper.transactionsCollectionName)
        .stream(primaryKey: ['id'])
        .eq('goal_id', widget.goalDetails.id.toString());

    double savedAmount = (widget.goalDetails.goalSavedAmount ?? "0").toDouble();
    double totalAmount = widget.goalDetails.goalAmount.toString().toDouble();
    _goalPercentage = (savedAmount * 100) / totalAmount;

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    if (_goalPercentage >= 100) {
      _confettiController.play();
    }

    ClarityService.setScreen('GoalDetails');
    ClarityService.logGoalViewed(
        goalName: widget.goalDetails.goalName.toString());

    super.initState();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  int daysBetween({required DateTime fromDate, required DateTime toDate}) {
    fromDate = DateTime(fromDate.year, fromDate.month, fromDate.day);
    toDate = DateTime(toDate.year, toDate.month, toDate.day);
    return (toDate.difference(fromDate).inHours / 24).round();
  }

  String convertDaysToMonths({required int days}) {
    if (days <= 0) return "";
    int months = days ~/ 30;
    int remainingDays = days % 30;
    String value = "";
    if (months > 0 && remainingDays > 0) {
      value =
          '$months ${LanguageStrings.lblMonths} ${LanguageStrings.lblAnd} $remainingDays ${LanguageStrings.lblDays}';
    } else if (months > 0) {
      value = '$months ${LanguageStrings.lblMonths}';
    } else {
      value = '$days ${LanguageStrings.lblDays}';
    }
    return "$value ${LanguageStrings.lblRemaining}";
  }

  // ── Progress ring card ────────────────────────────────────────────────────
  Widget _getGoalAmountWidget() {
    final pct = _goalPercentage.clamp(0, 100);
    Color progressColor;
    if (pct >= 70) {
      progressColor = context.colors.greenColor;
    } else if (pct >= 40) {
      progressColor = context.colors.goldColor;
    } else {
      progressColor = context.colors.redColor;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.colors.cardGlassColor,
            border: Border.all(color: context.colors.cardBorderColor, width: 1.2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            child: Column(
              children: [
                // Circular ring + percent
                SizedBox(
                  height: 168,
                  width: 168,
                  child: Stack(
                    children: [
                      // Animated ring
                      CustomTweenAnimation(
                        curve: Curves.easeOut,
                        beginValue: 0,
                        endValue: _goalPercentage / 100,
                        durationInSeconds:
                            Constant.goalPercentageAnimationDuration,
                        builder: (context, value, _) => SizedBox(
                          height: 168,
                          width: 168,
                          child: CircularProgressIndicator(
                            backgroundColor: context.colors.isDarkMode
                                ? Colors.white.withValues(alpha: 0.06)
                                : const Color(0xffE8EAFF),
                            strokeWidth: 14,
                            strokeCap: StrokeCap.round,
                            value: value,
                            color: progressColor,
                          ),
                        ),
                      ),
                      // Center content
                      CustomTweenAnimation(
                        curve: Curves.easeOut,
                        beginValue: 0,
                        endValue: _goalPercentage,
                        durationInSeconds:
                            Constant.goalPercentageAnimationDuration,
                        builder: (context, value, _) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${value.toStringAsFixed(0)}%",
                                style: TextStyle(
                                  color: context.colors.blackColors,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 38,
                                  letterSpacing: -1.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                LanguageStrings.lblSavedAmount,
                                style: TextStyle(
                                  color: context.colors.lightGreyColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Big saved amount
                CustomTweenAnimation(
                  beginValue: 0,
                  endValue: double.parse(
                      widget.goalDetails.goalSavedAmount ?? "0"),
                  curve: Curves.easeOut,
                  durationInSeconds: Constant.goalPercentageAnimationDuration,
                  builder: (context, value, child) {
                    return Text(
                      value.toString().currency(),
                      style: TextStyle(
                        fontSize: 32,
                        color: context.colors.blackColors,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
                Container(height: 1, color: context.colors.cardBorderColor),
                const SizedBox(height: 18),

                // Total / Remaining
                Row(
                  children: [
                    Expanded(
                      child: _statTile(
                        label: LanguageStrings.lblTotalAmount,
                        value: widget.goalDetails.goalAmount
                            .toString()
                            .currency(),
                        iconColor: context.colors.accentColor,
                        icon: Icons.track_changes_rounded,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: context.colors.cardBorderColor,
                    ),
                    Expanded(
                      child: _statTile(
                        label: LanguageStrings.lblRemainingAmount,
                        value:
                            "${(double.parse(widget.goalDetails.goalAmount.toString()) - double.parse(widget.goalDetails.goalSavedAmount ?? "0"))}".currency(),
                        iconColor: progressColor,
                        icon: Icons.hourglass_bottom_rounded,
                        alignRight: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statTile({
    required String label,
    required String value,
    required Color iconColor,
    required IconData icon,
    bool alignRight = false,
  }) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!alignRight)
              Icon(icon, size: 13, color: iconColor),
            if (!alignRight) const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                  color: context.colors.lightGreyColor, fontSize: 11),
            ),
            if (alignRight) const SizedBox(width: 4),
            if (alignRight) Icon(icon, size: 13, color: iconColor),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: context.colors.blackColors,
            fontSize: 15,
            letterSpacing: -0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ── Add / Withdraw buttons ────────────────────────────────────────────────
  Widget _getSaveAndWithdrawButtonWidget() {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            label: LanguageStrings.lblAdd,
            icon: Icons.add_rounded,
            gradient: [
              context.colors.greenColor.withValues(alpha: 0.85),
              context.colors.greenColor,
            ],
            onTap: () {
              double remainingAmount =
                  widget.goalDetails.goalAmount.toString().toDouble() -
                      (widget.goalDetails.goalSavedAmount ?? "0").toDouble();
              if (remainingAmount <= 0.0) {
                Utils.showMessage(context,
                    LanguageStrings.lblAlreadyAchievedAmount, MessageType.success);
                return;
              }
              Utils.showPremiumSheet(
                  context: context,
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider(
                          create: (context) => AddOrWithdrawMoneyCubit(
                              TransactionRepository())),
                      BlocProvider(
                          create: (context) =>
                              UpdateGoalCubit(GoalRepository())),
                    ],
                    child: AddOrWithdrawMoneyDialog(
                      goalDetails: widget.goalDetails,
                      title: LanguageStrings.lblAdd,
                    ),
                  )).then((value) {
                if (value != null) {
                  Map<String, dynamic> data = value as Map<String, dynamic>;
                  widget.goalDetails =
                      widget.goalDetails.copyWith(amount: data["savedAmount"]);
                  double savedAmount =
                      (widget.goalDetails.goalSavedAmount ?? "0").toDouble();
                  double totalAmount =
                      widget.goalDetails.goalAmount.toString().toDouble();
                  _goalPercentage = (savedAmount * 100) / totalAmount;
                  if (_goalPercentage >= 100) {
                    _confettiController.play();
                    ClarityService.logGoalCompleted(
                        goalName: widget.goalDetails.goalName.toString());
                  }
                  setState(() {});
                  AdService.instance.showInterstitialOnTransaction();
                }
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(
            label: LanguageStrings.lblWithdraw,
            icon: Icons.remove_rounded,
            gradient: [
              context.colors.redColor.withValues(alpha: 0.85),
              context.colors.redColor,
            ],
            onTap: () {
              if (widget.goalDetails.goalSavedAmount.toString().toDouble() <=
                  0.0) {
                Utils.showMessage(
                    context,
                    LanguageStrings.lblDoNotHaveSufficientAmountToWithdraw,
                    MessageType.error);
                return;
              }
              Utils.showPremiumSheet(
                  context: context,
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider(
                          create: (context) => AddOrWithdrawMoneyCubit(
                              TransactionRepository())),
                      BlocProvider(
                          create: (context) =>
                              UpdateGoalCubit(GoalRepository())),
                    ],
                    child: AddOrWithdrawMoneyDialog(
                      goalDetails: widget.goalDetails,
                      title: LanguageStrings.lblWithdraw,
                    ),
                  )).then((value) {
                if (value != null) {
                  Map<String, dynamic> data = value as Map<String, dynamic>;
                  widget.goalDetails =
                      widget.goalDetails.copyWith(amount: data["savedAmount"]);
                  double savedAmount =
                      (widget.goalDetails.goalSavedAmount ?? "0").toDouble();
                  double totalAmount =
                      widget.goalDetails.goalAmount.toString().toDouble();
                  _goalPercentage = (savedAmount * 100) / totalAmount;
                  setState(() {});
                  AdService.instance.showInterstitialOnTransaction();
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Achievement date ──────────────────────────────────────────────────────
  Widget _getGoalAchievementDateWidget() {
    final isAchieved = _goalPercentage >= 100;
    final targetDate = DateTime.parse(
        "${widget.goalDetails.goalDate.toString()} 00:00:00");
    final now = DateTime.now();
    final daysLeft = daysBetween(fromDate: now, toDate: targetDate);

    // ── Determine chip label + colours ────────────────────────────────────
    String chipLabel;
    Color chipColor;
    IconData statusIcon;
    String dateLabel;

    if (isAchieved) {
      if (daysLeft > 0) {
        // Completed BEFORE target date
        chipLabel = "${convertDaysToMonths(days: daysLeft)} early 🎉";
        chipColor = context.colors.greenColor;
        statusIcon = Icons.emoji_events_rounded;
        dateLabel = "Achieved before target";
      } else if (daysLeft == 0) {
        // Completed exactly ON target date
        chipLabel = "Right on time 🎯";
        chipColor = context.colors.accentColor;
        statusIcon = Icons.check_circle_rounded;
        dateLabel = "Achieved on target date";
      } else {
        // Completed AFTER target date
        final daysLate = daysLeft.abs();
        chipLabel = "${convertDaysToMonths(days: daysLate)} late";
        chipColor = context.colors.lightGreyColor;
        statusIcon = Icons.check_rounded;
        dateLabel = "Achieved (past target)";
      }
    } else {
      // Goal still in progress
      final timeLabel = convertDaysToMonths(days: daysLeft);
      if (daysLeft < 0) {
        chipLabel = "Overdue by ${convertDaysToMonths(days: daysLeft.abs())}";
        chipColor = context.colors.redColor;
        statusIcon = Icons.warning_amber_rounded;
        dateLabel = LanguageStrings.lblGoalAchievementDate;
      } else if (timeLabel.isNotEmpty) {
        chipLabel = timeLabel;
        chipColor = context.colors.goldColor;
        statusIcon = Icons.calendar_month_rounded;
        dateLabel = LanguageStrings.lblGoalAchievementDate;
      } else {
        chipLabel = "";
        chipColor = context.colors.goldColor;
        statusIcon = Icons.calendar_month_rounded;
        dateLabel = LanguageStrings.lblGoalAchievementDate;
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.cardGlassColor,
            border: Border.all(
                color: isAchieved
                    ? chipColor.withValues(alpha: 0.3)
                    : context.colors.cardBorderColor,
                width: 1.2),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: chipColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: chipColor.withValues(alpha: 0.3)),
                ),
                child: Icon(
                  statusIcon,
                  size: 18,
                  color: chipColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateLabel,
                      style: TextStyle(
                        color: context.colors.lightGreyColor,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.goalDetails.goalDate.toString(),
                      style: TextStyle(
                        color: context.colors.blackColors,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              if (chipLabel.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: chipColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: chipColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    chipLabel,
                    style: TextStyle(
                      color: chipColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Smart savings suggestions ─────────────────────────────────────────────
  Widget _getSmartSavingSuggestionsWidget() {
    int remainingDays = daysBetween(
        fromDate: DateTime.now(),
        toDate: DateTime.parse(
            "${widget.goalDetails.goalDate.toString()} 00:00:00"));

    double remainingAmount =
        double.parse(widget.goalDetails.goalAmount.toString()) -
            double.parse(widget.goalDetails.goalSavedAmount ?? "0");

    // Deadline passed or goal already met — nothing meaningful to suggest.
    if (remainingDays <= 0 || remainingAmount <= 0) return const SizedBox.shrink();

    double saveAmountPerDay = remainingAmount / remainingDays;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.cardGlassColor,
            border: Border.all(color: context.colors.cardBorderColor, width: 1.2),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.colors.accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: context.colors.accentColor.withValues(alpha: 0.25)),
                    ),
                    child: Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 16,
                      color: context.colors.accentColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LanguageStrings.lblSmartSavingsTips,
                          style: TextStyle(
                            color: context.colors.blackColors,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          LanguageStrings
                              .lblToAchieveTheGoalByTheTargetDateYouShouldSave,
                          style: TextStyle(
                            color: context.colors.lightGreyColor,
                            fontSize: 11,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(height: 1, color: context.colors.cardBorderColor),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _savingPill(
                    label: LanguageStrings.lblDaily,
                    amount: saveAmountPerDay.toString().currency(),
                    icon: Icons.today_rounded,
                  ),
                  if (remainingDays > 7) ...[
                    Container(
                        width: 1, height: 32, color: context.colors.cardBorderColor),
                    _savingPill(
                      label: LanguageStrings.lblWeekly,
                      amount: (saveAmountPerDay * 7).toString().currency(),
                      icon: Icons.date_range_rounded,
                    ),
                  ],
                  if (remainingDays > 30) ...[
                    Container(
                        width: 1, height: 32, color: context.colors.cardBorderColor),
                    _savingPill(
                      label: LanguageStrings.lblMonthly,
                      amount: (saveAmountPerDay * 30).toString().currency(),
                      icon: Icons.calendar_view_month_rounded,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _savingPill(
      {required String label,
      required String amount,
      required IconData icon}) {
    return Column(
      children: [
        Icon(icon, size: 18, color: context.colors.accentColor),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            color: context.colors.blackColors,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: context.colors.lightGreyColor,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ── Transaction row ───────────────────────────────────────────────────────
  Widget _getTransactionDetailsWidget(
      {required TransactionModel transactionDetails}) {
    final isDebit = transactionDetails.transactionType == "debit";
    final txColor =
        isDebit ? context.colors.redColor : context.colors.greenColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.colors.cardGlassColor,
              border: Border.all(
                  color: context.colors.cardBorderColor, width: 1.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: txColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: txColor.withValues(alpha: 0.2)),
                  ),
                  child: Icon(
                    isDebit
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    color: txColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (transactionDetails.transactionNote ?? "").isNotEmpty
                            ? transactionDetails.transactionNote.toString()
                            : (isDebit
                                ? LanguageStrings.lblWithdraw
                                : LanguageStrings.lblAdd),
                        style: TextStyle(
                          color: context.colors.blackColors,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        DateFormat(Constant.dateFormat).format(DateTime.parse(
                            transactionDetails.transactionDate.toString())),
                        style: TextStyle(
                          fontSize: 11,
                          color: context.colors.lightGreyColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: txColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${isDebit ? "−" : "+"} ${transactionDetails.transactionAmount.toString().currency()}",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: txColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getTransactionHistory() {
    return StreamBuilder(
      stream: _transactionsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasError) {
            return Text(LanguageStrings.lblSomethingWentWrong);
          }
          if (snapshot.hasData) {
            List<Map<String, dynamic>> transactionData = snapshot.data!;

            if (transactionData.isNotEmpty) {
              List<TransactionModel> parsedTransactions = [];
              for (var data in transactionData) {
                parsedTransactions.add(TransactionModel.fromJson(data));
              }

              // Build transaction rows, inserting a banner after every 4th entry
              final txWidgets = <Widget>[];
              for (int i = 0; i < parsedTransactions.length; i++) {
                txWidgets.add(_getTransactionDetailsWidget(
                    transactionDetails: parsedTransactions[i]));
                if ((i + 1) % 4 == 0 && i + 1 < parsedTransactions.length) {
                  txWidgets.add(const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: BannerAdWidget(),
                  ));
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                      ProgressChartWidget(
                        transactions: parsedTransactions,
                        goalAmount: double.parse(
                            widget.goalDetails.goalAmount.toString()),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        LanguageStrings.lblTransactions,
                        style: TextStyle(
                          color: context.colors.blackColors,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ] +
                    txWidgets,
              );
            } else {
              return const SizedBox.shrink();
            }
          } else {
            return const SizedBox.shrink();
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
              children: List.generate(
                  Constant.numberOfShimmerLoadingWidget,
                  (index) => CustomShimmerLoadingWidget(
                        height: 70,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                      )).toList());
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _getAppreciationTextWidget() {
    if (_goalPercentage >= 100) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.colors.greenColor.withValues(alpha: 0.15),
              context.colors.greenColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.greenColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.emoji_events_rounded,
                color: context.colors.goldColor, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                LanguageStrings.lblGoalAchievedText,
                style: TextStyle(
                  color: context.colors.greenColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: context.colors.accentColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.accentColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.trending_up_rounded,
              color: context.colors.accentColor, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LanguageStrings.lblCongrats,
                style: TextStyle(
                  color: context.colors.blackColors,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                LanguageStrings.lblYourProgressAreGrowingUp,
                style: TextStyle(
                  color: context.colors.lightGreyColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetDate = DateTime.parse(
        "${widget.goalDetails.goalDate.toString()} 00:00:00");
    final daysLeft = daysBetween(fromDate: DateTime.now(), toDate: targetDate);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: false,
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
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: context.colors.blackColors,
            ),
          ),
        ),
        title: Text(
          LanguageStrings.lblGoalDetails,
          style: TextStyle(
            color: context.colors.blackColors,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.4,
          ),
        ),
      ),
      bottomNavigationBar: BannerAdWidget(),
      body: Stack(
        children: [
          BackgroundWidget(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.goalDetails.goalSavedAmount.toString().toDouble() > 0) ...[
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 0),
                        child: _getAppreciationTextWidget(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 80),
                      child: _getGoalAmountWidget(),
                    ),
                    const SizedBox(height: 12),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 160),
                      child: _getGoalAchievementDateWidget(),
                    ),
                    const SizedBox(height: 12),
                    // Show tips only when: goal unfinished (with float margin),
                    // deadline is still in the future, and remaining amount > 0.
                    if (_goalPercentage < 99.99 && daysLeft > 0) ...[
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 220),
                        child: _getSmartSavingSuggestionsWidget(),
                      ),
                      const SizedBox(height: 14),
                    ],
                    const SizedBox(height: 14),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 280),
                      offset: 12,
                      child: _getSaveAndWithdrawButtonWidget(),
                    ),
                    const SizedBox(height: 14),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 340),
                      child: _getTransactionHistory(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Color(0xff6C47FF),
                Color(0xffF5A623),
                Color(0xff34D399),
                Colors.pink,
                Colors.white,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
