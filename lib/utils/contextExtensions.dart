import 'package:flutter/material.dart';

extension Appcontext on BuildContext {
  get width => MediaQuery.sizeOf(this).width;

  get height => MediaQuery.sizeOf(this).height;

  pushNamed(String route, {Map<String, dynamic>? arguments}) {
    Navigator.pushNamed(this, route, arguments: arguments);
  }

  pushReplacementNamed(String route, {Map<String, dynamic>? arguments}) {
    Navigator.pushReplacementNamed(this, route, arguments: arguments);
  }

  pop([result]) {
    Navigator.pop(this, result);
  }

  pushNamedAndRemoveUntil(String route, {Map<String, dynamic>? arguments}) {
    Navigator.pushNamedAndRemoveUntil(this, route, (route) => false);
  }
}
