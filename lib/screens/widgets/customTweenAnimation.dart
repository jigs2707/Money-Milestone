import 'package:flutter/material.dart';

class CustomTweenAnimation extends StatelessWidget {

  const CustomTweenAnimation({super.key, this.durationInSeconds, required this.beginValue, required this.endValue, required this.curve, required this.builder});
  final ValueWidgetBuilder<double> builder;
  final int? durationInSeconds;
  final double beginValue;
  final double endValue;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: beginValue, end: endValue),
      curve: curve,
      duration: Duration(seconds: durationInSeconds ?? 2),
      builder: (BuildContext context, Object? value, Widget? child) => builder(context, double.parse(value.toString()), child),
    );
  }
}