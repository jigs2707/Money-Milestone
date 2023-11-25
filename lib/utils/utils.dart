import 'package:flutter/material.dart';
import 'package:my_financial_goals/app/generalImports.dart';

class Utils {
  static void removeFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static Future<void> showMessage(final BuildContext context, final String text,
      final MessageType type) async {
        print("called here");
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry; 
    overlayEntry = OverlayEntry(
      builder: (final context) => Positioned(
        left: 5,
        right: 5,
        bottom: 15,
        child: MessageContainer(
          context: context,
          text: text,
          type: type,
        ),
      ),
    );
    overlayState.insert(overlayEntry);
    await Future.delayed(
        const Duration(seconds: Constant.messageDisplayDuration));

    overlayEntry.remove();
  }
}
