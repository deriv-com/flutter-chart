import 'dart:math';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/chart_date_utils.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_highlight_painter.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_variant.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/large_screen_crosshair_line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/small_screen_crosshair_line_painter.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'crosshair_details.dart';

/// A widget that displays crosshair details on a chart.
///
/// This widget shows information about a specific point on the chart when the user
/// interacts with it through long press or hover. It displays crosshair lines,
/// price and time labels, and detailed information about the data point.
class CrosshairArea extends StatelessWidget {
  /// Initializes a widget to display candle/point details on longpress in a chart.
  const CrosshairArea({
    required this.mainSeries,
    required this.quoteToCanvasY,
    required this.quoteFromCanvasY,
    required this.crosshairTick,
    required this.cursorPosition,
    required this.animationDuration,
    required this.crosshairVariant,
    required this.isTickWithinDataRange,
    required this.updateAndFindClosestTick,
    this.pipSize = 4,
    Key? key,
  }) : super(key: key);

  /// The main series of the chart.
  final DataSeries<Tick> mainSeries;

  /// Number of decimal digits when showing prices.
  final int pipSize;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteToCanvasY;

  /// Conversion function for converting chart's canvas' Y position to quote.
  final double Function(double) quoteFromCanvasY;

  /// The tick to display in the crosshair.
  final Tick? crosshairTick;

  /// The position of the cursor.
  final Offset cursorPosition;

  /// The duration for animations.
  final Duration animationDuration;

  /// The variant of the crosshair to be used.
  /// This is used to determine the type of crosshair to display.
  /// The default is [CrosshairVariant.smallScreen].
  /// [CrosshairVariant.largeScreen] is mostly for web.
  final CrosshairVariant crosshairVariant;

  /// Whether the current tick is within the actual data range.
  /// When false, the tick is a virtual tick created for cursor positions outside data range.
  /// This is used to determine whether to show the crosshair highlight.
  /// If true, the crosshair will highlight the tick; if false, it will not.
  /// This is useful for distinguishing between actual data points and virtual ticks.
  final bool isTickWithinDataRange;

  /// Function to update and find the closest tick based on cursor position.
  ///
  /// Takes an optional [double] parameter representing the cursor X position.
  /// If no position is provided, it uses the last known long press position.
  /// Returns the closest [Tick] to the specified or default position, or null if none found.
  final Tick? Function([double?]) updateAndFindClosestTick;

  /// Calculates the optimal vertical position for the crosshair details box.
  ///
  /// In Flutter canvas, the coordinate system has (0,0) at the top-left corner,
  /// with y-values increasing downward. This method calculates a position that
  /// places the details box above the cursor with appropriate spacing.
  ///
  /// The calculation works as follows:
  /// 1. Start with the cursor's Y position
  /// 2. Subtract the height of the details box (100px) to position it above the cursor
  /// 3. Subtract an additional gap (120px) to create space between the cursor and the box
  /// 4. Ensure the box doesn't go too close to the top edge by using max(10, result)
  ///
  /// This ensures the details box is visible and well-positioned relative to the cursor,
  /// while preventing it from being rendered partially off-screen at the top.
  ///
  /// Parameters:
  /// - [cursorY]: The Y-coordinate of the cursor on the canvas
  ///
  /// Returns:
  /// The Y-coordinate (top position) where the details box should be rendered.
  /// The value is guaranteed to be at least 10 pixels from the top of the canvas.
  double _calculateDetailsPosition(
      {required double cursorY, required Tick tick}) {
    // Height of the details information box in pixels
    final double detailsBoxHeight = mainSeries.getCrosshairDetailsBoxHeight();

    // Additional vertical gap between the cursor and the details box
    // This ensures the box doesn't overlap with or crowd the cursor
    const double gap = 120;

    // Calculate position and ensure it's at least 10px from the top edge
    // This prevents the box from being rendered partially off-screen
    return max(10, cursorY - detailsBoxHeight - gap);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      Tick? updatedCrosshairTick = crosshairTick;

      if (cursorPosition.dx != 0) {
        updatedCrosshairTick = updateAndFindClosestTick(cursorPosition.dx);
      }
      return SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child:
            buildCrosshairContent(context, constraints, updatedCrosshairTick),
      );
    });
  }

  /// Builds the content of the crosshair, including lines, dots, and information boxes.
  ///
  /// This method constructs the visual elements of the crosshair based on the current
  /// tick and cursor position.
  ///
  /// [context] The build context.
  /// [constraints] The layout constraints for the crosshair area.
  Widget buildCrosshairContent(
      BuildContext context, BoxConstraints constraints, Tick? tick) {
    if (tick == null) {
      return const SizedBox.shrink();
    }

    final XAxisModel xAxis = context.watch<XAxisModel>();
    final ChartTheme theme = context.read<ChartTheme>();
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        AnimatedPositioned(
          duration: animationDuration,
          left: xAxis.xFromEpoch(tick.epoch),
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: crosshairVariant == CrosshairVariant.smallScreen
                ? SmallScreenCrosshairLinePainter(
                    theme: theme,
                  )
                : LargeScreenCrosshairLinePainter(
                    theme: theme,
                    cursorY: cursorPosition.dy,
                  ),
          ),
        ),
        AnimatedPositioned(
          top: quoteToCanvasY(tick.quote),
          left: xAxis.xFromEpoch(tick.epoch),
          duration: animationDuration,
          child: CustomPaint(
            size: Size(1, constraints.maxHeight),
            painter: crosshairVariant == CrosshairVariant.smallScreen
                ? mainSeries.getCrosshairDotPainter(theme)
                : null,
          ),
        ),
        if (isTickWithinDataRange)
          _buildCrosshairTickHightlight(
              constraints: constraints, xAxis: xAxis, theme: theme, tick: tick),
        // Add crosshair quote label at the right side of the chart
        if (crosshairVariant != CrosshairVariant.smallScreen &&
            cursorPosition.dy > 0)
          Positioned(
            top: cursorPosition.dy,
            right: 0,
            child: FractionalTranslation(
              translation: const Offset(0, -0.5), // Center the label vertically
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.crosshairInformationBoxContainerNormalColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  quoteFromCanvasY(cursorPosition.dy).toStringAsFixed(pipSize),
                  style: theme.crosshairAxisLabelStyle.copyWith(
                    color: theme.crosshairInformationBoxTextDefault,
                  ),
                ),
              ),
            ),
          ),
        // Add vertical date label at the bottom of the chart
        if (crosshairVariant != CrosshairVariant.smallScreen)
          Positioned(
            bottom: 0,
            left: xAxis.xFromEpoch(tick.epoch),
            child: FractionalTranslation(
              translation:
                  const Offset(-0.5, 0.85), // Center the label horizontally
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.crosshairInformationBoxContainerNormalColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  ChartDateUtils.formatDateTimeWithSeconds(tick.epoch),
                  style: theme.crosshairAxisLabelStyle.copyWith(
                    color: theme.crosshairInformationBoxTextDefault,
                  ),
                ),
              ),
            ),
          ),
        if (isTickWithinDataRange)
          _buildCrosshairDetails(constraints, xAxis, tick),
      ],
    );
  }

  AnimatedPositioned _buildCrosshairDetails(
      BoxConstraints constraints, XAxisModel xAxis, Tick? tick) {
    return AnimatedPositioned(
      duration: animationDuration,
      // Position the details above the cursor with a gap
      // Use cursorY which is the cursor's Y position
      // Subtract the height of the details box plus a gap
      top: crosshairVariant == CrosshairVariant.smallScreen
          ? 8
          : _calculateDetailsPosition(cursorY: cursorPosition.dy, tick: tick!),
      bottom: 0,
      width: constraints.maxWidth,
      left: xAxis.xFromEpoch(tick!.epoch) - constraints.maxWidth / 2,
      child: Align(
        alignment: Alignment.topCenter,
        child: CrosshairDetails(
          mainSeries: mainSeries,
          crosshairTick: tick,
          pipSize: pipSize,
          crosshairVariant: crosshairVariant,
        ),
      ),
    );
  }

  /// Builds a widget that highlights the current tick at the crosshair position.
  ///
  /// This method creates a visual highlight for the data point (tick, candle, etc.)
  /// that the crosshair is currently pointing to. It delegates the actual painting
  /// to a series-specific highlight painter obtained from the main series.
  ///
  /// The highlight is positioned at the exact location of the data point and provides
  /// visual feedback to the user about which specific data element they are examining.
  /// Different chart types (line, candle, OHLC) will have different highlight visualizations.
  ///
  /// Parameters:
  /// * [constraints] - The layout constraints for the crosshair area.
  /// * [xAxis] - The X-axis model providing epoch-to-coordinate conversion and granularity.
  /// * [theme] - The chart theme containing colors and styles for the highlight.
  ///
  /// Returns:
  /// A positioned widget containing the custom painter for the highlight, or an empty
  /// widget if no highlight painter is available for the current series type.
  Widget _buildCrosshairTickHightlight(
      {required BoxConstraints constraints,
      required XAxisModel xAxis,
      required ChartTheme theme,
      required Tick? tick}) {
    if (tick == null) {
      return const SizedBox.shrink();
    }

    // Get the appropriate highlight painter for the current tick based on the series type
    final CrosshairHighlightPainter? highlightPainter =
        mainSeries.getCrosshairHighlightPainter(
      tick,
      quoteToCanvasY,
      xAxis.xFromEpoch(tick.epoch),
      xAxis.granularity,
      xAxis.xFromEpoch,
      theme,
    );

    if (highlightPainter == null) {
      return const SizedBox.shrink();
    }

    return AnimatedPositioned(
      duration: animationDuration,
      left: 0,
      top: 0,
      child: CustomPaint(
        size: Size(constraints.maxWidth, constraints.maxHeight),
        painter: highlightPainter,
      ),
    );
  }
}
