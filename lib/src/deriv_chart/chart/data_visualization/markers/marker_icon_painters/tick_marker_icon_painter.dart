import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_group.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_icon_painters/marker_group_icon_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_icon_painters/painter_props.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/chart_marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_line.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_start_line.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_start_marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/deriv_chart/chart/y_axis/y_axis_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';

/// A specialized painter for rendering tick-based contract markers on financial charts.
///
/// `TickMarkerIconPainter` extends the abstract `MarkerGroupIconPainter` class to provide
/// specific rendering logic for tick-based contracts. Tick-based contracts are financial
/// contracts where the outcome depends on price movements at specific time intervals (ticks).
///
/// This painter visualizes various aspects of tick contracts on the chart, including:
/// - The starting point of the contract
/// - Entry and exit points
/// - Individual price ticks
/// - Barrier lines connecting significant points
///
/// The painter uses different visual representations for different marker types:
/// - Start markers are shown as location pins with optional labels
/// - Entry points are shown as circles with a distinctive border
/// - Tick points are shown as small dots
/// - Exit points are shown as circles
/// - End points are shown as flag icons
///
/// This class is part of the chart's visualization pipeline and works in conjunction
/// with `MarkerGroupPainter` to render marker groups on the chart canvas.
class TickMarkerIconPainter extends MarkerGroupIconPainter {
  /// Renders a group of tick contract markers on the chart canvas.
  ///
  /// This method is called by the chart's rendering system to paint a group of
  /// related markers (representing a single tick contract) on the canvas. It:
  /// 1. Converts marker positions from market data (epoch/quote) to canvas coordinates
  /// 2. Calculates the opacity based on marker positions
  /// 3. Draws barrier lines connecting significant points
  /// 4. Delegates the rendering of individual markers to specialized methods
  ///
  /// @param canvas The canvas on which to paint.
  /// @param size The size of the drawing area.
  /// @param theme The chart's theme, which provides colors and styles.
  /// @param markerGroup The group of markers to render.
  /// @param epochToX A function that converts epoch timestamps to X coordinates.
  /// @param quoteToY A function that converts price quotes to Y coordinates.
  /// @param painterProps Properties that affect how markers are rendered.
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
    final Map<MarkerType, Offset> points = <MarkerType, Offset>{};

    for (final ChartMarker marker in markerGroup.markers) {
      final Offset center;

      // Special handling for contractMarker - always position on left side
      if (marker.markerType == MarkerType.contractMarker) {
        center = Offset(
          20, // Fixed left position (20 pixels from left edge)
          quoteToY(marker.quote),
        );
      } else {
        center = Offset(
          epochToX(marker.epoch),
          quoteToY(marker.quote),
        );
      }

      if (marker.markerType != null && marker.markerType != MarkerType.tick) {
        points[marker.markerType!] = center;
      }
    }

    final Offset? startPoint = points[MarkerType.start];
    final Offset? exitPoint = points[MarkerType.exit];
    final Offset? endPoint = points[MarkerType.end];

    double opacity = 1;

    if (startPoint != null && (endPoint != null || exitPoint != null)) {
      opacity = calculateOpacity(startPoint.dx, exitPoint?.dx);
    }

    final Paint paint = Paint()
      ..color = markerGroup.style.backgroundColor.withOpacity(opacity);

    _drawBarriers(canvas, size, points, markerGroup, markerGroup.style, opacity,
        painterProps, paint);

    for (final ChartMarker marker in markerGroup.markers) {
      final Offset center = points[marker.markerType!] ??
          (marker.markerType == MarkerType.contractMarker
              ? Offset(
                  20,
                  quoteToY(
                      marker.quote)) // Fixed left position for contractMarker
              : Offset(epochToX(marker.epoch), quoteToY(marker.quote)));

      if (marker.markerType == MarkerType.entry &&
          points[MarkerType.entryTick] != null) {
        continue;
      }

      _drawMarker(canvas, size, theme, marker, center, markerGroup.style,
          painterProps.zoom, opacity, paint);
    }
  }

  /// Draws barrier lines connecting significant points in the contract.
  ///
  /// This private method renders various lines that connect important points in the
  /// contract, such as the contract marker, entry tick, and end point.
  /// These lines help visualize the contract's progression and price movement.
  ///
  /// The method draws different types of lines:
  /// - A dashed horizontal line from the contract marker to the entry tick
  /// - A solid line from the entry tick to the end marker
  /// - A dashed horizontal line from the end marker to the chart's right edge
  ///
  /// @param canvas The canvas on which to paint.
  /// @param size The size of the drawing area.
  /// @param points A map of marker types to their positions on the canvas.
  /// @param markerGroup The group of markers to render.
  /// @param style The style to apply to the barriers.
  /// @param opacity The opacity to apply to the barriers.
  /// @param painterProps Properties that affect how barriers are rendered.
  void _drawBarriers(
      Canvas canvas,
      Size size,
      Map<MarkerType, Offset> points,
      MarkerGroup markerGroup,
      MarkerStyle style,
      double opacity,
      PainterProps painterProps,
      Paint paint) {
    final Offset? _contractMarkerOffset = points[MarkerType.contractMarker];
    final Offset? _entryTickOffset = points[MarkerType.entryTick];
    final Offset? _endOffset = points[MarkerType.end];

    // Determine marker direction color from the contractMarker
    Color lineColor = style.backgroundColor;
    for (final ChartMarker marker in markerGroup.markers) {
      if (marker.markerType == MarkerType.contractMarker) {
        lineColor = marker.direction == MarkerDirection.up
            ? style.upColor
            : style.downColor;
        break;
      }
    }

    final Color finalLineColor = lineColor.withOpacity(opacity);

    YAxisConfig.instance.yAxisClipping(canvas, size, () {
      // Horizontal dashed line from contractMarker to entryTick
      if (_contractMarkerOffset != null && _entryTickOffset != null) {
        paintHorizontalDashedLine(
          canvas,
          _entryTickOffset.dx,
          _contractMarkerOffset.dx,
          _contractMarkerOffset.dy,
          finalLineColor,
          1,
          dashWidth: 2,
          dashSpace: 2,
        );
      }

      // Solid line from entryTick to end marker
      if (_entryTickOffset != null && _endOffset != null) {
        final Paint solidLinePaint = Paint()
          ..color = finalLineColor
          ..strokeWidth = 1;
        canvas.drawLine(_entryTickOffset, _endOffset, solidLinePaint);
      }

      // Horizontal dashed line from end marker to the chart's right edge (before yAxis)
      if (_endOffset != null) {
        final double rightEdgeX = size.width;

        paintHorizontalDashedLine(
          canvas,
          _endOffset.dx,
          rightEdgeX,
          _endOffset.dy,
          finalLineColor,
          1,
          dashWidth: 2,
          dashSpace: 2,
        );
      }
    });
  }

  /// Renders an individual marker based on its type.
  ///
  /// This private method handles the rendering of different types of markers
  /// (start, entry, tick, exit, end) with their specific visual representations.
  /// It delegates to specialized methods for each marker type.
  ///
  /// @param canvas The canvas on which to paint.
  /// @param size The size of the drawing area.
  /// @param theme The chart's theme, which provides colors and styles.
  /// @param marker The marker to render.
  /// @param anchor The position on the canvas where the marker should be rendered.
  /// @param style The style to apply to the marker.
  /// @param zoom The current zoom level of the chart.
  /// @param opacity The opacity to apply to the marker.
  void _drawMarker(
      Canvas canvas,
      Size size,
      ChartTheme theme,
      ChartMarker marker,
      Offset anchor,
      MarkerStyle style,
      double zoom,
      double opacity,
      Paint paint) {
    YAxisConfig.instance.yAxisClipping(canvas, size, () {
      switch (marker.markerType) {
        case MarkerType.contractMarker:
          _drawContractMarker(
              canvas, theme, marker, anchor, style, zoom, opacity);
          break;
        case MarkerType.activeStart:
          paintStartLine(canvas, size, marker, anchor, style, zoom);
          break;
        case MarkerType.start:
          _drawStartPoint(
              canvas, size, theme, marker, anchor, style, zoom, opacity);
          break;
        case MarkerType.entry:
        case MarkerType.entryTick:
          _drawEntryPoint(canvas, marker, anchor, style, zoom, opacity);
          break;
        case MarkerType.end:
          _drawEndPoint(canvas, marker, anchor, style, zoom, opacity);
          break;
        case MarkerType.exit:
          canvas.drawCircle(
            anchor,
            3 * zoom,
            paint,
          );
          break;
        case MarkerType.tick:
          final Paint paint = Paint()..color = theme.base01Color;
          _drawTickPoint(canvas, anchor, paint, zoom);
          break;
        case MarkerType.latestTick:
          _drawTickPoint(canvas, anchor, paint, zoom);
          break;
        default:
          break;
      }
    });
  }

  /// Renders a contract marker with circular duration display.
  ///
  /// This method draws a circular marker that shows the contract progress
  /// with a circular progress indicator representing the remaining duration.
  /// The marker includes a background circle, progress arc, and a directional
  /// arrow icon in the center.
  ///
  /// @param canvas The canvas on which to paint.
  /// @param theme The chart's theme, which provides colors and styles.
  /// @param marker The marker object containing direction and progress.
  /// @param anchor The position on the canvas where the marker should be rendered.
  /// @param style The style to apply to the marker.
  /// @param zoom The current zoom level of the chart.
  /// @param opacity The opacity to apply to the marker.
  void _drawContractMarker(
    Canvas canvas,
    ChartTheme theme,
    ChartMarker marker,
    Offset anchor,
    MarkerStyle style,
    double zoom,
    double opacity,
  ) {
    final double radius = 12 * zoom;
    final double borderRadius = radius + (1 * zoom); // Add 1 pixel padding

    // Determine colors based on marker direction
    final Color markerColor = marker.direction == MarkerDirection.up
        ? style.upColor
        : style.downColor;

    // Draw background circle
    final Paint backgroundPaint = Paint()
      ..color = markerColor.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(anchor, radius, backgroundPaint);

    // Draw border circle with padding
    final Paint borderPaint = Paint()
      ..color = markerColor.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * zoom;

    canvas.drawCircle(anchor, borderRadius, borderPaint);

    // Draw background progress circle (unfilled portion)
    final Color progressBackgroundColor = marker.direction == MarkerDirection.up
        ? Colors.black.withOpacity(0.2 * opacity)
        : Colors.black.withOpacity(0.2 * opacity);

    final Paint progressBackgroundPaint = Paint()
      ..color = progressBackgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * zoom;

    canvas.drawCircle(anchor, radius, progressBackgroundPaint);

    // Draw progress arc (assuming 75% completion for now - this should be dynamic)
    final Paint progressPaint = Paint()
      ..color = style.backgroundColor.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * zoom
      ..strokeCap = StrokeCap.round;

    const double progressPercentage =
        0.75; // This should be passed as parameter
    const double sweepAngle = -2 * 3.14159 * progressPercentage;

    canvas.drawArc(
      Rect.fromCircle(center: anchor, radius: radius),
      -3.14159 / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw arrow icon in the center
    _drawArrowIcon(
        canvas, anchor, marker, Colors.white.withOpacity(opacity), zoom);
  }

  /// Draws a diagonal arrow icon inside the contract marker.
  ///
  /// @param canvas The canvas on which to paint.
  /// @param center The center position of the arrow.
  /// @param marker The marker object containing direction information.
  /// @param color The color of the arrow.
  /// @param zoom The current zoom level of the chart.
  void _drawArrowIcon(Canvas canvas, Offset center, ChartMarker marker,
      Color color, double zoom) {
    final double dir = marker.direction == MarkerDirection.up ? 1 : -1;
    final double iconSize = 22 * zoom;

    final Path path = Path();

    canvas
      ..save()
      ..translate(
        center.dx - iconSize / 2,
        center.dy - (iconSize / 2) * dir,
      )
      // Scale from 24x24 original SVG size to desired icon size
      ..scale(
        iconSize / 24,
        (iconSize / 24) * dir,
      );

    // Arrow-up path (will be flipped for down direction)
    path
      ..moveTo(17, 8)
      ..lineTo(17, 15)
      ..cubicTo(17, 15.5625, 16.5312, 16, 16, 16)
      ..cubicTo(15.4375, 16, 15, 15.5625, 15, 15)
      ..lineTo(15, 10.4375)
      ..lineTo(8.6875, 16.7188)
      ..cubicTo(8.3125, 17.125, 7.65625, 17.125, 7.28125, 16.7188)
      ..cubicTo(6.875, 16.3438, 6.875, 15.6875, 7.28125, 15.3125)
      ..lineTo(13.5625, 9)
      ..lineTo(9, 9)
      ..cubicTo(8.4375, 9, 8, 8.5625, 8, 8)
      ..cubicTo(8, 7.46875, 8.4375, 7, 9, 7)
      ..lineTo(16, 7)
      ..cubicTo(16.5312, 7, 17, 7.46875, 17, 8)
      ..close();

    canvas
      ..drawPath(path, Paint()..color = color)
      ..restore();
  }

  /// Renders a tick point marker.
  ///
  /// This private method draws a small circular dot representing a price tick.
  /// Tick points are used to visualize individual price updates in the contract.
  ///
  /// @param canvas The canvas on which to paint.
  /// @param anchor The position on the canvas where the tick point should be rendered.
  /// @param paint The paint object to use for drawing.
  /// @param zoom The current zoom level of the chart.
  void _drawTickPoint(Canvas canvas, Offset anchor, Paint paint, double zoom) {
    canvas.drawCircle(
      anchor,
      1.5 * zoom,
      paint,
    );
  }

  /// Renders an entry point marker.
  ///
  /// This private method draws a circular marker with a distinctive design
  /// representing the entry point of the contract. The entry point marks
  /// the price and time at which the contract started. It consists of an
  /// outer circle with marker direction color and an inner white circle.
  ///
  /// @param canvas The canvas on which to paint.
  /// @param marker The marker object containing direction information.
  /// @param anchor The position on the canvas where the entry point should be rendered.
  /// @param style The style to apply to the marker.
  /// @param zoom The current zoom level of the chart.
  /// @param opacity The opacity to apply to the entry point.
  void _drawEntryPoint(Canvas canvas, ChartMarker marker, Offset anchor,
      MarkerStyle style, double zoom, double opacity) {
    // Draw white filled circle
    final Paint fillPaint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(anchor, 3 * zoom, fillPaint);

    // Draw colored stroke to create outer ring effect
    final Paint strokePaint = Paint()
      ..color = (marker.direction == MarkerDirection.up
              ? style.upColor
              : style.downColor)
          .withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * zoom;

    canvas.drawCircle(anchor, 3 * zoom, strokePaint);
  }

  /// Renders the starting point of a tick contract.
  ///
  /// This private method draws a location pin marker at the starting point of
  /// the contract, with an optional text label. The marker's opacity is adjusted
  /// based on its position relative to other markers.
  ///
  /// @param canvas The canvas on which to paint.
  /// @param size The size of the drawing area.
  /// @param theme The chart's theme, which provides colors and styles.
  /// @param marker The marker to render.
  /// @param anchor The position on the canvas where the marker should be rendered.
  /// @param style The style to apply to the marker.
  /// @param zoom The current zoom level of the chart.
  /// @param opacity The opacity to apply to the marker.
  void _drawStartPoint(
    Canvas canvas,
    Size size,
    ChartTheme theme,
    ChartMarker marker,
    Offset anchor,
    MarkerStyle style,
    double zoom,
    double opacity,
  ) {
    if (marker.quote != 0) {
      paintStartMarker(
        canvas,
        anchor - Offset(20 * zoom / 2, 20 * zoom),
        style.backgroundColor.withOpacity(opacity),
        20 * zoom,
      );
    }

    if (marker.text != null) {
      final TextStyle textStyle = TextStyle(
        color: (marker.color ?? style.backgroundColor).withOpacity(opacity),
        fontSize: style.activeMarkerText.fontSize! * zoom,
        fontWeight: FontWeight.bold,
        backgroundColor: theme.backgroundColor.withOpacity(opacity),
      );

      final TextPainter textPainter = makeTextPainter(marker.text!, textStyle);

      final Offset iconShift =
          Offset(textPainter.width / 2, 20 * zoom + textPainter.height);

      paintWithTextPainter(
        canvas,
        painter: textPainter,
        anchor: anchor - iconShift,
        anchorAlignment: Alignment.centerLeft,
      );
    }
  }

  /// Renders an end point marker.
  ///
  /// This private method draws a circular marker representing the end point
  /// of the contract. The color is determined by the marker direction.
  ///
  /// @param canvas The canvas on which to paint.
  /// @param marker The marker object containing direction information.
  /// @param anchor The position on the canvas where the end point should be rendered.
  /// @param style The style to apply to the marker.
  /// @param zoom The current zoom level of the chart.
  /// @param opacity The opacity to apply to the end point.
  void _drawEndPoint(Canvas canvas, ChartMarker marker, Offset anchor,
      MarkerStyle style, double zoom, double opacity) {
    final Paint paint = Paint()
      ..color = (marker.direction == MarkerDirection.up
              ? style.upColor
              : style.downColor)
          .withOpacity(opacity);
    canvas.drawCircle(anchor, 2 * zoom, paint);
  }
}
