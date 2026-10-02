import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer.dart';

/// A class that hold animation progress values.
class AnimationInfo {
  /// Initializes
  const AnimationInfo({
    this.currentTickPercent = 1,
    this.blinkingPercent = 1,
    this.stateChangePercent = 1,
    this.accumulatorPreviewPercent = 1,
    this.accumulatorLabelEmphasis = 0,
    this.accumulatorGuidePulse = 0,
  });

  /// Animation percent of current tick.
  final double currentTickPercent;

  /// Animation percent of blinking dot in current tick.
  final double blinkingPercent;

  /// Animation percent of [InteractiveLayer] state change.
  final double stateChangePercent;

  /// Animation percent of the Accumulators barrier band gliding from one growth
  /// rate to the next while it is being dragged.
  ///
  /// Separate from [currentTickPercent] because rungs are crossed far faster
  /// than a tick animation runs, so this one has to be restartable mid-flight.
  final double accumulatorPreviewPercent;

  /// How emphasised the Accumulators barrier labels are, 0 at rest and 1 while
  /// the growth rate is being changed.
  ///
  /// The labels are the values the change is actually moving, so they grow and
  /// thicken while it is in flight to say so.
  final double accumulatorLabelEmphasis;

  /// Where the Accumulators tap hint is in its loop, 0 to 1.
  ///
  /// Unlike the others this one does not run towards anything: it repeats for
  /// as long as the hint is up, and the hint's shape is derived from it.
  final double accumulatorGuidePulse;
}
