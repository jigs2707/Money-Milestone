import 'package:flutter/material.dart';

/// Lightweight fade + slide-up entrance animation.
/// Uses [TweenAnimationBuilder] — no AnimationController needed, no leaks.
///
/// [delay]  — stagger delay before the animation starts.
/// [offset] — starting Y offset in logical pixels (default 24).
/// [duration] — total animation duration (default 400ms).
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 24.0,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOut,
  });

  final Widget child;
  final Duration delay;
  final double offset;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    // Wrap in a FutureBuilder that resolves after [delay] to trigger rebuild.
    if (delay == Duration.zero) {
      return _AnimatedBody(
          child: child, offset: offset, duration: duration, curve: curve);
    }
    return _DelayedFadeSlide(
        child: child, delay: delay, offset: offset, duration: duration, curve: curve);
  }
}

class _AnimatedBody extends StatelessWidget {
  const _AnimatedBody(
      {required this.child,
      required this.offset,
      required this.duration,
      required this.curve});

  final Widget child;
  final double offset;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: curve,
      builder: (context, value, _) => Opacity(
        opacity: value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, offset * (1 - value)),
          child: child,
        ),
      ),
    );
  }
}

/// Delays the animation start using a StatefulWidget that triggers a rebuild
/// after [delay], no AnimationController required.
class _DelayedFadeSlide extends StatefulWidget {
  const _DelayedFadeSlide({
    required this.child,
    required this.delay,
    required this.offset,
    required this.duration,
    required this.curve,
  });

  final Widget child;
  final Duration delay;
  final double offset;
  final Duration duration;
  final Curve curve;

  @override
  State<_DelayedFadeSlide> createState() => _DelayedFadeSlideState();
}

class _DelayedFadeSlideState extends State<_DelayedFadeSlide> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _started = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _started ? 1.0 : 0.0),
      duration: _started ? widget.duration : Duration.zero,
      curve: widget.curve,
      builder: (context, value, _) => Opacity(
        opacity: value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - value)),
          child: widget.child,
        ),
      ),
    );
  }
}
