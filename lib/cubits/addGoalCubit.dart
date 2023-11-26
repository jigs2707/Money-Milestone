import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:money_milestone/data/model/goalModal.dart';
import 'package:money_milestone/data/repository/goalRepository.dart';


abstract class AddGoalState {}

class AddGoalInitial extends AddGoalState {}

class AddGoalInProgress extends AddGoalState {}

class AddGoalSuccess extends AddGoalState {
  AddGoalSuccess({required this.goalDetails});

  final GoalModel goalDetails;
}

class AddGoalFailure extends AddGoalState {
  AddGoalFailure(this.errorMessage);

  final String errorMessage;
}

class AddGoalCubit extends Cubit<AddGoalState> {
  final GoalRepository _goalRepository;

  AddGoalCubit(this._goalRepository) : super(AddGoalInitial());

  void addGoal({required GoalModel goalDetails, required String userId}) async {
    try {
      emit(AddGoalInProgress());
      //
      await _goalRepository.addGoal(goalDetails: goalDetails, userId: userId);
      //
      emit(AddGoalSuccess(goalDetails: goalDetails));
    } catch (e) {
      emit(AddGoalFailure(e.toString()));
    }
  }
}
