import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/adx/adx_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_painters/bar_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/oscillator_line_painter.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

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

  late SingleIndicatorSeries adxSeries;
  late SingleIndicatorSeries positiveDISeries;
  late SingleIndicatorSeries negativeDISeries;
  late SingleIndicatorSeries adxHistogramSeries;

  late List<SingleIndicatorSeries> adxSeriesList;

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

    final ADXHistogramIndicator<Tick> adxHistogramIndicator =
        ADXHistogramIndicator<Tick>.fromIndicator(
            positiveDIIndicator, negativeDIIndicator);

    final ADXIndicator<Tick> adxIndicator = ADXIndicator<Tick>.fromIndicator(
      positiveDIIndicator,
      negativeDIIndicator,
      adxPeriod: adxOptions.smoothingPeriod,
    );

    positiveDISeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => positiveDIIndicator,
      inputIndicator: positiveDIIndicator,
      options: adxOptions,
      style: config.positiveLineStyle,
    );

    negativeDISeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => negativeDIIndicator,
      inputIndicator: negativeDIIndicator,
      options: adxOptions,
      style: config.negativeLineStyle,
    );

    adxHistogramSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => BarPainter(
        series as DataSeries<Tick>,
        checkColorCallback: ({
          required double currentQuote,
          required double previousQuote,
        }) =>
            !currentQuote.isNegative,
      ),
      indicatorCreator: () => adxHistogramIndicator,
      inputIndicator: adxHistogramIndicator,
      options: adxOptions,
      style: config.barStyle,
    );

    adxSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => OscillatorLinePainter(
        series as DataSeries<Tick>,
        secondaryHorizontalLines: <double>[0],
      ),
      indicatorCreator: () => adxIndicator,
      inputIndicator: adxIndicator,
      options: adxOptions,
      style: config.lineStyle,
    );

    adxSeriesList = <SingleIndicatorSeries>[
      adxHistogramSeries,
      adxSeries,
      positiveDISeries,
      negativeDISeries,
    ];

    return null;
  }

  @override
  bool didUpdate(ChartData? oldData) {
    final ADXSeries? series = oldData as ADXSeries?;

    final bool positiveDIUpdated =
        positiveDISeries.didUpdate(series?.positiveDISeries);
    final bool negativeDIUpdated =
        negativeDISeries.didUpdate(series?.negativeDISeries);
    final bool adxUpdated = adxSeries.didUpdate(series?.adxSeries);
    final bool histogramUpdated =
        adxHistogramSeries.didUpdate(series?.adxHistogramSeries);

    return positiveDIUpdated ||
        negativeDIUpdated ||
        adxUpdated ||
        histogramUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    for (final SingleIndicatorSeries series in adxSeriesList) {
      series.update(leftEpoch, rightEpoch);
    }
  }

  @override
  List<double> recalculateMinMax() =>
      <double>[adxSeriesList.getMinValue(), adxSeriesList.getMaxValue()];

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
    if (config.showSeries) {
      positiveDISeries.paint(
          canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
      negativeDISeries.paint(
          canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
      adxSeries.paint(
          canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    }
    if (config.showHistogram) {
      adxHistogramSeries.paint(
          canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    }
  }

  @override
  int? getMaxEpoch() => adxSeries.getMaxEpoch();

  @override
  int? getMinEpoch() => adxSeries.getMinEpoch();
}
