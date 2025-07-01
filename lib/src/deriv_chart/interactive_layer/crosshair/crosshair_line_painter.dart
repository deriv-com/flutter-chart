import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';

/// A custom painter to paint the crosshair `line`.
abstract class CrosshairLinePainter extends CustomPainter {
  /// Initializes a custom painter to paint the crosshair `line`.
  const CrosshairLinePainter({
    required this.theme,
    this.cursorY = 0,
  });

  /// The theme used to paint the crosshair line.
  final ChartTheme theme;

  /// The quote value of the crosshair.
  /// This is used to determine the position of the crosshair horizontal line on large screens.
  final double cursorY;

  @override
  void paint(Canvas canvas, Size size);

  @override
  bool shouldRepaint(CrosshairLinePainter oldDelegate) =>
      oldDelegate.theme != theme || oldDelegate.cursorY != cursorY;

  @override
  bool shouldRebuildSemantics(CrosshairLinePainter oldDelegate) => false;
}
