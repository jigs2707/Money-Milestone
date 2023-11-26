import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_milestone/data/model/goalModal.dart';
import 'package:money_milestone/data/repository/goalRepository.dart';

abstract class UpdateGoalState {}

class UpdateGoalInitial extends UpdateGoalState {}

class UpdateGoalInProgress extends UpdateGoalState {}

class UpdateGoalSuccess extends UpdateGoalState {
  UpdateGoalSuccess({required this.goalData});

  final GoalModel goalData;
}

class UpdateGoalFailure extends UpdateGoalState {
  UpdateGoalFailure(this.errorMessage);

  final String errorMessage;
}

class UpdateGoalCubit extends Cubit<UpdateGoalState> {
  final GoalRepository _goalRepository;

  UpdateGoalCubit(this._goalRepository) : super(UpdateGoalInitial());


  void updateGoal(
      {required GoalModel goalDetails, required String userId}) async {
    try {
      emit(UpdateGoalInProgress());

      await _goalRepository
          .updateGoal(goalDetails: goalDetails, userId: userId);

      emit(UpdateGoalSuccess(goalData: goalDetails));
    } catch (e) {
      emit(UpdateGoalFailure(e.toString()));
    }
  }
}
