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
  ///
  /// If [gapHeight] and [gapOffset] are provided, creates a gap in the line:
  /// - [gapHeight]: The height of the gap in pixels
  /// - [gapOffset]: The Y position where the gap starts (top of the gap)
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
    double? gapHeight,
    double? gapOffset,
  }) {
    final double lineStartY = topPadding;
    final double lineEndY = size.height - bottomPadding;

    // If gap parameters are provided, draw line in two segments
    if (gapHeight != null && gapOffset != null) {
      final double gapTop = gapOffset;
      final double gapBottom = gapOffset + gapHeight;

      // Draw top segment
      if (dashed) {
        paintVerticalDashedLine(
          canvas,
          x,
          lineStartY,
          gapTop,
          color,
          strokeWidth,
          dashWidth: dashWidth,
          dashSpace: dashSpace,
        );
      } else {
        final Paint paint = Paint()
          ..color = color
          ..strokeWidth = strokeWidth;
        canvas.drawLine(Offset(x, lineStartY), Offset(x, gapTop), paint);
      }

      // Draw bottom segment
      if (dashed) {
        paintVerticalDashedLine(
          canvas,
          x,
          gapBottom,
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
        canvas.drawLine(Offset(x, gapBottom), Offset(x, lineEndY), paint);
      }
    } else {
      // Draw full line without gap
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
  }

  /// Paints a vertical line with text label centered in a gap at the anchor level.
  ///
  /// The [canvas] is the canvas on which to paint.
  /// The [size] is the size of the drawing area.
  /// The [text] is the text to display in the gap.
  /// The [anchor] is the position where the gap should start (anchor level).
  /// The [color] is the color for both the line and text.
  /// The [zoom] is the zoom factor for text sizing.
  /// The [dashed] parameter determines whether the line should be dashed.
  static void paintVerticalLineWithText(
    Canvas canvas,
    Size size,
    String text,
    Offset anchor,
    Color color,
    double zoom, {
    required bool dashed,
  }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 12 * zoom,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Add padding around text and center it vertically within the gap
    final double verticalPadding = 4 * zoom;
    final double gapHeight = textPainter.height + (verticalPadding * 2);

    // Center text within the gap
    final double textY = anchor.dy + (gapHeight - textPainter.height) / 2;
    final double textX = anchor.dx - textPainter.width / 2;

    // Draw vertical line with gap starting at barrier level
    paintVerticalTimeLine(
      canvas,
      size,
      anchor.dx,
      color: color,
      dashed: dashed,
      gapHeight: gapHeight,
      gapOffset: anchor.dy,
    );

    // Paint the text in the gap
    textPainter.paint(canvas, Offset(textX, textY));
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
