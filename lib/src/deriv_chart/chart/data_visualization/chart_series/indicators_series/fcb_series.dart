import 'package:deriv_chart/src/add_ons/indicators_ui/fcb_indicator/fcb_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/channel_fill_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import '../data_series.dart';
import '../series.dart';
import '../series_painter.dart';
import 'single_indicator_series.dart';

/// A series which shows Fractal Chaos Band Series data calculated
/// from 'entries'.
class FractalChaosBandSeries extends Series {
  /// Initializes
  FractalChaosBandSeries(
    this.indicatorInput, {
    required this.config,
    String? id,
  }) : super(id ?? 'FCB');

  ///input data
  final IndicatorInput indicatorInput;

  /// FCB high series
  late SingleIndicatorSeries fcbHighSeries;

  /// FCB low series
  late SingleIndicatorSeries fcbLowSeries;

  /// Configuration of FCB Indicator.
  final FractalChaosBandIndicatorConfig config;

  @override
  SeriesPainter<Series>? createPainter() {
    fcbHighSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => FCBHighIndicator<Tick>(indicatorInput),
      inputIndicator: CloseValueIndicator<Tick>(indicatorInput),
      style: config.highLineStyle,
    );
    fcbLowSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => FCBLowIndicator<Tick>(indicatorInput),
      inputIndicator: CloseValueIndicator<Tick>(indicatorInput),
      style: config.lowLineStyle,
    );

    if (config.showChannelFill) {
      return ChannelFillPainter(
        fcbHighSeries,
        fcbLowSeries,
        firstUpperChannelFillColor: config.fillColor.withOpacity(0.2),
        secondUpperChannelFillColor: config.fillColor.withOpacity(0.2),
      );
    }

    return null;
  }

  @override
  bool shouldRepaint(ChartData? previous) {
    if (previous == null) {
      return true;
    }

    final FractalChaosBandSeries oldSeries = previous as FractalChaosBandSeries;
    return config.toJson().toString() != oldSeries.config.toJson().toString();
  }

  @override
  bool didUpdate(ChartData? oldData) {
    final FractalChaosBandSeries? series = oldData as FractalChaosBandSeries?;
    final bool _fcbHighUpdated = fcbHighSeries.didUpdate(series?.fcbHighSeries);
    final bool _fcbLowUpdated = fcbLowSeries.didUpdate(series?.fcbLowSeries);
    return _fcbHighUpdated || _fcbLowUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    fcbHighSeries.update(leftEpoch, rightEpoch);
    fcbLowSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() => <double>[
        <ChartData>[
          fcbHighSeries,
          fcbLowSeries,
        ].getMinValue(),
        <ChartData>[
          fcbHighSeries,
          fcbLowSeries,
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
    ChartScaleModel chartScaleModel,
  ) {
    fcbLowSeries.paint(canvas, size, epochToX, quoteToY, animationInfo,
        chartConfig, theme, chartScaleModel);
    fcbHighSeries.paint(canvas, size, epochToX, quoteToY, animationInfo,
        chartConfig, theme, chartScaleModel);

    if (config.showChannelFill &&
        fcbHighSeries.visibleEntries.isNotEmpty &&
        fcbLowSeries.visibleEntries.isNotEmpty) {
      super.paint(canvas, size, epochToX, quoteToY, animationInfo, chartConfig,
          theme, chartScaleModel);
    }
  }

  @override
  int? getMaxEpoch() => <ChartData>[
        fcbLowSeries,
        fcbHighSeries,
      ].getMaxEpoch();

  @override
  int? getMinEpoch() => <ChartData>[
        fcbLowSeries,
        fcbHighSeries,
      ].getMinEpoch();
}
