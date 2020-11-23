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

  LineSeries _lowerSeries;
  LineSeries _middleSeries;
  LineSeries _upperSeries;

  /// Period
  final int period;

  @override
  SeriesPainter<Series> createPainter() {
    final Indicator closePrice = QuoteIndicator(ticks);
    final StandardDeviationIndicator standardDeviation =
        StandardDeviationIndicator(closePrice, period);

    final BollingerBandsMiddleIndicator bbmSMA =
        BollingerBandsMiddleIndicator(SMAIndicator(closePrice, period));

    final BollingerBandsLowerIndicator bblSMA =
        BollingerBandsLowerIndicator(bbmSMA, standardDeviation);

    final BollingerBandsUpperIndicator bbuSMA =
        BollingerBandsUpperIndicator(bbmSMA, standardDeviation);

    final List<Tick> lowerResult = <Tick>[];
    final List<Tick> middleResult = <Tick>[];
    final List<Tick> upperResult = <Tick>[];

    for (int i = 0; i < ticks.length; i++) {
      lowerResult.add(bblSMA.getValue(i));
      middleResult.add(bbmSMA.getValue(i));
      upperResult.add(bbuSMA.getValue(i));
    }

    _lowerSeries = LineSeries(lowerResult,
        style: const LineStyle(hasArea: false, color: Colors.redAccent));
    _middleSeries = LineSeries(middleResult,
        style: const LineStyle(hasArea: false, color: Colors.white));
    _upperSeries = LineSeries(upperResult,
        style: const LineStyle(hasArea: false, color: Colors.lightGreen));

    return null; // TODO(ramin): return the painter that paints Channel Fill between bands
  }

  @override
  void didUpdate(ChartData oldData) {
    final BollingerBandSeries series = oldData;
    _lowerSeries.didUpdate(series._lowerSeries);
    _middleSeries.didUpdate(series._middleSeries);
    _upperSeries.didUpdate(series._upperSeries);
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    _lowerSeries.update(leftEpoch, rightEpoch);
    _middleSeries.update(leftEpoch, rightEpoch);
    _upperSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() {
    final List<double> lowerBounds = _lowerSeries.recalculateMinMax();
    final List<double> middleBounds = _middleSeries.recalculateMinMax();
    final List<double> upperBounds = _upperSeries.recalculateMinMax();

    // Can just use lowerBounds for min and upper for max. But to be safe we calculate min and max.
    return <double>[
      min(min(lowerBounds[0], middleBounds[0]), upperBounds[0]),
      max(max(lowerBounds[1], middleBounds[1]), upperBounds[1]),
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
    _lowerSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, pipSize, granularity);
    _middleSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, pipSize, granularity);
    _upperSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, pipSize, granularity);

    // TODO(ramin): call super.paint to paint the Channels fill.
  }
}
