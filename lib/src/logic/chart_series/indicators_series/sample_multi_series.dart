import 'dart:math';

import 'package:deriv_chart/src/logic/component.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/sample_multi_renderable.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/indicators/indicators.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

/// A sample class just to examine how a custom indicator with multiple data-series can be implemented in this structure.
///
/// Can also extend from a concrete implementation of [Series] like [LineSeries] and instead of two only
/// define one nested series. In that case, since we override [createRenderable]
/// and set value for [rendererable] we should have another Renderable inside this class.
///
/// Or we can directly implement [Component] interface.
class SampleMultiSeries extends Series<Tick> {
  /// Initializes
  SampleMultiSeries(List<Tick> entries, String id)
      : series1 = LineSeries(
          MovingAverage.movingAverage(entries, 10),
          's1',
          style: const LineStyle(hasArea: false),
        ),
        series2 = LineSeries(
          MovingAverage.movingAverage(entries, 20),
          's2',
          style: const LineStyle(hasArea: false),
        ),
        super(entries, id);

  /// Series 1
  final LineSeries series1;

  /// Series 2
  final LineSeries series2;

  @override
  void update(int leftEpoch, int rightEpoch) {
    series1.update(leftEpoch, rightEpoch);
    series2.update(leftEpoch, rightEpoch);

    super.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() => <double>[
        min(series1.minValue, series2.maxValue),
        max(series1.maxValue, series2.maxValue)
      ];

  @override
  void createRenderable() => rendererable = SampleMultiRenderable(this);

  @override
  void didUpdate(Component oldComponent) {
    super.didUpdate(oldComponent);

    final SampleMultiSeries old = oldComponent;

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

  @override
  Widget getCrossHairInfo(Tick crossHairTick, int pipSize) {
    throw UnimplementedError();
  }
}
