import 'dart:math';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';

/// Calculates the appropriate width for the y-axis based on the price values.
///
/// This function determines how much horizontal space the y-axis should occupy
/// to properly display price labels. It takes into account the current price values,
/// the theme's styling for y-axis labels, and the precision of price display.
///
/// The calculation is based on the width needed to display the last (most recent)
/// price value, plus additional padding specified in the theme. If there are no
/// ticks available, a default width of 60 logical pixels is returned.
///
/// @param ticks A list of price ticks from which to determine the y-axis width.
///        The last tick in the list is used for the calculation.
/// @param theme The chart theme, which provides styling information for the y-axis labels.
/// @param pipSize The number of decimal places to display for price values.
/// @return The calculated width for the y-axis in logical pixels.
double calculateYAxisWidth(List<Tick> ticks, ChartTheme theme, int pipSize) {
  if (ticks.isEmpty) {
    return 60;
  } else {
    final double width = labelWidth(
      ticks.last.close,
      theme.gridStyle.yLabelStyle,
      pipSize,
    );

    return width + theme.gridStyle.labelHorizontalPadding * 2;
  }
}

/// Calculates the width needed to display the current tick's price label.
///
/// This function determines how much horizontal space is needed to display
/// the price label for the current (most recent) tick. It's used for components
/// that need to display the current price, such as price labels or tooltips.
///
/// The calculation is based on the width needed to display the last (most recent)
/// price value, plus additional padding (4 logical pixels on each side, plus 3
/// extra pixels). If there are no ticks available, a default width of 60 logical
/// pixels is returned.
///
/// @param ticks A list of price ticks from which to determine the label width.
///        The last tick in the list is used for the calculation.
/// @param textStyle The text style to apply to the price label, which affects its width.
/// @param pipSize The number of decimal places to display for price values.
/// @return The calculated width for the current tick's price label in logical pixels.
double calculateCurrentTickWidth(
    List<Tick> ticks, TextStyle textStyle, int pipSize) {
  if (ticks.isEmpty) {
    return 60;
  } else {
    final double width = labelWidth(
      ticks.last.close,
      textStyle,
      pipSize,
    );

    return width + 4 * 2 + 3;
  }
}

/// Calculates the opacity for markers based on their horizontal positions.
///
/// This function determines how transparent a marker should be based on its
/// position relative to another marker (typically an exit point). It's used
/// to create a visual fade effect for markers as they approach an exit point.
///
/// The opacity is calculated based on the horizontal distance between the
/// 'from' position and the 'exitTo' position. If the distance is less than
/// 10 logical pixels, the opacity starts decreasing. The opacity reaches 0
/// when the distance is 10 pixels or less, and reaches 1 when the distance
/// is 16 pixels or more.
///
/// If no exit position is provided (exitTo is null), the opacity is set to 1
/// (fully opaque).
///
/// @param from The horizontal position (x-coordinate) of the marker.
/// @param exitTo The horizontal position (x-coordinate) of the exit point,
///        or null if there is no exit point.
/// @return The calculated opacity value between 0 (transparent) and 1 (opaque).
double calculateOpacity(
  double from,
  double? exitTo,
) {
  if (exitTo != null) {
    return min(max(exitTo - from - 10, 0) / 6, 1);
  }
  return 1;
}
