import 'package:my_financial_goals/app/generalImports.dart';
import 'package:my_financial_goals/data/repository/userRepository.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final AuthRepository _authRepository;

  SignUpCubit(this._authRepository) : super(SectionInitial());

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
      user.sendEmailVerification();
      //
      await UserRepository().addUserName(name: name, userId: user.uid);
      //
      _authRepository.signOut();
      emit(SignUpSuccess(userData: user));
    } catch (e) {
      print(e.toString());
      emit(SignUpFailure(e.toString()));
    }
  }
}

abstract class SignUpState {}

class SectionInitial extends SignUpState {}

class SignUpProgress extends SignUpState {}

class SignUpSuccess extends SignUpState {
  SignUpSuccess({required this.userData});
  final User userData;
}

class SignUpFailure extends SignUpState {
  SignUpFailure(this.errorMessage);
  final String errorMessage;
}
