import 'package:money_milestone/screens/ui/goalDetailsScreen.dart';
import 'package:money_milestone/screens/ui/homeScreen.dart';
import 'package:money_milestone/screens/ui/logInScreen.dart';
import 'package:money_milestone/screens/ui/profileScreen.dart';
import 'package:money_milestone/screens/ui/signUpScreen.dart';
import 'package:money_milestone/screens/ui/splashScreen.dart';
import 'package:flutter/material.dart';

class Routes {
  // Route names
  static const String splashRoute = "/";
  static const String logInScreen = "/logIn";
  static const String signUpScreen = "/signUp";
  static const String homeScreen = "/home";
  static const String goalDetailsScreen = "/goalDetails";
  static const String profileScreen = "/profile";

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

      case profileScreen:
        return ProfileScreen.route(routeSettings);

      default:
        return MaterialPageRoute(
          builder: (final _) => const Scaffold(
            body: Center(child: Text("Something went wrong")),
          ),
        );
    }
  }
}
