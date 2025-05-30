import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_highlight_painter.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:flutter/material.dart';

/// A custom painter to paint a highlighted OHLC candle at the crosshair position.
class CrosshairOhlcHighlightPainter extends CrosshairHighlightPainter {
  /// Initializes a custom painter to paint a highlighted OHLC candle.
  const CrosshairOhlcHighlightPainter({
    required Candle candle,
    required double Function(double) quoteToY,
    required double xCenter,
    required this.candleWidth,
    required this.highlightColor,
    this.strokeWidth = 1.5,
  }) : super(
          tick: candle,
          quoteToY: quoteToY,
          xCenter: xCenter,
        );

  /// Gets the candle to highlight.
  Candle get candle => tick as Candle;

  /// The width of the candle.
  final double candleWidth;

  /// The color to use for highlighting the OHLC candle.
  final Color highlightColor;

  /// The stroke width for the OHLC candle lines.
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = highlightColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Draw the wick (vertical line representing high to low)
    canvas
      ..drawLine(
        Offset(xCenter, quoteToY(candle.high)),
        Offset(xCenter, quoteToY(candle.low)),
        paint,
      )

      // Draw the open line (horizontal line on the left)
      ..drawLine(
        Offset(xCenter - candleWidth / 2, quoteToY(candle.open)),
        Offset(xCenter, quoteToY(candle.open)),
        paint,
      )

      // Draw the close line (horizontal line on the right)
      ..drawLine(
        Offset(xCenter, quoteToY(candle.close)),
        Offset(xCenter + candleWidth / 2, quoteToY(candle.close)),
        paint,
      );
  }

  @override
  bool shouldRepaint(covariant CrosshairOhlcHighlightPainter oldDelegate) =>
      super.shouldRepaint(oldDelegate) ||
      oldDelegate.candleWidth != candleWidth ||
      oldDelegate.highlightColor != highlightColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
