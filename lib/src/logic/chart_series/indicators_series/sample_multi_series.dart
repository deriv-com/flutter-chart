import 'dart:math';

import 'package:deriv_chart/src/logic/chart_series/indicators_series/sample_multi_renderable.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/indicators/indicators.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

/// A sample class just to represent how a custom indicator with multiple data-series can be implemented.
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
    super.update(leftEpoch, rightEpoch);
    series1.update(leftEpoch, rightEpoch);
    series2.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> getMinMaxValues() => <double>[
        min(series1.minValue, series2.maxValue),
        max(series1.maxValue, series2.maxValue)
      ];

  @override
  void createRenderable() => rendererable = SampleMultiRenderable(this);

  @override
  void didUpdateSeries(Series<Tick> oldSeries) {
    super.didUpdateSeries(oldSeries);

    final SampleMultiSeries old = oldSeries;

    series1.didUpdateSeries(old.series1);
    series2.didUpdateSeries(old.series2);
  }

  @override
  void paint(
    Canvas canvas,
    Size size,
    double Function(int) epochToX,
    double Function(double) quoteToY,
    AnimationInfo animationInfo,
    int pipSize,
  ) {
    super.paint(canvas, size, epochToX, quoteToY, animationInfo, pipSize);

    series1.paint(canvas, size, epochToX, quoteToY, animationInfo, pipSize);
    series2.paint(canvas, size, epochToX, quoteToY, animationInfo, pipSize);
  }

  @override
  Widget getCrossHairInfo(Tick crossHairTick, int pipSize) {
    throw UnimplementedError();
  }
}
