import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_highlight_painter.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

/// A custom painter to paint a highlighted point at the crosshair position for line charts.
class CrosshairLineHighlightPainter extends CrosshairHighlightPainter {
  /// Initializes a custom painter to paint a highlighted point.
  const CrosshairLineHighlightPainter({
    required Tick tick,
    required double Function(double) quoteToY,
    required double xCenter,
    required this.pointColor,
    required this.pointSize,
    this.borderColor,
    this.borderWidth = 2.0,
  }) : super(
          tick: tick,
          quoteToY: quoteToY,
          xCenter: xCenter,
        );

  /// The color of the highlighted point.
  final Color pointColor;

  /// The size (diameter) of the highlighted point.
  final double pointSize;

  /// The color of the point's border, if any.
  final Color? borderColor;

  /// The width of the point's border, if any.
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final double yPosition = quoteToY(tick.quote);

    // Draw border if borderColor is provided
    if (borderColor != null) {
      final Paint borderPaint = Paint()
        ..color = borderColor!
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(xCenter, yPosition),
        pointSize / 2 + borderWidth,
        borderPaint,
      );
    }

    // Draw the point
    final Paint pointPaint = Paint()
      ..color = pointColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(xCenter, yPosition),
      pointSize / 2,
      pointPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CrosshairLineHighlightPainter oldDelegate) =>
      super.shouldRepaint(oldDelegate) ||
      oldDelegate.pointColor != pointColor ||
      oldDelegate.pointSize != pointSize ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.borderWidth != borderWidth;
}
