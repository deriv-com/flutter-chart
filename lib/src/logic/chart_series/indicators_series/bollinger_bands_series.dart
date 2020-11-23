import 'dart:math';

import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/bollinger/bollinger_bands_lower_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/quote_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/sma_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/bollinger/bollinger_bands_middle_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/bollinger/bollinger_bands_upper_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/statistics/standard_deviation_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/indicator.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

/// Bollinger bands series
class BollingerBandSeries extends Series {
  ///Initializes
  BollingerBandSeries(this.ticks, {this.period = 20, String id}) : super(id);

  /// Ticks to calculate bollingers for
  final List<Tick> ticks;

  LineSeries _lowSeries;
  LineSeries _middleSeries;

  /// Period
  final int period;

  @override
  SeriesPainter<Series> createPainter() {
    final Indicator closePrice = QuoteIndicator(ticks);

    final BollingerBandsMiddleIndicator bbmSMA =
    BollingerBandsMiddleIndicator(SMAIndicator(closePrice, period));
    final StandardDeviationIndicator standardDeviation =
    StandardDeviationIndicator(closePrice, period);
    final BollingerBandsLowerIndicator bblSMA =
    BollingerBandsLowerIndicator(bbmSMA, standardDeviation);

    final List<Tick> lowerResult = <Tick>[];
    final List<Tick> middleResult = <Tick>[];

    for (int i = 0; i < ticks.length; i++) {
      lowerResult.add(bblSMA.getValue(i));
      middleResult.add(bbmSMA.getValue(i));
    }

    _lowSeries = LineSeries(lowerResult,
        style: const LineStyle(hasArea: false, color: Colors.redAccent));
    _middleSeries = LineSeries(middleResult,
        style: const LineStyle(hasArea: false, color: Colors.white));

    return null; // TODO(ramin): return the painter that paints Channel Fill between bands
  }

  @override
  void didUpdate(ChartData oldData) {
    final BollingerBandSeries series = oldData;
    _lowSeries.didUpdate(series._lowSeries);
    _middleSeries.didUpdate(series._middleSeries);
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    _lowSeries.update(leftEpoch, rightEpoch);
    _middleSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() {
    final List<double> lowerBounds = _lowSeries.recalculateMinMax();
    final List<double> middleBounds = _middleSeries.recalculateMinMax();

    return <double>[
      min(lowerBounds[0], middleBounds[0]),
      max(lowerBounds[1], middleBounds[1])
    ];
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
    _lowSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, pipSize, granularity);
    _middleSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, pipSize, granularity);

    // TODO(ramin): call super.paint to paint the Channels fill.
  }
}
