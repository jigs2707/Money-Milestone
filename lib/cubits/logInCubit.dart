import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_milestone/data/repository/authRepository.dart';
import 'package:money_milestone/utils/analyticsService.dart';
import 'package:money_milestone/utils/clarityService.dart';

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

  void doLogIn({required String email, required String password}) async {
    try {
      emit(LogInProgress());
      //
      User user = await _authRepository.logIn(email: email, password: password);
      //
      // Reload so emailVerified reflects the latest server state.
      final bool verified = await _authRepository.isEmailVerified();
      //
      if (!verified) {
        // Sign the user back out and tell the UI their email isn't verified.
        await _authRepository.signOut();
        emit(LogInFailure(
            'email-not-verified: Please verify your email before logging in.'));
        return;
      }
      //
      await AnalyticsService.logLogin();
      ClarityService.setUserId(user.uid);
      ClarityService.logLogin();
      emit(LogInSuccess(userData: user));
    } catch (e) {
      emit(LogInFailure(e.toString()));
    }
  }
}
