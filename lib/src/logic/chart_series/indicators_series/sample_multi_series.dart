// @dart=2.9

import 'dart:math';

import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/indicator_options.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/sample_multi_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';

import 'ma_series.dart';

/// A sample class just to examine how a custom indicator with multiple data-series can be implemented in this structure.
///
/// Can also extend from a concrete implementation of [Series] like [LineSeries] and instead of two only
/// define one nested series. In that case, since we override [createPainter()]
/// and set value for [seriesPainter] we should have another [SeriesPainter] inside this class.
///
/// Or we can directly implement [ChartData] interface.
class SampleMultiSeries extends Series {
  /// Initializes a sample class just to examine how a custom indicator with multiple data-series can be implemented in this structure.
  SampleMultiSeries(IndicatorInput indicatorInput, {String id})
      : series1 = MASeries(indicatorInput, const MAOptions(period: 10)),
        series2 = MASeries(indicatorInput, const MAOptions()),
        super(id ?? 'SampleMultiSeries');

  /// Series 1.
  final MASeries series1;

  /// Series 2.
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
  SeriesPainter<SampleMultiSeries> createPainter() => SampleMultiPainter(this);

  @override
  bool didUpdate(ChartData oldData) {
    final SampleMultiSeries old = oldData;

    final bool series1Updated = series1.didUpdate(old.series1);
    final bool series2Updated = series2.didUpdate(old.series2);

    return series1Updated || series2Updated;
  }

  @override
  void paint(
    Canvas canvas,
    Size size,
    double Function(int) epochToX,
    double Function(double) quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme theme,
  ) {
    super.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);

    series1.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    series2.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
  }

  @override
  int getMinEpoch() => min(series1.getMinEpoch(), series2.getMinEpoch());

  @override
  int getMaxEpoch() => max(series1.getMaxEpoch(), series2.getMaxEpoch());
}
