import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_milestone/data/repository/authRepository.dart';

abstract class LogInState {}

class LogInInitial extends LogInState {}

class LogInProgress extends LogInState {}

class LogInSuccess extends LogInState {
  LogInSuccess({required this.userData});

  final User userData;
}

class LogInFailure extends LogInState {
  LogInFailure(this.errorMessage);

  final String errorMessage;
}

class LogInCubit extends Cubit<LogInState> {
  final AuthRepository _authRepository;

  LogInCubit(this._authRepository) : super(LogInInitial());

//To:Do Add the email verification

  void doLogIn({required String email, required String password}) async {
    try {
      emit(LogInProgress());
      //
      User user = await _authRepository.logIn(email: email, password: password);
      //
        emit(LogInSuccess(userData: user));

    } catch (e) {
      emit(LogInFailure(e.toString()));
    }
  }
}
