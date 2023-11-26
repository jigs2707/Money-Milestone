// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_milestone/cubits/addOrWithdrawMoneyCubit.dart';
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

class AddOrWithdrawMoneyDialog extends StatefulWidget {
  final String title;
  final GoalModel goalDetails;

  const AddOrWithdrawMoneyDialog(
      {super.key, required this.title, required this.goalDetails});

  @override
  State<AddOrWithdrawMoneyDialog> createState() =>
      _AddOrWithdrawMoneyDialogState();
}

class _AddOrWithdrawMoneyDialogState extends State<AddOrWithdrawMoneyDialog> {
  final TextEditingController _amountController = TextEditingController();

  final TextEditingController _notesController = TextEditingController();

  final FocusNode _notesFocusNode = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                "${widget.title} ${LanguageStrings.lblMoney}",
                style: const TextStyle(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    if (widget.title == LanguageStrings.lblWithdraw) ...[
                      Text(
                          "${LanguageStrings.lblSavedAmount}:${(widget.goalDetails.goalSavedAmount ?? "0").currency()}"),
                    ] else ...[
                      Text(
                          "${LanguageStrings.lblRemainingAmount}:${(widget.goalDetails.goalAmount.toString().toDouble() - (widget.goalDetails.goalSavedAmount ?? "0").toDouble()).toString().currency()}"),
                    ],
                    const SizedBox(
                      height: 10,
                    ),
                    CustomTextFormField(
                      controller: _amountController,
                      allowOnlySingleDecimalPoint: true,
                      nextFocus: _notesFocusNode,
                      hintText: LanguageStrings.lblEnterAmount,
                      labelText: LanguageStrings.lblAmount,
                      backgroundColor: AppColors.primaryColor,
                      textInputAction: TextInputAction.next,
                      textInputType: const TextInputType.numberWithOptions(
                          decimal: true, signed: false),
                      validator: (amount) {
                        if (amount == null || amount.isEmpty) {
                          return LanguageStrings.lblEnterDetails;
                        } else {
                          if (widget.title == LanguageStrings.lblWithdraw) {
                            if (amount.toString().toDouble() >
                                widget.goalDetails.goalSavedAmount
                                    .toString()
                                    .toDouble()) {
                              return LanguageStrings
                                  .lblEnterAmountLessThanSavedAmount;
                            }
                            return null;
                          } else {
                            double remainingAmount = (widget
                                    .goalDetails.goalAmount
                                    .toString()
                                    .toDouble() -
                                (widget.goalDetails.goalSavedAmount ?? "0")
                                    .toDouble());
                            if (amount.toString().toDouble() >
                                remainingAmount.toDouble()) {
                              return LanguageStrings
                                  .lblAmountIsGreaterThanRemainingAmount;
                            }
                          }
                          return null;
                        }
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomTextFormField(
                      controller: _notesController,
                      hintText: LanguageStrings.lblEnterNote,
                      labelText: LanguageStrings.lblNote,
                      textInputAction: TextInputAction.done,
                      textInputType: TextInputType.text,
                      backgroundColor: AppColors.primaryColor,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: CustomRoundedButton(
                onTap: () {
                  context.pop();
                },
                buttonTitle: LanguageStrings.lblCancel,
                showBorder: false,
                widthPercentage: 1,
                titleColor: AppColors.blackColors,
                backgroundColor: AppColors.primaryColor,
                radius: 0,
                borderRadius:
                    const BorderRadius.only(bottomLeft: Radius.circular(10)),
              ),
            ),
            Expanded(
              child: BlocListener<UpdateGoalCubit, UpdateGoalState>(
                listener: (context, state) {
                  if (state is UpdateGoalSuccess) {
                    context
                        .pop({"savedAmount": state.goalData.goalSavedAmount});
                  } else if (state is UpdateGoalFailure) {
                    Utils.showMessage(
                        context, state.errorMessage, MessageType.error);
                  }
                },
                child: BlocConsumer<AddOrWithdrawMoneyCubit,
                    AddOrWithdrawMoneyState>(
                  listener: (context, state) async {
                    if (state is AddOrWithdrawMoneySuccess) {
                      //Update goal saved amount
                      String newAmount = "";

                      if (state.transactionData.transactionType == "debit") {
                        newAmount = (double.parse(widget
                                    .goalDetails.goalSavedAmount
                                    .toString()) -
                                double.parse(state
                                    .transactionData.transactionAmount
                                    .toString()))
                            .toString();
                      } else {
                        newAmount = (double.parse(widget
                                    .goalDetails.goalSavedAmount
                                    .toString()) +
                                double.parse(state
                                    .transactionData.transactionAmount
                                    .toString()))
                            .toString();
                      }
                      GoalModel goalData =
                          widget.goalDetails.copyWith(amount: newAmount);
                      //
                      String userId = HiveRepository.getUserId ?? "";

                      context
                          .read<UpdateGoalCubit>()
                          .updateGoal(goalDetails: goalData, userId: userId);
                      ////

                      Utils.showMessage(
                          context,
                          state.transactionData.transactionType == "debit"
                              ? LanguageStrings.lblAmountWithdrawSuccessfully
                              : LanguageStrings.lblAmountAddedSuccessfully,
                          MessageType.success);
                    } else if (state is AddOrWithdrawMoneyFailure) {
                      Utils.showMessage(
                          context, state.errorMessage, MessageType.error);
                    }
                  },
                  builder: (context, state) {
                    Widget? child;
                    if (state is AddOrWithdrawMoneyInProgress) {
                      child = const CustomCircularProgressIndicator();
                    } else if (state is AddOrWithdrawMoneyFailure ||
                        state is AddOrWithdrawMoneySuccess) {
                      child = null;
                    }
                    //
                    return CustomRoundedButton(
                      onTap: () async {
                        Utils.removeFocus();
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        String userId = HiveRepository.getUserId ?? "";

                        //
                        context
                            .read<AddOrWithdrawMoneyCubit>()
                            .addAmountTransaction(
                                amount:
                                    _amountController.text.trim().toString(),
                                note: _notesController.text.trim().toString(),
                                type:
                                    widget.title == LanguageStrings.lblWithdraw
                                        ? "debit"
                                        : "credit",
                                date: DateTime.now().toString(),
                                userId: userId,
                                goalId: widget.goalDetails.id.toString());
                      },
                      buttonTitle: LanguageStrings.lblDone,
                      showBorder: false,
                      widthPercentage: 1,
                      titleColor: AppColors.whiteColors,
                      radius: 0,
                      borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(10)),
                      child: child,
                    );
                  },
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
