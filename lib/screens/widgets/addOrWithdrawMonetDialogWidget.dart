// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_milestone/cubits/addOrWithdrawMoneyCubit.dart';
import 'package:money_milestone/cubits/updateGoalCubit.dart';
import 'package:money_milestone/data/model/goalModal.dart';
import 'package:money_milestone/data/repository/hiveRepository.dart';
import 'package:money_milestone/screens/widgets/customCircularProgressIndicator.dart';
import 'package:money_milestone/screens/widgets/customTextFormfield.dart';
import 'package:money_milestone/utils/app_colors_extension.dart';
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

  bool get isWithdraw => widget.title == LanguageStrings.lblWithdraw;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor =
        isWithdraw ? context.colors.redColor : context.colors.greenColor;

    final double savedAmount =
        (widget.goalDetails.goalSavedAmount ?? "0").toDouble();
    final double totalAmount =
        widget.goalDetails.goalAmount.toString().toDouble();
    final double remainingAmount = totalAmount - savedAmount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                ),
                child: Icon(
                  isWithdraw
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.title} Money",
                    style: TextStyle(
                      color: context.colors.blackColors,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      letterSpacing: -0.4,
                    ),
                  ),
                  Text(
                    isWithdraw
                        ? "Record a withdrawal from this goal"
                        : "Record a deposit to this goal",
                    style: TextStyle(
                      color: context.colors.lightGreyColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Balance pill ────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accentColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _balanceStat(
                  label: "Goal Target",
                  value: totalAmount.toString().currency(),
                  color: context.colors.accentColor,
                ),
                Container(
                    width: 1,
                    height: 28,
                    color: accentColor.withValues(alpha: 0.2)),
                _balanceStat(
                  label: isWithdraw ? "Available" : "Remaining",
                  value: isWithdraw
                      ? savedAmount.toString().currency()
                      : remainingAmount.toString().currency(),
                  color: accentColor,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Form ────────────────────────────────────────────────────────
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel(
                    Icons.payments_outlined, LanguageStrings.lblAmount),
                const SizedBox(height: 6),
                CustomTextFormField(
                  controller: _amountController,
                  allowOnlySingleDecimalPoint: true,
                  nextFocus: _notesFocusNode,
                  hintText: LanguageStrings.lblEnterAmount,
                  backgroundColor: context.colors.isDarkMode
                      ? const Color(0xff1C2135)
                      : const Color(0xffF4F5FF),
                  textInputAction: TextInputAction.next,
                  textInputType: const TextInputType.numberWithOptions(
                      decimal: true, signed: false),
                  validator: (amount) {
                    if (amount == null || amount.isEmpty) {
                      return LanguageStrings.lblEnterDetails;
                    }
                    if (isWithdraw) {
                      if (amount.toString().toDouble() > savedAmount) {
                        return LanguageStrings.lblEnterAmountLessThanSavedAmount;
                      }
                    } else {
                      if (amount.toString().toDouble() > remainingAmount) {
                        return LanguageStrings
                            .lblAmountIsGreaterThanRemainingAmount;
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                _buildLabel(Icons.sticky_note_2_outlined,
                    "${LanguageStrings.lblNote} (optional)"),
                const SizedBox(height: 6),
                CustomTextFormField(
                  controller: _notesController,
                  hintText: LanguageStrings.lblEnterNote,
                  textInputAction: TextInputAction.done,
                  textInputType: TextInputType.text,
                  backgroundColor: context.colors.isDarkMode
                      ? const Color(0xff1C2135)
                      : const Color(0xffF4F5FF),
                ),
                const SizedBox(height: 28),

                // ── Buttons ──────────────────────────────────────────────
                BlocListener<UpdateGoalCubit, UpdateGoalState>(
                  listener: (context, state) {
                    if (state is UpdateGoalSuccess) {
                      context.pop(
                          {"savedAmount": state.goalData.goalSavedAmount});
                    } else if (state is UpdateGoalFailure) {
                      Utils.showMessage(
                          context, state.errorMessage, MessageType.error);
                    }
                  },
                  child: BlocConsumer<AddOrWithdrawMoneyCubit,
                      AddOrWithdrawMoneyState>(
                    listener: (context, state) async {
                      if (state is AddOrWithdrawMoneySuccess) {
                        String newAmount;
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
                        String userId = HiveRepository.getUserId ?? "";
                        context
                            .read<UpdateGoalCubit>()
                            .updateGoal(goalDetails: goalData, userId: userId);

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
                      final isLoading = state is AddOrWithdrawMoneyInProgress;

                      return Row(
                        children: [
                          // Cancel
                          Expanded(
                            child: GestureDetector(
                              onTap: () => context.pop(),
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: context.colors.isDarkMode
                                      ? const Color(0xff1C2135)
                                      : const Color(0xffF4F5FF),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: context.colors.cardBorderColor),
                                ),
                                child: Center(
                                  child: Text(
                                    LanguageStrings.lblCancel,
                                    style: TextStyle(
                                      color: context.colors.lightGreyColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Confirm
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () {
                                      Utils.removeFocus();
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }
                                      String userId =
                                          HiveRepository.getUserId ?? "";
                                      context
                                          .read<AddOrWithdrawMoneyCubit>()
                                          .addAmountTransaction(
                                            amount: _amountController.text
                                                .trim(),
                                            note:
                                                _notesController.text.trim(),
                                            type: isWithdraw
                                                ? "debit"
                                                : "credit",
                                            date: DateTime.now().toString(),
                                            userId: userId,
                                            goalId: widget.goalDetails.id
                                                .toString(),
                                          );
                                    },
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      accentColor.withValues(alpha: 0.9),
                                      accentColor,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentColor.withValues(alpha: 0.35),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: isLoading
                                      ? CustomCircularProgressIndicator(
                                          color: Colors.white)
                                      : Text(
                                          "Confirm ${widget.title}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceStat(
      {required String label,
      required String value,
      required Color color}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.colors.lightGreyColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: context.colors.lightGreyColor),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: context.colors.lightGreyColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
