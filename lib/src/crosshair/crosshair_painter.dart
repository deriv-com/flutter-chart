import 'dart:ui' as ui;

import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_series.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

class CrosshairPainter extends CustomPainter {
  CrosshairPainter({
    @required this.mainSeries,
    @required this.crosshairTick,
    @required this.epochToCanvasX,
    @required this.quoteToCanvasY,
  });

  /// Chart's main series
  final Series mainSeries;
  final Tick crosshairTick;
  final double Function(int) epochToCanvasX;
  final double Function(double) quoteToCanvasY;

  @override
  void paint(Canvas canvas, Size size) {
    if (crosshairTick == null) {
      return;
    }

    final double x = epochToCanvasX(crosshairTick.epoch);
    final double y = quoteToCanvasY(crosshairTick.quote);

    canvas.drawLine(
      Offset(x, 8),
      Offset(x, size.height),
      Paint()
        ..strokeWidth = 2
        ..style = PaintingStyle.fill
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          Offset(0, size.height),
          <Color>[
            // TODO(Ramin): Use theme color when cross-hair design got updated
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
          <double>[
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
