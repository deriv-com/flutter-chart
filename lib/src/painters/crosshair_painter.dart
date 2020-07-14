import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/candle.dart';
import '../models/chart_style.dart';

class CrosshairPainter extends CustomPainter {
  CrosshairPainter({
    @required this.crosshairCandle,
    @required this.style,
    @required this.pipSize,
    @required this.epochToCanvasX,
    @required this.quoteToCanvasY,
  });

  final Candle crosshairCandle;
  final ChartStyle style;
  final int pipSize;
  final double Function(int) epochToCanvasX;
  final double Function(double) quoteToCanvasY;

  @override
  void paint(Canvas canvas, Size size) {
    if (crosshairCandle == null) return;

    final crosshairPaint = Paint()..color = Colors.white;
    final x = epochToCanvasX(crosshairCandle.epoch);

    canvas.drawLine(
      Offset(x, 40),
      Offset(x, size.height),
      crosshairPaint,
    );

    canvas.drawCircle(
      Offset(x, quoteToCanvasY(crosshairCandle.close)),
      3,
      crosshairPaint,
    );
  }

  @override
  bool shouldRepaint(CrosshairPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(CrosshairPainter oldDelegate) => false;
}
