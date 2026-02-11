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
    final double lineStartY = topPadding;
    final double lineEndY = size.height - bottomPadding;

    if (dashed) {
      paintVerticalDashedLine(
        canvas,
        x,
        lineStartY,
        lineEndY,
        color,
        strokeWidth,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
      );
    } else {
      final Paint paint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth;
      canvas.drawLine(Offset(x, lineStartY), Offset(x, lineEndY), paint);
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

  /// Paints [text] centered at the bottom (a few pixels above) of the chart at [x].
  ///
  /// This is similar to [paintBottomIcon] but for text labels (e.g., "1", "2").
  /// Used for checkpoint markers and exit time markers.
  static void paintBottomText(
    Canvas canvas,
    Size size,
    double x,
    String text,
    double zoom,
    Color color,
  ) {
    // Use a circular container size matching the icon size for consistent alignment
    final double containerSize = 24 * zoom;

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 14 * zoom,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Center the text within the container area at the bottom
    final Offset textOffset = Offset(
      x - textPainter.width / 2,
      size.height - containerSize + (containerSize - textPainter.height) / 2,
    );

    textPainter.paint(canvas, textOffset);
  }
}
