import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/chart_date_utils.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/behaviour/crosshair_behaviour.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/painters/highlight/crosshair_highlight_painter.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/utils/find.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    required this.crosshairBehaviour,
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

  /// The behaviour implementation that defines how the crosshair should be displayed.
  ///
  /// This determines the visual appearance and interaction behaviour of the crosshair
  /// based on the chart type (line, OHLC) and screen size (small, large).
  final CrosshairBehaviour crosshairBehaviour;

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
            painter: crosshairBehaviour.createLinePainter(
                theme: theme, cursorY: cursorPosition.dy),
          ),
        ),
        AnimatedPositioned(
          top: quoteToCanvasY(crosshairTick!.quote),
          left: xAxis.xFromEpoch(crosshairTick!.epoch),
          duration: animationDuration,
          child: CustomPaint(
            size: Size(1, constraints.maxHeight),
            painter: crosshairBehaviour.createDotPainter(
                dotColor: dotColor, dotBorderColor: dotEffect),
          ),
        ),
        _buildCrosshairTickHightlight(
            constraints: constraints, xAxis: xAxis, theme: theme),
        // Add crosshair quote label at the right side of the chart
        crosshairBehaviour.createCrosshairLabel(
            content: Text(crosshairTick!.quote.toStringAsFixed(pipSize),
                style: theme.crosshairAxisLabelStyle.copyWith(
                  color: theme.crosshairInformationBoxTextDefault,
                )),
            translationOffset:
                const Offset(0, -0.5), // Center the label vertically
            topOffset: cursorPosition.dy,
            rightOffset: 0,
            decoration: BoxDecoration(
              color: theme.crosshairInformationBoxContainerNormalColor,
              borderRadius: BorderRadius.circular(4),
            )),
        // Add vertical date label at the bottom of the chart
        crosshairBehaviour.createCrosshairLabel(
            content: Text(
              ChartDateUtils.formatDateTimeWithSeconds(
                  crosshairTick?.epoch ?? 0),
              style: theme.crosshairAxisLabelStyle.copyWith(
                color: theme.crosshairInformationBoxTextDefault,
              ),
            ),
            translationOffset:
                const Offset(-0.5, 0.85), // Center the label horizontally
            leftOffset: xAxis.xFromEpoch(crosshairTick!.epoch),
            bottomOffset: 0,
            decoration: BoxDecoration(
              color: theme.crosshairInformationBoxContainerNormalColor,
              borderRadius: BorderRadius.circular(4),
            )),
        crosshairBehaviour.createCrosshairDetails(
          crosshairHeader: _buildCrosshairHeader(theme: theme),
          theme: theme,
          mainSeries: mainSeries,
          animationDuration: animationDuration,
          crosshairTick: crosshairTick!,
          pipSize: pipSize,
          cursorY: cursorPosition.dy,
          leftOffset:
              xAxis.xFromEpoch(crosshairTick!.epoch) - constraints.maxWidth / 2,
          width: constraints.maxWidth,
        ),
      ],
    );
  }

  Widget _buildCrosshairHeader({required ChartTheme theme}) {
    if (crosshairTick == null) {
      return const SizedBox.shrink();
    }
    final previousTick = findClosestPreviousTick(
        crosshairTick!, mainSeries.visibleEntries.entries);

    final double percentageChange = getPercentageChange(
        crosshairTick: crosshairTick!, previousTick: previousTick);
    final String percentChangeLabel =
        '${percentageChange.toStringAsFixed(pipSize)}%';

    final Color color = percentageChange >= 0
        ? theme.crosshairInformationBoxTextProfit
        : theme.crosshairInformationBoxTextLoss;
    return Container(
      width: double.infinity,
      color: color,
      alignment: Alignment.center,
      child: Text(
        '$percentChangeLabel',
        style: theme.crosshairInformationBoxTitleStyle.copyWith(
          color: theme.crosshairInformationBoxTextStatic,
        ),
      ),
    );
  }

  /// Calculates the percentage change between the current tick and the previous tick.
  ///
  /// Returns 0 if there's no previous tick or if the previous tick's close value is 0.
  /// Uses the closest previous tick found by the findClosestPreviousTick function
  /// if no previousTick is explicitly provided.
  double getPercentageChange(
      {required Tick crosshairTick, required Tick? previousTick}) {
    final double prevClose = previousTick?.close ?? 0;
    // If there's no previous tick or its close value is 0, return 0 to avoid division by zero
    // and to indicate no change.
    // The previous tick can legitimately be null in cases such as when the crosshair is on the first tick
    // or when there are no previous ticks available in the data series.
    if (prevClose == 0) {
      return 0;
    }

    final double change = crosshairTick.close - prevClose;
    return (change / prevClose) * 100;
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
      required ChartTheme theme}) {
    if (crosshairTick == null) {
      return const SizedBox.shrink();
    }

    // Get the appropriate highlight painter for the current tick based on the series type
    final CrosshairHighlightPainter highlightPainter =
        mainSeries.getCrosshairHighlightPainter(
      crosshairTick!,
      quoteToCanvasY,
      xAxis.xFromEpoch(crosshairTick!.epoch),
      xAxis.granularity,
      theme,
      xAxis.xFromEpoch,
    );

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
