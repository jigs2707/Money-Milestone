import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_milestone/data/model/goalModal.dart';
import 'package:money_milestone/data/model/transactionModel.dart';
import 'package:money_milestone/data/repository/transactionRepository.dart';
import 'package:money_milestone/data/repository/userRepository.dart';
import 'package:money_milestone/utils/analyticsService.dart';
import 'package:money_milestone/utils/clarityService.dart';
import 'package:money_milestone/utils/notificationService.dart';

abstract class AddOrWithdrawMoneyState {}

class AddOrWithdrawMoneyInitial extends AddOrWithdrawMoneyState {}

class AddOrWithdrawMoneyInProgress extends AddOrWithdrawMoneyState {}

class AddOrWithdrawMoneySuccess extends AddOrWithdrawMoneyState {
  AddOrWithdrawMoneySuccess({required this.transactionData});

  final TransactionModel transactionData;
}

class AddOrWithdrawMoneyFailure extends AddOrWithdrawMoneyState {
  AddOrWithdrawMoneyFailure(this.errorMessage);

  final String errorMessage;
}

class AddOrWithdrawMoneyCubit extends Cubit<AddOrWithdrawMoneyState> {
  final TransactionRepository _transactionRepository;

  AddOrWithdrawMoneyCubit(this._transactionRepository)
      : super(AddOrWithdrawMoneyInitial());

  void addAmountTransaction({
    required String amount,
    required String note,
    required String type,
    required String date,
    required String userId,
    required String goalId,
    GoalModel? goal,
  }) async {
    try {
      emit(AddOrWithdrawMoneyInProgress());
      //
      TransactionModel transactionData = TransactionModel(
          transactionAmount: amount,
          transactionDate: date,
          transactionNote: note,
          transactionType: type,
          transactionId: "");

      //Update the saved amount in goal document
      await _transactionRepository.addAmountTransaction(
          goalId: goalId, transactionDetails: transactionData, userId: userId);

      //Update streak if it's a deposit and log analytics
      final isDeposit = type != "debit";
      final parsedAmount = double.tryParse(amount) ?? 0;
      if (isDeposit) {
        await AnalyticsService.logDeposit(amount: parsedAmount, goalId: goalId);
        ClarityService.logDeposit(amount: parsedAmount);
        await UserRepository().updateStreak(userId: userId);

        // Fire milestone / completion notifications when goal data is available
        if (goal != null) {
          final total = double.tryParse(goal.goalAmount ?? '0') ?? 0;
          final prevSaved = double.tryParse(goal.goalSavedAmount ?? '0') ?? 0;
          if (total > 0) {
            final prevPct = (prevSaved / total * 100).floor();
            final newPct = ((prevSaved + parsedAmount) / total * 100).floor();
            if (newPct >= 100) {
              await NotificationService.instance.showCompletionNotification(goal);
            } else {
              for (final milestone in [25, 50, 75, 90]) {
                if (prevPct < milestone && newPct >= milestone) {
                  await NotificationService.instance
                      .showMilestoneNotification(goal, milestone);
                  break;
                }
              }
            }
          }
        }
      } else {
        await AnalyticsService.logWithdrawal(amount: parsedAmount, goalId: goalId);
        ClarityService.logWithdrawal(amount: parsedAmount);
      }

      emit(AddOrWithdrawMoneySuccess(transactionData: transactionData));
    } catch (e) {
      emit(AddOrWithdrawMoneyFailure(e.toString()));
    }
  }
}
