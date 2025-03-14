import 'package:deriv_chart/src/add_ons/indicators_ui/macd_indicator/macd_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_painters/bar_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/single_indicator_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/oscillator_line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/indicator.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import '../data_series.dart';
import '../series.dart';
import '../series_painter.dart';
import 'models/macd_options.dart';

/// MACD series
class MACDSeries extends Series {
  /// Initializes
  MACDSeries(
    this.indicatorInput, {
    required this.options,
    required this.config,
    String? id = '',
  }) : super(id ?? 'MACD$options');

  ///input data
  final IndicatorInput indicatorInput;

  /// MACD Series
  late SingleIndicatorSeries macdSeries;

  /// Signal MACD Series
  late SingleIndicatorSeries signalMACDSeries;

  /// MACD Histogram Series
  late SingleIndicatorSeries macdHistogramSeries;

  /// MACD Configuration.
  MACDIndicatorConfig config;

  /// MACD Options.
  MACDOptions options;

  @override
  SeriesPainter<Series>? createPainter() {
    final MACDIndicator<Tick> macdIndicator = MACDIndicator<Tick>(
      indicatorInput,
      fastMAPeriod: config.fastMAPeriod,
      slowMAPeriod: config.slowMAPeriod,
    );

    final SignalMACDIndicator<Tick> signalMACDIndicator =
        SignalMACDIndicator<Tick>.fromIndicator(macdIndicator);

    final MACDHistogramIndicator<Tick> macdHistogramIndicator =
        MACDHistogramIndicator<Tick>.fromIndicator(
      macdIndicator,
      signalMACDIndicator,
    );

    macdSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => OscillatorLinePainter(
          series as DataSeries<Tick>,
          secondaryHorizontalLines: <double>[0]),
      indicatorCreator: () => macdIndicator,
      inputIndicator: CloseValueIndicator<Tick>(indicatorInput),
      style: options.lineStyle,
      options: options,
      lastTickIndicatorStyle: getLastIndicatorStyle(
        options.lineStyle.color,
        showLastIndicator: options.showLastIndicator,
      ),
    );

    signalMACDSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => signalMACDIndicator,
      inputIndicator: CloseValueIndicator<Tick>(indicatorInput),
      style: options.signalLineStyle,
      options: options,
      lastTickIndicatorStyle: getLastIndicatorStyle(
        options.signalLineStyle.color,
        showLastIndicator: options.showLastIndicator,
      ),
    );

    macdHistogramSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => BarPainter(
        series as DataSeries<Tick>,
        checkColorCallback: ({
          required double previousQuote,
          required double currentQuote,
        }) =>
            currentQuote >= previousQuote,
      ),
      indicatorCreator: () => macdHistogramIndicator,
      inputIndicator: CloseValueIndicator<Tick>(indicatorInput),
      style: options.barStyle,
      options: options,
    );

    return null;
  }

  @override
  bool didUpdate(ChartData? oldData) {
    final MACDSeries? series = oldData as MACDSeries;

    final bool macdUpdated = macdSeries.didUpdate(series?.macdSeries);

    final bool signalMACDUpdated =
        signalMACDSeries.didUpdate(series?.signalMACDSeries);

    final bool macdHistogramUpdated =
        macdHistogramSeries.didUpdate(series?.macdHistogramSeries);

    return macdUpdated || signalMACDUpdated || macdHistogramUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    macdSeries.update(leftEpoch, rightEpoch);
    signalMACDSeries.update(leftEpoch, rightEpoch);
    macdHistogramSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() => <double>[
        <ChartData>[macdSeries, signalMACDSeries, macdHistogramSeries]
            .getMinValue(),
        <ChartData>[macdSeries, signalMACDSeries, macdHistogramSeries]
            .getMaxValue()
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
    ChartScaleModel chartScaleModel,
  ) {
    macdHistogramSeries.paint(canvas, size, epochToX, quoteToY, animationInfo,
        chartConfig, theme, chartScaleModel);
    macdSeries.paint(canvas, size, epochToX, quoteToY, animationInfo,
        chartConfig, theme, chartScaleModel);
    signalMACDSeries.paint(canvas, size, epochToX, quoteToY, animationInfo,
        chartConfig, theme, chartScaleModel);
  }

  @override
  int? getMaxEpoch() => <ChartData>[
        macdSeries,
        signalMACDSeries,
        macdHistogramSeries,
      ].getMaxEpoch();

  @override
  int? getMinEpoch() => <ChartData>[
        macdSeries,
        signalMACDSeries,
        macdHistogramSeries,
      ].getMinEpoch();
}
