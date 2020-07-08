import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/candle.dart';
import '../models/chart_style.dart';

import '../paint/paint_text.dart';

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

    if (style == ChartStyle.line) {
      paintTextFromCenter(
        canvas,
        text: crosshairCandle.close.toStringAsFixed(pipSize),
        centerX: x,
        centerY: 10,
        style: TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFeatures: [FontFeature.tabularFigures()],
          backgroundColor: Color(0xFF0E0E0E),
        ),
      );
    }

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
        backgroundColor: Color(0xFF0E0E0E),
      ),
    );
  }

  @override
  bool shouldRepaint(CrosshairPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(CrosshairPainter oldDelegate) => false;
}
