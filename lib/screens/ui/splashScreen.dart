// ignore_for_file: file_names, use_build_context_synchronously

import 'package:my_financial_goals/app/routes.dart';
import 'package:my_financial_goals/utils/constant.dart';
import 'package:my_financial_goals/utils/colors.dart';
import 'package:my_financial_goals/utils/contextExtensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({final Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();

  static Route route(final RouteSettings routeSettings) => CupertinoPageRoute(
        builder: (final _) => const SplashScreen(),
      );
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: Constant.splashScreenDuration), () {
      context.pushNamed(Routes.logInScreen);
    });
    super.initState();
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
          body: Container(
        height: context.height,
        width: context.width,
        color: AppColors.accentColor,
      ));
}
