import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/adx/adx_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/helper_functions.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import '../data_series.dart';
import '../series.dart';
import '../series_painter.dart';
import 'models/adx_options.dart';
import 'single_indicator_series.dart';

/// ADX series
class ADXSeries extends Series {
  /// Initializes
  ADXSeries(
    this.ticks, {
    required this.adxOptions,
    required this.config,
    String? id,
  }) : super(id ?? 'ADX$adxOptions');

  late SingleIndicatorSeries _adxSeries;
  late SingleIndicatorSeries _positiveDISeries;
  late SingleIndicatorSeries _negativeDISeries;

  late List<SingleIndicatorSeries> _adxSeriesList;

  /// List of [Tick]s to calculate ADX on.
  final IndicatorDataInput ticks;

  /// ADX Configuration.
  ADXIndicatorConfig config;

  /// ADX Options.
  ADXOptions adxOptions;

  @override
  SeriesPainter<Series>? createPainter() {
    final NegativeDIIndicator<Tick> negativeDIIndicator =
        NegativeDIIndicator<Tick>(ticks, period: adxOptions.period);

    final PositiveDIIndicator<Tick> positiveDIIndicator =
        PositiveDIIndicator<Tick>(ticks, period: adxOptions.period);

    final ADXIndicator<Tick> adxIndicator = ADXIndicator<Tick>.fromIndicator(
      positiveDIIndicator,
      negativeDIIndicator,
      adxPeriod: adxOptions.period,
    );

    _positiveDISeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => positiveDIIndicator,
      inputIndicator: positiveDIIndicator,
      options: adxOptions,
      style: const LineStyle(color: Colors.green),
    );

    _negativeDISeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => negativeDIIndicator,
      inputIndicator: negativeDIIndicator,
      options: adxOptions,
      style: const LineStyle(color: Colors.red),
    );

    _adxSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => adxIndicator,
      inputIndicator: adxIndicator,
      options: adxOptions,
      style: const LineStyle(color: Colors.white),
    );

    _adxSeriesList = <SingleIndicatorSeries>[
      _adxSeries,
      _positiveDISeries,
      _negativeDISeries
    ];

    return null;
  }

  @override
  bool didUpdate(ChartData? oldData) {
    final ADXSeries? series = oldData as ADXSeries?;

    final bool positiveDIUpdated =
        _positiveDISeries.didUpdate(series?._positiveDISeries);
    final bool negativeDIUpdated =
        _negativeDISeries.didUpdate(series?._negativeDISeries);
    final bool adxUpdated = _adxSeries.didUpdate(series?._adxSeries);

    return positiveDIUpdated || negativeDIUpdated || adxUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    _positiveDISeries.update(leftEpoch, rightEpoch);
    _negativeDISeries.update(leftEpoch, rightEpoch);
    _adxSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() {
    final double minValue = _adxSeriesList
        .map((SingleIndicatorSeries series) => series.minValue)
        .reduce(safeMin);

    final double maxValue = _adxSeriesList
        .map((SingleIndicatorSeries series) => series.maxValue)
        .reduce(safeMax);

    return <double>[minValue, maxValue];
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
    for (final SingleIndicatorSeries series in _adxSeriesList) {
      series.paint(
          canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    }
  }

  @override
  int? getMaxEpoch() => _adxSeries.getMaxEpoch();

  @override
  int? getMinEpoch() => _adxSeries.getMinEpoch();
}
