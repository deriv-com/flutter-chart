import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';

/// Renders a vertical dashed line between two points on the chart.
///
/// This function draws a vertical dashed line connecting two points on the canvas.
/// It automatically determines which point is higher and which is lower, ensuring
/// that the line is drawn correctly regardless of the order in which the points
/// are provided.
///
/// The function delegates the actual drawing to the `paintVerticalDashedLine` helper
/// function, which handles the creation of the dashed pattern. This function primarily
/// serves as a convenient wrapper that:
/// 1. Accepts two arbitrary points rather than requiring explicit y-coordinates
/// 2. Determines the correct top and bottom points automatically
/// 3. Provides sensible defaults for the dash pattern
///
/// Vertical lines are commonly used in financial charts to connect related points
/// that occur at the same time but different prices, such as entry and exit points
/// of a contract.
///
/// @param canvas The canvas on which to paint the line.
/// @param point1 The first point to connect.
/// @param point2 The second point to connect.
/// @param color The color to use for the line.
/// @param lineThickness The thickness of the line in logical pixels.
/// @param dashWidth The width of each dash in the line. Default is 3.
/// @param dashSpace The space between dashes in the line. Default is 3.
void paintVerticalLine(
  Canvas canvas,
  Offset point1,
  Offset point2,
  Color color,
  double lineThickness, {
  double dashWidth = 3,
  double dashSpace = 3,
}) {
  // Determine which point is higher (smaller y-coordinate)
  // and which is lower (larger y-coordinate)
  final Offset _topOffset = point1.dy < point2.dy ? point1 : point2;
  final Offset _bottomOffset = point1.dy > point2.dy ? point1 : point2;

  // Delegate to paintVerticalDashedLine to draw the actual line
  // Note: We use the x-coordinate from point1 and the y-coordinates from
  // the determined top and bottom points to ensure a perfectly vertical line
  paintVerticalDashedLine(
    canvas,
    point1.dx,
    _topOffset.dy,
    _bottomOffset.dy,
    color,
    lineThickness,
    dashWidth: 2,
    dashSpace: 2,
  );
}
