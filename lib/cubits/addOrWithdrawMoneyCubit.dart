import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_milestone/data/model/transactionModel.dart';
import 'package:money_milestone/data/repository/transactionRepository.dart';

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
//
      emit(AddOrWithdrawMoneySuccess(transactionData: transactionData));
    } catch (e) {
      emit(AddOrWithdrawMoneyFailure(e.toString()));
    }
  }
}
