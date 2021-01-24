import 'dart:ui' as ui;

import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_series.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

/// The custom painter to paint the crossshair.
class CrosshairPainter extends CustomPainter {
  /// Initializes the custom painter to paint the crossshair.
  CrosshairPainter({
    @required this.mainSeries,
    @required this.crosshairTick,
    @required this.epochToCanvasX,
    @required this.quoteToCanvasY,
  });

  /// Chart's main series.
  final Series mainSeries;

  /// The tick of the showing data.
  final Tick crosshairTick;

  /// Conversion function for converting eoch to chart's canvas' X position.
  final double Function(int) epochToCanvasX;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteToCanvasY;

  @override
  void paint(Canvas canvas, Size size) {
    if (crosshairTick == null) return;

    final x = epochToCanvasX(crosshairTick.epoch);
    final y = quoteToCanvasY(crosshairTick.quote);

    canvas.drawLine(
      Offset(x, 8),
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
