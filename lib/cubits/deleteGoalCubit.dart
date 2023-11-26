import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_milestone/data/model/goalModal.dart';
import 'package:money_milestone/data/repository/goalRepository.dart';

abstract class DeleteGoalState {}

class DeleteGoalInitial extends DeleteGoalState {}

class DeleteGoalInProgress extends DeleteGoalState {}

class DeleteGoalSuccess extends DeleteGoalState {
  DeleteGoalSuccess({required this.goalDetails});

  final GoalModel goalDetails;
}

class DeleteGoalFailure extends DeleteGoalState {
  DeleteGoalFailure(this.errorMessage);

  final String errorMessage;
}

class DeleteGoalCubit extends Cubit<DeleteGoalState> {
  final GoalRepository _goalRepository;

  DeleteGoalCubit(this._goalRepository) : super(DeleteGoalInitial());

  void deleteGoal({required GoalModel goalDetails, required String userId}) async {
    try {
      emit(DeleteGoalInProgress());
      //
      await _goalRepository.deleteGoal(goalDetails: goalDetails, userId: userId);
      //
      emit(DeleteGoalSuccess(goalDetails: goalDetails));
    } catch (e) {
      emit(DeleteGoalFailure(e.toString()));
    }
  }
}
