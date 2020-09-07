import 'dart:ui' as ui;

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/chart_series/base_series.dart';
import 'package:deriv_chart/src/theme/painting_styles/chart_paiting_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../models/candle.dart';

class CrosshairPainter extends CustomPainter {
  CrosshairPainter({
    @required this.mainSeries,
    @required this.crosshairCandle,
    @required this.epochToCanvasX,
    @required this.quoteToCanvasY,
  });

  /// Chart's main series
  final BaseSeries mainSeries;
  final Candle crosshairCandle;
  final double Function(int) epochToCanvasX;
  final double Function(double) quoteToCanvasY;

  @override
  void paint(Canvas canvas, Size size) {
    if (crosshairCandle == null) return;

    final x = epochToCanvasX(crosshairCandle.epoch);
    final y = quoteToCanvasY(crosshairCandle.close);

    canvas.drawLine(
      Offset(x, 0),
      Offset(x, size.height),
      Paint()
        ..strokeWidth = 2
        ..style = PaintingStyle.fill
        ..shader = ui.Gradient.linear(
          Offset(0, 0),
          Offset(0, size.height),
          [
            // TODO(Ramin): Use theme color when cross-hair design got updated
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
          [
            0,
            0.5,
            1,
          ],
        ),
    );

    if (mainSeries is LineSeries) {
      canvas.drawCircle(
        Offset(x, y),
        5,
        // TODO(Ramin): Use theme color when cross-hair design got updated
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(CrosshairPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(CrosshairPainter oldDelegate) => false;
}
