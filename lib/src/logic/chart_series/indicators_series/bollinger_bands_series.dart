import 'dart:math';

import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/bollinger/bollinger_bands_lower_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/bollinger/bollinger_bands_upper_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/statistics/standard_deviation_indicator.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

/// Bollinger bands series
class BollingerBandSeries extends Series {
  /// Initializes
  ///
  /// Close values will be chosen by default.
  BollingerBandSeries(
    List<Tick> ticks, {
    int period = 20,
    MovingAverageType movingAverageType = MovingAverageType.simple,
    double standardDeviationFactor = 2,
    String id,
  }) : this.fromIndicator(
          CloseValueIndicator(ticks),
          period: period,
          movingAverageType: movingAverageType,
          standardDeviationFactor: standardDeviationFactor,
          id: id,
        );

  /// Initializes
  BollingerBandSeries.fromIndicator(
    Indicator indicator, {
    this.period = 20,
    this.movingAverageType = MovingAverageType.simple,
    this.standardDeviationFactor = 2,
    String id,
  })  : _fieldIndicator = indicator,
        super(id);

  LineSeries _lowerSeries;
  LineSeries _middleSeries;
  LineSeries _upperSeries;

  /// Period
  final int period;

  /// Bollinger Bands Moving Average type
  final MovingAverageType movingAverageType;

  /// Standard Deviation value
  final double standardDeviationFactor;

  final Indicator _fieldIndicator;

  @override
  SeriesPainter<Series> createPainter() {
    final StandardDeviationIndicator standardDeviation =
        StandardDeviationIndicator(_fieldIndicator, period);

    final CachedIndicator bbmSMA =
        MASeries.getMAIndicator(_fieldIndicator, period, movingAverageType);

    final BollingerBandsLowerIndicator bblSMA = BollingerBandsLowerIndicator(
      bbmSMA,
      standardDeviation,
      k: standardDeviationFactor,
    );

    final BollingerBandsUpperIndicator bbuSMA = BollingerBandsUpperIndicator(
      bbmSMA,
      standardDeviation,
      k: standardDeviationFactor,
    );

    _lowerSeries = LineSeries(bblSMA.results,
        style: const LineStyle(color: Colors.redAccent));
    _middleSeries =
        LineSeries(bbmSMA.results, style: const LineStyle(color: Colors.white));
    _upperSeries = LineSeries(bbuSMA.results,
        style: const LineStyle(color: Colors.lightGreen));

    return null; // TODO(ramin): return the painter that paints Channel Fill between bands
  }

  @override
  bool didUpdate(ChartData oldData) {
    final BollingerBandSeries series = oldData;

    final bool _lowerUpdated = _lowerSeries.didUpdate(series._lowerSeries);
    final bool _middleUpdated = _middleSeries.didUpdate(series._middleSeries);
    final bool _upperUpdated = _upperSeries.didUpdate(series._upperSeries);

    return _lowerUpdated || _middleUpdated || _upperUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    _lowerSeries.update(leftEpoch, rightEpoch);
    _middleSeries.update(leftEpoch, rightEpoch);
    _upperSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() =>
      // Can just use _lowerSeries minValue for min and _upperSeries maxValue for max.
      // But to be safe we calculate min and max. from all three series.
      <double>[
        min(
          min(_lowerSeries.minValue, _middleSeries.minValue),
          _upperSeries.minValue,
        ),
        max(
          max(_lowerSeries.maxValue, _middleSeries.maxValue),
          _upperSeries.maxValue,
        ),
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
    _lowerSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _middleSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _upperSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);

    // TODO(ramin): call super.paint to paint the Channels fill.
  }
}
