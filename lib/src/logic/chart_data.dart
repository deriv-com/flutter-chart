import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:flutter/material.dart';

typedef EpochToX = double Function(int);
typedef QuoteToY = double Function(double);

/// Any data that the chart takes and makes it paint its self on the chart's canvas including
/// Line, CandleStick data, Markers, barriers etc..
abstract class ChartData {
  /// The ID of this [ChartData]
  String id;

  /// Will be called by the chart when it was updated.
  void didUpdate(ChartData oldData);

  /// Updates this [ChartData] after tye chart's epoch boundaries changes.
  void update(int leftEpoch, int rightEpoch);

  /// The minimum value this [ChartData] has at the current X-Axis epoch range after [update] is called.
  ///
  /// [double.nan] should be returned if this [ChartData] doesn't have any element to have a minimum value.
  double get minValue;

  /// The maximum value this [ChartData] has at the current X-Axis epoch range after [update] is called.
  ///
  /// [double.nan] should be returned if this [ChartData] doesn't have any element to have a maximum value.
  double get maxValue;

  /// Paints this [ChartData] on the given [canvas].
  ///
  /// [Size] is the size of the [canvas].
  ///
  /// [epochToX] and [quoteToY] are the conversion functions
  /// to convert epoch to canvas X and quote to canvas Y.
  ///
  /// [animationInfo] Contains animations progress values in this frame of painting.
  ///
  /// [pipSize] Number of decimal digits [ChartData] must use when showing their prices.
  ///
  /// [granularity] Duration of 1 candle in ms (for ticks: average ms difference between ticks).
  void paint(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    int pipSize,
    int granularity,
  );
}
