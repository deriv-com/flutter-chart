import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/behaviour/large_screen_crosshair_behaviour.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/behaviour/small_screen_crosshair_behaviour.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/painters/crosshair_dot_painter.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

/// A concrete implementation of CrosshairBehaviour for line series charts on large screens.
///
/// This class extends LargeScreenCrosshairBehaviour to provide specific behaviour
/// optimized for line series charts when displayed on large screens like desktop or web.
/// It defines the dimensions of the details box appropriate for line chart data.
class LineSeriesLargeScreenBehaviour<T extends Tick>
    extends LargeScreenCrosshairBehaviour<T> {
  /// The height of the crosshair details box in logical pixels.
  ///
  /// For line series on large screens, this is set to 50 pixels, which provides
  /// enough space to display the essential information for a line chart point
  /// (typically just the price and time) without taking up too much screen space.
  @override
  double get detailsBoxHeight => 50;

  @override
  CustomPainter createDotPainter({
    dotColor = const Color(0xFF85ACB0),
    dotBorderColor = const Color(0xFF85ACB0),
  }) {
    return const CrosshairDotPainter(
      dotColor: Colors.transparent,
      dotBorderColor: Colors.transparent,
    );
  }
}

/// A concrete implementation of CrosshairBehaviour for line series charts on small screens.
///
/// This class extends SmallScreenCrosshairBehaviour to provide specific behaviour
/// optimized for line series charts when displayed on small screens like mobile devices.
/// It adds a dot painter to highlight the exact data point on the line chart.
class LineSeriesSmallScreenBehaviour<T extends Tick>
    extends SmallScreenCrosshairBehaviour<T> {
  /// Creates a custom painter for rendering a dot at the crosshair position.
  ///
  /// For line series charts on small screens, this method returns a CrosshairDotPainter
  /// that draws a dot at the exact data point on the line. This visual indicator
  /// helps users identify the precise point on the line that corresponds to the
  /// crosshair position.
  ///
  /// Parameters:
  /// - [dotColor]: The fill color of the dot (default: Color(0xFF85ACB0))
  /// - [dotBorderColor]: The border color of the dot (default: Color(0xFF85ACB0))
  ///
  /// Returns a CustomPainter for drawing the dot.
  @override
  CustomPainter createDotPainter({
    dotColor = const Color(0xFF85ACB0),
    dotBorderColor = const Color(0xFF85ACB0),
  }) {
    return CrosshairDotPainter(
      dotColor: dotColor,
      dotBorderColor: dotBorderColor,
    );
  }
}
