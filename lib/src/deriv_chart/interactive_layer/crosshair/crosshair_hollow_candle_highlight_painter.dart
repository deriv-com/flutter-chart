import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_highlight_painter.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:flutter/material.dart';

/// A custom painter to paint a highlighted hollow candle at the crosshair position.
class CrosshairHollowCandleHighlightPainter extends CrosshairHighlightPainter {
  /// Initializes a custom painter to paint a highlighted hollow candle.
  const CrosshairHollowCandleHighlightPainter({
    required Candle candle,
    required double Function(double) quoteToY,
    required double xCenter,
    required this.candleWidth,
    required this.bodyHighlightColor,
    required this.wickHighlightColor,
  }) : super(
          tick: candle,
          quoteToY: quoteToY,
          xCenter: xCenter,
        );

  /// Gets the candle to highlight.
  Candle get candle => tick as Candle;

  /// The width of the candle.
  final double candleWidth;

  /// The color to use for highlighting the candle body.
  final Color bodyHighlightColor;

  /// The color to use for highlighting the candle wick.
  final Color wickHighlightColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint wickPaint = Paint()
      ..color = wickHighlightColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.fill;

    // Draw the wicks (vertical lines from high to close and from low to open)
    canvas
      ..drawLine(
        Offset(xCenter, quoteToY(candle.high)),
        Offset(xCenter, quoteToY(candle.close)),
        wickPaint,
      )
      ..drawLine(
        Offset(xCenter, quoteToY(candle.low)),
        Offset(xCenter, quoteToY(candle.open)),
        wickPaint,
      );

    final double yOpen = quoteToY(candle.open);
    final double yClose = quoteToY(candle.close);

    // Determine if it's a bullish or bearish candle
    // Bullish means price went up (close > open)
    final bool isBullish = candle.close > candle.open;

    final Paint bodyPaint = Paint()
      ..color = bodyHighlightColor
      ..strokeWidth = 1.5;

    if (yOpen == yClose) {
      // Draw a horizontal line for doji candles
      canvas.drawLine(
        Offset(xCenter - candleWidth / 2, yOpen),
        Offset(xCenter + candleWidth / 2, yOpen),
        bodyPaint,
      );
    } else if (!isBullish) {
      // Bearish candle (filled)
      bodyPaint.style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTRB(
          xCenter - candleWidth / 2,
          yClose,
          xCenter + candleWidth / 2,
          yOpen,
        ),
        bodyPaint,
      );
    } else {
      // Bullish candle (hollow)
      bodyPaint.style = PaintingStyle.stroke;
      canvas.drawRect(
        Rect.fromLTRB(
          xCenter - candleWidth / 2,
          yOpen,
          xCenter + candleWidth / 2,
          yClose,
        ),
        bodyPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
          covariant CrosshairHollowCandleHighlightPainter oldDelegate) =>
      super.shouldRepaint(oldDelegate) ||
      oldDelegate.candleWidth != candleWidth ||
      oldDelegate.bodyHighlightColor != bodyHighlightColor ||
      oldDelegate.wickHighlightColor != wickHighlightColor;
}
