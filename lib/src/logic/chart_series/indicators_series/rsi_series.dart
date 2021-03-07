import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/rsi/rsi_indicator_config.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_series.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/oscillator_line_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

/// RSI series.
class RSISeries extends Series {
  /// Initializes an RSI Indicator.
  RSISeries(
    IndicatorInput indicatorInput, {
    String id,
  }) : this.fromIndicator(
          CloseValueIndicator<Tick>(indicatorInput),
          const RSIIndicatorConfig(),
          id: id,
        );

  /// Initializes an RSI Indicator from the given [closeIndicator].
  RSISeries.fromIndicator(
    CloseValueIndicator<Tick> closeIndicator,
    this.config, {
    String id,
  })  : _closeIndicator = closeIndicator,
        super(id);

  LineSeries _rsiSeries;

  final CloseValueIndicator<Tick> _closeIndicator;

  /// Configuration of RSI.
  final RSIIndicatorConfig config;

  @override
  SeriesPainter<Series> createPainter() {
    final RSIIndicator<Tick> rsiIndicator = RSIIndicator<Tick>.fromIndicator(
      _closeIndicator,
      config.period,
    )..calculateValues();

    _rsiSeries = OscillatorLineSeries(
      rsiIndicator.results,
      style: config.lineStyle,
      mainHorizontalLinesStyle: config.mainHorizontalLinesStyle,
      secondaryHorizontalLinesStyle: config.zeroHorizontalLinesStyle,
      topHorizontalLine: config.overBoughtPrice,
      bottomHorizontalLine: config.overSoldPrice,
    );

    return null;
  }

  @override
  bool didUpdate(ChartData oldData) {
    final RSISeries oldSeries = oldData;

    final bool rsiUpdated = _rsiSeries.didUpdate(oldSeries?._rsiSeries);

    return rsiUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    _rsiSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() => <double>[
        _rsiSeries.minValue,
        _rsiSeries.maxValue,
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
    _rsiSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
  }

  @override
  int getMaxEpoch() => _rsiSeries.getMaxEpoch();

  @override
  int getMinEpoch() => _rsiSeries.getMinEpoch();
}
