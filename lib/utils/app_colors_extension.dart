import 'package:flutter/material.dart';

class ContextColors {
  final BuildContext context;
  ContextColors(this.context);

  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;

  // Background layers
  Color get primaryColor => isDarkMode ? const Color(0xff0B0F1A) : const Color(0xffF0F2FF);
  Color get secondaryColor => isDarkMode ? const Color(0xff141829) : const Color(0xffFFFFFF);
  Color get surfaceColor => isDarkMode ? const Color(0xff1C2135) : const Color(0xffF8F9FF);

  // Brand accent — electric indigo / violet
  Color get accentColor => const Color(0xff6C47FF);
  Color get accentLightColor => isDarkMode ? const Color(0xff8B6FFF) : const Color(0xff5A35EE);

  // Gold highlight
  Color get goldColor => const Color(0xffF5A623);
  Color get goldLightColor => const Color(0xffFFD085);

  // Gradient pair (indigo → violet)
  Color get gradiantTopColor => isDarkMode ? const Color(0xff8B6FFF) : const Color(0xff6C47FF);
  Color get gradiantBottomColor => isDarkMode ? const Color(0xff4B32CC) : const Color(0xff5A35EE);

  // Semantic colours
  Color get greenColor => isDarkMode ? const Color(0xff34D399) : const Color(0xff059669);
  Color get redColor => isDarkMode ? const Color(0xffF87171) : const Color(0xffDC2626);
  Color get ratingStarColor => const Color(0xffF5A623);

  // Text
  Color get blackColors => isDarkMode ? const Color(0xffF1F3FF) : const Color(0xff0D0F1E);
  Color get lightGreyColor => isDarkMode ? const Color(0xff8892B0) : const Color(0xff6B7280);
  Color get whiteColors => Colors.white;

  // Card glass tint
  Color get cardGlassColor =>
      isDarkMode ? const Color(0xff1C2135).withValues(alpha: 0.75) : const Color(0xffFFFFFF).withValues(alpha: 0.72);
  Color get cardBorderColor =>
      isDarkMode ? const Color(0xff6C47FF).withValues(alpha: 0.18) : const Color(0xff6C47FF).withValues(alpha: 0.14);

  // Shimmer
  Color get shimmerBaseColor =>
      isDarkMode ? const Color(0xff1C2135) : const Color(0xffE8EAFF);
  Color get shimmerHighlightColor =>
      isDarkMode ? const Color(0xff2A3050) : const Color(0xffD0D4FF);
  Color get shimmerContentColor => isDarkMode ? Colors.black : Colors.white;
}

extension AppColorsExtension on BuildContext {
  ContextColors get colors => ContextColors(this);
}
