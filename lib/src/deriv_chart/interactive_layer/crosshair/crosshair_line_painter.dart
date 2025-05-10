import 'dart:ui' as ui;

import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_line.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_variant.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';

/// A custom painter to paint the crossshair `line`.
class CrosshairLinePainter extends CustomPainter {
  /// Initializes a custom painter to paint the crossshair `line`.
  const CrosshairLinePainter({
    required this.crosshairVariant,
    required this.theme,
    this.cursorY = 0,
  });

  /// The variant of the crosshair to be used.
  /// This is used to determine the type of crosshair to display.
  /// The default is [CrosshairVariant.smallScreen].
  /// [CrosshairVariant.largeScreen] is mostly for web.
  final CrosshairVariant crosshairVariant;

  /// The theme used to paint the crosshair line.
  final ChartTheme theme;

  /// The quote value of the crosshair.
  /// This is used to determine the position of the crosshair horizontal line on large screens.
  final double cursorY;

  @override
  void paint(Canvas canvas, Size size) {
    if (crosshairVariant == CrosshairVariant.smallScreen) {
      paintSmallScreenLine(canvas: canvas, size: size);
    } else {
      paintLargeScreenLines(canvas: canvas, size: size);
    }
  }

  @override
  bool shouldRepaint(CrosshairLinePainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(CrosshairLinePainter oldDelegate) => false;

  /// Paints the crosshair line for small screens.
  ///
  /// This method creates a gradient line that extends vertically from the top to the bottom
  /// of the chart area. The gradient transitions from the upper colors to the lower colors.
  ///
  /// [canvas] The canvas to paint on.
  /// [size] The size of the painting area.
  void paintSmallScreenLine({required Canvas canvas, required Size size}) {
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

  /// Paints the crosshair lines for large screens.
  ///
  /// This method creates two dashed lines: a horizontal line across the entire width
  /// of the chart at the cursor's Y position, and a vertical line from the top to the
  /// bottom of the chart.
  ///
  /// The dashed lines appear as a series of short line segments with spaces between them,
  /// creating a pattern like this:
  /// ```
  ///     |     |     |     |     |
  ///     |     |     |     |     |
  /// ----+-----+-----+-----+-----+----
  ///     |     |     |     |     |
  ///     |     |     |     |     |
  /// ```
  /// By default, each dash is 3 pixels long with a 3-pixel space between dashes.
  ///
  /// [canvas] The canvas to paint on.
  /// [size] The size of the painting area.
  void paintLargeScreenLines({required Canvas canvas, required Size size}) {
    final lineColor = theme.crosshairLineDesktopColor;
    // Paint the horizontal dashed line and make it occupy the entire width of the screen (-size.width, size.width).
    paintHorizontalDashedLine(
        canvas, -size.width, size.width, cursorY, lineColor, 1);
    // Paint the vertical dashed line and make it occupy the entire height of the screen (0, size.height).
    paintVerticalDashedLine(canvas, 0, 0, size.height, lineColor, 1);
  }
}
