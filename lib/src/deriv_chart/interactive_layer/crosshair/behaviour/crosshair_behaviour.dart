import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';

/// An abstract class that defines the behavior of crosshair in charts.
///
/// The CrosshairBehaviour class provides a set of methods to customize how
/// crosshair elements are displayed and interact with the chart. Different
/// implementations of this class can provide varying behaviours for different
/// chart types (like line charts vs candlestick charts) or different screen sizes.
///
/// The generic type parameter T extends Tick and represents the type of data
/// that the crosshair will interact with.
abstract class CrosshairBehaviour<T extends Tick> {
  /// Creates a custom painter for the crosshair lines.
  ///
  /// Retrieves the information widget to be displayed in the crosshair tooltip.
  ///
  /// This method generates a widget that displays information about the data point
  /// where the crosshair is positioned. The information typically includes values
  /// like price, volume, or other relevant data from the tick.
  ///
  /// Parameters:
  /// - [mainSeries]: The main data series of the chart
  /// - [crosshairTick]: The tick data at the crosshair position
  /// - [pipSize]: Number of decimal places to display in price values
  /// - [theme]: The chart theme containing styling information
  ///
  /// Returns a widget that displays the crosshair information.
  Widget getCrossHairInfo(
      {required DataSeries<T> mainSeries,
      required T crosshairTick,
      required int pipSize,
      required ChartTheme theme});

  /// Creates a label widget that displays the time information at the crosshair position.
  ///
  /// This method generates a widget that shows the date and time of the data point
  /// where the crosshair is positioned.
  ///
  /// Parameters:
  /// - [dateText]: The formatted date string to display
  /// - [style]: The text style to apply to the label
  /// - [timeText]: The formatted time string to display (optional)
  ///
  /// Returns a widget that displays the time information.
  Widget createTimeLabel(
      {required String dateText,
      required TextStyle style,
      String timeText = ''});

  /// Creates a custom painter for rendering the crosshair lines on the chart.
  ///
  /// This method returns a CustomPainter that draws the horizontal and/or vertical
  /// lines that make up the crosshair. The appearance of these lines is determined
  /// by the provided theme.
  ///
  /// Parameters:
  /// - [theme]: The chart theme containing styling information for the lines
  /// - [cursorY]: The Y-coordinate of the cursor position (default: 0)
  ///
  /// Returns a CustomPainter for drawing the crosshair lines.
  CustomPainter createLinePainter({
    required ChartTheme theme,
    double cursorY = 0,
  });

  /// Creates a custom painter for rendering a dot at the crosshair position.
  ///
  /// This method returns a CustomPainter that draws a dot at the intersection
  /// of the crosshair lines, typically representing the exact data point.
  /// The default implementation returns null, meaning no dot is drawn.
  ///
  /// Parameters:
  /// - [dotColor]: The fill color of the dot (default: Color(0xFF85ACB0))
  /// - [dotBorderColor]: The border color of the dot (default: Color(0xFF85ACB0))
  ///
  /// Returns a CustomPainter for drawing the dot, or null if no dot should be drawn.
  CustomPainter createDotPainter({
    dotColor = const Color(0xFF85ACB0),
    dotBorderColor = const Color(0xFF85ACB0),
  });

  /// Creates a label widget that appears along the crosshair lines.
  ///
  /// This method generates a widget that displays information (like price or time)
  /// along the crosshair lines. These labels typically appear at the edges of the chart.
  ///
  /// Parameters:
  /// - [content]: The widget to display inside the label
  /// - [translationOffset]: The offset for positioning the label relative to its anchor point
  /// - [topOffset]: Distance from the top edge of the chart (optional)
  /// - [rightOffset]: Distance from the right edge of the chart (optional)
  /// - [bottomOffset]: Distance from the bottom edge of the chart (optional)
  /// - [leftOffset]: Distance from the left edge of the chart (optional)
  /// - [containerPadding]: Padding inside the label container (default: horizontal 8, vertical 4)
  /// - [decoration]: Visual decoration for the label container
  ///
  /// Returns a positioned widget that displays the label.
  Widget createCrosshairLabel(
      {required Widget content,
      required Offset translationOffset,
      double? topOffset,
      double? rightOffset,
      double? bottomOffset,
      double? leftOffset,
      EdgeInsetsGeometry? containerPadding =
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      Decoration? decoration});

  /// Creates a detailed information widget that appears when the crosshair is active.
  ///
  /// This method generates a comprehensive widget that displays detailed information
  /// about the data point at the crosshair position. This typically includes a header
  /// with percentage change, price information, and time information.
  ///
  /// Parameters:
  /// - [crosshairTick]: The tick data at the crosshair position
  /// - [animationDuration]: Duration for animations when the widget appears/disappears
  /// - [mainSeries]: The main data series of the chart
  /// - [theme]: The chart theme containing styling information
  /// - [crosshairHeader]: The widget to display as the header of the details box
  /// - [width]: The width of the details widget (optional)
  /// - [topOffset]: Distance from the top edge of the chart (optional)
  /// - [rightOffset]: Distance from the right edge of the chart (optional)
  /// - [bottomOffset]: Distance from the bottom edge of the chart (optional)
  /// - [leftOffset]: Distance from the left edge of the chart (optional)
  /// - [alignment]: Alignment of the details widget (default: Alignment.center)
  /// - [pipSize]: Number of decimal places to display in price values (default: 4)
  /// - [cursorY]: The Y-coordinate of the cursor position (default: 0)
  ///
  /// Returns an animated positioned widget that displays the detailed information.
  Widget createCrosshairDetails(
      {required T crosshairTick,
      required Duration animationDuration,
      required DataSeries<T> mainSeries,
      required ChartTheme theme,
      required Widget crosshairHeader,
      double? width,
      double? topOffset,
      double? rightOffset,
      double? bottomOffset,
      double? leftOffset,
      AlignmentGeometry alignment = Alignment.center,
      int pipSize = 4,
      double cursorY = 0});

  /// Calculates the optimal vertical position for the crosshair details box.
  ///
  /// This method determines where the details box should be positioned vertically
  /// based on the cursor's Y position. The implementation should ensure the box
  /// is visible and doesn't go off-screen.
  ///
  /// Parameters:
  /// - [cursorY]: The Y-coordinate of the cursor on the canvas
  ///
  /// Returns the Y-coordinate (top position) where the details box should be rendered.
  double calculateDetailsPosition({required double cursorY});

  /// The height of the crosshair details box in logical pixels.
  ///
  /// This property defines how tall the details box should be, which affects
  /// positioning calculations to ensure the box fits within the chart area.
  double get detailsBoxHeight;
}
