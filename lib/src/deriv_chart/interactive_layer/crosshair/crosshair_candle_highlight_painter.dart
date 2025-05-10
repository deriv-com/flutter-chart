import 'package:deriv_chart/src/models/candle.dart';
import 'package:flutter/material.dart';

/// A custom painter to paint a highlighted candle at the crosshair position.
class CrosshairCandleHighlightPainter extends CustomPainter {
  /// Initializes a custom painter to paint a highlighted candle.
  const CrosshairCandleHighlightPainter({
    required this.candle,
    required this.quoteToY,
    required this.xCenter,
    required this.candleWidth,
    required this.bodyHighlightColor,
    required this.wickHighlightColor,
  });

  /// The candle to highlight.
  final Candle candle;

  /// Function to convert quote to Y coordinate.
  final double Function(double) quoteToY;

  /// The X center position of the candle.
  final double xCenter;

  /// The width of the candle.
  final double candleWidth;

  /// The color to use for highlighting the candle body.
  final Color bodyHighlightColor;

  /// The color to use for highlighting the candle wick.
  final Color wickHighlightColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = wickHighlightColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.fill;

    // Draw the wick (vertical line representing high to low)
    canvas.drawLine(
      Offset(xCenter, quoteToY(candle.high)),
      Offset(xCenter, quoteToY(candle.low)),
      paint,
    );

    // Draw the body (rectangle representing open to close)
    final double yOpen = quoteToY(candle.open);
    final double yClose = quoteToY(candle.close);

    // Determine the top and bottom of the candle body
    final double top = yOpen < yClose ? yOpen : yClose;
    final double bottom = yOpen < yClose ? yClose : yOpen;

    paint.color = bodyHighlightColor;

    canvas.drawRect(
      Rect.fromLTRB(
        xCenter - candleWidth / 2,
        top,
        xCenter + candleWidth / 2,
        bottom,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CrosshairCandleHighlightPainter oldDelegate) =>
      oldDelegate.candle != candle ||
      oldDelegate.xCenter != xCenter ||
      oldDelegate.candleWidth != candleWidth ||
      oldDelegate.bodyHighlightColor != bodyHighlightColor;
}
