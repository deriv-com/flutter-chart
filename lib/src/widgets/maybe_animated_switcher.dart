import 'package:deriv_chart/src/theme/design_tokens/core_design_tokens.dart';
import 'package:flutter/material.dart';

/// {@template maybe_animated_switcher}
/// A widget that conditionally wraps its child in an [AnimatedSwitcher]
/// if [enabled] is true. Otherwise, it just returns the child.
/// {@endtemplate}
class MaybeAnimatedSwitcher extends StatelessWidget {
  /// {@macro maybe_animated_switcher}
  const MaybeAnimatedSwitcher({
    required this.enabled,
    required this.duration,
    required this.child,
    Key? key,
    this.switchInCurve = CoreDesignTokens.coreMotionEase400,
    this.switchOutCurve = CoreDesignTokens.coreMotionEase400,
  }) : super(key: key);

  /// Whether to animate the child.
  ///
  /// If [enabled] is false, the child will not be animated.
  final bool enabled;

  /// The duration of the animation.
  final Duration duration;

  /// The child to wrap in an [AnimatedSwitcher].
  final Widget child;

  /// The curve to use for the animation when the child is being switched in.
  final Curve switchInCurve;

  /// The curve to use for the animation when the child is being switched out.
  final Curve switchOutCurve;

  @override
  Widget build(BuildContext context) {
    if (enabled) {
      return AnimatedSwitcher(
        duration: duration,
        switchInCurve: switchInCurve,
        switchOutCurve: switchOutCurve,
        child: child,
      );
    }
    return child;
  }
}
