import 'dart:math';

import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/single_indicator_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/indicator_options.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

/// Bollinger bands series
class BollingerBandSeries extends Series {
  /// Initializes
  ///
  /// Close values will be chosen by default.
  BollingerBandSeries(
    IndicatorInput indicatorInput, {
    MAOptions maOptions,
    double standardDeviationFactor = 2,
    String id,
  }) : this.fromIndicator(
          CloseValueIndicator<Tick>(indicatorInput),
          maOptions: maOptions,
          standardDeviationFactor: standardDeviationFactor,
          id: id,
        );

  /// Initializes
  BollingerBandSeries.fromIndicator(
    Indicator<Tick> indicator, {
    this.maOptions,
    this.standardDeviationFactor = 2,
    String id,
  })  : _fieldIndicator = indicator,
        super(id);

  SingleIndicatorSeries _lowerSeries;
  SingleIndicatorSeries _middleSeries;
  SingleIndicatorSeries _upperSeries;

  /// Moving Average options
  final MAOptions maOptions;

  /// Standard Deviation value
  final double standardDeviationFactor;

  final Indicator<Tick> _fieldIndicator;

  @override
  SeriesPainter<Series> createPainter() {
    final StandardDeviationIndicator<Tick> standardDeviation =
        StandardDeviationIndicator<Tick>(_fieldIndicator, maOptions.period);

    final CachedIndicator<Tick> bbmSMA =
        MASeries.getMAIndicator(_fieldIndicator, maOptions);

    _middleSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => LinePainter(series),
      indicatorCreator: () => bbmSMA,
      inputIndicator: _fieldIndicator,
      options: maOptions,
    );

    _lowerSeries = SingleIndicatorSeries(
        painterCreator: (Series series) => LinePainter(series),
        indicatorCreator: () => BollingerBandsLowerIndicator<Tick>(
              bbmSMA,
              standardDeviation,
              k: standardDeviationFactor,
            ),
        inputIndicator: _fieldIndicator,
        options: maOptions);

    _upperSeries = SingleIndicatorSeries(
        painterCreator: (Series series) => LinePainter(series),
        indicatorCreator: () => BollingerBandsUpperIndicator<Tick>(
              bbmSMA,
              standardDeviation,
              k: standardDeviationFactor,
            ),
        inputIndicator: _fieldIndicator,
        options: maOptions);

    return null; // TODO(ramin): return the painter that paints Channel Fill between bands
  }

  @override
  bool didUpdate(ChartData oldData) {
    final BollingerBandSeries series = oldData;

    final bool lowerUpdated = _lowerSeries.didUpdate(series?._lowerSeries);
    final bool middleUpdated = _middleSeries.didUpdate(series?._middleSeries);
    final bool upperUpdated = _upperSeries.didUpdate(series?._upperSeries);

    return lowerUpdated || middleUpdated || upperUpdated;
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

  @override
  int getMinEpoch() =>
      min(_lowerSeries.getMinEpoch(), _upperSeries.getMinEpoch());

  @override
  int getMaxEpoch() =>
      max(_lowerSeries.getMaxEpoch(), _upperSeries.getMaxEpoch());
}
