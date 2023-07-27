import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/single_indicator_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/oscillator_line_painter.dart';

import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import 'models/smi_options.dart';

/// Stochastic Momentum Index series class.
class SMISeries extends Series {
  /// Initializes.
  SMISeries(
    this.input, {
    required this.smiOptions,
    this.overboughtValue = 40,
    this.oversoldValue = -40,
    String? id,
  }) : super(id ?? 'SMI');

  late SingleIndicatorSeries _smiSeries;
  late SingleIndicatorSeries _smiSignalSeries;

  late List<Series> _innerSeries;

  /// Indicator input.
  final IndicatorDataInput input;

  /// Overbought value.
  final double overboughtValue;

  /// Oversold value.
  final double oversoldValue;

  /// SMI Options
  final SMIOptions smiOptions;

  @override
  SeriesPainter<Series>? createPainter() {
    final SMIIndicator<Tick> smiIndicator = SMIIndicator<Tick>(
      input,
      period: smiOptions.period,
      smoothingPeriod: smiOptions.smoothingPeriod,
      doubleSmoothingPeriod: smiOptions.doubleSmoothingPeriod,
    );

    _smiSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => OscillatorLinePainter(
        series as DataSeries<Tick>,
        topHorizontalLine: overboughtValue,
        bottomHorizontalLine: oversoldValue,
        secondaryHorizontalLinesStyle: const LineStyle(),
      ),
      indicatorCreator: () => smiIndicator,
      options: smiOptions,
      inputIndicator: CloseValueIndicator<Tick>(input),
    );

    _smiSignalSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () =>
          MASeries.getMAIndicator(smiIndicator, smiOptions.signalOptions),
      inputIndicator: smiIndicator,
      style: const LineStyle(color: Colors.red),
      options: smiOptions,
    );

    _innerSeries = <Series>[_smiSeries, _smiSignalSeries];

    return null;
  }

  @override
  bool didUpdate(ChartData? oldData) {
    final SMISeries? oldSeries = oldData as SMISeries?;

    final bool smiUpdated = _smiSeries.didUpdate(oldSeries?._smiSeries);
    final bool smiSignalUpdated =
        _smiSignalSeries.didUpdate(oldSeries?._smiSignalSeries);

    return smiUpdated || smiSignalUpdated;
  }

  @override
  int? getMaxEpoch() => _smiSeries.getMaxEpoch();

  @override
  int? getMinEpoch() => _smiSeries.getMinEpoch();

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    _smiSeries.update(leftEpoch, rightEpoch);
    _smiSignalSeries.update(leftEpoch, rightEpoch);
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
    _smiSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _smiSignalSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
  }
}
