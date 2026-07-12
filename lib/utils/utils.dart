import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:money_milestone/screens/widgets/messageContainer.dart';
import 'package:money_milestone/utils/app_colors_extension.dart';
import 'package:money_milestone/utils/constant.dart';

class Utils {
  static void removeFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static LinearGradient gradiant(BuildContext context) {
    return LinearGradient(
      colors: [
        context.colors.gradiantTopColor,
        context.colors.gradiantBottomColor,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get premiumGradient => const LinearGradient(
        colors: [Color(0xff6C47FF), Color(0xff5A35EE)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

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

  /// Premium slide-up bottom sheet — use for all forms
  static Future<Object?> showPremiumSheet(
      {required BuildContext context, required Widget child}) async {
    final result = await showModalBottomSheet<Object>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (modalCtx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Padding(
          // Moves sheet up when keyboard appears — must use modalCtx so it
          // rebuilds reactively when the keyboard opens inside the sheet.
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: context.colors.isDarkMode
                  ? const Color(0xff141829)
                  : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: context.colors.accentColor.withValues(alpha: 0.18),
                width: 1.2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.colors.lightGreyColor.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                child,
                // bottom safe-area pad
                SizedBox(height: MediaQuery.of(modalCtx).padding.bottom + 8),
              ],
            ),
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
