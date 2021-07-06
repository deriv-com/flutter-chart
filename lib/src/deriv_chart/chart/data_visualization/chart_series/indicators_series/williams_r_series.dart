import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/oscillator_line_painter.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import '../series.dart';
import '../series_painter.dart';
import 'abstract_single_indicator_series.dart';
import 'models/williams_r_options.dart';

/// WilliamsRSeries
class WilliamsRSeries extends AbstractSingleIndicatorSeries {
  /// Initializes
  WilliamsRSeries(
    this._indicatorDataInput,
    this._options, {
    this.overboughtValue = -20,
    this.oversoldValue = -80,
    this.showZones = true,
    this.overboughtSoldLineStyles =
        const LineStyle(color: Colors.white, thickness: 0.5),
    String? id,
  }) : super(
          CloseValueIndicator<Tick>(_indicatorDataInput),
          id ?? 'WilliamsR',
          options: _options,
        );

  final IndicatorDataInput _indicatorDataInput;

  final WilliamsROptions _options;

  /// Overbought value
  final double overboughtValue;

  /// Oversold value
  final double oversoldValue;

  /// The line style for overbought/sold horizontal lines.
  final LineStyle overboughtSoldLineStyles;

  /// Whether to show overbought/sold lines and zones channel fill.
  final bool showZones;

  @override
  SeriesPainter<Series> createPainter() => showZones
      ? OscillatorLinePainter(
          this,
          topHorizontalLine: overboughtValue,
          bottomHorizontalLine: oversoldValue,
          secondaryHorizontalLinesStyle: overboughtSoldLineStyles,
          // TODO(NA): Zero line style will be removed from OscillatorLinePainter.
          mainHorizontalLinesStyle: overboughtSoldLineStyles,
        )
      : LinePainter(this);

  @override
  CachedIndicator<Tick> initializeIndicator() => WilliamsRIndicator<Tick>(
        _indicatorDataInput,
        _options.period,
      );
}
