import 'package:deriv_chart/src/logic/chart_series/indicators_series/single_indicator_series.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import '../data_series.dart';
import '../series.dart';
import '../series_painter.dart';

/// A series which shows Fractal Chaos Band Series data calculated from 'entries'.
class FractalChaosBandSeries extends Series {
  /// Initializes
  FractalChaosBandSeries(
    this.indicatorInput, {
    String? id,
    bool channelFill = false,
  }) : super(id ?? 'FCB');

  ///input data
  final IndicatorInput indicatorInput;

  late SingleIndicatorSeries _fcbHighSeries;
  late SingleIndicatorSeries _fcbLowSeries;

  @override
  SeriesPainter<Series>? createPainter() {
    _fcbHighSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick?>),
      // Using SMA temporarily until TA's migration branch gets updated.
      indicatorCreator: () =>
          SMAIndicator<Tick>(CloseValueIndicator<Tick>(indicatorInput), 10),
      inputIndicator: CloseValueIndicator<Tick>(indicatorInput),
      style: const LineStyle(color: Colors.blue),
    );
    _fcbLowSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick?>),
      indicatorCreator: () =>
          SMAIndicator<Tick>(CloseValueIndicator<Tick>(indicatorInput), 10),
      inputIndicator: CloseValueIndicator<Tick>(indicatorInput),
      style: const LineStyle(color: Colors.blue),
    );

    return null;
  }

  @override
  bool didUpdate(ChartData? oldData) {
    final FractalChaosBandSeries? series = oldData as FractalChaosBandSeries;
    final bool _fcbHighUpdated =
        _fcbHighSeries.didUpdate(series?._fcbHighSeries);
    final bool _fcbLowUpdated = _fcbLowSeries.didUpdate(series?._fcbLowSeries);
    return _fcbHighUpdated || _fcbLowUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    _fcbHighSeries.update(leftEpoch, rightEpoch);
    _fcbLowSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() => <double>[
        <ChartData>[
          _fcbHighSeries,
          _fcbLowSeries,
        ].getMinValue(),
        <ChartData>[
          _fcbHighSeries,
          _fcbLowSeries,
        ].getMaxValue()
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
    _fcbLowSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _fcbHighSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
  }

  @override
  int? getMaxEpoch() => <ChartData>[
        _fcbLowSeries,
        _fcbHighSeries,
      ].getMaxEpoch();

  @override
  int? getMinEpoch() => <ChartData>[
        _fcbLowSeries,
        _fcbHighSeries,
      ].getMinEpoch();
}
