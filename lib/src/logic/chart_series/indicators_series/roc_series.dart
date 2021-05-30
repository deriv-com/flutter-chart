import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/roc/roc_indicator_config.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/abstract_single_indicator_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/roc_options.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

/// ROC series.
class ROCSeries extends AbstractSingleIndicatorSeries {
  /// Initializes an ROC Indicator.
  ROCSeries(
    IndicatorInput indicatorInput, {
    String id,
    ROCOptions rocOptions,
  }) : this.fromIndicator(
          CloseValueIndicator<Tick>(indicatorInput),
          const ROCIndicatorConfig(),
          rocOptions: rocOptions,
          id: id,
        );

  /// Initializes an ROC Indicator from the given [inputIndicator].
  ROCSeries.fromIndicator(
    Indicator<Tick> inputIndicator,
    this.config, {
    @required this.rocOptions,
    String id,
  })  : _inputIndicator = inputIndicator,
        super(
          inputIndicator,
          id ?? 'ROCIndicator',
          rocOptions,
        );

  final Indicator<Tick> _inputIndicator;

  /// Configuration of ROC.
  final ROCIndicatorConfig config;

  /// Options for ROC Indicator.
  final ROCOptions rocOptions;

  @override
  SeriesPainter<Series> createPainter() => LinePainter(this);

  @override
  CachedIndicator<Tick> initializeIndicator() =>
      ROCIndicator<Tick>.fromIndicator(
        _inputIndicator,
        rocOptions.period,
      );
}
