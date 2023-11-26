import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:money_milestone/utils/colors.dart';


class BackgroundWidget extends StatelessWidget {
  const BackgroundWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PositionedDirectional(
          top: -150,
          start: -150,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentColor.withOpacity(0.3),
              ),
              width: 400,
              height: 400,
            ),
          ),
        ),
        PositionedDirectional(
          bottom: -70,
          end: -70,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentColor.withOpacity(0.3),
              ),
              width: 200,
              height: 200,
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: child,
        )
      ],
    );
  }
}
