import 'dart:io';

import 'package:money_milestone/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money_milestone/utils/utils.dart';

class CustomRoundedButton extends StatelessWidget {
  const CustomRoundedButton({
    required this.buttonTitle,
    required this.showBorder,
    required this.widthPercentage,
    this.backgroundColor,
    final Key? key,
    this.child,
    this.maxLines,
    this.borderColor,
    this.elevation,
    this.onTap,
    this.radius,
    this.shadowColor,
    this.height,
    this.titleColor,
    this.fontWeight,
    this.textSize,
    this.borderRadius
  }) : super(key: key);
  final String buttonTitle;
  final double? height;
  final double widthPercentage;
  final Function? onTap;
  final Color? backgroundColor;
  final double? radius;
  final Color? shadowColor;
  final bool showBorder;
  final Color? borderColor;
  final Color? titleColor;
  final double? textSize;
  final FontWeight? fontWeight;
  final double? elevation;
  final int? maxLines;
  final Widget? child;
  final BorderRadius? borderRadius;

  @override
  Widget build(final BuildContext context) => SizedBox(
        height: height ?? 48,
        width: MediaQuery.sizeOf(context).width * widthPercentage,
        child: Platform.isIOS
            ? CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                alignment: Alignment.center,
                onPressed: onTap as void Function()?,
                color: backgroundColor ?? AppColors.secondaryColor,
                borderRadius: borderRadius?? BorderRadius.circular(radius ?? 10),
                child: Center(
                  child: child ??
                      Text(
                        buttonTitle,
                        maxLines: maxLines ?? 2,
                        style: TextStyle(
                          fontSize: textSize ?? 18.0,
                          color: titleColor ?? AppColors.blackColors,
                          fontWeight: fontWeight ?? FontWeight.normal,
                        ),
                      ),
                ),
              )
            : MaterialButton(
                height: height ?? 48.0,
                padding: const EdgeInsets.symmetric(horizontal: 0),
                visualDensity: VisualDensity.standard,
                textColor: titleColor,
                focusElevation: 0.1,
                enableFeedback: true,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: showBorder
                        ? borderColor ?? AppColors.accentColor
                        : Colors.transparent,
                  ),
                  borderRadius:borderRadius ?? BorderRadius.all(Radius.circular(radius ?? 10)),
                ),
                onPressed: onTap as void Function()?,
                elevation: elevation ?? 0.0,

                color: backgroundColor,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: backgroundColor != null? null :Utils.gradiant(),
                    borderRadius:borderRadius?? BorderRadius.circular(radius ??10)


                  ),
                  child: Center(
                    child: child ??
                        Text(
                          buttonTitle,
                          maxLines: maxLines ?? 2,
                          style: TextStyle(
                            fontSize: textSize ?? 18.0,
                            color: titleColor ?? AppColors.blackColors,
                            fontWeight: fontWeight ?? FontWeight.normal,
                          ),
                        ),
                  ),
                ),
              ),
      );
}
