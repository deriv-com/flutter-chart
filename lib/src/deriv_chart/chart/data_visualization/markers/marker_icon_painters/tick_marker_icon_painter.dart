import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_group.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_icon_painters/marker_group_icon_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_icon_painters/painter_props.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/chart_marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_end_line.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_line.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_start_line.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_start_marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/deriv_chart/chart/y_axis/y_axis_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/quill_icons.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

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
  /// @param animationInfo Information about any ongoing animations.
  @override
  void paintMarkerGroup(
    Canvas canvas,
    Size size,
    ChartTheme theme,
    MarkerGroup markerGroup,
    EpochToX epochToX,
    QuoteToY quoteToY,
    PainterProps painterProps,
    AnimationInfo animationInfo,
  ) {
    final Map<MarkerType, Offset> points = <MarkerType, Offset>{};
    // Ensure left padding refers to the left edge of the contract circle.
    // Use the outer border radius drawn in _drawContractMarker: radius (12*zoom)
    // plus 1*zoom for the stroke radius.
    final double _contractOuterRadius =
        (12 * painterProps.zoom) + (1 * painterProps.zoom);

    for (final ChartMarker marker in markerGroup.markers) {
      final Offset center;

      // Special handling for contractMarker and contractMarkerFixed - position with left padding
      if (marker.markerType == MarkerType.contractMarker ||
          marker.markerType == MarkerType.contractMarkerFixed) {
        center = Offset(
          markerGroup.props.contractMarkerLeftPadding + _contractOuterRadius,
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
    final Offset? endPoint = points[MarkerType.exitSpot];

    double opacity = 1;

    if (startPoint != null && (endPoint != null || exitPoint != null)) {
      opacity = calculateOpacity(startPoint.dx, exitPoint?.dx);
    }

    final Paint paint = Paint()
      ..color = markerGroup.style.backgroundColor.withOpacity(opacity);

    _drawBarriers(canvas, size, points, markerGroup, markerGroup.style, theme,
        opacity, painterProps, paint);

    for (final ChartMarker marker in markerGroup.markers) {
      final Offset center = points[marker.markerType!] ??
          (marker.markerType == MarkerType.contractMarker ||
                  marker.markerType == MarkerType.contractMarkerFixed
              ? Offset(
                  markerGroup.props.contractMarkerLeftPadding +
                      _contractOuterRadius,
                  quoteToY(marker.quote),
                )
              : Offset(epochToX(marker.epoch), quoteToY(marker.quote)));

      if (marker.markerType == MarkerType.entry &&
          points[MarkerType.entrySpot] != null) {
        continue;
      }

      _drawMarker(
          canvas,
          size,
          theme,
          marker,
          center,
          markerGroup.style,
          painterProps.zoom,
          painterProps.granularity,
          opacity,
          paint,
          animationInfo,
          markerGroup.id,
          markerGroup);
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
      ChartTheme theme,
      double opacity,
      PainterProps painterProps,
      Paint paint) {
    final Offset? _contractMarkerOffset = points[MarkerType.contractMarker];
    final Offset? _startCollapsedOffset = points[MarkerType.startTimeCollapsed];
    final Offset? _exitCollapsedOffset = points[MarkerType.exitTimeCollapsed];
    final Offset? _entrySpotOffset = points[MarkerType.entrySpot];
    final Offset? _exitSpotOffset = points[MarkerType.exitSpot];

    // Determine marker direction color from the marker group direction
    final Color lineColor = markerGroup.direction == MarkerDirection.up
        ? theme.markerStyle.upColorProminent
        : theme.markerStyle.downColorProminent;

    final Color finalLineColor = lineColor.withOpacity(opacity);

    YAxisConfig.instance.yAxisClipping(canvas, size, () {
      // Horizontal dashed line from contractMarker to start time
      if (_contractMarkerOffset != null && _startCollapsedOffset != null) {
        paintHorizontalDashedLine(
          canvas,
          _contractMarkerOffset.dx,
          _startCollapsedOffset.dx,
          _contractMarkerOffset.dy,
          finalLineColor,
          1,
          dashWidth: 2,
          dashSpace: 2,
        );
      }

      final Paint solidLinePaint = Paint()
        ..color = finalLineColor
        ..strokeWidth = 1;

      // Solid line logic
      if (_startCollapsedOffset != null) {
        if (_exitCollapsedOffset != null) {
          // Solid line between collapsed start and exit time markers
          canvas.drawLine(
              _startCollapsedOffset, _exitCollapsedOffset, solidLinePaint);
        } else {
          // No exit marker: draw solid line from start to chart's right edge
          final double rightEdgeX = size.width;
          canvas.drawLine(
            _startCollapsedOffset,
            Offset(rightEdgeX, _startCollapsedOffset.dy),
            solidLinePaint,
          );
        }
      }

      // Horizontal dashed line from exit time marker to the chart's right edge (before yAxis)
      if (_contractMarkerOffset != null && _exitCollapsedOffset != null) {
        final double rightEdgeX = size.width;

        paintHorizontalDashedLine(
          canvas,
          _exitCollapsedOffset.dx,
          rightEdgeX,
          _exitCollapsedOffset.dy,
          finalLineColor,
          1,
          dashWidth: 2,
          dashSpace: 2,
        );
      }

      // Vertical dashed line from entry spot to solid line
      if (_entrySpotOffset != null &&
          _startCollapsedOffset != null &&
          _startCollapsedOffset.dy != _entrySpotOffset.dy) {
        paintVerticalDashedLine(
          canvas,
          _entrySpotOffset.dx,
          math.min(_startCollapsedOffset.dy, _entrySpotOffset.dy),
          math.max(_startCollapsedOffset.dy, _entrySpotOffset.dy),
          finalLineColor,
          1,
          dashWidth: 2,
          dashSpace: 2,
        );
      }

      // Vertical dashed line from exit spot to solid line
      if (_exitSpotOffset != null &&
          _exitCollapsedOffset != null &&
          _exitCollapsedOffset.dy != _exitSpotOffset.dy) {
        paintVerticalDashedLine(
          canvas,
          _exitSpotOffset.dx,
          math.min(_exitCollapsedOffset.dy, _exitSpotOffset.dy),
          math.max(_exitCollapsedOffset.dy, _exitSpotOffset.dy),
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
  /// @param animationInfo Information about any ongoing animations.
  /// @param markerGroupId The ID of the marker group for animation tracking.
  /// @param markerGroup The marker group containing all related markers for this contract.
  void _drawMarker(
      Canvas canvas,
      Size size,
      ChartTheme theme,
      ChartMarker marker,
      Offset anchor,
      MarkerStyle style,
      double zoom,
      int granularity,
      double opacity,
      Paint paint,
      AnimationInfo animationInfo,
      String? markerGroupId,
      MarkerGroup markerGroup) {
    YAxisConfig.instance.yAxisClipping(canvas, size, () {
      switch (marker.markerType) {
        // Use a fixed zoom value of 1.2 for contract markers to provide a
        // consistently larger size, improving tap target accessibility.
        case MarkerType.contractMarker:
          _drawContractMarker(canvas, marker, anchor, style, 1.2, granularity,
              opacity, animationInfo, markerGroupId, markerGroup);
          break;
        case MarkerType.contractMarkerFixed:
          _drawContractMarker(canvas, marker, anchor, style, 1.2, granularity,
              opacity, animationInfo, markerGroupId, markerGroup);
          break;
        case MarkerType.startTime:
          paintStartLine(canvas, size, marker, anchor, style, theme, zoom,
              markerGroup.props);
          break;
        case MarkerType.start:
          _drawStartPoint(
              canvas, size, theme, marker, anchor, style, zoom, opacity);
          break;
        case MarkerType.entry:
        case MarkerType.entrySpot:
          _drawSpotPoint(canvas, marker, anchor, style, theme, zoom, opacity);
          break;
        case MarkerType.exitSpot:
          _drawSpotPoint(canvas, marker, anchor, style, theme, zoom, opacity);
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
        case MarkerType.exitTime:
          paintEndLine(canvas, size, marker, anchor, style, theme, zoom,
              markerGroup.props);
          break;
        case MarkerType.startTimeCollapsed:
          _drawCollapsedTimeLine(
            canvas,
            marker,
            anchor,
            style,
            theme,
            zoom,
            opacity,
          );
          break;
        case MarkerType.exitTimeCollapsed:
          _drawCollapsedTimeLine(
            canvas,
            marker,
            anchor,
            style,
            theme,
            zoom,
            opacity,
          );
          break;
        case MarkerType.profitAndLossLabel:
          _drawProfitAndLossLabel(
            canvas,
            theme,
            markerGroup,
            marker,
            anchor,
            style,
            1,
            opacity,
            fixedLeftAligned: false,
          );
          break;
        case MarkerType.profitAndLossLabelFixed:
          _drawProfitAndLossLabel(
            canvas,
            theme,
            markerGroup,
            marker,
            anchor,
            style,
            1,
            opacity,
            fixedLeftAligned: true,
          );
          break;
        default:
          break;
      }
    });
  }

  void _drawProfitAndLossLabel(
    Canvas canvas,
    ChartTheme theme,
    MarkerGroup markerGroup,
    ChartMarker marker,
    Offset anchor,
    MarkerStyle style,
    double zoom,
    double opacity, {
    required bool fixedLeftAligned,
  }) {
    final bool isProfit = markerGroup.props.isProfit;
    final Color borderColor = isProfit
        ? theme.closedMarkerBorderColorGreen
        : theme.closedMarkerBorderColorRed;
    final Color backgroundColor = isProfit
        ? theme.closedMarkerSurfaceColorGreen
        : theme.closedMarkerSurfaceColorRed;
    final Color textIconColor = isProfit
        ? theme.closedMarkerTextIconColorGreen
        : theme.closedMarkerTextIconColorRed;

    final double pillHeight = 32 * zoom;
    final double radius = pillHeight / 2;
    final double iconSize = 24 * zoom;
    const double leftPadding = 8;
    const double spacing = 4;
    const double rightPadding = 16;

    final TextStyle textStyle = theme
        .textStyle(
          textStyle: theme.profitAndLossLabelTextStyle,
          color: textIconColor,
        )
        .copyWith(
          fontSize: theme.profitAndLossLabelTextStyle.fontSize! * zoom,
          height: 1,
        );

    final String text = markerGroup.profitAndLossText ?? '';
    final TextPainter textPainter = makeTextPainter(text, textStyle);

    final double contentWidth =
        leftPadding + iconSize + spacing + textPainter.width + rightPadding;

    Rect pillRect;
    if (fixedLeftAligned) {
      const double leftX = 5;
      pillRect = Rect.fromLTWH(
        leftX,
        anchor.dy - pillHeight / 2,
        contentWidth,
        pillHeight,
      );
    } else {
      pillRect = Rect.fromCenter(
        center: Offset(anchor.dx, anchor.dy),
        width: contentWidth,
        height: pillHeight,
      );
    }

    final Paint fillPaint = Paint()
      ..color = backgroundColor.withOpacity(0.88 * opacity)
      ..style = PaintingStyle.fill;
    final RRect rrect =
        RRect.fromRectAndRadius(pillRect, Radius.circular(radius));
    canvas.drawRRect(rrect, fillPaint);

    final Paint strokePaint = Paint()
      ..color = borderColor.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rrect, strokePaint);

    final TextPainter iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(QuillIcons.flag_checkered.codePoint),
        style: TextStyle(
          fontFamily: QuillIcons.kFontFam,
          fontSize: iconSize,
          package: QuillIcons.kFontPkg,
          color: textIconColor.withOpacity(opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final double iconX = pillRect.left + leftPadding;
    final double iconY = anchor.dy - iconPainter.height / 2;
    iconPainter.paint(canvas, Offset(iconX, iconY));

    paintWithTextPainter(
      canvas,
      painter: textPainter,
      anchor: Offset(iconX + iconSize + spacing, anchor.dy),
      anchorAlignment: Alignment.centerLeft,
    );

    marker.tapArea = pillRect;
  }

  /// Calculate remaining duration with smooth animation transitions.
  ///
  /// This method calculates the remaining duration for the contract progress arc
  /// with smooth interpolation between updates using currentTickPercent from AnimationInfo.
  /// It takes granularity into account for accurate timing calculations.
  ///
  /// @param markerGroup The marker group containing contract information.
  /// @param animationInfo Animation information containing currentTickPercent.
  /// @param granularity The time interval between data points in milliseconds.
  /// @return The animated remaining duration as a value between 0.0 and 1.0.
  double _calculateAnimatedRemainingDuration(
    MarkerGroup markerGroup,
    AnimationInfo animationInfo,
    int granularity,
  ) {
    // Default to full arc duration
    double baseRemainingDuration = 1;

    if (markerGroup.currentEpoch != null) {
      // Find entryTick and end marker epochs
      int? entryTickEpoch;
      int? endEpoch;

      for (final ChartMarker groupMarker in markerGroup.markers) {
        if (groupMarker.markerType == MarkerType.entrySpot) {
          entryTickEpoch = groupMarker.epoch;
        } else if (groupMarker.markerType == MarkerType.exitTimeCollapsed) {
          endEpoch = groupMarker.epoch;
        }
      }

      // Calculate base remaining duration
      if (entryTickEpoch != null && endEpoch != null) {
        final int totalDuration = endEpoch - entryTickEpoch;
        final int baseElapsed = markerGroup.currentEpoch! - entryTickEpoch;
        final double baseProgress = baseElapsed / totalDuration;
        baseRemainingDuration = (1.0 - baseProgress).clamp(0.0, 1.0);

        // Apply smooth animation transition using currentTickPercent
        // This creates smooth interpolation between tick updates
        if (animationInfo.currentTickPercent < 1.0) {
          // Calculate the progress that would occur in one granularity period
          final double progressPerGranularity =
              granularity / totalDuration.toDouble();

          // Calculate the previous remaining duration (before current tick)
          final double previousRemainingDuration =
              (baseRemainingDuration + progressPerGranularity).clamp(0.0, 1.0);

          // Interpolate between previous and current duration using currentTickPercent
          baseRemainingDuration = ui.lerpDouble(
                previousRemainingDuration,
                baseRemainingDuration,
                animationInfo.currentTickPercent,
              ) ??
              baseRemainingDuration;
        }
      }
    }

    return baseRemainingDuration;
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
  /// @param animationInfo Information about any ongoing animations.
  /// @param markerGroupId The ID of the marker group for animation tracking.
  /// @param markerGroup The marker group containing all related markers for this contract.
  void _drawContractMarker(
    Canvas canvas,
    ChartMarker marker,
    Offset anchor,
    MarkerStyle style,
    double zoom,
    int granularity,
    double opacity,
    AnimationInfo animationInfo,
    String? markerGroupId,
    MarkerGroup markerGroup,
  ) {
    // Use the extracted protected method
    drawContractMarkerCircle(
      canvas,
      marker,
      anchor,
      style,
      zoom,
      granularity,
      opacity,
      animationInfo,
      markerGroup,
    );
  }

  /// Protected helper method to draw a label inside the contract marker circle.
  ///
  /// This method is accessible to subclasses for reuse.
  @protected
  void drawContractMarkerLabel(Canvas canvas, Offset anchor, String label,
      double opacity, double zoom, MarkerStyle style) {
    // Base radius used in _drawContractMarker
    final double radius = 12 * zoom;
    final double padding = 5 * zoom; // small padding from circle border
    final double maxWidth = (radius - padding) * 2;
    final double maxHeight = (radius - padding) * 2;

    final TextStyle baseTextStyle = style.markerLabelTextStyle.copyWith(
      fontSize: style.markerLabelTextStyle.fontSize! * zoom,
      color: style.markerLabelTextStyle.color!.withOpacity(opacity),
      height: 1,
    );

    final TextPainter painter = makeFittedTextPainter(
      label,
      baseTextStyle,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );

    paintWithTextPainter(
      canvas,
      painter: painter,
      anchor: anchor,
    );
  }

  /// Protected helper method to draw a diagonal arrow icon inside the contract marker.
  ///
  /// This method is accessible to subclasses for reuse.
  @protected
  void drawContractMarkerArrow(Canvas canvas, Offset center, ChartMarker marker,
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

  /// Protected helper method to draw the contract marker circle with progress arc.
  ///
  /// This method is accessible to subclasses for reuse.
  @protected
  void drawContractMarkerCircle(
    Canvas canvas,
    ChartMarker marker,
    Offset anchor,
    MarkerStyle style,
    double zoom,
    int granularity,
    double opacity,
    AnimationInfo animationInfo,
    MarkerGroup markerGroup,
  ) {
    final double radius = 12 * zoom;
    final double borderRadius = radius + (1 * zoom);

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

    // Update tap area to match the visual marker size (use outer border radius)
    marker.tapArea = Rect.fromCircle(center: anchor, radius: borderRadius);

    // Draw background progress circle (unfilled portion)
    final Color progressBackgroundColor = marker.direction == MarkerDirection.up
        ? Colors.black.withOpacity(0.2 * opacity)
        : Colors.black.withOpacity(0.2 * opacity);

    final Paint progressBackgroundPaint = Paint()
      ..color = progressBackgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * zoom;

    canvas.drawCircle(anchor, radius, progressBackgroundPaint);

    // Calculate animated remaining duration with smooth transitions
    final double remainingDuration = _calculateAnimatedRemainingDuration(
      markerGroup,
      animationInfo,
      granularity,
    );

    // Animate the progress arc based on remaining duration
    final Paint progressPaint = Paint()
      ..color = style.backgroundColor.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * zoom
      ..strokeCap = StrokeCap.round;

    final double sweepAngle = -2 * math.pi * remainingDuration;

    canvas.drawArc(
      Rect.fromCircle(center: anchor, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw label or arrow icon
    if (markerGroup.props.markerLabel != null) {
      drawContractMarkerLabel(
          canvas, anchor, markerGroup.props.markerLabel!, opacity, zoom, style);
    } else {
      drawContractMarkerArrow(
          canvas, anchor, marker, Colors.white.withOpacity(opacity), zoom);
    }
  }

  void _drawMarkerLabel(Canvas canvas, Offset anchor, String label,
      double opacity, double zoom, MarkerStyle style) {
    drawContractMarkerLabel(canvas, anchor, label, opacity, zoom, style);
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
    drawContractMarkerArrow(canvas, center, marker, color, zoom);
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
  void _drawSpotPoint(Canvas canvas, ChartMarker marker, Offset anchor,
      MarkerStyle style, ChartTheme theme, double zoom, double opacity) {
    // Draw white filled circle
    final Paint fillPaint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(anchor, 3 * zoom, fillPaint);

    // Draw colored stroke to create outer ring effect
    final Paint strokePaint = Paint()
      ..color = (marker.direction == MarkerDirection.up
              ? theme.markerStyle.upColorProminent
              : theme.markerStyle.downColorProminent)
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

  /// Draws a short solid vertical line centered on [anchor.dy].
  ///
  /// Used for the collapsed time markers (start/end) that show only a
  /// compact connector, matching the design for condensed layouts in chart view.
  void _drawCollapsedTimeLine(
    Canvas canvas,
    ChartMarker marker,
    Offset anchor,
    MarkerStyle style,
    ChartTheme theme,
    double zoom,
    double opacity,
  ) {
    // Length tuned to be subtle yet visible; scales with zoom.
    final double halfLength = 4 * zoom;
    final Color color = marker.direction == MarkerDirection.up
        ? theme.markerStyle.upColorProminent
        : theme.markerStyle.downColorProminent;
    final Paint paint = Paint()
      ..color = color.withOpacity(opacity)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(anchor.dx, anchor.dy - halfLength),
      Offset(anchor.dx, anchor.dy + halfLength),
      paint,
    );
  }
}
