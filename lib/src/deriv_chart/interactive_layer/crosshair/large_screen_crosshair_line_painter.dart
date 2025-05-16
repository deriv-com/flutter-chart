import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_line.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_line_painter.dart';
import 'package:flutter/material.dart';

/// A custom painter to paint the crosshair `line` for large screens.
class LargeScreenCrosshairLinePainter extends CrosshairLinePainter {
  /// Initializes a custom painter to paint the crosshair `line` for large screens.
  const LargeScreenCrosshairLinePainter({
    required super.theme,
    super.cursorY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final lineColor = theme.crosshairLineDesktopColor;
    // Paint the horizontal dashed line and make it occupy the entire width of the screen (-size.width, size.width).
    paintHorizontalDashedLine(
        canvas, -size.width, size.width, cursorY, lineColor, 1);
    // Paint the vertical dashed line and make it occupy the entire height of the screen (0, size.height).
    paintVerticalDashedLine(canvas, 0, 0, size.height, lineColor, 1);
  }
}
