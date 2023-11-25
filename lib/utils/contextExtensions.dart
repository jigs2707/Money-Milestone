import 'package:flutter/material.dart';

extension Appcontext on BuildContext {
  get width => MediaQuery.sizeOf(this).width;

  get height => MediaQuery.sizeOf(this).height;

  pushNamed(String route) {
    Navigator.pushNamed(this, route);
  }

  pushReplacementNamed(String route,
      {required Map<String, dynamic> arguments}) {
    Navigator.pushReplacementNamed(this, route, arguments: arguments);
  }

  pop() {
    Navigator.pop(this);
  }
}
