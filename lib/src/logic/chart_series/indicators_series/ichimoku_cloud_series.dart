import 'dart:math';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/ichimoku/ichimoku_base_line_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/ichimoku/ichimoku_conversion_line_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/ichimoku/ichimoku_lagging_span_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/ichimoku/ichimoku_span_a_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/ichimoku/ichimoku_span_b_indicator.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:flutter/material.dart';

/// Ichimoku Cloud series
class IchimokuCloudSeries extends Series {
  /// Initializes
  IchimokuCloudSeries(
    this.ticks, {
    String id,
    this.conversionLinePeriod = 9,
    this.baseLinePeriod = 26,
  }) : super(id);

  LineSeries _conversionLineSeries;
  LineSeries _baseLineSeries;
  LineSeries _laggingSpanSeries;
  LineSeries _spanASeries;
  LineSeries _spanBSeries;

  /// List of [Tick]s to calculate IchimokuCloud on.
  final List<Tick> ticks;

  /// The period to calculate the Conversion Line value.
  final int conversionLinePeriod;

  /// The period to calculate the Base Line value.
  final int baseLinePeriod;

  @override
  SeriesPainter<Series> createPainter() {
    final IchimokuBaseLineIndicator baseLineIndicator =
        IchimokuBaseLineIndicator(ticks, period: baseLinePeriod);

    final IchimokuConversionLineIndicator conversionLineIndicator =
        IchimokuConversionLineIndicator(ticks, period: conversionLinePeriod);

    final IchimokuLaggingSpanIndicator laggingSpanIndicator =
        IchimokuLaggingSpanIndicator(ticks);

    final IchimokuSpanAIndicator spanAIndicator = IchimokuSpanAIndicator(ticks,
        conversionLineIndicator: conversionLineIndicator,
        baseLineIndicator: baseLineIndicator);

    final IchimokuSpanBIndicator spanBIndicator = IchimokuSpanBIndicator(ticks);

    _conversionLineSeries = LineSeries(conversionLineIndicator.results,
        style: const LineStyle(color: Colors.indigo));

    _baseLineSeries = LineSeries(baseLineIndicator.results,
        style: const LineStyle(color: Colors.redAccent));

    _laggingSpanSeries = LineSeries(laggingSpanIndicator.results,
        style: const LineStyle(color: Colors.lime));

    _spanASeries = LineSeries(spanAIndicator.results,
        style: const LineStyle(color: Colors.lightGreenAccent));

    _spanBSeries = LineSeries(spanBIndicator.results,
        style: const LineStyle(color: Colors.red));

    return null; // TODO(ramin): return the painter that paints Channel Fill between bands
  }

  @override
  bool didUpdate(ChartData oldData) {
    final IchimokuCloudSeries series = oldData;

    final bool conversionLineUpdated =
        _conversionLineSeries.didUpdate(series._conversionLineSeries);
    final bool baseLineUpdated =
        _baseLineSeries.didUpdate(series._baseLineSeries);
    final bool laggingSpanUpdated =
        _laggingSpanSeries.didUpdate(series._laggingSpanSeries);
    final bool spanAUpdated = _spanASeries.didUpdate(series._spanASeries);
    final bool spanBUpdated = _spanBSeries.didUpdate(series._spanBSeries);

    return conversionLineUpdated ||
        baseLineUpdated ||
        laggingSpanUpdated ||
        spanAUpdated ||
        spanBUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    _conversionLineSeries.update(leftEpoch, rightEpoch);
    _baseLineSeries.update(leftEpoch, rightEpoch);
    _laggingSpanSeries.update(leftEpoch, rightEpoch);
    _spanASeries.update(leftEpoch, rightEpoch);
    _spanBSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() =>
      // We Calculate min and max from all three series(Except SpanA because values of SpanA are always between Conversion Line and Base Line values).
      <double>[
        min<double>(
          min<double>(
            min<double>(
                _conversionLineSeries.minValue, _baseLineSeries.minValue),
            _laggingSpanSeries.minValue,
          ),
          _spanBSeries.minValue,
        ),
        max(
            max<double>(
              max<double>(
                  _conversionLineSeries.maxValue, _baseLineSeries.maxValue),
              _laggingSpanSeries.maxValue,
            ),
            _spanBSeries.maxValue),
      ];

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
    _conversionLineSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _baseLineSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _laggingSpanSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _spanASeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _spanBSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);

    // TODO(ramin): call super.paint to paint the Channels fill.
  }
}
