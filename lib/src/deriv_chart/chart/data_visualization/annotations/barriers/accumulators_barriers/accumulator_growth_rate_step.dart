import 'package:flutter/foundation.dart';

/// A single selectable position on the Accumulators growth-rate ladder.
///
/// The consumer supplies one of these per growth rate the user is allowed to
/// pick. [barrierSpotDistance] is what the chart snaps to while dragging: it is
/// the distance, in quote units, between the spot and each barrier for this
/// growth rate.
@immutable
class AccumulatorGrowthRateStep {
  /// Initializes a step of the growth-rate ladder.
  const AccumulatorGrowthRateStep({
    required this.growthRate,
    required this.barrierSpotDistance,
    this.barrierSpotDistanceDisplay,
    this.growthRateDisplay,
  });

  /// The growth rate this step selects, as a fraction (e.g. `0.03` for 3%).
  final double growthRate;

  /// Distance in quote units between the spot and each barrier at this step.
  ///
  /// Always positive. The band this step represents spans
  /// `spot - barrierSpotDistance` to `spot + barrierSpotDistance`.
  final double barrierSpotDistance;

  /// Pre-formatted [barrierSpotDistance] for the `±` labels next to the
  /// barriers. Falls back to the indicator's own value when omitted.
  final String? barrierSpotDistanceDisplay;

  /// Pre-formatted [growthRate] (e.g. `'3%'`), for consumers that echo the
  /// value back in their own UI.
  final String? growthRateDisplay;

  @override
  bool operator ==(Object other) =>
      other is AccumulatorGrowthRateStep &&
      other.growthRate == growthRate &&
      other.barrierSpotDistance == barrierSpotDistance &&
      other.barrierSpotDistanceDisplay == barrierSpotDistanceDisplay &&
      other.growthRateDisplay == growthRateDisplay;

  @override
  int get hashCode => Object.hash(
        growthRate,
        barrierSpotDistance,
        barrierSpotDistanceDisplay,
        growthRateDisplay,
      );

  @override
  String toString() => 'AccumulatorGrowthRateStep(growthRate: $growthRate, '
      'barrierSpotDistance: $barrierSpotDistance)';
}
