
import 'package:flutter/material.dart';
import 'package:money_milestone/utils/colors.dart';
import 'package:money_milestone/utils/app_colors_extension.dart';
import 'package:shimmer/shimmer.dart';

class CustomShimmerLoadingWidget extends StatelessWidget {
  CustomShimmerLoadingWidget(
      {final Key? key, this.height, this.width, this.borderRadius, this.margin})
      : super(key: key);
  final double? height;
  final double? width;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(final BuildContext context) => Shimmer.fromColors(
    baseColor: context.colors.shimmerBaseColor,
    highlightColor: context.colors.shimmerHighlightColor,
    child: Container(
      width: width,
      margin: margin,
      height: height ?? 10,
      decoration: BoxDecoration(

        color: context.colors.shimmerContentColor,
        borderRadius: BorderRadius.circular( borderRadius ?? 10),
      ),

    ),
  );
}
