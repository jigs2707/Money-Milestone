import 'package:my_financial_goals/app/generalImports.dart';
import 'package:my_financial_goals/utils/languageString.dart';

class LogInCubit extends Cubit<LogInState> {
  final AuthRepository _authRepository;

  LogInCubit(this._authRepository) : super(SectionInitial());

//To:Do Add the email verification

  void doLogIn({required String email, required String password}) async {
    try {
      emit(LogInProgress());
      //
      User user = await _authRepository.logIn(email: email, password: password);
      //
     // if (user.emailVerified) {
        //
        emit(LogInSuccess(userData: user));
      // } else {
      //   _authRepository.signOut();
      //   emit(LogInFailure(LanguageStrings.lblPleaseVerifyYourMail));
      // }
    } catch (e) {
      emit(LogInFailure(e.toString()));
    }
  }
}

abstract class LogInState {}

class SectionInitial extends LogInState {}

class LogInProgress extends LogInState {}

class LogInSuccess extends LogInState {
  LogInSuccess({required this.userData});
  final User userData;
}

class LogInFailure extends LogInState {
  LogInFailure(this.errorMessage);
  final String errorMessage;
}
