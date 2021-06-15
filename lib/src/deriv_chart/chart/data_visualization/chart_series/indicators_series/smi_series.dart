import 'dart:math';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/single_indicator_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/oscillator_line_painter.dart';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import '../series.dart';

/// Stochastic Momentum Index series class.
class SMISeries extends Series {
  /// Initializes.
  SMISeries(
    this.input, {
    this.overboughtValue = 40,
    this.oversoldValue = -40,
    String id,
  }) : super(id);

  SingleIndicatorSeries _smi;
  SingleIndicatorSeries _smiSignal;

  List<Series> _innerSeries;

  /// Indicator input.
  final IndicatorDataInput input;

  /// Overbought value.
  final double overboughtValue;

  /// Oversold value.
  final double oversoldValue;

  @override
  SeriesPainter<Series> createPainter() {
    final SMIIndicator<Tick> smiIndicator = SMIIndicator<Tick>(input);

    _smi = SingleIndicatorSeries(
      painterCreator: (Series series) => OscillatorLinePainter(
        series,
      ),
      indicatorCreator: () => smiIndicator,
      inputIndicator: CloseValueIndicator<Tick>(input),
    );

    _smiSignal = SingleIndicatorSeries(
      painterCreator: (Series series) => LinePainter(series),
      indicatorCreator: () =>
          SMISignalIndicator<Tick>.fromIndicator(smiIndicator),
      inputIndicator: CloseValueIndicator<Tick>(input),
    );

    _innerSeries = <Series>[_smi, _smiSignal];

    return null;
  }

  @override
  bool didUpdate(ChartData oldData) {
    final SMISeries oldSeries = oldData;

    final bool smiUpdated = _smi.didUpdate(oldSeries._smi);
    final bool smiSignalUpdated = _smiSignal.didUpdate(oldSeries._smiSignal);

    return smiUpdated || smiSignalUpdated;
  }

  @override
  int getMaxEpoch() => _smi.getMaxEpoch();

  @override
  int getMinEpoch() => _smi.getMinEpoch();

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    _smi.onUpdate(leftEpoch, rightEpoch);
    _smiSignal.onUpdate(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() => <double>[
        _innerSeries.getMinValue(),
        _innerSeries.getMaxValue(),
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
    _smi.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _smiSignal.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
  }
}
