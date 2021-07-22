import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/oscillator_line_painter.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import '../series.dart';
import '../series_painter.dart';
import 'abstract_single_indicator_series.dart';
import 'models/cci_options.dart';

/// Commodity Channel Index series.
class CCISeries extends AbstractSingleIndicatorSeries {
  /// Initializes
  ///
  /// [options]      options of the [CCISeries] which by changing the CCI
  ///                indicators result will be calculated again.
  /// [cciLineStyle] The style of the Commodity Channel Index line chart.
  /// [id]           The id of this series class. Mostly helpful when there is
  ///                more than one series of the same type.
  CCISeries(
    this._indicatorInput,
    CCIOptions options, {
    this.overboughtValue = 100,
    this.oversoldValue = -100,
    this.overboughtLineStyle =
        const LineStyle(color: Colors.white, thickness: 0.5),
    this.oversoldLineStyle =
        const LineStyle(color: Colors.white, thickness: 0.5),
    this.zeroHorizontalLineStyle =
        const LineStyle(color: Colors.white, thickness: 0.5),
    LineStyle cciLineStyle = const LineStyle(),
    this.showZones = true,
    String? id,
  })  : _options = options,
        super(
          CloseValueIndicator<Tick>(_indicatorInput),
          id ?? 'CCISeries',
          options: options,
          style: cciLineStyle,
        );

  final IndicatorInput _indicatorInput;

  final CCIOptions _options;

  /// Overbought line value.
  final double overboughtValue;

  /// Oversold line value.
  final double oversoldValue;

  /// LineStyle of overbought line
  final LineStyle overboughtLineStyle;

  /// LineStyle of oversold line
  final LineStyle oversoldLineStyle;

  /// The RSI zero horizontal line style.
  final LineStyle zeroHorizontalLineStyle;

  /// Whether to fill overbought/sold zones.
  final bool showZones;

  @override
  SeriesPainter<Series> createPainter() => showZones
      ? OscillatorLinePainter(
          this,
          topHorizontalLine: overboughtValue,
          bottomHorizontalLine: oversoldValue,
          topHorizontalLinesStyle: overboughtLineStyle,
          bottomHorizontalLinesStyle: oversoldLineStyle,
          secondaryHorizontalLinesStyle: zeroHorizontalLineStyle,
        )
      : LinePainter(this);

  @override
  CachedIndicator<Tick> initializeIndicator() =>
      CommodityChannelIndexIndicator<Tick>(_indicatorInput, _options.period);
}
