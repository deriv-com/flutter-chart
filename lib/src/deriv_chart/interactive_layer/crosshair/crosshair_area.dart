import 'dart:math';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/chart_date_utils.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_highlight_painter.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_variant.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/large_screen_crosshair_line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/small_screen_crosshair_line_painter.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'crosshair_details.dart';
import 'crosshair_dot_painter.dart';

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
    required this.crosshairTick,
    required this.cursorPosition,
    required this.animationDuration,
    required this.crosshairVariant,
    this.pipSize = 4,
    Key? key,
  }) : super(key: key);

  /// The main series of the chart.
  final DataSeries<Tick> mainSeries;

  /// Number of decimal digits when showing prices.
  final int pipSize;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteToCanvasY;

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

  /// Calculates the position for the crosshair details box
  /// to maintain a gap from the horizontal line (cursor position)
  double _calculateDetailsPosition(
      {required double cursorY, required double maxHeight}) {
    // Estimated height of the details box
    const double detailsBoxHeight = 100;
    // Gap between cursor and details box
    const double gap = 120;

    // If cursor is in the top half of the chart, position details below the cursor
    // if (cursorY < maxHeight / 2) {
    if (cursorY > maxHeight) {
      return cursorY + gap;
    }
    // Otherwise position details above the cursor
    else {
      // Make sure details don't go off the top of the chart
      return max(10, cursorY - detailsBoxHeight - gap);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: buildCrosshairContent(context, constraints),
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
      BuildContext context, BoxConstraints constraints) {
    if (crosshairTick == null) {
      return const SizedBox.shrink();
    }

    final XAxisModel xAxis = context.watch<XAxisModel>();
    final ChartTheme theme = context.read<ChartTheme>();
    final Color dotColor = theme.currentSpotDotColor;
    final Color dotEffect = theme.currentSpotDotEffect;
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        AnimatedPositioned(
          duration: animationDuration,
          left: xAxis.xFromEpoch(crosshairTick!.epoch),
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
          top: quoteToCanvasY(crosshairTick!.quote),
          left: xAxis.xFromEpoch(crosshairTick!.epoch),
          duration: animationDuration,
          child: CustomPaint(
            size: Size(1, constraints.maxHeight),
            painter: crosshairVariant == CrosshairVariant.smallScreen &&
                    crosshairTick is! Candle
                ? CrosshairDotPainter(
                    dotColor: dotColor, dotBorderColor: dotEffect)
                : null,
          ),
        ),
        _highlightTick(constraints: constraints, xAxis: xAxis, theme: theme),
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
                  crosshairTick!.quote.toStringAsFixed(pipSize),
                  style: theme.crosshairAxisLabelStyle.copyWith(
                    color: theme.crosshairInformationBoxTextDefault,
                  ),
                ),
              ),
            ),
          ),
        // Add vertical date label at the bottom of the chart
        if (crosshairVariant != CrosshairVariant.smallScreen &&
            crosshairTick != null)
          Positioned(
            bottom: 0,
            left: xAxis.xFromEpoch(crosshairTick!.epoch),
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
                  ChartDateUtils.formatDateTimeWithSeconds(
                      crosshairTick!.epoch),
                  style: theme.crosshairAxisLabelStyle.copyWith(
                    color: theme.crosshairInformationBoxTextDefault,
                  ),
                ),
              ),
            ),
          ),
        AnimatedPositioned(
          duration: animationDuration,
          // Position the details above the cursor with a gap
          // Use cursorY which is the cursor's Y position
          // Subtract the height of the details box plus a gap
          top: crosshairVariant == CrosshairVariant.smallScreen
              ? 0
              : _calculateDetailsPosition(
                  cursorY: cursorPosition.dy, maxHeight: constraints.maxHeight),
          bottom: 0,
          width: constraints.maxWidth,
          left:
              xAxis.xFromEpoch(crosshairTick!.epoch) - constraints.maxWidth / 2,
          child: Align(
            alignment: Alignment.topCenter,
            child: CrosshairDetails(
              mainSeries: mainSeries,
              crosshairTick: crosshairTick!,
              pipSize: pipSize,
              crosshairVariant: crosshairVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _highlightTick(
      {required BoxConstraints constraints,
      required XAxisModel xAxis,
      required ChartTheme theme}) {
    if (crosshairTick == null) {
      return const SizedBox.shrink();
    }

    // Get the appropriate highlight painter for the current tick based on the series type
    final CrosshairHighlightPainter? highlightPainter =
        mainSeries.getCrosshairHighlightPainter(
      crosshairTick!,
      quoteToCanvasY,
      xAxis.xFromEpoch(crosshairTick!.epoch),
      // Use a reasonable default element width (6% of the granularity width)
      (xAxis.xFromEpoch(xAxis.granularity) - xAxis.xFromEpoch(0)) * 0.6,
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
