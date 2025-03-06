import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/single_indicator_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/oscillator_line_painter.dart';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/indicator.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import '../data_series.dart';
import '../series.dart';
import 'ma_series.dart';
import 'models/smi_options.dart';

/// Stochastic Momentum Index series class.
class SMISeries extends Series {
  /// Initializes.
  SMISeries(
    this.input, {
    required this.smiOptions,
    this.overboughtValue = 40,
    this.oversoldValue = -40,
    this.overboughtStyle = const LineStyle(),
    this.oversoldStyle = const LineStyle(),
    String? id,
  }) : super(id ?? 'SMI');

  /// SMI series.
  late SingleIndicatorSeries smiSeries;

  /// SMI signal series.
  late SingleIndicatorSeries smiSignalSeries;

  late List<Series> _innerSeries;

  /// Indicator input.
  final IndicatorDataInput input;

  /// Overbought value.
  final double overboughtValue;

  /// Oversold value.
  final double oversoldValue;

  /// Overbought style.
  final LineStyle overboughtStyle;

  /// Oversold style.
  final LineStyle oversoldStyle;

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

    smiSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => OscillatorLinePainter(
        series as DataSeries<Tick>,
        topHorizontalLine: overboughtValue,
        bottomHorizontalLine: oversoldValue,
        secondaryHorizontalLinesStyle: const LineStyle(),
        topHorizontalLinesStyle: overboughtStyle,
        bottomHorizontalLinesStyle: oversoldStyle,
      ),
      indicatorCreator: () => smiIndicator,
      style: smiOptions.lineStyle,
      options: smiOptions,
      inputIndicator: CloseValueIndicator<Tick>(input),
      lastTickIndicatorStyle: smiOptions.lineStyle != null
          ? getLastIndicatorStyle(
              smiOptions.lineStyle!.color,
              showLastIndicator: smiOptions.showLastIndicator,
            )
          : null,
    );

    smiSignalSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () =>
          MASeries.getMAIndicator(smiIndicator, smiOptions.signalOptions),
      inputIndicator: smiIndicator,
      style: smiOptions.signalLineStyle ?? const LineStyle(color: Colors.red),
      options: smiOptions,
      lastTickIndicatorStyle: smiOptions.signalLineStyle != null
          ? getLastIndicatorStyle(
              smiOptions.signalLineStyle!.color,
              showLastIndicator: smiOptions.showLastIndicator,
            )
          : null,
    );

    _innerSeries = <Series>[smiSeries, smiSignalSeries];

    return null;
  }

  @override
  bool didUpdate(ChartData? oldData) {
    final SMISeries? oldSeries = oldData as SMISeries?;

    final bool smiUpdated = smiSeries.didUpdate(oldSeries?.smiSeries);
    final bool smiSignalUpdated =
        smiSignalSeries.didUpdate(oldSeries?.smiSignalSeries);

    return smiUpdated || smiSignalUpdated;
  }

  @override
  int? getMaxEpoch() => smiSeries.getMaxEpoch();

  @override
  int? getMinEpoch() => smiSeries.getMinEpoch();

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    smiSeries.update(leftEpoch, rightEpoch);
    smiSignalSeries.update(leftEpoch, rightEpoch);
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
    ChartScaleModel chartScaleModel,
  ) {
    smiSeries.paint(canvas, size, epochToX, quoteToY, animationInfo,
        chartConfig, theme, chartScaleModel);
    smiSignalSeries.paint(canvas, size, epochToX, quoteToY, animationInfo,
        chartConfig, theme, chartScaleModel);
  }
}
