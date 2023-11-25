
import 'package:flutter/material.dart';
import 'package:my_financial_goals/utils/colors.dart';

class CustomCircularProgressIndicator extends StatelessWidget {
  const CustomCircularProgressIndicator({
    final Key? key,
    this.color,
    this.strokeWidth,
    this.widthAndHeight,
  }) : super(key: key);
  final Color? color;
  final double? strokeWidth;
  final double? widthAndHeight;

  @override
  Widget build(final BuildContext context) => Center(
        child: SizedBox(
          height: widthAndHeight ?? 30,
          width: widthAndHeight ?? 30,
          child: CircularProgressIndicator.adaptive(
            strokeWidth: strokeWidth ?? 3,
            backgroundColor: color ?? AppColors.accentColor,
          ),
        ),
      );
}
