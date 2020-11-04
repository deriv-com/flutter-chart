import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:flutter/material.dart';

class ChartPainter extends CustomPainter {
  ChartPainter({
    this.chartConfig,
    this.chartDataList,
    this.animationInfo,
    this.epochToCanvasX,
    this.quoteToCanvasY,
  });

  /// Chart config
  final ChartConfig chartConfig;

  final double Function(int) epochToCanvasX;
  final double Function(double) quoteToCanvasY;

  final AnimationInfo animationInfo;

  final List<ChartData> chartDataList;

  @override
  void paint(Canvas canvas, Size size) {
    for (final ChartData c in chartDataList) {
      c.paint(
        canvas,
        size,
        epochToCanvasX,
        quoteToCanvasY,
        animationInfo,
        chartConfig,
      );
    }
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(ChartPainter oldDelegate) => false;
}
