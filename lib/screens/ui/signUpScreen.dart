import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_milestone/app/routes.dart';
import 'package:money_milestone/cubits/signUpCubit.dart';
import 'package:money_milestone/data/repository/authRepository.dart';
import 'package:money_milestone/data/repository/hiveRepository.dart';
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
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static Route route(final RouteSettings routeSettings) => CupertinoPageRoute(
        builder: (final _) => BlocProvider<SignUpCubit>(
            create: (final _) => SignUpCubit(AuthRepository()),
            child: const SignUpScreen()),
      );

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
//
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  //
  final _emailFocusNode = FocusNode();

  final _passwordFocusNode = FocusNode();

  final _confirmPasswordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
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
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      LanguageStrings.lblSignUp,
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const SizedBox(height: 25),
                  CustomTextFormField(
                    backgroundColor: AppColors.secondaryColor,
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
                  const SizedBox(
                    height: 20,
                  ),
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
                    nextFocus: _confirmPasswordFocusNode,
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
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextFormField(
                    backgroundColor: AppColors.secondaryColor,
                    controller: _confirmPasswordController,
                    hintText: LanguageStrings.lblEnterYourConfirmPassword,
                    isPswd: true,
                    labelText: LanguageStrings.lblConfirmPassword,
                    textInputAction: TextInputAction.done,
                    textInputType: TextInputType.text,
                    validator: (confirmPassword) {
                      if (confirmPassword != null &&
                          confirmPassword.isNotEmpty) {
                        return null;
                      }
                      return LanguageStrings.lblEnterDetails;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  BlocConsumer<SignUpCubit, SignUpState>(
                    listener: (final context, final state) {
                      if (state is SignUpSuccess) {
                        HiveRepository.setUsername =
                            _nameController.text.trim().toString();
                        HiveRepository.setUserLoggedIn = true;
                        HiveRepository.setUserId = state.userData.uid;

                        context.pushNamedAndRemoveUntil(Routes.homeScreen);
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
                        child = const CustomCircularProgressIndicator(
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
                          child: child);
                    },
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: context.width * 0.4,
                        child: Divider(
                          height: 1,
                          thickness: 0.5,
                          color: AppColors.lightGreyColor,
                        ),
                      ),
                      const Text(" ${LanguageStrings.lblOr} "),
                      SizedBox(
                        width: context.width * 0.4,
                        child: Divider(
                          height: 1,
                          thickness: 0.5,
                          color: AppColors.lightGreyColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      context.pop();
                    },
                    child: const Text.rich(
                      TextSpan(
                          text: "${LanguageStrings.lblAlreadyHaveAnAccount} ",
                          style: TextStyle(
                              color: AppColors.blackColors,
                              fontWeight: FontWeight.w500),
                          children: [
                            TextSpan(
                                text: LanguageStrings.lblLogin,
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
      ),
    );
  }
}
