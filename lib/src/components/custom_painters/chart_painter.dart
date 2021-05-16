import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';

/// The `CustomPainter` which paints the chart.
class ChartPainter extends CustomPainter {
  /// Initializes the `CustomPainter` which paints the chart.
  ChartPainter({
    this.chartConfig,
    this.theme,
    this.chartData,
    this.animationInfo,
    this.epochToCanvasX,
    this.quoteToCanvasY,
  });

  /// Chart config
  final ChartConfig chartConfig;

  /// The theme used to paint the chart.
  final ChartTheme theme;

  /// Conversion function for converting epoch to chart's canvas' X position.
  final double Function(int) epochToCanvasX;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteToCanvasY;

  /// Animation info where the animation progress values are in.
  final AnimationInfo animationInfo;

  /// The chart data to paint inside of the chart.
  final ChartData chartData;

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
    );
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) =>
      chartData.shouldRepaint(oldDelegate.chartData);

  @override
  bool shouldRebuildSemantics(ChartPainter oldDelegate) => false;
}
