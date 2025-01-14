import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money_milestone/cubits/addOrWithdrawMoneyCubit.dart';
import 'package:money_milestone/cubits/updateGoalCubit.dart';
import 'package:money_milestone/data/model/goalModal.dart';
import 'package:money_milestone/data/model/transactionModel.dart';
import 'package:money_milestone/data/repository/goalRepository.dart';
import 'package:money_milestone/data/repository/hiveRepository.dart';
import 'package:money_milestone/data/repository/transactionRepository.dart';
import 'package:money_milestone/screens/widgets/addOrWithdrawMonetDialogWidget.dart';
import 'package:money_milestone/screens/widgets/bannerAdWidget.dart';
import 'package:money_milestone/screens/widgets/customRoundedButton.dart';
import 'package:money_milestone/screens/widgets/customTweenAnimation.dart';
import 'package:money_milestone/screens/widgets/customerShimmerWidget.dart';
import 'package:money_milestone/utils/colors.dart';
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
    //
    Map<String, dynamic> arguments =
        routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(
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
  Stream<QuerySnapshot>? _transactionsStream;

  double _goalPercentage = 0.0;

  @override
  void initState() {
    String userId = HiveRepository.getUserId ?? "";

    _transactionsStream = FirebaseFirestore.instance
        .collection(DatabaseHelper.transactionsCollectionName)
        .doc(userId)
        .collection(widget.goalDetails.id.toString())
        .snapshots();

    double savedAmount = (widget.goalDetails.goalSavedAmount ?? "0").toDouble();
    double totalAmount = widget.goalDetails.goalAmount.toString().toDouble();
    _goalPercentage = (savedAmount * 100) / totalAmount;

    super.initState();
  }

  int daysBetween({required DateTime fromDate, required DateTime toDate}) {
    fromDate = DateTime(fromDate.year, fromDate.month, fromDate.day);
    toDate = DateTime(toDate.year, toDate.month, toDate.day);
    return (toDate.difference(fromDate).inHours / 24).round();
  }

  String convertDaysToMonths({required int days}) {
    if (days <= 0) {
      return "";
    }

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

  Widget _getTitleAndValue({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: AppColors.primaryColor, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
        Text(
          value,
          style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.whiteColors,
              fontSize: 18),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      ],
    );
  }

  Widget _getGoalAmountWidget() {
    //
    return Container(
      decoration: BoxDecoration(
          gradient: Utils.gradiant(), borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: Center(
                child: Stack(
                  children: [
                    CustomTweenAnimation(
                      curve: Curves.linear,
                      beginValue: 0,
                      endValue: _goalPercentage,
                      durationInSeconds:
                          Constant.goalPercentageAnimationDuration,
                      builder: (context, value, _) => SizedBox(
                        height: 80,
                        width: 80,
                        child: Center(
                            child: Text(
                          "${value.toStringAsFixed(0)}%",
                          style: TextStyle(
                              color: value > 70
                                  ? Colors.green
                                  : value > 40
                                      ? Colors.yellow
                                      : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 24),
                        )),
                      ),
                    ),
                    CustomTweenAnimation(
                      curve: Curves.linear,
                      beginValue: 0,
                      endValue: _goalPercentage / 100,
                      durationInSeconds:
                          Constant.goalPercentageAnimationDuration,
                      builder: (context, value, _) => SizedBox(
                        height: 80,
                        width: 80,
                        child: CircularProgressIndicator(
                          backgroundColor: AppColors.primaryColor,
                          strokeWidth: 10,
                          strokeCap: StrokeCap.round,
                          value: value,
                          color: value > 0.7
                              ? Colors.green
                              : value > 0.4
                                  ? Colors.yellow
                                  : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    LanguageStrings.lblSavedAmount,
                    style:
                        TextStyle(color: AppColors.primaryColor, fontSize: 12),
                  ),
                  CustomTweenAnimation(
                    beginValue: 0,
                    endValue:
                        double.parse(widget.goalDetails.goalSavedAmount ?? "0"),
                    curve: Curves.linear,
                    durationInSeconds: Constant.goalPercentageAnimationDuration,
                    builder: (context, value, child) {
                      return Text(
                        value.toString().currency(),
                        style: const TextStyle(
                            fontSize: 24,
                            color: AppColors.whiteColors,
                            fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _getTitleAndValue(
                            title: LanguageStrings.lblTotalAmount,
                            value: widget.goalDetails.goalAmount
                                .toString()
                                .currency()),
                      ),
                      Expanded(
                        child: _getTitleAndValue(
                            title: LanguageStrings.lblRemainingAmount,
                            value:
                                "${(double.parse(widget.goalDetails.goalAmount.toString()) - double.parse(widget.goalDetails.goalSavedAmount ?? "0"))}"
                                    .currency()),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _getSaveAndWithdrawButtonWidget() {
    return Row(
      children: [
        Expanded(
          child: CustomRoundedButton(
            buttonTitle: LanguageStrings.lblAdd,
            showBorder: false,
            widthPercentage: 1,
            height: 40,
            titleColor: AppColors.whiteColors,
            backgroundColor: AppColors.greenColor.withOpacity(0.7),
            onTap: () {
              double remainingAmount =
                  widget.goalDetails.goalAmount.toString().toDouble() -
                      (widget.goalDetails.goalSavedAmount ?? "0").toDouble();

              if (remainingAmount <= 0.0) {
                return Utils.showMessage(
                    context,
                    LanguageStrings.lblAlreadyAchievedAmount,
                    MessageType.success);
              }
              Utils.showAnimatedDialog(
                  context: context,
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (context) =>
                            AddOrWithdrawMoneyCubit(TransactionRepository()),
                      ),
                      BlocProvider(
                        create: (context) => UpdateGoalCubit(GoalRepository()),
                      )
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

                  setState(() {});
                }
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CustomRoundedButton(
            buttonTitle: LanguageStrings.lblWithdraw,
            showBorder: false,
            widthPercentage: 1,
            height: 40,
            titleColor: AppColors.whiteColors,
            backgroundColor: AppColors.redColor.withOpacity(0.7),
            onTap: () {
              if (widget.goalDetails.goalSavedAmount.toString().toDouble() <=
                  0.0) {
                return Utils.showMessage(
                    context,
                    LanguageStrings.lblDoNotHaveSufficientAmountToWithdraw,
                    MessageType.error);
              }
              Utils.showAnimatedDialog(
                  context: context,
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (context) =>
                            AddOrWithdrawMoneyCubit(TransactionRepository()),
                      ),
                      BlocProvider(
                        create: (context) => UpdateGoalCubit(GoalRepository()),
                      )
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
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _getGoalAchievementDateWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.secondaryColor,
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 20,
            color: AppColors.lightGreyColor,
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                    text: widget.goalDetails.goalDate.toString(),
                    children: [
                      TextSpan(
                          text:
                              " (${convertDaysToMonths(days: daysBetween(fromDate: DateTime.now(), toDate: DateTime.parse("${widget.goalDetails.goalDate.toString()} 00:00:00")))})",
                          style: const TextStyle(
                              color: AppColors.blackColors, fontSize: 12))
                    ]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
              Text(
                LanguageStrings.lblGoalAchievementDate,
                style: TextStyle(
                  color: AppColors.lightGreyColor,
                  fontSize: 12,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _getAmountSuggestionWidget(
      {required String title, required String amount}) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: AppColors.blackColors),
        ),
        Text(
          amount,
          style: const TextStyle(color: AppColors.blackColors),
        ),
      ],
    );
  }

  Widget _getSmartSavingSuggestionsWidget() {
    int remainingDaysToAchieveGoal = daysBetween(
        fromDate: DateTime.now(),
        toDate: DateTime.parse(
            "${widget.goalDetails.goalDate.toString()} 00:00:00"));

    //
    double remainingAmount =
        double.parse(widget.goalDetails.goalAmount.toString()) -
            double.parse(widget.goalDetails.goalSavedAmount ?? "0");
    double saveAmountPerDay = remainingAmount / remainingDaysToAchieveGoal;

    return Container(
      decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            LanguageStrings.lblSmartSavingsTips,
            style: TextStyle(
                color: AppColors.blackColors,
                fontSize: 18,
                fontWeight: FontWeight.w500),
          ),
          Text(
            LanguageStrings.lblToAchieveTheGoalByTheTargetDateYouShouldSave,
            style: TextStyle(
                color: AppColors.lightGreyColor,
                fontSize: 12,
                fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _getAmountSuggestionWidget(
                  amount: saveAmountPerDay.toString().currency(),
                  title: LanguageStrings.lblDaily),
              if (remainingDaysToAchieveGoal > 7) ...[
                Container(
                  height: 30,
                  width: 1,
                  color: AppColors.lightGreyColor,
                ),
                _getAmountSuggestionWidget(
                    amount: (saveAmountPerDay * 7).toString().currency(),
                    title: LanguageStrings.lblWeekly),
              ],
              if (remainingDaysToAchieveGoal > 30) ...[
                Container(
                  height: 30,
                  width: 1,
                  color: AppColors.lightGreyColor,
                ),
                _getAmountSuggestionWidget(
                    amount: (saveAmountPerDay * 30).toString().currency(),
                    title: LanguageStrings.lblMonthly),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _getTransactionDetailsWidget(
      {required TransactionModel transactionDetails}) {
    return Card(
      surfaceTintColor: transactionDetails.transactionType == "debit"
          ? AppColors.redColor.withOpacity(0.5)
          : AppColors.greenColor.withOpacity(0.5),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 12,
                      color: AppColors.lightGreyColor,
                    ),
                    Text(
                      DateFormat(Constant.dateFormat).format(
                        DateTime.parse(
                          transactionDetails.transactionDate.toString(),
                        ),
                      ),
                      style: TextStyle(
                          fontSize: 12, color: AppColors.lightGreyColor),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  "${transactionDetails.transactionType == "debit" ? "-" : "+"} ${transactionDetails.transactionAmount.toString().currency()}",
                  style: TextStyle(
                    color: transactionDetails.transactionType == "debit"
                        ? AppColors.redColor
                        : AppColors.greenColor,
                  ),
                ),
              ],
            ),
            if ((transactionDetails.transactionNote ?? "").isNotEmpty) ...[
              const SizedBox(
                height: 5,
              ),
              Text(
                transactionDetails.transactionNote.toString(),
                style:
                    const TextStyle(color: AppColors.blackColors, fontSize: 14),
              ),
            ],
            const SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getTransactionHistory() {
    return StreamBuilder(
      stream: _transactionsStream,
      builder: (context, snapshot) {
        //connection established and active
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasError) {
            return const Text(LanguageStrings.lblSomethingWentWrong);
          }
          if (snapshot.hasData) {
            List<DocumentSnapshot?> transactionData = snapshot.data!.docs;

            if (transactionData.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                      const Text(
                        LanguageStrings.lblTransactions,
                        style: TextStyle(
                            color: AppColors.accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ] +
                    List<Widget>.generate(transactionData.length, (index) {
                      Map<String, dynamic> data = Map.from(
                          transactionData[index]!.data()
                              as Map<String, dynamic>);
                      data["id"] = transactionData[index]!.id;
                      TransactionModel transactionDetails =
                          TransactionModel.fromJson(data);
                      //
                      return _getTransactionDetailsWidget(
                          transactionDetails: transactionDetails);
                    }),
              );
            } else {
              return Container();
            }
          } else {
            return Container();
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
              children: List.generate(
                  Constant.numberOfShimmerLoadingWidget,
                  (index) => const CustomShimmerLoadingWidget(
                        height: 70,
                        margin: EdgeInsets.symmetric(vertical: 5),
                      )).toList());
        } else {
          return Container();
        }
      },
    );
  }

  Widget _getAppreciationTextWidget() {
    if (_goalPercentage == 100) {
      return const Text(
        LanguageStrings.lblGoalAchievedText,
        style: TextStyle(
            color: AppColors.greenColor,
            fontSize: 16,
            fontWeight: FontWeight.w700),
        softWrap: true,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      );
    }
    return const Column(
      children: [
        Text(
          LanguageStrings.lblCongrats,
          style: TextStyle(
              color: AppColors.blackColors,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 2),
        ),
        Text(
          LanguageStrings.lblYourProgressAreGrowingUp,
          style: TextStyle(
            color: AppColors.blackColors,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        centerTitle: false,
        title: const Text(LanguageStrings.lblGoalDetails),
      ),
      bottomNavigationBar: const BannerAdWidget(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (widget.goalDetails.goalSavedAmount.toString().toDouble() >
                    0) ...[
                  _getAppreciationTextWidget(),
                  const SizedBox(
                    height: 10,
                  ),
                ],
                _getGoalAmountWidget(),
                const SizedBox(
                  height: 10,
                ),
                _getGoalAchievementDateWidget(),
                const SizedBox(
                  height: 10,
                ),
                _getSmartSavingSuggestionsWidget(),
                const SizedBox(
                  height: 10,
                ),
                _getSaveAndWithdrawButtonWidget(),
                const SizedBox(
                  height: 10,
                ),
                _getTransactionHistory(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
