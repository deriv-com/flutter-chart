import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/chart_marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_props.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_time_marker_utils.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';

/// Renders a vertical dashed line with a flag icon to indicate the end time of a contract.
///
/// This function draws a vertical dashed line at the specified horizontal position,
/// extending from near the top of the chart to near the bottom. The line visually
/// marks the end time of a contract or trade on a financial chart. It also renders
/// a flag icon near the bottom of the line.
///
/// The function performs two main rendering operations:
/// 1. Draws a vertical dashed line using the `paintVerticalDashedLine` helper function
/// 2. Renders a flag icon near the bottom of the chart
///
/// The vertical line uses the background color from the provided style, and the icon
/// is styled according to the marker style with appropriate scaling based on the zoom factor.
///
/// @param canvas The canvas on which to paint the line and icon.
/// @param size The size of the drawing area, used to determine the vertical extent of the line.
/// @param marker The chart marker (kept for signature parity with start line painter).
/// @param anchor The position on the canvas where the line should be anchored.
/// @param style The marker style, which provides colors and icon styling information.
/// @param zoom The zoom factor to apply to icon size and other dimensions.
void paintEndLine(
  Canvas canvas,
  Size size,
  ChartMarker marker,
  Offset anchor,
  MarkerStyle style,
  double zoom,
  MarkerProps props,
) {
  // Determine marker color based on marker.color or marker direction
  final Color markerColor = marker.color ??
      (marker.direction == MarkerDirection.up
          ? style.upColor
          : style.downColor);
  final bool isDashed = props.isRunning;

  // Draw the vertical line from near the top of the chart to near the bottom.
  // Use dashed style while running, otherwise paint as a solid line.
  TimeMarkerPainters.paintVerticalTimeLine(
    canvas,
    size,
    anchor.dx,
    color: markerColor,
    dashed: isDashed,
  );

  // Render the end icon (flag) at the bottom of the line following MarkerStyle.
  TimeMarkerPainters.paintBottomIcon(
    canvas,
    size,
    anchor.dx,
    style.endTimeIcon,
    zoom,
    markerColor,
  );
}
