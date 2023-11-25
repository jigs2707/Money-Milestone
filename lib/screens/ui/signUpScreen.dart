import 'package:my_financial_goals/app/generalImports.dart';
import 'package:my_financial_goals/app/routes.dart';
import 'package:my_financial_goals/cubits/signUpCubit.dart';
import 'package:my_financial_goals/screens/widgets/customCircularProgressIndicator.dart';
import 'package:my_financial_goals/screens/widgets/customRoundedButton.dart';
import 'package:my_financial_goals/screens/widgets/customTextFormfield.dart';
import 'package:my_financial_goals/utils/languageString.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_financial_goals/utils/stringExtensions.dart';
import 'package:my_financial_goals/utils/utils.dart';

// ignore: must_be_immutable
class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  static Route route(final RouteSettings routeSettings) => CupertinoPageRoute(
        builder: (final _) => BlocProvider<SignUpCubit>(
            create: (final _) => SignUpCubit(AuthRepository()),
            child: SignUpScreen()),
      );

//
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();
  //
  final _emailFocusNode = FocusNode();
  final _passswordFocusNode = FocusNode();

  final _confirmPassswordFocusNode = FocusNode();

  Widget _showSizedBox({double? height, double? width}) {
    return SizedBox(
      height: height,
      width: width,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    LanguageStrings.lblSignUp,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.start,
                  ),
                ),
                _showSizedBox(height: 25),
                CustomTextFormField(
                  controller: _nameController,
                  hintText: LanguageStrings.lblEnterYourName,
                  nextFocus: _emailFocusNode,
                  labelText: LanguageStrings.lblName,
                  textInputAction: TextInputAction.next,
                  textInputType: TextInputType.text,
                  validator: (name) {
                    if (name != null && name.isNotEmpty) {
                      return null;
                    }
                    return LanguageStrings.lblEnterDetails;
                  },
                ),
                _showSizedBox(
                  height: 10,
                ),
                CustomTextFormField(
                  controller: _emailController,
                  hintText: LanguageStrings.lblEnterYourEmail,
                  nextFocus: _passswordFocusNode,
                  labelText: LanguageStrings.lblEmail,
                  textInputAction: TextInputAction.next,
                  textInputType: TextInputType.emailAddress,
                  validator: (email) {
                    if (email != null && email.isNotEmpty) {
                      return null;
                    }
                    return LanguageStrings.lblEnterDetails;
                  },
                ),
                _showSizedBox(
                  height: 10,
                ),
                CustomTextFormField(
                  controller: _passwordController,
                  hintText: LanguageStrings.lblEnterYourPassword,
                  isPswd: true,
                  nextFocus: _confirmPassswordFocusNode,
                  labelText: LanguageStrings.lblPassword,
                  textInputAction: TextInputAction.next,
                  textInputType: TextInputType.text,
                  validator: (password) {
                    if (password != null && password.isNotEmpty) {
                      return null;
                    }
                    return LanguageStrings.lblEnterDetails;
                  },
                ),
                _showSizedBox(
                  height: 10,
                ),
                CustomTextFormField(
                  controller: _confirmPasswordController,
                  hintText: LanguageStrings.lblEnterYourconfirmPassword,
                  isPswd: true,
                  labelText: LanguageStrings.lblconfirmPassword,
                  textInputAction: TextInputAction.done,
                  textInputType: TextInputType.text,
                  validator: (confirmPassword) {
                    if (confirmPassword != null && confirmPassword.isNotEmpty) {
                      return null;
                    }
                    return LanguageStrings.lblEnterDetails;
                  },
                ),
                _showSizedBox(
                  height: 10,
                ),
                BlocConsumer<SignUpCubit, SignUpState>(
                  listener: (final context, final state)  {
                    if (state is SignUpSuccess) {
                      //
                      Utils.showMessage(context, LanguageStrings.lblVerificationMailSent,
                          MessageType.warning);
                          
                       Future.delayed(const Duration(seconds: 1),(){
                        context.pop();
                      });
                      
                      //
                    } else if (state is SignUpFailure) {
                      Utils.showMessage(
                          context,
                          state.errorMessage.getFirebaseError(),
                          MessageType.error);
                    }
                  },
                  builder: (final context, final state) {
                    Widget? child;
                    if (state is SignUpProgress) {
                      child = CustomCircularProgressIndicator(
                        color: AppColors.whiteColors,
                      );
                    } else if (state is SignUpFailure ||
                        state is SignUpSuccess) {
                      child = null;
                    }
                    return CustomRoundedButton(
                        onTap: () {
                          //
                          Utils.removeFocus();
                          //
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          if (_confirmPasswordController.text
                                  .toString()
                                  .trim() !=
                              _passwordController.text.toString().trim()) {
                            Utils.showMessage(
                                context,
                                LanguageStrings.lblPasswordDoesNotMatch,
                                MessageType.error);
                            return;
                          }

                          //
                          context.read<SignUpCubit>().signUp(
                              email: _emailController.text.trim().toString(),
                              password:
                                  _passwordController.text.trim().toString(),
                              name: _nameController.text.trim().toString());
                        },
                        titleColor: AppColors.whiteColors,
                        height: 56,
                        buttonTitle: LanguageStrings.lblSignUp,
                        showBorder: false,
                        widthPercentage: 1,
                        backgroundColor: AppColors.accentColor,
                        child: child);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
