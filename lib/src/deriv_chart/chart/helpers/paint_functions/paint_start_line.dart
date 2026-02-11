import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/chart_marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_props.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_time_marker_utils.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';

/// Renders a vertical dashed line with a stopwatch icon to indicate the start time of a contract.
///
/// This function draws a vertical dashed line at the specified horizontal position,
/// extending from near the top of the chart to near the bottom. The line visually
/// marks the starting time of a contract or trade on a financial chart. A stopwatch
/// icon is rendered at the bottom of the line.
///
/// The function performs two main rendering operations:
/// 1. Draws a vertical dashed line using the `paintVerticalTimeLine` helper function
/// 2. Renders a stopwatch icon at the bottom of the chart
///
/// The vertical line uses the color determined by the marker's direction or explicit color,
/// and the icon is styled according to the marker style with appropriate scaling based
/// on the zoom factor.
///
/// The [canvas] is the canvas on which to paint the line and icon.
/// The [size] is the size of the drawing area, used to determine the vertical extent of the line.
/// The [marker] is the chart marker used to determine line color.
/// The [anchor] is the position on the canvas where the line should be anchored.
/// The [style] is the marker style, which provides colors and icon styling information.
/// The [theme] is the chart theme, which provides color schemes and styling.
/// The [zoom] is the zoom factor to apply to icon size and other dimensions.
/// The [opacity] is the opacity to apply to the line and icon.
/// The [props] contains additional marker properties that can affect rendering.
void paintStartLine(
    Canvas canvas,
    Size size,
    ChartMarker marker,
    Offset anchor,
    MarkerStyle style,
    ChartTheme theme,
    double zoom,
    double opacity,
    MarkerProps props) {
  // Determine marker color based on marker.color or marker direction
  final Color markerColor = marker.color ??
      (marker.direction == MarkerDirection.up
          ? theme.markerStyle.upColorProminent
          : theme.markerStyle.downColorProminent);

  final Color lineColor = markerColor.withOpacity(opacity);

  // Draw full vertical dashed line from near the top of the chart to near the bottom
  TimeMarkerPainters.paintVerticalTimeLine(
    canvas,
    size,
    anchor.dx,
    color: lineColor,
    dashed: true,
  );

  // Render the start icon (stopwatch) at the bottom of the line following MarkerStyle
  TimeMarkerPainters.paintBottomIcon(
    canvas,
    size,
    anchor.dx,
    style.startTimeIcon,
    zoom,
    lineColor,
  );
}
