import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/chart_marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_props.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_time_marker_utils.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';

/// Renders a vertical dashed line with optional text to indicate a checkpoint.
///
/// This function draws a vertical dashed line at the specified horizontal position,
/// similar to start/exit time markers, but without a bottom icon. If the marker has
/// text, it renders the text at the bottom of the line.
///
/// This marker type is used for intermediate checkpoints in multi-stage contracts
/// (e.g., Double Rise/Fall) where multiple evaluation points need to be visualized
/// along the timeline.
///
/// The function performs two main rendering operations:
/// 1. Draws a vertical dashed line using the `paintVerticalTimeLine` helper function
/// 2. If text is provided in the marker, renders a text label at the bottom of the line
///
/// The vertical line uses the color determined by the marker's direction or explicit color,
/// and can optionally be rendered with reduced opacity if specified in the marker properties.
///
/// The [canvas] is the canvas on which to paint the line and text.
/// The [size] is the size of the drawing area, used to determine the vertical extent of the line.
/// The [marker] is the chart marker containing information like text to display and direction.
/// The [anchor] is the position on the canvas where the line should be anchored.
/// The [style] is the marker style, which provides colors and styling information.
/// The [theme] is the chart theme, which provides color schemes and styling.
/// The [zoom] is the zoom factor to apply to text size and other dimensions.
/// The [opacity] is the opacity to apply to the line and text.
/// The [props] contains additional marker properties that can affect rendering.
void paintCheckpointLine(
  Canvas canvas,
  Size size,
  ChartMarker marker,
  Offset anchor,
  MarkerStyle style,
  ChartTheme theme,
  double zoom,
  double opacity,
  MarkerProps props,
) {
  // Determine marker color based on marker.color or marker direction
  final Color markerColor = marker.color ??
      (marker.direction == MarkerDirection.up
          ? theme.markerStyle.upColorProminent
          : theme.markerStyle.downColorProminent);

  final Color lineColor = markerColor.withOpacity(opacity);

  // Draw full vertical dashed line from near the top to near the bottom of the chart
  TimeMarkerPainters.paintVerticalTimeLine(
    canvas,
    size,
    anchor.dx,
    color: lineColor,
    dashed: true,
  );

  // Render text label at the bottom if provided (e.g., "1", "2")
  if (marker.text != null && marker.text!.isNotEmpty) {
    TimeMarkerPainters.paintBottomText(
      canvas,
      size,
      anchor.dx,
      marker.text!,
      zoom,
      lineColor,
    );
  }
}
