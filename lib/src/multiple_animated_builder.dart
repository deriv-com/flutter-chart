import 'package:flutter/material.dart';

/// Convenience widget that combines multiple nested [AnimatedBuilder].
///
/// ```
/// MultipleAnimatedBuilder(
///   animations: [_anim1, anim2],
///   builder: ...,
/// );
/// ```
/// is equivalent to
/// ```
/// AnimatedBuilder(
///   animation: anim1,
///   builder: (context, child) => AnimatedBuilder(
///     animation: anim2,
///     builder: ...,
///   ),
/// )
/// ```
class MultipleAnimatedBuilder extends StatelessWidget {
  /// Create multiple animated builder.
  const MultipleAnimatedBuilder({
    Key key,
    @required this.animations,
    @required this.builder,
  }) : super(key: key);

  /// List of animations that build will listen to.
  final List<Listenable> animations;

  /// Called every time any of the animations changes value.
  final TransitionBuilder builder;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(animations),
      builder: builder,
    );
  }
}
