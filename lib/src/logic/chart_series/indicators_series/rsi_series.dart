import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/rsi/rsi_indicator_config.dart';
import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/abstract_single_indicator_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/rsi_options.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/oscillator_line_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

/// RSI series.
class RSISeries extends AbstractSingleIndicatorSeries {
  /// Initializes an RSI Indicator.
  RSISeries(
    IndicatorInput indicatorInput, {
    String id,
    RSIOptions rsiOptions,
  }) : this.fromIndicator(
          CloseValueIndicator<Tick>(indicatorInput),
          const RSIIndicatorConfig(),
          rsiOptions: rsiOptions,
          id: id,
        );

  /// Initializes an RSI Indicator from the given [inputIndicator].
  RSISeries.fromIndicator(
    Indicator<Tick> inputIndicator,
    this.config, {
    @required this.rsiOptions,
    String id,
  })  : _inputIndicator = inputIndicator,
        super(
          inputIndicator,
          id ?? 'RSIIndicator',
          rsiOptions,
          style: config.lineStyle,
        );

  final Indicator<Tick> _inputIndicator;

  /// Configuration of RSI.
  final RSIIndicatorConfig config;

  /// Options for RSI Indicator.
  final RSIOptions rsiOptions;

  @override
  List<double> recalculateMinMax() {
    final List<double> rsiMinMax = super.recalculateMinMax();

    return <double>[
      safeMin(
          safeMin(rsiMinMax[0], config.overSoldPrice), config.overBoughtPrice),
      safeMax(
          safeMax(rsiMinMax[1], config.overSoldPrice), config.overBoughtPrice),
    ];
  }

  @override
  SeriesPainter<Series> createPainter() => OscillatorLinePainter(
        this,
        bottomHorizontalLine: config.overSoldPrice,
        topHorizontalLine: config.overBoughtPrice,
        mainHorizontalLinesStyle: config.mainHorizontalLinesStyle,
      );

  @override
  CachedIndicator<Tick> initializeIndicator() =>
      RSIIndicator<Tick>.fromIndicator(
        _inputIndicator,
        rsiOptions.period,
      );
}
