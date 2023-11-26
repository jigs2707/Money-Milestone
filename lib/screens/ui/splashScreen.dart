// ignore_for_file: file_names, use_build_context_synchronously

import 'package:money_milestone/app/routes.dart';
import 'package:money_milestone/data/repository/hiveRepository.dart';
import 'package:money_milestone/utils/constant.dart';
import 'package:money_milestone/utils/colors.dart';
import 'package:money_milestone/utils/contextExtensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money_milestone/utils/utils.dart';

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
      if (HiveRepository.isUserLoggedIn) {
        context.pushReplacementNamed(Routes.homeScreen);
      } else {
        context.pushReplacementNamed(Routes.logInScreen);
      }
    });
    super.initState();
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
          body: Container(
        height: context.height,
        width: context.width,
        decoration: BoxDecoration(gradient: Utils.gradiant()),
        child: const Center(
          child: Text(
            Constant.appName,
            style: TextStyle(
                color: AppColors.whiteColors,
                fontWeight: FontWeight.bold,
                fontSize: 42),
          ),
        ),
      ));
}
