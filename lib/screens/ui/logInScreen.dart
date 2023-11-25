import 'package:my_financial_goals/app/generalImports.dart';
import 'package:my_financial_goals/app/routes.dart';
import 'package:my_financial_goals/cubits/logInCubit.dart';
import 'package:my_financial_goals/screens/widgets/customCircularProgressIndicator.dart';
import 'package:my_financial_goals/screens/widgets/customRoundedButton.dart';
import 'package:my_financial_goals/screens/widgets/customTextFormfield.dart';
import 'package:my_financial_goals/utils/languageString.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_financial_goals/utils/stringExtensions.dart';
import 'package:my_financial_goals/utils/utils.dart';

// ignore: must_be_immutable
class LogInScreen extends StatefulWidget {

  const LogInScreen({super.key});

  static Route route(final RouteSettings routeSettings) => CupertinoPageRoute(
        builder: (final _) => BlocProvider<LogInCubit>(
            create: (final _) => LogInCubit(AuthRepository()),
            child: LogInScreen()),
      );

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final _passswordFocusNode = FocusNode();

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
        key: formKey,
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
                    LanguageStrings.lblLogin,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.start,
                  ),
                ),
                _showSizedBox(height: 25),
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
                  labelText: LanguageStrings.lblPassword,
                  textInputAction: TextInputAction.done,
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
                BlocConsumer<LogInCubit, LogInState>(
                  listener: (final context, final state) {
                    if (state is LogInSuccess) {
                      context.pushReplacementNamed(Routes.homeScreen,
                          arguments: {"userData": state.userData});
                    } else if (state is LogInFailure) {
                      Utils.showMessage(
                          context,
                          state.errorMessage.getFirebaseError(),
                          MessageType.error);
                    }
                  },
                  builder: (final context, final state) {
                    Widget? child;
                    if (state is LogInProgress) {
                      child = CustomCircularProgressIndicator(
                        color: AppColors.whiteColors,
                      );
                    } else if (state is LogInFailure || state is LogInSuccess) {
                      child = null;
                    }
                    return CustomRoundedButton(
                        onTap: () {
                          //
                          if (!formKey.currentState!.validate()) {
                            return;
                          }
                          //
                          Utils.removeFocus();
                          //
                          context.read<LogInCubit>().doLogIn(
                              email: _emailController.text.trim().toString(),
                              password:
                                  _passwordController.text.trim().toString());
                        },
                        titleColor: AppColors.whiteColors,
                        height: 56,
                        buttonTitle: LanguageStrings.lblLogin,
                        showBorder: false,
                        widthPercentage: 1,
                        backgroundColor: AppColors.accentColor,
                        child: child);
                  },
                ),
                _showSizedBox(height: 25),
                GestureDetector(
                  onTap: () {
                    context.pushNamed(Routes.signUpScreen);
                  },
                  child: Text.rich(
                    TextSpan(text: LanguageStrings.lblNewUser, children: [
                      TextSpan(
                          text: LanguageStrings.lblSignUp,
                          style: TextStyle(
                            color: AppColors.redColor,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ))
                    ]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
