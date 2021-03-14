import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/rsi/rsi_indicator_config.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/abstract_single_indicator_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/rsi_options.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_series.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/oscillator_line_painter.dart';
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
        super(inputIndicator, id, rsiOptions);

  LineSeries _rsiSeries;

  final Indicator<Tick> _inputIndicator;

  /// Configuration of RSI.
  final RSIIndicatorConfig config;

  /// Options for RSI Indicator.
  final RSIOptions rsiOptions;

  @override
  SeriesPainter<Series> createPainter() => OscillatorLinePainter(
        this,
        bottomHorizontalLine: config.overSoldPrice,
        mainHorizontalLinesStyle: config.mainHorizontalLinesStyle,
        secondaryHorizontalLinesStyle: config.zeroHorizontalLinesStyle,
        topHorizontalLine: config.overBoughtPrice,
      );

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

  @override
  CachedIndicator<Tick> initializeIndicator() =>
      RSIIndicator<Tick>.fromIndicator(
        _inputIndicator,
        rsiOptions.period,
      );
}
