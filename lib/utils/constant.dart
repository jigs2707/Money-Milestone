import 'package:flutter/material.dart';

class Constant {
  static const String appName = "My financial Gooals";

  ///Duration in Second
  static const int splashScreenDuration = 3;
  static const int messageDisplayDuration = 3;

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
