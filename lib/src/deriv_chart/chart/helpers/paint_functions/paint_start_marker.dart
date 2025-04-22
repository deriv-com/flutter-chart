import 'package:flutter/material.dart';

/// Renders a location pin icon to indicate the start point of a contract.
///
/// This function draws a location pin icon (from Material Icons) at the specified
/// position on the canvas. The pin visually marks the starting point of a contract
/// or trade on a financial chart, making it easy for users to identify where a
/// contract began.
///
/// The function uses Flutter's TextPainter to render the icon, which is an efficient
/// way to draw icons from icon fonts. The icon is rendered with the specified color
/// and size, allowing for consistent styling with other chart elements.
///
/// This marker is typically used in conjunction with other visual elements like
/// vertical lines (`paintStartLine`) to provide a complete visual representation
/// of contract start points.
///
/// @param canvas The canvas on which to paint the marker.
/// @param offset The position on the canvas where the marker should be drawn.
/// @param color The color to use for the marker.
/// @param iconSize The size of the icon in logical pixels.
void paintStartMarker(
    Canvas canvas, Offset offset, Color color, double iconSize) {
  // Use the location_on icon from Material Icons as the pin marker
  const IconData icon = Icons.location_on;

  // Create a TextPainter to render the icon
  // TextPainter is used because it's an efficient way to render
  // icons from icon fonts like Material Icons
  TextPainter(textDirection: TextDirection.ltr)
    // Configure the text span with the icon character and styling
    ..text = TextSpan(
      // Convert the icon's code point to a character
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: iconSize,
        fontFamily: icon.fontFamily,
        color: color,
      ),
    )
    // Calculate the layout of the icon
    ..layout()
    // Paint the icon at the specified offset
    ..paint(
      canvas,
      offset,
    );
}
