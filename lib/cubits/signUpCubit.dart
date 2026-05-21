import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_milestone/data/repository/authRepository.dart';
import 'package:money_milestone/data/repository/userRepository.dart';

abstract class SignUpState {}

class SignUpInitial extends SignUpState {}

class SignUpProgress extends SignUpState {}

/// Emitted when the account is created and a verification email has been sent.
/// The UI should navigate to the Email Verification screen.
class SignUpEmailVerificationSent extends SignUpState {
  SignUpEmailVerificationSent({required this.userData});

  final User userData;
}

class SignUpSuccess extends SignUpState {
  SignUpSuccess({required this.userData});

  final User userData;
}

class SignUpFailure extends SignUpState {
  SignUpFailure(this.errorMessage);

  final String errorMessage;
}

class SignUpCubit extends Cubit<SignUpState> {
  final AuthRepository _authRepository;

  SignUpCubit(this._authRepository) : super(SignUpInitial());

  void signUp(
      {required String email,
      required String password,
      required String name}) async {
    try {
      emit(SignUpProgress());
      //
      User user =
          await _authRepository.signUp(email: email, password: password);
      //
      await UserRepository().addUserName(name: name, userId: user.uid);
      //
      // Send email verification — user must confirm before they can log in.
      await _authRepository.sendEmailVerification();
      //
      emit(SignUpEmailVerificationSent(userData: user));
    } catch (e) {
      emit(SignUpFailure(e.toString()));
    }
  }
}
