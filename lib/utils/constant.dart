import 'package:flutter/material.dart';

class Constant {
  static const String appName = "Money Milestone";

  ///Duration in Second
  static const int splashScreenDuration = 3;
  static const int messageDisplayDuration = 3;
  static const int goalPercentageAnimationDuration = 1;

  static const int numberOfShimmerLoadingWidget = 5;

  static const String currencySymbol = "₹";

  static const String dateFormat = "dd/MM/yyyy";

  static const int numberOfDecimalPointAfterAmount = 2;

  static const int showCalenderTillDays = 30000;
}

// to manage snackBar/toast/message
enum MessageType { success, error, warning }

Map<MessageType, Color> messageColors = {
  MessageType.success: Colors.green,
  MessageType.error: Colors.red,
  MessageType.warning: Colors.orange
};

Map<MessageType, IconData> messageIcon = {
  MessageType.success: Icons.done_rounded,
  MessageType.error: Icons.error_outline_rounded,
  MessageType.warning: Icons.warning_amber_rounded
};
