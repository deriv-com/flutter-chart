import 'package:deriv_chart/src/paint/paint_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

    paintTextFromCenter(
      canvas,
      text: crosshairCandle.close.toStringAsFixed(pipSize),
      centerX: x,
      centerY: 10,
      style: TextStyle(
        fontSize: 14,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );

    final time = DateTime.fromMillisecondsSinceEpoch(crosshairCandle.epoch);
    final timeLabel = DateFormat('dd MMM yy HH:mm:ss').format(time);

    paintTextFromCenter(
      canvas,
      text: timeLabel,
      centerX: x,
      centerY: 28,
      style: TextStyle(
        fontSize: 12,
        color: Colors.white70,
      ),
    );
  }

  @override
  bool shouldRepaint(CrosshairPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(CrosshairPainter oldDelegate) => false;
}
