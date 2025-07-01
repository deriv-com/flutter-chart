import 'package:flutter/material.dart';

/// A custom painter to paint the crossshair `dot`.
class CrosshairDotPainter extends CustomPainter {
  /// Initializes a custom painter to paint the crosshair `dot`.
  const CrosshairDotPainter({
    this.dotColor = const Color(0xFF85ACB0),
    this.dotBorderColor = const Color(0xFF85ACB0),
  });

  /// Crosshair dot colors.
  final Color dotColor;

  /// Crosshair dot border colors.
  final Color dotBorderColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the outer circle (border)
    canvas
      ..drawCircle(
        const Offset(0, 0),
        7,
        Paint()
          ..color = dotBorderColor
          ..style = PaintingStyle.fill,
      )

      // Draw the inner circle (fill)
      ..drawCircle(
        const Offset(0, 0),
        4,
        Paint()
          ..color = dotColor
          ..style = PaintingStyle.fill,
      );
  }

  @override
  bool shouldRepaint(CrosshairDotPainter oldDelegate) =>
      oldDelegate.dotColor != dotColor ||
      oldDelegate.dotBorderColor != dotBorderColor;

  @override
  bool shouldRebuildSemantics(CrosshairDotPainter oldDelegate) => false;
}
