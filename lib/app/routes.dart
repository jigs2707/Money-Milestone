import 'package:money_milestone/screens/ui/goalDetailsScreen.dart';
import 'package:money_milestone/screens/ui/homeScreen.dart';
import 'package:money_milestone/screens/ui/logInScreen.dart';
import 'package:money_milestone/screens/ui/signUpScreen.dart';
import 'package:money_milestone/screens/ui/splashScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Routes {
  //route names
  static const String splashRoute = "/";
  static const String logInScreen = "/logIn";
  static const String signUpScreen = "/signUp";
  static const String homeScreen = "/home";
  static const String goalDetailsScreen = "/goalDetails";

  //
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

      case goalDetailsScreen:
        return GoalDetailsScreen.route(routeSettings);


      default:
        return CupertinoPageRoute(
          builder: (final _) => const Scaffold(
            body: Center(child: Text("something went wrong")),
          ),
        );
    }
  }
}
