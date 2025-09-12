import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';

/// The `CustomPainter` which paints the chart.
class ChartPainter extends CustomPainter {
  /// Initializes the `CustomPainter` which paints the chart.
  ChartPainter({
    required this.chartConfig,
    required this.theme,
    required this.chartData,
    required this.epochToCanvasX,
    required this.quoteToCanvasY,
    required this.chartScaleModel,
    this.animationInfo = const AnimationInfo(),
  });

  /// Chart config
  final ChartConfig chartConfig;

  /// The theme used to paint the chart.
  final ChartTheme theme;

  /// Conversion function for converting epoch to chart's canvas' X position.
  final EpochToX epochToCanvasX;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final QuoteToY quoteToCanvasY;

  /// Animation info where the animation progress values are in.
  final AnimationInfo animationInfo;

  /// The chart data to paint inside of the chart.
  final ChartData chartData;

  /// The controller of the chart.
  final ChartScaleModel chartScaleModel;

  @override
  void paint(Canvas canvas, Size size) {
    chartData.paint(
      canvas,
      size,
      epochToCanvasX,
      quoteToCanvasY,
      animationInfo,
      chartConfig,
      theme,
      chartScaleModel,
    );
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) =>
      chartData.shouldRepaint(oldDelegate.chartData);

  @override
  bool shouldRebuildSemantics(ChartPainter oldDelegate) => false;

  @override
  SemanticsBuilderCallback get semanticsBuilder {
    return (Size size) {
      return chartData.buildSemantics(size, epochToCanvasX, quoteToCanvasY);
    };
  }
}
