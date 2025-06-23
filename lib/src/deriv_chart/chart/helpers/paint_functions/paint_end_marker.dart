import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';

/// Renders a flag-shaped marker to indicate the end or expiry point of a contract.
///
/// This function draws a stylized flag icon at the specified position on the canvas.
/// The flag consists of two parts: a background rectangle and a detailed flag shape
/// with a checkered pattern. The flag is commonly used to visually mark the end or
/// expiry point of a contract or trade on a financial chart.
///
/// The function handles the following rendering steps:
/// 1. Saves the current canvas state
/// 2. Translates the canvas to the specified center position
/// 3. Applies scaling based on the zoom factor
/// 4. Draws the background rectangle with the theme's base color
/// 5. Draws the detailed flag shape with the specified color
/// 6. Restores the canvas to its original state
///
/// The flag design includes a pole and a checkered pattern that resembles a
/// racing flag, making it visually distinctive and easily recognizable on the chart.
///
/// @param canvas The canvas on which to paint the marker.
/// @param theme The chart theme, which provides colors for the marker.
/// @param center The position on the canvas where the marker should be centered.
/// @param color The color to use for the flag part of the marker.
/// @param zoom The zoom factor to apply to the marker size.
void paintEndMarker(
    Canvas canvas, ChartTheme theme, Offset center, Color color, double zoom) {
  canvas
    ..save()
    ..translate(
      center.dx,
      center.dy,
    )
    ..scale(1 * zoom);

  final Paint paint = Paint()
    ..style = PaintingStyle.fill
    ..color = theme.backgroundColor.withOpacity(1);

  // This path defines a simple rectangle that serves as the background for the flag and was generated with http://demo.qunee.com/svg2canvas/.
  final Path path = Path()
    ..moveTo(2, 2)
    ..lineTo(18, 2)
    ..lineTo(18, 12)
    ..lineTo(2, 12)
    ..close();

  // This path defines the detailed flag shape with a checkered pattern
  // The path includes the flag pole and a series of small rectangles
  // that create a checkered pattern resembling a racing flag
  final Path flagPath = Path()
    ..moveTo(2, 0)
    ..lineTo(2, 1)
    ..lineTo(19, 1)
    ..lineTo(19, 12)
    ..lineTo(2, 12)
    ..lineTo(2, 20)
    ..lineTo(1, 20)
    ..lineTo(1, 0)
    ..lineTo(2, 0)
    ..close()
    // The following sections define the checkered pattern
    // Each moveTo/lineTo sequence creates a small rectangle
    // First row (bottom)
    ..moveTo(18, 8)
    ..lineTo(15, 8)
    ..lineTo(15, 11)
    ..lineTo(18, 11)
    ..lineTo(18, 8)
    ..close()
    ..moveTo(12, 8)
    ..lineTo(9, 8)
    ..lineTo(9, 11)
    ..lineTo(12, 11)
    ..lineTo(12, 8)
    ..close()
    ..moveTo(6, 8)
    ..lineTo(3, 8)
    ..lineTo(3, 11)
    ..lineTo(6, 11)
    ..lineTo(6, 8)
    ..close()
    // Middle row
    ..moveTo(15, 5)
    ..lineTo(12, 5)
    ..lineTo(12, 8)
    ..lineTo(15, 8)
    ..lineTo(15, 5)
    ..close()
    ..moveTo(9, 5)
    ..lineTo(6, 5)
    ..lineTo(6, 8)
    ..lineTo(9, 8)
    ..lineTo(9, 5)
    ..close()
    // Top row
    ..moveTo(6, 2)
    ..lineTo(3, 2)
    ..lineTo(3, 5)
    ..lineTo(6, 5)
    ..lineTo(6, 2)
    ..close()
    ..moveTo(18, 2)
    ..lineTo(15, 2)
    ..lineTo(15, 5)
    ..lineTo(18, 5)
    ..lineTo(18, 2)
    ..close()
    ..moveTo(12, 2)
    ..lineTo(9, 2)
    ..lineTo(9, 5)
    ..lineTo(12, 5)
    ..lineTo(12, 2)
    ..close()
    ..fillType = PathFillType.evenOdd;

  final Paint flagPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = color;

  canvas
    ..drawPath(path, paint)
    ..drawPath(flagPath, flagPaint)
    ..restore();
}
