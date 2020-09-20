import 'dart:math';

import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/sample_multi_renderable.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_series.dart';
import 'package:deriv_chart/src/logic/chart_series/renderable.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

import 'ma_series.dart';

/// A sample class just to examine how a custom indicator with multiple data-series can be implemented in this structure.
///
/// Can also extend from a concrete implementation of [Series] like [LineSeries] and instead of two only
/// define one nested series. In that case, since we override [createRenderable]
/// and set value for [rendererable] we should have another Renderable inside this class.
///
/// Or we can directly implement [ChartData] interface.
class SampleMultiSeries extends Series {
  /// Initializes
  SampleMultiSeries(List<Tick> entries, {String id})
      : series1 = MASeries(entries, period: 10),
        series2 = MASeries(entries, period: 20),
        super(id);

  /// Series 1
  final MASeries series1;

  /// Series 2
  final MASeries series2;

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    series1.update(leftEpoch, rightEpoch);
    series2.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() => <double>[
        min(series1.minValue, series2.minValue),
        max(series1.maxValue, series2.maxValue),
      ];

  @override
  Rendererable<SampleMultiSeries> createRenderable() =>
      SampleMultiRenderable(this);

  @override
  void didUpdate(ChartData oldData) {
    final SampleMultiSeries old = oldData;

    series1.didUpdate(old.series1);
    series2.didUpdate(old.series2);
  }

  @override
  void paint(
    Canvas canvas,
    Size size,
    double Function(int) epochToX,
    double Function(double) quoteToY,
    AnimationInfo animationInfo,
    int pipSize,
    int granularity,
  ) {
    super.paint(
        canvas, size, epochToX, quoteToY, animationInfo, pipSize, granularity);

    series1.paint(
        canvas, size, epochToX, quoteToY, animationInfo, pipSize, granularity);
    series2.paint(
        canvas, size, epochToX, quoteToY, animationInfo, pipSize, granularity);
  }
}
