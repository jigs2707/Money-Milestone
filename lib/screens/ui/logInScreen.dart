// ignore_for_file: use_build_context_synchronously


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_milestone/app/routes.dart';
import 'package:money_milestone/cubits/logInCubit.dart';
import 'package:money_milestone/data/repository/authRepository.dart';
import 'package:money_milestone/data/repository/hiveRepository.dart';
import 'package:money_milestone/data/repository/userRepository.dart';
import 'package:money_milestone/screens/widgets/backgroundWidget.dart';
import 'package:money_milestone/screens/widgets/customCircularProgressIndicator.dart';
import 'package:money_milestone/screens/widgets/customRoundedButton.dart';
import 'package:money_milestone/screens/widgets/customTextFormfield.dart';
import 'package:money_milestone/utils/colors.dart';
import 'package:money_milestone/utils/constant.dart';
import 'package:money_milestone/utils/contextExtensions.dart';
import 'package:money_milestone/utils/languageString.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money_milestone/utils/stringExtensions.dart';
import 'package:money_milestone/utils/utils.dart';

// ignore: must_be_immutable
class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  static Route route(final RouteSettings routeSettings) =>
      CupertinoPageRoute(
        builder: (final _) =>
            BlocProvider<LogInCubit>(
                create: (final _) => LogInCubit(AuthRepository()),
                child: const LogInScreen()),
      );

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordFocusNode.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: BackgroundWidget(
          child: Form(
            key: _formKey,
            child: Center(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        LanguageStrings.lblLogin,
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    const SizedBox(height: 25),
                    CustomTextFormField(
                      backgroundColor: AppColors.secondaryColor,
                      controller: _emailController,
                      hintText: LanguageStrings.lblEnterYourEmail,
                      nextFocus: _passwordFocusNode,
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
                    const SizedBox(
                      height: 20,
                    ),
                    CustomTextFormField(
                      backgroundColor: AppColors.secondaryColor,
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
                    const SizedBox(
                      height: 20,
                    ),
                    BlocConsumer<LogInCubit, LogInState>(
                      listener: (final context, final state) async {
                        if (state is LogInSuccess) {
                          String username = await UserRepository()
                              .getUserName(userId: state.userData.uid);

                          HiveRepository.setUserLoggedIn = true;
                          HiveRepository.setUsername = username;
                          HiveRepository.setUserId = state.userData.uid;

                          context.pushReplacementNamed(
                            Routes.homeScreen,
                          );
                          //
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
                          child = const CustomCircularProgressIndicator(
                            color: AppColors.whiteColors,
                          );
                        } else if (state is LogInFailure ||
                            state is LogInSuccess) {
                          child = null;
                        }
                        return CustomRoundedButton(
                            onTap: () {
                              //
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }
                              //
                              Utils.removeFocus();
                              //
                              context.read<LogInCubit>().doLogIn(
                                  email:
                                  _emailController.text.trim().toString(),
                                  password: _passwordController.text
                                      .trim()
                                      .toString());
                            },
                            titleColor: AppColors.whiteColors,
                            height: 56,
                            buttonTitle: LanguageStrings.lblLogin,
                            showBorder: false,
                            widthPercentage: 1,
                            child: child);
                      },
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: context.width*0.4,
                          child: Divider(
                            height: 1,
                            thickness: 0.5,
                            color: AppColors.lightGreyColor,

                          ),
                        ),
                        const Text(" ${LanguageStrings.lblOr} "),
                        SizedBox(
                          width: context.width*0.4,
                          child: Divider(
                            height: 1,
                            thickness: 0.5,
                            color: AppColors.lightGreyColor,

                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    GestureDetector(
                      onTap: () {
                        context.pushNamed(Routes.signUpScreen);
                      },
                      child: const Text.rich(
                        TextSpan(
                            text: "${LanguageStrings.lblNewUser} ",
                            style: TextStyle(
                                color: AppColors.blackColors,
                                fontWeight: FontWeight.w500),
                            children: [
                              TextSpan(
                                  text: LanguageStrings.lblSignUp,
                                  style: TextStyle(
                                      color: AppColors.accentColor,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.accentColor))
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
        ));
  }
}
