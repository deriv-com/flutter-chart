import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:flutter/material.dart';

class ChartPainter extends CustomPainter {
  ChartPainter({
    this.pipSize,
    this.chartDataList,
    this.animationInfo,
    this.granularity,
    this.epochToCanvasX,
    this.quoteToCanvasY,
  });

  final int pipSize;
  final int granularity;

  final double Function(int) epochToCanvasX;
  final double Function(double) quoteToCanvasY;

  final AnimationInfo animationInfo;

  Canvas canvas;
  Size size;

  final List<ChartData> chartDataList;

  @override
  void paint(Canvas canvas, Size size) {
    this.canvas = canvas;
    this.size = size;

    for (final ChartData c in chartDataList) {
      c.paint(
        canvas,
        size,
        epochToCanvasX,
        quoteToCanvasY,
        animationInfo,
        pipSize,
        granularity,
      );
    }
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(ChartPainter oldDelegate) => false;
}
