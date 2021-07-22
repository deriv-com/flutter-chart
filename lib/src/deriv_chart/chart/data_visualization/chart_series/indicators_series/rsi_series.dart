import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/rsi/rsi_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/oscillator_line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/helper_functions.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import '../series.dart';
import '../series_painter.dart';
import 'abstract_single_indicator_series.dart';
import 'models/rsi_options.dart';

/// RSI series.
class RSISeries extends AbstractSingleIndicatorSeries {
  /// Initializes an RSI Indicator.
  RSISeries(
    IndicatorInput indicatorInput, {
    String? id,
    required RSIOptions rsiOptions,
    bool showZones = true,
  }) : this.fromIndicator(
          CloseValueIndicator<Tick>(indicatorInput),
          const RSIIndicatorConfig(),
          rsiOptions: rsiOptions,
          showZones: showZones,
          id: id,
        );

  /// Initializes an RSI Indicator from the given [inputIndicator].
  RSISeries.fromIndicator(
    Indicator<Tick> inputIndicator,
    this.config, {
    required this.rsiOptions,
    this.showZones = true,
    String? id,
  })  : _inputIndicator = inputIndicator,
        super(
          inputIndicator,
          id ?? 'RSIIndicator',
          options: rsiOptions,
          style: config.lineStyle,
        );

  final Indicator<Tick> _inputIndicator;

  /// Configuration of RSI.
  final RSIIndicatorConfig config;

  /// Options for RSI Indicator.
  final RSIOptions rsiOptions;

  /// Whether to fill overbought/sold zones.
  final bool showZones;

  @override
  List<double> recalculateMinMax() {
    final List<double> rsiMinMax = super.recalculateMinMax();

    if (!config.pinLabels) {
      return rsiMinMax;
    }
    return <double>[
      safeMin(safeMin(rsiMinMax[0], config.oscillatorLinesConfig.oversoldValue),
          config.oscillatorLinesConfig.overboughtValue),
      safeMax(safeMax(rsiMinMax[1], config.oscillatorLinesConfig.oversoldValue),
          config.oscillatorLinesConfig.overboughtValue),
    ];
  }

  @override
  SeriesPainter<Series> createPainter() => showZones
      ? OscillatorLinePainter(
          this,
          bottomHorizontalLine: config.oscillatorLinesConfig.oversoldValue,
          topHorizontalLine: config.oscillatorLinesConfig.overboughtValue,
          topHorizontalLinesStyle: config.oscillatorLinesConfig.overboughtStyle,
          bottomHorizontalLinesStyle:
              config.oscillatorLinesConfig.oversoldStyle,
        )
      : LinePainter(this);

  @override
  CachedIndicator<Tick> initializeIndicator() =>
      RSIIndicator<Tick>.fromIndicator(
        _inputIndicator,
        rsiOptions.period,
      );
}
