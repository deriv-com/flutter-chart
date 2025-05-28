import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/behaviour/large_screen_crosshair_behaviour.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/behaviour/small_screen_crosshair_behaviour.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/painters/crosshair_dot_painter.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

/// A concrete implementation of CrosshairBehaviour for OHLC series charts on large screens.
///
/// This class extends LargeScreenCrosshairBehaviour to provide specific behaviour
/// optimized for OHLC (Open-High-Low-Close) series charts when displayed on large screens
/// like desktop or web. It defines the dimensions of the details box appropriate for
/// displaying the more complex OHLC data.
class OHLCSeriesLargeScreenBehaviour<T extends Tick>
    extends LargeScreenCrosshairBehaviour<T> {
  /// The height of the crosshair details box in logical pixels.
  ///
  /// For OHLC series on large screens, this is set to 100 pixels, and is used to calculate the position of the information box from the crosshair lines.
  @override
  double get detailsBoxHeight => 100;

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

/// A concrete implementation of CrosshairBehaviour for OHLC series charts on small screens.
///
/// This class extends SmallScreenCrosshairBehaviour to provide specific behaviour
/// optimized for OHLC (Open-High-Low-Close) series charts when displayed on small screens
/// like mobile devices. Unlike line charts, OHLC charts don't display a dot at the
/// crosshair position since the candlestick or bar itself serves as a visual indicator.
class OHLCSeriesSmallScreenBehaviour<T extends Tick>
    extends SmallScreenCrosshairBehaviour<T> {
  /// The height of the crosshair details box in logical pixels.
  ///
  /// For OHLC series on large screens, this is set to 100 pixels, and is used to calculate the position of the information box from the crosshair lines.
  @override
  double get detailsBoxHeight => 100;

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
