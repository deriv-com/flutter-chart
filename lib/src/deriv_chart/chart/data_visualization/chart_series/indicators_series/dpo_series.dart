import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/oscillator_line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import '../series.dart';
import '../series_painter.dart';
import 'ma_series.dart';
import 'models/dpo_options.dart';
import 'single_indicator_series.dart';

/// Detrended Price Oscillator series
class DPOSeries extends Series {
  /// Initializes
  ///
  /// Close values will be chosen by default.
  DPOSeries(
    IndicatorInput indicatorInput, {
    required DPOOptions dpoOptions,
    String? id,
  }) : this.fromIndicator(
          CloseValueIndicator<Tick>(indicatorInput),
          dpoOptions: dpoOptions,
          id: id ?? 'Ichimoku$dpoOptions',
        );

  /// Initializes
  DPOSeries.fromIndicator(
    Indicator<Tick> indicator, {
    required this.dpoOptions,
    String? id,
  })  : _fieldIndicator = indicator,
        super(id ?? 'Ichimoku$dpoOptions');

  late SingleIndicatorSeries _dpoSeries;

  /// Detrended Price Oscillator options
  final DPOOptions dpoOptions;

  final Indicator<Tick> _fieldIndicator;

  @override
  SeriesPainter<Series>? createPainter() {
    final DPOIndicator<Tick> dpoIndicator = DPOIndicator<Tick>(
      _fieldIndicator,
      (Indicator<Tick> indicator) =>
          MASeries.getMAIndicator(indicator, dpoOptions),
      period: dpoOptions.period,
      isCentered: dpoOptions.isCentered,
    );

    _dpoSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => OscillatorLinePainter(
        series as DataSeries<Tick>,
        secondaryHorizontalLines: <double>[0],
      ),
      indicatorCreator: () => dpoIndicator,
      inputIndicator: _fieldIndicator,
      options: dpoOptions,
      offset: dpoOptions.isCentered ? -dpoIndicator.timeShift : 0,
    );

    return null;
  }

  @override
  bool didUpdate(ChartData? oldData) {
    final DPOSeries? series = oldData as DPOSeries;

    final bool dpoUpdated = _dpoSeries.didUpdate(series?._dpoSeries);

    return dpoUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    _dpoSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() => <double>[
        _dpoSeries.minValue,
        _dpoSeries.maxValue,
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
    _dpoSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
  }

  @override
  int? getMinEpoch() => _dpoSeries.getMinEpoch();

  @override
  int? getMaxEpoch() => _dpoSeries.getMaxEpoch();
}
