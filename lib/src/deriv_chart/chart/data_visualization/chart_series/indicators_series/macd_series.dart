import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/macd_indicator/macd_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_painters/bar_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/single_indicator_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/oscillator_line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/bar_style.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

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

  late SingleIndicatorSeries _macdSeries;
  late SingleIndicatorSeries _signalMACDSeries;
  late SingleIndicatorSeries _macdHistogramSeries;

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
    )..calculateValues();

    final SignalMACDIndicator<Tick> signalMACDIndicator =
        SignalMACDIndicator<Tick>.fromIndicator(macdIndicator)
          ..calculateValues();

    final MACDHistogramIndicator<Tick> macdHistogramIndicator =
        MACDHistogramIndicator<Tick>.fromIndicator(
            macdIndicator, signalMACDIndicator)
          ..calculateValues();

    _macdSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => OscillatorLinePainter(
          series as DataSeries<Tick>,
          secondaryHorizontalLines: <double>[0]),
      indicatorCreator: () => macdIndicator,
      inputIndicator: CloseValueIndicator<Tick>(indicatorInput),
      style: options.lineStyle,
      options: options,
    );

    _signalMACDSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => signalMACDIndicator,
      inputIndicator: CloseValueIndicator<Tick>(indicatorInput),
      style: options.signalLineStyle,
      options: options,
    );

    _macdHistogramSeries = SingleIndicatorSeries(
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

    final bool macdUpdated = _macdSeries.didUpdate(series?._macdSeries);

    final bool signalMACDUpdated =
        _signalMACDSeries.didUpdate(series?._signalMACDSeries);

    final bool macdHistogramUpdated =
        _macdHistogramSeries.didUpdate(series?._macdHistogramSeries);

    return macdUpdated || signalMACDUpdated || macdHistogramUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    _macdSeries.update(leftEpoch, rightEpoch);
    _signalMACDSeries.update(leftEpoch, rightEpoch);
    _macdHistogramSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() => <double>[
        <ChartData>[_macdSeries, _signalMACDSeries, _macdHistogramSeries]
            .getMinValue(),
        <ChartData>[_macdSeries, _signalMACDSeries, _macdHistogramSeries]
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
  ) {
    _macdHistogramSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _macdSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _signalMACDSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
  }

  @override
  int? getMaxEpoch() => <ChartData>[
        _macdSeries,
        _signalMACDSeries,
        _macdHistogramSeries,
      ].getMaxEpoch();

  @override
  int? getMinEpoch() => <ChartData>[
        _macdSeries,
        _signalMACDSeries,
        _macdHistogramSeries,
      ].getMinEpoch();
}
