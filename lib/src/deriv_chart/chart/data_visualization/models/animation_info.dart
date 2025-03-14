import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer.dart';

/// A class that hold animation progress values.
class AnimationInfo {
  /// Initializes
  const AnimationInfo({
    this.currentTickPercent = 1,
    this.blinkingPercent = 1,
    this.stateChangePercent = 1,
  });

  /// Animation percent of current tick.
  final double currentTickPercent;

  /// Animation percent of blinking dot in current tick.
  final double blinkingPercent;

  /// Animation percent of [InteractiveLayer] state change.
  final double stateChangePercent;
}
