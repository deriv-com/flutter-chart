import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_group.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_icon_painters/painter_props.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_icon_painters/tick_marker_icon_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/chart_marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_line.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/deriv_chart/chart/y_axis/y_axis_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';

/// AccumulatorMarkerIconPainter is a specialized painter for rendering accumulator contract markers on charts.
///
/// This class extends TickMarkerIconPainter and provides additional functionality specific to
/// accumulator contracts, particularly focusing on rendering high and low barriers with shaded areas
/// between them. It visualizes the price range within which the accumulator contract operates.
///
/// The painter handles various visual elements including:
/// - Shaded areas between high and low barriers
/// - Horizontal barrier lines with arrow indicators
/// - Text labels showing barrier values
/// - Previous tick indicators with connecting lines
///
/// It supports persistent borders, which allow barriers to remain visible even when they extend
/// beyond the visible chart area, providing context for off-screen price levels.
///
/// This painter is used by MarkerGroupSeries when rendering marker groups of type "accumulator"
/// and works in conjunction with the chart's coordinate conversion functions to properly position
/// visual elements on the canvas.
class AccumulatorMarkerIconPainter extends TickMarkerIconPainter {
  /// Creates an AccumulatorMarkerIconPainter with optional font size configuration.
  ///
  /// The [fontSize] parameter allows customizing text size for barrier labels,
  /// particularly useful for responsive layouts or different display densities.
  AccumulatorMarkerIconPainter({this.fontSize});

  /// Font size for barrier labels, used primarily in web/desktop environments.
  /// When null, the default text size from the theme will be used.
  final double? fontSize;

  /// Converts a ChartMarker's epoch and quote values to canvas coordinates.
  ///
  /// @param marker The ChartMarker to convert
  /// @param epochToX Function to convert epoch (timestamp) to X coordinate
  /// @param quoteToY Function to convert quote (price) to Y coordinate
  /// @return Offset The position on the canvas where the marker should be drawn
  Offset _getOffset(
    ChartMarker marker,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) =>
      Offset(
        epochToX(marker.epoch),
        quoteToY(marker.quote),
      );

  /// Paints the marker group on the canvas, extending the base implementation with
  /// accumulator-specific barrier rendering.
  ///
  /// First calls the parent class implementation to draw standard markers, then
  /// adds specialized barrier visualization for accumulator contracts.
  ///
  /// @param canvas The canvas to draw on
  /// @param size The size of the drawing area
  /// @param theme The chart theme providing colors and styles
  /// @param markerGroup The group of markers to render
  /// @param epochToX Function to convert epoch (timestamp) to X coordinate
  /// @param quoteToY Function to convert quote (price) to Y coordinate
  /// @param painterProps Additional properties affecting rendering
  @override
  void paintMarkerGroup(
    Canvas canvas,
    Size size,
    ChartTheme theme,
    MarkerGroup markerGroup,
    EpochToX epochToX,
    QuoteToY quoteToY,
    PainterProps painterProps,
  ) {
    super.paintMarkerGroup(
      canvas,
      size,
      theme,
      markerGroup,
      epochToX,
      quoteToY,
      painterProps,
    );

    final Map<MarkerType, ChartMarker> markers = <MarkerType, ChartMarker>{};

    for (final ChartMarker marker in markerGroup.markers) {
      if (marker.markerType != null) {
        markers[marker.markerType!] = marker;
      }
    }

    final ChartMarker? lowMarker = markers[MarkerType.lowBarrier];
    final ChartMarker? highMarker = markers[MarkerType.highBarrier];
    final ChartMarker? endMarker = markers[MarkerType.end];

    final ChartMarker? previousTickMarker = markers[MarkerType.previousTick];

    if (lowMarker != null && highMarker != null) {
      final Offset lowOffset = _getOffset(lowMarker, epochToX, quoteToY);
      final Offset highOffset = _getOffset(highMarker, epochToX, quoteToY);

      final double endLeft = endMarker != null
          ? _getOffset(endMarker, epochToX, quoteToY).dx
          : size.width;

      _drawShadedBarriers(
        canvas: canvas,
        size: size,
        painterProps: painterProps,
        lowMarker: lowMarker,
        highMarker: highMarker,
        endLeft: endLeft,
        startLeft: lowOffset.dx,
        top: highOffset.dy,
        markerGroup: markerGroup,
        bottom: lowOffset.dy,
        previousTickMarker: previousTickMarker,
      );
    }
  }

  /// Determines if the marker group has persistent borders configured.
  ///
  /// Persistent borders remain visible even when they extend beyond the
  /// visible chart area, providing context for off-screen price levels.
  ///
  /// @param markerGroup The marker group to check
  /// @return bool True if the marker group has persistent borders
  bool _hasPersistentBorders(MarkerGroup markerGroup) {
    return markerGroup.props.hasPersistentBorders;
  }

  /// Draws shaded barriers between high and low price levels.
  ///
  /// This is the core visualization method for accumulator contracts, rendering:
  /// - Horizontal lines at high and low barrier levels
  /// - Arrow indicators at the start of each barrier line
  /// - Text labels showing barrier values
  /// - A shaded area between the barriers
  /// - Optional previous tick indicator with connecting line
  ///
  /// The method handles various edge cases such as barriers extending beyond
  /// the visible chart area and ensures proper clipping to the chart boundaries.
  ///
  /// @param canvas The canvas to draw on
  /// @param size The size of the drawing area
  /// @param painterProps Additional properties affecting rendering
  /// @param lowMarker The marker representing the low barrier
  /// @param highMarker The marker representing the high barrier
  /// @param endLeft The x-coordinate where the barriers end (usually contract end or chart edge)
  /// @param startLeft The x-coordinate where the barriers start
  /// @param top The y-coordinate of the high barrier
  /// @param markerGroup The marker group containing these barriers
  /// @param bottom The y-coordinate of the low barrier
  /// @param previousTickMarker Optional marker for the previous tick
  void _drawShadedBarriers({
    required Canvas canvas,
    required Size size,
    required PainterProps painterProps,
    required ChartMarker lowMarker,
    required ChartMarker highMarker,
    required double endLeft,
    required double startLeft,
    required double top,
    required MarkerGroup markerGroup,
    required double bottom,
    ChartMarker? previousTickMarker,
  }) {
    final double endTop = size.height;

    final bool hasPersistentBorders = _hasPersistentBorders(markerGroup);

    final bool isTopVisible =
        top < endTop && (top >= 0 || !hasPersistentBorders);
    final bool isBottomVisible = bottom < endTop;
    // using 2 instead of 0 to distance the top barrier line
    // from the top of the chart and make it clearly visible:
    final double persistentTop = top < 0 && hasPersistentBorders ? 2 : endTop;
    final double displayedTop = isTopVisible ? top : persistentTop;
    final double displayedBottom = isBottomVisible ? bottom : endTop;
    final bool isStartLeftVisible = startLeft < endLeft;

    final double middleTop = bottom - (bottom - top).abs() / 2;

    final Color barrierColor = lowMarker.color ?? Colors.blue;
    final Paint paint = Paint()
      ..color = barrierColor
      ..style = PaintingStyle.fill;

    final Color shadeColor = barrierColor.withOpacity(0.08);

    if (!isStartLeftVisible) {
      return;
    }

    final TextStyle textStyle = TextStyle(
      color: barrierColor,
      fontSize: fontSize,
    );

    YAxisConfig.instance.yAxisClipping(canvas, size, () {
      if (previousTickMarker != null && previousTickMarker.color != null) {
        _drawPreviousTickBarrier(
          size,
          canvas,
          startLeft,
          endLeft,
          middleTop,
          previousTickMarker.color!,
          barrierColor,
        );
      }

      if (isTopVisible || hasPersistentBorders) {
        final Path path = Path()
          ..moveTo(startLeft + 2.5, displayedTop)
          ..lineTo(startLeft - 2.5, displayedTop)
          ..lineTo(startLeft, displayedTop + 4.5)
          ..lineTo(startLeft + 2.5, displayedTop)
          ..close();

        canvas.drawPath(path, paint);

        paintHorizontalDashedLine(
          canvas,
          startLeft - 2.5,
          endLeft,
          displayedTop,
          barrierColor,
          1.5,
          dashSpace: 0,
        );

        // draw difference between high barrier and previous spot price
        if (highMarker.text != null) {
          final TextPainter textPainter =
              makeTextPainter(highMarker.text!, textStyle);
          paintWithTextPainter(
            canvas,
            painter: textPainter,
            anchor: Offset(endLeft - YAxisConfig.instance.cachedLabelWidth! - 1,
                displayedTop - 10),
            anchorAlignment: Alignment.centerRight,
          );
        }
      }
      if (isBottomVisible || hasPersistentBorders) {
        final Path path = Path()
          ..moveTo(startLeft + 2.5, displayedBottom)
          ..lineTo(startLeft - 2.5, displayedBottom)
          ..lineTo(startLeft, displayedBottom - 4.5)
          ..lineTo(startLeft + 2.5, displayedBottom)
          ..close();

        canvas.drawPath(path, paint);

        paintHorizontalDashedLine(
          canvas,
          startLeft - 2.5,
          endLeft,
          displayedBottom,
          barrierColor,
          1.5,
          dashSpace: 0,
        );

        // draw difference between low barrier and previous spot price
        if (lowMarker.text != null) {
          final TextPainter textPainter =
              makeTextPainter(lowMarker.text!, textStyle);

          paintWithTextPainter(
            canvas,
            painter: textPainter,
            anchor: Offset(endLeft - YAxisConfig.instance.cachedLabelWidth! - 1,
                displayedBottom + 12),
            anchorAlignment: Alignment.centerRight,
          );
        }
      }

      final Paint rectPaint = Paint()..color = shadeColor;

      canvas.drawRect(
        Rect.fromLTRB(startLeft, displayedTop, endLeft, displayedBottom),
        rectPaint,
      );
    });
  }

  /// Draws a horizontal dashed line with a circle indicator for the previous tick.
  ///
  /// This visualizes the previous price level before the current tick, providing
  /// context for price movement within the accumulator contract.
  ///
  /// @param size The size of the drawing area
  /// @param canvas The canvas to draw on
  /// @param startX The x-coordinate where the line starts
  /// @param endX The x-coordinate where the line ends
  /// @param y The y-coordinate (price level) of the line
  /// @param circleColor The color for the circle indicator
  /// @param barrierColor The color for the dashed line
  void _drawPreviousTickBarrier(
    Size size,
    Canvas canvas,
    double startX,
    double endX,
    double y,
    Color circleColor,
    Color barrierColor,
  ) {
    canvas.drawCircle(
      Offset(startX, y),
      1.5,
      Paint()..color = circleColor,
    );

    paintHorizontalDashedLine(
      canvas,
      startX,
      endX,
      y,
      barrierColor,
      1.5,
      dashWidth: 2,
      dashSpace: 4,
    );
  }
}
