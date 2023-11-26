// ignore_for_file: use_build_context_synchronously



import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:money_milestone/data/repository/authRepository.dart';
import 'package:money_milestone/data/repository/goalRepository.dart';
import 'package:money_milestone/data/repository/hiveRepository.dart';
import 'package:money_milestone/screens/widgets/addGoalDialog.dart';
import 'package:money_milestone/screens/widgets/customRoundedButton.dart';
import 'package:money_milestone/screens/widgets/customTweenAnimation.dart';
import 'package:money_milestone/screens/widgets/customerShimmerWidget.dart';
import 'package:money_milestone/utils/colors.dart';
import 'package:money_milestone/utils/constant.dart';
import 'package:money_milestone/utils/contextExtensions.dart';
import 'package:money_milestone/utils/databaseHelper.dart';
import 'package:money_milestone/utils/assets.dart';
import 'package:money_milestone/utils/languageString.dart';
import 'package:money_milestone/utils/stringExtensions.dart';
import 'package:money_milestone/utils/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static Route route(final RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (final _) => BlocProvider(
          create: (BuildContext context) => DeleteGoalCubit(GoalRepository()),
          child: const HomeScreen()),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  Stream<QuerySnapshot>? _goalsStream;

  final databaseReference = FirebaseFirestore.instance;


  @override
  void initState() {
    super.initState();
    //
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

  Widget _getGoalDetailsWidget(GoalModel goalDetails) {
    //
    double goalPercentage = 0.0;
    double savedAmount = double.parse(goalDetails.goalSavedAmount ?? "0");
    double totalAmount = double.parse(goalDetails.goalAmount.toString());
    goalPercentage = (savedAmount * 100) / totalAmount;

    return InkWell(
      onTap: () async {
        context.pushNamed(Routes.goalDetailsScreen, arguments: {
          "goalDetails": goalDetails,
        });
      },
      child: Card(
        //surfaceTintColor: AppColors.whiteColors,
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      goalDetails.goalName.toString(),
                      style: const TextStyle(
                        color: AppColors.blackColors,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton(
                    color: AppColors.accentColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.only(
                        topStart: Radius.circular(10),
                        bottomEnd: Radius.circular(10),
                        bottomStart: Radius.circular(10),
                      ),
                    ),
                    padding: EdgeInsets.zero,
                    iconSize: 24,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                          onTap: () {
                            _showAddGoalDialog(goalDetails);
                          },
                          value: 1,
                          child: const Text(
                            LanguageStrings.lblEdit,
                            style: TextStyle(color: AppColors.whiteColors),
                          )),
                      PopupMenuItem(
                          onTap: () {
                            String userId = HiveRepository.getUserId ?? "";
                            context.read<DeleteGoalCubit>().deleteGoal(
                                goalDetails: goalDetails, userId: userId);
                          },
                          value: 2,
                          child: const Text(
                            LanguageStrings.lblDelete,
                            style: TextStyle(color: AppColors.whiteColors),
                          ))
                    ],
                    child: Icon(
                      Icons.more_vert,
                      color: AppColors.lightGreyColor,
                      size: 20,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Divider(
                color: AppColors.lightGreyColor,
                height: 1,
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  CustomTweenAnimation(
                    curve: Curves.linear,
                    beginValue: 0,
                    endValue: goalPercentage / 100,
                    durationInSeconds: Constant.goalPercentageAnimationDuration,
                    builder: (context, value, _) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      height: 10,
                      width: context.width * 0.75,
                      child: LinearProgressIndicator(
                        borderRadius: BorderRadius.circular(50),
                        backgroundColor: AppColors.whiteColors,
                        value: value,
                        color: value > 0.7
                            ? Colors.green
                            : value > 0.4
                                ? Colors.yellow
                                : Colors.red,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      "${(goalPercentage.toStringAsFixed(0))}%",
                      style: TextStyle(
                          fontSize: 12, color: AppColors.lightGreyColor),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.money_outlined,
                        color: AppColors.lightGreyColor,
                        size: 15,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        "${(goalDetails.goalSavedAmount ?? "0").toString().currency()}/${goalDetails.goalAmount.toString().currency()}",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.lightGreyColor,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        color: AppColors.lightGreyColor,
                        size: 15,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        DateFormat(Constant.dateFormat).format(
                            DateTime.parse(goalDetails.goalDate.toString())),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.lightGreyColor,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _setYourFirstGoalWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            Assets.noGoalAnimation,
            height: 250,
            width: 250,
          ),
          const Text(
            LanguageStrings.lblSetYourGoal,
            style: TextStyle(
                color: AppColors.blackColors,
                fontWeight: FontWeight.bold,
                fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            LanguageStrings.lblSetYourGoalDescription,
            style: TextStyle(
                color: AppColors.blackColors,
                fontWeight: FontWeight.w500,
                fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 20,
          ),
          CustomRoundedButton(
              onTap: () {
                _showAddGoalDialog();
              },
              titleColor: AppColors.whiteColors,
              buttonTitle: LanguageStrings.lblAddGoal,
              showBorder: false,
              widthPercentage: 1)
        ],
      ),
    );
  }

  void _showAddGoalDialog([GoalModel? goalDetails]) {
    Utils.showAnimatedDialog(
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
          child:  AddGoalDialog(goalDetails: goalDetails),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        title: const Text(Constant.appName),
        actions: [
          Tooltip(
            message: LanguageStrings.lblLogout,
            child: IconButton(
              onPressed: () {
                AuthRepository().signOut().then((value) {
                  //clear store details from hive db
                  HiveRepository.clearBoxValues(
                      boxName: HiveRepository.authStatusBoxKey);
                  HiveRepository.clearBoxValues(
                      boxName: HiveRepository.userDetailBoxKey);
                  //
                  return context.pushReplacementNamed(Routes.logInScreen);
                });
              },
              icon: const Icon(Icons.logout_outlined),
            ),
          )
        ],
      ),
      body: BlocListener<DeleteGoalCubit, DeleteGoalState>(
        listener: (context, state) {
          if (state is DeleteGoalFailure) {
            Utils.showMessage(context, state.errorMessage, MessageType.error);
          } else if (state is DeleteGoalSuccess) {
            Utils.showMessage(
                context,
                LanguageStrings.lblGoalDeletedSuccessfully,
                MessageType.success);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                LanguageStrings.lblHello,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackColors,
                ),
              ),
              Text(
                HiveRepository.getUsername ?? "",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackColors,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              StreamBuilder(
                stream: _goalsStream,
                builder: (context, snapshot) {
                  //connection established and active
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasError) {
                      return const Text("error here");
                    }
                    if (snapshot.hasData) {
                      List<DocumentSnapshot?> goalsData = snapshot.data!.docs;

                      if (goalsData.isNotEmpty) {
                        return Column(
                          children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      LanguageStrings.lblMyGoals,
                                      style: TextStyle(
                                          color: AppColors.accentColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24),
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      child: const Text(
                                        LanguageStrings.lblAddGoal,
                                        style: TextStyle(
                                            color: AppColors.blackColors,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            decoration:
                                                TextDecoration.underline),
                                      ),
                                      onTap: () {
                                        _showAddGoalDialog();
                                      },
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                              ] +
                              List<Widget>.generate(goalsData.length, (index) {
                                Map<String, dynamic> data = Map.from(
                                    goalsData[index]!.data()
                                        as Map<String, dynamic>);
                                data["id"] = goalsData[index]!.id;
                                GoalModel goalDetails =
                                    GoalModel.fromJson(data);
                                //

                                return _getGoalDetailsWidget(goalDetails);
                              }),
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
                            (index) => const CustomShimmerLoadingWidget(
                                  height: 70,
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                )).toList());
                  } else {
                    return Container();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
