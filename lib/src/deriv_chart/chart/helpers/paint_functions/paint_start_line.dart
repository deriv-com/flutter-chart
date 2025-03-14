import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/chart_marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_line.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';

/// Renders a vertical dashed line with optional text to indicate the start time of a contract.
///
/// This function draws a vertical dashed line at the specified horizontal position,
/// extending from near the top of the chart to near the bottom. The line visually
/// marks the starting time of a contract or trade on a financial chart. If the marker
/// has text, it also renders a text label near the bottom of the line.
///
/// The function performs two main rendering operations:
/// 1. Draws a vertical dashed line using the `paintVerticalDashedLine` helper function
/// 2. If text is provided in the marker, renders a text label near the bottom of the chart
///
/// The vertical line uses the background color from the provided style, and the text
/// (if present) is styled according to the marker style with appropriate scaling
/// based on the zoom factor.
///
/// @param canvas The canvas on which to paint the line and text.
/// @param size The size of the drawing area, used to determine the vertical extent of the line.
/// @param marker The chart marker containing information like text to display.
/// @param anchor The position on the canvas where the line should be anchored.
/// @param style The marker style, which provides colors and text styling information.
/// @param zoom The zoom factor to apply to text size and other dimensions.
void paintStartLine(Canvas canvas, Size size, ChartMarker marker, Offset anchor,
    MarkerStyle style, double zoom) {
  // Draw a vertical dashed line from near the top of the chart to near the bottom
  // The line is positioned at the x-coordinate of the anchor point
  // It starts 10 pixels from the top and ends 10 pixels from the bottom
  paintVerticalDashedLine(
    canvas,
    anchor.dx,
    10,
    size.height - 10,
    style.backgroundColor,
    1,
    dashWidth: 6,
  );

  // If the marker has text, render it near the bottom of the chart
  if (marker.text != null) {
    // Create a text style based on the marker style, with appropriate scaling
    final TextStyle textStyle = TextStyle(
      color: style.backgroundColor,
      fontSize: style.activeMarkerText.fontSize! * zoom,
      fontWeight: FontWeight.normal,
    );

    // Create a text painter for the marker text
    final TextPainter textPainter = makeTextPainter(marker.text!, textStyle);

    // Position the text to the left of the line, near the bottom of the chart
    // The text is shifted left by its width plus 5 pixels of padding
    // It's positioned 20 pixels from the bottom of the chart
    final Offset iconShift =
        Offset(anchor.dx - textPainter.width - 5, size.height - 20);

    // Paint the text at the calculated position
    paintWithTextPainter(
      canvas,
      painter: textPainter,
      anchor: iconShift,
      anchorAlignment: Alignment.centerLeft,
    );
  }
}
