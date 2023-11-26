
import 'package:flutter/material.dart';
import 'package:money_milestone/utils/colors.dart';
import 'package:shimmer/shimmer.dart';

class CustomShimmerLoadingWidget extends StatelessWidget {
  const CustomShimmerLoadingWidget(
      {final Key? key, this.height, this.width, this.borderRadius, this.margin})
      : super(key: key);
  final double? height;
  final double? width;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(final BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.shimmerBaseColor,
    highlightColor: AppColors.shimmerHighlightColor,
    child: Container(
      width: width,
      margin: margin,
      height: height ?? 10,
      decoration: BoxDecoration(

        color: AppColors.shimmerContentColor,
        borderRadius: BorderRadius.circular( borderRadius ?? 10),
      ),

    ),
  );
}
