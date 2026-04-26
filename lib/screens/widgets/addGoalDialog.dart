// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import 'package:money_milestone/cubits/addGoalCubit.dart';
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
  bool get isEditing => widget.goalDetails != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _goalNameController.text = widget.goalDetails!.goalName!;
      _goalAmountController.text = widget.goalDetails!.goalAmount!;
      _goalAchieveDateController.text = intl.DateFormat(Constant.dateFormat)
          .format(DateTime.parse("${widget.goalDetails!.goalDate!} 00:00:00"));
      selectedDate = widget.goalDetails!.goalDate;
    }
  }

  @override
  void dispose() {
    _goalNameController.dispose();
    _goalAmountController.dispose();
    _goalAchieveDateController.dispose();
    _goalAmountFocusNode.dispose();
    _goalAchieveDateFocusNode.dispose();
    super.dispose();
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      initialDate: selectedDate != null
          ? DateTime.parse("${widget.goalDetails!.goalDate!} 00:00:00")
          : null,
      lastDate: DateTime.now().add(
        Duration(days: Constant.showCalenderTillDays),
      ),
    ).then((value) {
      if (value != null) {
        _goalAchieveDateController.text =
            intl.DateFormat(Constant.dateFormat).format(value);
        selectedDate = intl.DateFormat("yyyy-MM-dd").format(value);
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colors.accentColor.withValues(alpha: 0.2),
                      context.colors.accentColor.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: context.colors.accentColor.withValues(alpha: 0.3)),
                ),
                child: Icon(
                  isEditing ? Icons.edit_rounded : Icons.flag_rounded,
                  color: context.colors.accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? LanguageStrings.lblEdit : LanguageStrings.lblAddGoal,
                    style: TextStyle(
                      color: context.colors.blackColors,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      letterSpacing: -0.4,
                    ),
                  ),
                  Text(
                    isEditing
                        ? "Update your savings goal"
                        : "Set a new savings target",
                    style: TextStyle(
                      color: context.colors.lightGreyColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Form ────────────────────────────────────────────────
          Form(
            key: _formKey,
            child: Column(
              children: [
                // Goal name
                _buildLabel(Icons.label_outline_rounded,
                    LanguageStrings.lblGoalName),
                const SizedBox(height: 6),
                CustomTextFormField(
                  controller: _goalNameController,
                  textInputType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  nextFocus: _goalAmountFocusNode,
                  hintText: LanguageStrings.lblEnterYourGoal,
                  backgroundColor: context.colors.isDarkMode
                      ? const Color(0xff1C2135)
                      : const Color(0xffF4F5FF),
                  validator: (name) {
                    if (name == null || name.isEmpty) {
                      return LanguageStrings.lblEnterDetails;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Target amount
                _buildLabel(Icons.account_balance_wallet_outlined,
                    LanguageStrings.lblGoalAmount),
                const SizedBox(height: 6),
                CustomTextFormField(
                  controller: _goalAmountController,
                  textInputType: const TextInputType.numberWithOptions(
                      signed: false, decimal: true),
                  textInputAction: TextInputAction.next,
                  nextFocus: _goalAchieveDateFocusNode,
                  allowOnlySingleDecimalPoint: true,
                  hintText: LanguageStrings.lblEnterGoalAmount,
                  backgroundColor: context.colors.isDarkMode
                      ? const Color(0xff1C2135)
                      : const Color(0xffF4F5FF),
                  validator: (amount) {
                    if (amount == null || amount.isEmpty) {
                      return LanguageStrings.lblEnterDetails;
                    } else if (isEditing) {
                      if (amount.toString().toDouble() <
                          widget.goalDetails!.goalSavedAmount
                              .toString()
                              .toDouble()) {
                        return LanguageStrings.lblAmountCanNotBeLessThanSavedAmount;
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Target date
                _buildLabel(Icons.calendar_today_outlined,
                    LanguageStrings.lblGoalDate),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _showDatePicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 15),
                    decoration: BoxDecoration(
                      color: context.colors.isDarkMode
                          ? const Color(0xff1C2135)
                          : const Color(0xffF4F5FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selectedDate != null
                            ? context.colors.accentColor.withValues(alpha: 0.4)
                            : context.colors.cardBorderColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          size: 18,
                          color: selectedDate != null
                              ? context.colors.accentColor
                              : context.colors.lightGreyColor,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          selectedDate != null
                              ? _goalAchieveDateController.text
                              : "Tap to select a target date",
                          style: TextStyle(
                            color: selectedDate != null
                                ? context.colors.blackColors
                                : context.colors.lightGreyColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── CTA Buttons ─────────────────────────────────────
                BlocConsumer<UpdateGoalCubit, UpdateGoalState>(
                  listener: (context, updateGoalState) {
                    if (updateGoalState is UpdateGoalSuccess) {
                      Utils.showMessage(
                          context,
                          LanguageStrings.lblGoalUpdatedSuccessfully,
                          MessageType.success);
                      context.pop();
                    } else if (updateGoalState is UpdateGoalFailure) {
                      Utils.showMessage(context,
                          updateGoalState.errorMessage, MessageType.error);
                    }
                  },
                  builder: (context, updateGoalState) {
                    return BlocConsumer<AddGoalCubit, AddGoalState>(
                      listener: (context, state) {
                        if (state is AddGoalSuccess) {
                          Utils.showMessage(
                              context,
                              LanguageStrings.lblGoalAddedSuccessfully,
                              MessageType.success);
                          context.pop();
                        } else if (state is AddGoalFailure) {
                          Utils.showMessage(context, state.errorMessage,
                              MessageType.error);
                        }
                      },
                      builder: (context, state) {
                        final isLoading =
                            state is AddGoalInProgress ||
                                updateGoalState is UpdateGoalInProgress;

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
                            // Save
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: isLoading
                                    ? null
                                    : () async {
                                        Utils.removeFocus();
                                        if (!_formKey.currentState!
                                            .validate()) return;
                                        if (selectedDate == null) {
                                          Utils.showMessage(
                                              context,
                                              LanguageStrings.lblEnterDetails,
                                              MessageType.error);
                                          return;
                                        }
                                        String userId =
                                            HiveRepository.getUserId ?? "";
                                        if (isEditing) {
                                          context
                                              .read<UpdateGoalCubit>()
                                              .updateGoal(
                                                  goalDetails: GoalModel(
                                                    id: widget.goalDetails!.id,
                                                    goalName: _goalNameController
                                                        .text
                                                        .trim(),
                                                    goalAmount:
                                                        _goalAmountController
                                                            .text
                                                            .trim(),
                                                    goalDate: selectedDate,
                                                    goalSavedAmount: widget
                                                        .goalDetails!
                                                        .goalSavedAmount,
                                                  ),
                                                  userId: userId);
                                        } else {
                                          context.read<AddGoalCubit>().addGoal(
                                              goalDetails: GoalModel(
                                                id: "",
                                                goalName: _goalNameController
                                                    .text
                                                    .trim(),
                                                goalAmount:
                                                    _goalAmountController.text
                                                        .trim(),
                                                goalDate: selectedDate,
                                                goalSavedAmount: "0",
                                              ),
                                              userId: userId);
                                        }
                                      },
                                child: Container(
                                  height: 52,
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
                                        color: context.colors.accentColor
                                            .withValues(alpha: 0.38),
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
                                            isEditing
                                                ? LanguageStrings.lblEdit
                                                : "Save Goal",
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
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
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
