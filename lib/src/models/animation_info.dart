/// A class that hold animation progress values.
class AnimationInfo {
  /// Initializes
  const AnimationInfo({this.currentTickPercent = 1, this.blinkingPercent = 1});

  /// Animation percent of current tick.
  final double currentTickPercent;

  /// Animation percent of blinking dot in current tick.
  final double blinkingPercent;
}
