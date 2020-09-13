import 'package:deriv_chart/src/logic/component.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:flutter/material.dart';

class ChartPainter extends CustomPainter {
  ChartPainter({
    this.pipSize,
    this.components,
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

  final List<Component> components;

  @override
  void paint(Canvas canvas, Size size) {
    this.canvas = canvas;
    this.size = size;

    for (final Component c in components) {
      c.paint(
        canvas,
        size,
        epochToCanvasX,
        quoteToCanvasY,
        animationInfo,
        pipSize,
      );
    }
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(ChartPainter oldDelegate) => false;
}
