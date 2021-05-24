import 'dart:math';

import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'models/animation_info.dart';

/// Conversion function to convert epoch value to canvas X.
typedef EpochToX = double Function(int);

/// Conversion function to convert value(quote) value to canvas Y.
typedef QuoteToY = double Function(double);

/// Any data that the chart takes and makes it paint its self on the chart's canvas including
/// Line, CandleStick data, Markers, barriers etc..
abstract class ChartData {
  /// The ID of this [ChartData].
  ///
  /// [id] is used to recognize an old [ChartData] with its new version after chart being updated.
  /// Doing so makes the chart able to perform live update animation.
  String id;

  /// Will be called by the chart when it was updated.
  ///
  /// Returns `true` if this chart data has changed with the chart widget update.
  bool didUpdate(ChartData oldData);

  /// Checks if this ChartData needs to repaint with the chart widget's new frame.
  bool shouldRepaint(ChartData oldData);

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

  /// Minimum epoch of this [ChartData] on the chart's X-Axis.
  ///
  /// The chart calls this on any of its [ChartData]s and gets their minimum epoch
  /// then sets its X-Axis leftmost scroll limit based on them.
  int getMinEpoch();

  /// Maximum epoch of this [ChartData] on the chart's X-Axis.
  ///
  /// The chart uses it same as [getMinEpoch] to determine its rightmost scroll limit.
  int getMaxEpoch();

  /// Paints this [ChartData] on the given [canvas].
  ///
  /// [Size] is the size of the [canvas].
  ///
  /// [epochToX] and [quoteToY] are conversion functions in the chart's coordinate system.
  /// They respectively convert epoch to canvas X and quote to canvas Y.
  ///
  /// [animationInfo] Contains animations progress values in this frame of painting.
  ///
  /// [ChartConfig] is the chart's config which consist of
  ///   - `pipSize` Number of decimal digits [ChartData] must use when showing their prices.
  ///   - `granularity` Duration of 1 candle in ms (for ticks: average ms difference between ticks).
  ///
  /// [theme] Chart's theme
  void paint(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme theme,
  );
}

/// An extension on Iterable with [ChartData] elements.
extension ChartDataListExtension on Iterable<ChartData> {
  /// Gets the minimum of [ChartData.getMinEpoch]s.
  int getMinEpoch() =>
      _getEpochWithPredicate((ChartData c) => c?.getMinEpoch(), min);

  /// Gets the maximum of [ChartData.getMaxEpoch]s.
  int getMaxEpoch() =>
      _getEpochWithPredicate((ChartData c) => c?.getMaxEpoch(), max);

  int _getEpochWithPredicate(
    int Function(ChartData) getEpoch,
    int Function(int, int) epochComparator,
  ) {
    final Iterable<int> maxEpochs =
        map((ChartData c) => getEpoch(c)).where((int epoch) => epoch != null);

    return maxEpochs.isNotEmpty
        ? maxEpochs
            .reduce((int current, int next) => epochComparator(current, next))
        : null;
  }

  /// Gets the minimum of [ChartData.minValue]s.
  double getMinValue() {
    final List<ChartData> chartData = this;
    if (chartData != null) {
      final Iterable<double> minValues = chartData
          .where((ChartData c) => c != null && !c.minValue.isNaN)
          .map((ChartData e) => e.minValue);
      return minValues.isEmpty ? double.nan : minValues.reduce(min);
    }
    return double.nan;
  }

  /// Gets the maximum of [ChartData.maxValue]s.
  double getMaxValue() {
    final List<ChartData> chartData = this;
    if (chartData != null) {
      final Iterable<double> maxValues = chartData
          .where((ChartData c) => c != null && !c.maxValue.isNaN)
          .map((e) => e.maxValue);
      return maxValues.isEmpty ? double.nan : maxValues.reduce(max);
    }
    return double.nan;
  }
}
