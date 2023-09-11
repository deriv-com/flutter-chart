import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/abstract_single_indicator_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/roc_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/oscillator_line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/indicator.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import '../series.dart';
import '../series_painter.dart';

/// ROC series.
class ROCSeries extends AbstractSingleIndicatorSeries {
  /// Initializes an ROC Indicator.
  ROCSeries(
    IndicatorInput indicatorInput, {
    required ROCOptions rocOptions,
    LineStyle? lineStyle,
    String? id,
  }) : this.fromIndicator(
          CloseValueIndicator<Tick>(indicatorInput),
          rocOptions: rocOptions,
          lineStyle: lineStyle,
          id: id ?? 'ROCIndicator',
        );

  /// Initializes an ROC Indicator from the given [inputIndicator].
  ROCSeries.fromIndicator(
    Indicator<Tick> inputIndicator, {
    required this.rocOptions,
    LineStyle? lineStyle,
    String? id,
  })  : _inputIndicator = inputIndicator,
        super(
          inputIndicator,
          id ?? 'ROCIndicator',
          options: rocOptions,
          style: lineStyle,
          lastTickIndicatorStyle: lineStyle != null
              ? getLastIndicatorStyle(
                  lineStyle.color,
                  showLastIndicator: rocOptions.showLastIndicator,
                )
              : null,
        );

  final Indicator<Tick> _inputIndicator;

  /// Options for ROC Indicator.
  final ROCOptions rocOptions;

  @override
  SeriesPainter<Series> createPainter() => OscillatorLinePainter(
        this,
        secondaryHorizontalLines: const <double>[0],
        secondaryHorizontalLinesStyle: const LineStyle(
          color: Color(0xFF3E3E3E),
        ),
      );

  @override
  CachedIndicator<Tick> initializeIndicator() =>
      ROCIndicator<Tick>.fromIndicator(
        _inputIndicator,
        rocOptions.period,
      );
}
