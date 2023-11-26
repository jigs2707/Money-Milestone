import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:money_milestone/screens/widgets/messageContainer.dart';
import 'package:money_milestone/utils/colors.dart';
import 'package:money_milestone/utils/constant.dart';

class Utils {
  static void removeFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static LinearGradient gradiant() {
    return const LinearGradient(
      colors: [
        AppColors.gradiantTopColor,
        AppColors.gradiantBottomColor,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static Future<Object?> showAnimatedDialog(
      {required BuildContext context, required Widget child}) async {
    Object? result = await showGeneralDialog(
      context: context,
      pageBuilder: (final context, final animation, final secondaryAnimation) =>
          const SizedBox(),
      transitionBuilder: (final context, final animation,
              final secondaryAnimation, Widget _) =>
          Transform.scale(
        scale: Curves.easeInOut.transform(animation.value),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: child,
          ),
        ),
      ),
    );
    return result;
  }

  static Future<void> showMessage(final BuildContext context, final String text,
      final MessageType type) async {
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
