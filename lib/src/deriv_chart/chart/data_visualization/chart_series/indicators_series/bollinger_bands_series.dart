import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/helper_functions.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import 'models/bollinger_bands_options.dart';
import 'single_indicator_series.dart';

/// Bollinger bands series
class BollingerBandSeries extends Series {
  /// Initializes
  ///
  /// Close values will be chosen by default.
  BollingerBandSeries(
    IndicatorInput indicatorInput, {
    required BollingerBandsOptions bbOptions,
    String? id,
  }) : this.fromIndicator(
          CloseValueIndicator<Tick>(indicatorInput),
          bbOptions: bbOptions,
          id: id,
        );

  /// Initializes
  BollingerBandSeries.fromIndicator(
    Indicator<Tick> indicator, {
    required this.bbOptions,
    String? id,
  })  : _fieldIndicator = indicator,
        super(id ?? 'Bollinger$bbOptions');

  late SingleIndicatorSeries lowerSeries;
  late SingleIndicatorSeries middleSeries;
  late SingleIndicatorSeries upperSeries;

  /// Bollinger bands options
  final BollingerBandsOptions bbOptions;

  final Indicator<Tick> _fieldIndicator;

  final List<Series> innerSeries = <Series>[];

  @override
  SeriesPainter<Series>? createPainter() {
    final StandardDeviationIndicator<Tick> standardDeviation =
        StandardDeviationIndicator<Tick>(_fieldIndicator, bbOptions.period);

    final CachedIndicator<Tick> bbmSMA =
        MASeries.getMAIndicator(_fieldIndicator, bbOptions);

    middleSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => bbmSMA,
      inputIndicator: _fieldIndicator,
      options: bbOptions,
      style: bbOptions.middleLineStyle,
    );

    lowerSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => BollingerBandsLowerIndicator<Tick>(
        bbmSMA,
        standardDeviation,
        k: bbOptions.standardDeviationFactor,
      ),
      inputIndicator: _fieldIndicator,
      options: bbOptions,
      style: bbOptions.lowerLineStyle,
    );

    upperSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => BollingerBandsUpperIndicator<Tick>(
        bbmSMA,
        standardDeviation,
        k: bbOptions.standardDeviationFactor,
      ),
      inputIndicator: _fieldIndicator,
      options: bbOptions,
      style: bbOptions.upperLineStyle,
    );

    innerSeries
      ..add(lowerSeries)
      ..add(middleSeries)
      ..add(upperSeries);

    // TODO(ramin): return the painter that paints Channel Fill between bands
    return null;
  }

  @override
  bool didUpdate(ChartData? oldData) {
    final BollingerBandSeries? series = oldData as BollingerBandSeries?;

    final bool lowerUpdated = lowerSeries.didUpdate(series?.lowerSeries);
    final bool middleUpdated = middleSeries.didUpdate(series?.middleSeries);
    final bool upperUpdated = upperSeries.didUpdate(series?.upperSeries);

    return lowerUpdated || middleUpdated || upperUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    lowerSeries.update(leftEpoch, rightEpoch);
    middleSeries.update(leftEpoch, rightEpoch);
    upperSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() =>
      // Can just use lowerSeries minValue for min and upperSeries maxValue
      // for max. But to be safe we calculate min and max. from all three series
      <double>[
        innerSeries
            .map((Series series) => series.minValue)
            .reduce((double a, double b) => safeMin(a, b)),
        innerSeries
            .map((Series series) => series.maxValue)
            .reduce((double a, double b) => safeMax(a, b)),
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
    lowerSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    middleSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    upperSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);

    // TODO(ramin): call super.paint to paint the Channels fill.
  }

  @override
  int? getMinEpoch() => innerSeries.getMinEpoch();

  @override
  int? getMaxEpoch() => innerSeries.getMaxEpoch();
}
