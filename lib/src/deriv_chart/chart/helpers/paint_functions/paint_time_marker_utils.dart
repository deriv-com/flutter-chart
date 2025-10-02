import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_line.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:flutter/material.dart';

/// Shared utilities for painting time marker visuals (vertical line and bottom icon).
///
/// These helpers encapsulate common drawing logic used by start/end time painters
/// to avoid duplication and keep individual painters focused on their specifics.
class TimeMarkerPainters {
  /// Paints a vertical line at [x] from [topPadding] to [size.height - bottomPadding].
  ///
  /// When [dashed] is true, draws a dashed line using [dashWidth] and [dashSpace].
  /// Otherwise, draws a solid line with [strokeWidth].
  static void paintVerticalTimeLine(
    Canvas canvas,
    Size size,
    double x, {
    required Color color,
    required bool dashed,
    double strokeWidth = 1,
    double topPadding = 10,
    double bottomPadding = 28,
    double dashWidth = 2,
    double dashSpace = 2,
  }) {
    if (dashed) {
      paintVerticalDashedLine(
        canvas,
        x,
        topPadding,
        size.height - bottomPadding,
        color,
        strokeWidth,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
      );
    } else {
      final Paint paint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth;

      canvas.drawLine(
        Offset(x, topPadding),
        Offset(x, size.height - bottomPadding),
        paint,
      );
    }
  }

  /// Paints an [icon] centered at the bottom (a few pixels above) of the chart at [x].
  static void paintBottomIcon(
    Canvas canvas,
    Size size,
    double x,
    IconData icon,
    double zoom,
    Color color,
  ) {
    final double iconSize = 24 * zoom;

    final TextPainter iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          fontSize: iconSize,
          package: icon.fontPackage,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    paintWithTextPainter(
      canvas,
      painter: iconPainter,
      anchor: Offset(x, size.height),
      anchorAlignment: Alignment.bottomCenter,
    );
  }
}
