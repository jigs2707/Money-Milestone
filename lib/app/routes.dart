import 'package:my_financial_goals/screens/ui/homepage.dart';
import 'package:my_financial_goals/screens/ui/logInScreen.dart';
import 'package:my_financial_goals/screens/ui/signUpScreen.dart';
import 'package:my_financial_goals/screens/ui/splashScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Routes {
  //
  static const  String splashRoute = "/";
  static const String logInScreen = "/logIn";
  static const String signUpScreen = "/signUp";
  static const String homeScreen = "/home";

  static String currentRoute = splashRoute;
  static String previousRoute = "";
  static String secondPreviousRoute = "";

  static Route<dynamic> onGeneratedRoute(final RouteSettings routeSettings) {
    previousRoute = currentRoute;
    currentRoute = routeSettings.name ?? "";

    switch (routeSettings.name) {

      case splashRoute:
        return SplashScreen.route(routeSettings);

 
      case logInScreen:
        return LogInScreen.route(routeSettings);

      case signUpScreen:
        return SignUpScreen.route(routeSettings);

      case homeScreen:
        return HomeScreen.route(routeSettings);


      default:
        return CupertinoPageRoute(
          builder: (final _) => const Scaffold(
            body: Center(child: Text("something went wrong")),
          ),
        );
    }
  }
}
