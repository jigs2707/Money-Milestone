// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import 'package:money_milestone/cubits/addGoalCubit.dart';
import 'package:money_milestone/cubits/updateGoalCubit.dart';
import 'package:money_milestone/data/model/goalModal.dart';
import 'package:money_milestone/data/repository/hiveRepository.dart';
import 'package:money_milestone/screens/widgets/customCircularProgressIndicator.dart';
import 'package:money_milestone/screens/widgets/customRoundedButton.dart';
import 'package:money_milestone/screens/widgets/customTextFormfield.dart';
import 'package:money_milestone/utils/colors.dart';
import 'package:money_milestone/utils/constant.dart';
import 'package:money_milestone/utils/contextExtensions.dart';
import 'package:money_milestone/utils/languageString.dart';
import 'package:money_milestone/utils/stringExtensions.dart';
import 'package:money_milestone/utils/utils.dart';

class AddGoalDialog extends StatefulWidget {
  final GoalModel? goalDetails;

  const AddGoalDialog({super.key, this.goalDetails});

  @override
  State<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final TextEditingController _goalNameController = TextEditingController();

  final TextEditingController _goalAmountController = TextEditingController();

  final TextEditingController _goalAchieveDateController =
      TextEditingController();

  final FocusNode _goalAmountFocusNode = FocusNode();

  final FocusNode _goalAchieveDateFocusNode = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? selectedDate;

  @override
  initState() {
    super.initState();
    if (widget.goalDetails != null) {
      _goalNameController.text = widget.goalDetails!.goalName!;
      _goalAmountController.text = widget.goalDetails!.goalAmount!;
      _goalAchieveDateController.text = intl.DateFormat(Constant.dateFormat)
          .format(DateTime.parse("${widget.goalDetails!.goalDate!} 00:00:00"));

      selectedDate = widget.goalDetails!.goalDate;
    }
  }

  _showDatePicker({required BuildContext context}) {
    showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      initialDate: selectedDate != null
          ? DateTime.parse("${widget.goalDetails!.goalDate!} 00:00:00")
          : null,
      lastDate: DateTime.now().add(
        const Duration(days: Constant.showCalenderTillDays),
      ),
    ).then((value) {
      if (value != null) {
        _goalAchieveDateController.text =
            intl.DateFormat(Constant.dateFormat).format(value);
        selectedDate = intl.DateFormat("yyyy-MM-dd").format(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            LanguageStrings.lblAddGoal,
            style: TextStyle(
              color: AppColors.blackColors,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const Divider(
          height: 1,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                CustomTextFormField(
                  controller: _goalNameController,
                  textInputType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  nextFocus: _goalAmountFocusNode,
                  labelText: LanguageStrings.lblGoalName,
                  hintText: LanguageStrings.lblEnterYourGoal,
                  backgroundColor: AppColors.primaryColor,
                  validator: (name) {
                    if (name == null || name.isEmpty) {
                      return LanguageStrings.lblEnterDetails;
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextFormField(
                  controller: _goalAmountController,
                  textInputType: const TextInputType.numberWithOptions(
                      signed: false, decimal: true),
                  textInputAction: TextInputAction.next,
                  nextFocus: _goalAchieveDateFocusNode,
                  allowOnlySingleDecimalPoint: true,
                  labelText: LanguageStrings.lblGoalAmount,
                  hintText: LanguageStrings.lblEnterGoalAmount,
                  backgroundColor: AppColors.primaryColor,
                  validator: (amount) {
                    if (amount == null || amount.isEmpty) {
                      return LanguageStrings.lblEnterDetails;
                    } else if (widget.goalDetails != null) {
                      if (amount.toString().toDouble() <
                          widget.goalDetails!.goalSavedAmount
                              .toString()
                              .toDouble()) {
                        return LanguageStrings
                            .lblAmountCanNotBeLessThanSavedAmount;
                      }
                      return null;
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextFormField(
                  controller: _goalAchieveDateController,
                  textInputAction: TextInputAction.done,
                  nextFocus: _goalAchieveDateFocusNode,
                  allowOnlySingleDecimalPoint: true,
                  isReadOnly: true,
                  labelText: LanguageStrings.lblGoalDate,
                  backgroundColor: AppColors.primaryColor,
                  callback: () {
                    _showDatePicker(context: context);
                  },
                  validator: (date) {
                    if (date == null || date.isEmpty) {
                      return LanguageStrings.lblEnterDetails;
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: CustomRoundedButton(
                buttonTitle: LanguageStrings.lblCancel,
                backgroundColor: AppColors.primaryColor,
                showBorder: false,
                widthPercentage: 1,
                radius: 0,
                onTap: () {
                  context.pop();
                },
                borderRadius:
                    const BorderRadius.only(bottomLeft: Radius.circular(10)),
              ),
            ),
            Expanded(
              child: BlocConsumer<UpdateGoalCubit, UpdateGoalState>(
                listener: (context, updateGoalState) {
                  if (updateGoalState is UpdateGoalSuccess) {
                    Utils.showMessage(
                        context,
                        LanguageStrings.lblGoalUpdatedSuccessfully,
                        MessageType.success);

                    context.pop();
                  } else if (updateGoalState is UpdateGoalFailure) {
                    Utils.showMessage(context, updateGoalState.errorMessage,
                        MessageType.error);
                  }
                },
                builder: (context, updateGoalState) {
                  Widget? child;
                  if (updateGoalState is UpdateGoalInProgress) {
                    child = const CircularProgressIndicator();
                  } else if (updateGoalState is UpdateGoalFailure ||
                      updateGoalState is UpdateGoalSuccess) {
                    child = null;
                  }
                  return BlocConsumer<AddGoalCubit, AddGoalState>(
                    listener: (context, state) {
                      if (state is AddGoalSuccess) {
                        Utils.showMessage(
                            context,
                            LanguageStrings.lblGoalAddedSuccessfully,
                            MessageType.success);
                        context.pop();
                      } else if (state is AddGoalFailure) {
                        Utils.showMessage(
                            context, state.errorMessage, MessageType.error);
                      }
                    },
                    builder: (context, state) {
                      if (state is AddGoalInProgress) {
                        child = const CustomCircularProgressIndicator();
                      } else if (state is AddGoalFailure ||
                          state is AddGoalSuccess) {
                        child = null;
                      }

                      return CustomRoundedButton(
                        buttonTitle: LanguageStrings.lblDone,
                        showBorder: false,
                        widthPercentage: 1,
                        titleColor: AppColors.secondaryColor,
                        radius: 0,
                        borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(10)),
                        onTap: () async {
                          Utils.removeFocus();
                          if (state is AddGoalInProgress) {
                            return;
                          }
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          String userId = HiveRepository.getUserId ?? "";

                          if (widget.goalDetails != null) {
                            context.read<UpdateGoalCubit>().updateGoal(
                                goalDetails: GoalModel(
                                    id: widget.goalDetails!.id,
                                    goalName: _goalNameController.text
                                        .trim()
                                        .toString(),
                                    goalAmount: _goalAmountController.text
                                        .trim()
                                        .toString(),
                                    goalDate: selectedDate,
                                    goalSavedAmount:
                                        widget.goalDetails!.goalSavedAmount),
                                userId: userId);
                          } else {
                            context.read<AddGoalCubit>().addGoal(
                                goalDetails: GoalModel(
                                    id: "",
                                    goalName: _goalNameController.text
                                        .trim()
                                        .toString(),
                                    goalAmount: _goalAmountController.text
                                        .trim()
                                        .toString(),
                                    goalDate: selectedDate,
                                    goalSavedAmount: "0"),
                                userId: userId);
                          }
                        },
                        child: child,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        )
      ],
    );
  }
}
