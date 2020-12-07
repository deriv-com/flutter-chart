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
    this.child,
  }) : super(key: key);

  /// List of animations that build will listen to.
  final List<Listenable> animations;

  /// Called every time the animation changes value.
  final TransitionBuilder builder;

  /// The child widget to pass to the [builder].
  ///
  /// If a [builder] callback's return value contains a subtree that does not
  /// depend on the animation, it's more efficient to build that subtree once
  /// instead of rebuilding it on every animation tick.
  ///
  /// If the pre-built subtree is passed as the [child] parameter, the
  /// [AnimatedBuilder] will pass it back to the [builder] function so that it
  /// can be incorporated into the build.
  ///
  /// Using this pre-built child is entirely optional, but can improve
  /// performance significantly in some cases and is therefore a good practice.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget result = AnimatedBuilder(
      animation: animations.first,
      builder: builder,
    );

    for (final Listenable animation in animations.skip(1)) {
      result = AnimatedBuilder(
        animation: animation,
        builder: builder,
      );
    }

    return result;
  }
}
