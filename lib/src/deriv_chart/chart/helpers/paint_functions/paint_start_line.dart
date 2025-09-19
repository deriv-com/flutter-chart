import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/chart_marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_props.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_time_marker_utils.dart';
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
    MarkerStyle style, double zoom, MarkerProps props) {
  final Color markerColor = style.lineDefaultColor;

  // Draw a vertical dashed line from near the top of the chart to near the bottom.
  TimeMarkerPainters.paintVerticalTimeLine(
    canvas,
    size,
    anchor.dx,
    color: markerColor,
    dashed: true,
  );

  // Render the start icon at the bottom of the line following MarkerStyle.
  TimeMarkerPainters.paintBottomIcon(
    canvas,
    size,
    anchor.dx,
    style.startTimeIcon,
    zoom,
    markerColor,
  );
}
