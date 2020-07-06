import 'package:flutter/material.dart';

import '../models/candle.dart';

class CrosshairPainter extends CustomPainter {
  CrosshairPainter({
    @required this.crosshairCandle,
    @required this.pipSize,
    @required this.epochToCanvasX,
    @required this.quoteToCanvasY,
  });

  final Candle crosshairCandle;
  final int pipSize;
  final double Function(int) epochToCanvasX;
  final double Function(double) quoteToCanvasY;

  @override
  void paint(Canvas canvas, Size size) {
    if (crosshairCandle == null) return;

    final x = epochToCanvasX(crosshairCandle.epoch);
    canvas.drawLine(
      Offset(x, 0),
      Offset(x, size.height),
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(CrosshairPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(CrosshairPainter oldDelegate) => false;
}
