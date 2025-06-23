import 'dart:ui' as ui;
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_line_painter.dart';
import 'package:flutter/material.dart';

/// A custom painter to paint the crosshair `line`.
class SmallScreenCrosshairLinePainter extends CrosshairLinePainter {
  /// Initializes a custom painter to paint the crosshair `line` for small screens.
  const SmallScreenCrosshairLinePainter({
    required super.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Color upperStart =
        theme.crosshairLineResponsiveUpperLineGradientStart;
    final Color upperEnd = theme.crosshairLineResponsiveUpperLineGradientEnd;
    final Color lowerStart =
        theme.crosshairLineResponsiveLowerLineGradientStart;
    final Color lowerEnd = theme.crosshairLineResponsiveLowerLineGradientEnd;

    canvas.drawLine(
      const Offset(0, 8),
      Offset(0, size.height),
      Paint()
        ..strokeWidth = 2
        ..style = PaintingStyle.fill
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, size.height),
          <Color>[
            upperStart,
            upperEnd,
            lowerStart,
            lowerEnd,
          ],
          const <double>[
            0,
            0.25,
            0.5,
            1,
          ],
        ),
    );
  }
}
