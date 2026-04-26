import 'package:flutter/material.dart';
import 'package:money_milestone/utils/app_colors_extension.dart';

/// Premium 3-dot pulsing loader for use inside buttons.
/// Each dot fades in/out with a staggered delay — no heavy animation overhead.
/// Uses a single [AnimationController] properly disposed in State.
class CustomCircularProgressIndicator extends StatefulWidget {
  const CustomCircularProgressIndicator({
    super.key,
    this.color,
    this.size = 7.0,
    // kept for legacy compat — ignored
    this.strokeWidth,
    this.widthAndHeight,
  });

  final Color? color;
  final double size;
  final double? strokeWidth;
  final double? widthAndHeight;

  @override
  State<CustomCircularProgressIndicator> createState() =>
      _CustomCircularProgressIndicatorState();
}

class _CustomCircularProgressIndicatorState
    extends State<CustomCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = widget.color ?? context.colors.whiteColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final start = i * 0.2;
        final end = start + 0.6;
        return _Dot(
          ctrl: _ctrl,
          color: dotColor,
          size: widget.size,
          interval: Interval(start, end, curve: Curves.easeInOut),
        );
      }),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    required this.ctrl,
    required this.color,
    required this.size,
    required this.interval,
  });

  final AnimationController ctrl;
  final Color color;
  final double size;
  final Interval interval;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final t = interval.transform(ctrl.value);
        final scale = 0.6 + 0.4 * t;
        final opacity = 0.35 + 0.65 * t;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: size * 0.35),
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
