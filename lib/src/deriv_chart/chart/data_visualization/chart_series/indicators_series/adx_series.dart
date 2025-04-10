import 'package:deriv_chart/src/add_ons/indicators_ui/adx/adx_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_painters/bar_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/channel_fill_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/oscillator_line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/indicator.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
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

  /// ADX series
  late SingleIndicatorSeries adxSeries;

  /// Positive DI series
  late SingleIndicatorSeries positiveDISeries;

  /// Negative DI series
  late SingleIndicatorSeries negativeDISeries;

  /// ADX histogram series
  late SingleIndicatorSeries adxHistogramSeries;

  /// ADX Series List
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
      lastTickIndicatorStyle: getLastIndicatorStyle(
        config.positiveLineStyle.color,
        showLastIndicator: config.showLastIndicator,
      ),
    );

    negativeDISeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => negativeDIIndicator,
      inputIndicator: negativeDIIndicator,
      options: adxOptions,
      style: config.negativeLineStyle,
      lastTickIndicatorStyle: getLastIndicatorStyle(
        config.negativeLineStyle.color,
        showLastIndicator: config.showLastIndicator,
      ),
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
      lastTickIndicatorStyle: getLastIndicatorStyle(
        config.lineStyle.color,
        showLastIndicator: config.showLastIndicator,
      ),
    );

    adxSeriesList = <SingleIndicatorSeries>[
      adxSeries,
      positiveDISeries,
      negativeDISeries,
    ];

    if (config.showHistogram) {
      adxSeriesList.add(adxHistogramSeries);
    }

    if (config.showShading) {
      return ChannelFillPainter(
        positiveDISeries,
        negativeDISeries,
        firstUpperChannelFillColor:
            config.positiveLineStyle.color.withValues(alpha: 0.2),
        secondUpperChannelFillColor:
            config.negativeLineStyle.color.withValues(alpha: 0.2),
      );
    }

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
  bool shouldRepaint(ChartData? previous) {
    if (previous == null) {
      return true;
    }

    final ADXSeries oldSeries = previous as ADXSeries;
    return config.toJson().toString() != oldSeries.config.toJson().toString();
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
    ChartScaleModel chartScaleModel,
  ) {
    if (config.showSeries) {
      positiveDISeries.paint(canvas, size, epochToX, quoteToY, animationInfo,
          chartConfig, theme, chartScaleModel);
      negativeDISeries.paint(canvas, size, epochToX, quoteToY, animationInfo,
          chartConfig, theme, chartScaleModel);
      adxSeries.paint(canvas, size, epochToX, quoteToY, animationInfo,
          chartConfig, theme, chartScaleModel);
    }
    if (config.showHistogram) {
      adxHistogramSeries.paint(canvas, size, epochToX, quoteToY, animationInfo,
          chartConfig, theme, chartScaleModel);
    }

    if (config.showShading) {
      super.paint(canvas, size, epochToX, quoteToY, animationInfo, chartConfig,
          theme, chartScaleModel);
    }
  }

  @override
  int? getMaxEpoch() => adxSeries.getMaxEpoch();

  @override
  int? getMinEpoch() => adxSeries.getMinEpoch();
}
