import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/chart_marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_icon_painters/painter_props.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Result of painting a marker pill, containing dimensions and tap area.
class MarkerPillResult {
  /// Creates a marker pill result.
  const MarkerPillResult({
    required this.pillRightEdge,
    required this.tapArea,
  });

  /// The right edge x-coordinate of the painted pill.
  final double pillRightEdge;

  /// The tap area for the marker (icon + pill combined).
  final Rect tapArea;
}

/// Paints a pill-shaped profit/loss indicator attached to a contract marker.
///
/// This helper draws a rounded pill that extends from the right side of a
/// circular contract marker icon, containing profit/loss text. The pill
/// can be animated or static based on the [animationProgress] parameter.
///
/// The pill consists of:
/// - A right semicircle that continues from the contract marker icon
/// - A rectangular body with rounded right end
/// - A dark background with colored border
/// - White text showing profit/loss value
///
/// @param canvas The canvas to draw on
/// @param contractMarker The contract marker this pill is attached to
/// @param style The marker style defining colors and dimensions
/// @param painterProps Properties like zoom level affecting marker size
/// @param profitAndLossText The text to display in the pill
/// @param quoteToY Function to convert quote value to y-coordinate
/// @param contractMarkerLeftPadding Left padding for the contract marker
/// @param pillWidth The desired width of the pill (excluding the icon)
/// @param animationProgress Animation progress from 0.0 to 1.0 (defaults to 1.0 for no animation)
/// @return MarkerPillResult containing the right edge position and tap area
MarkerPillResult paintMarkerPill({
  required Canvas canvas,
  required ChartMarker contractMarker,
  required MarkerStyle style,
  required PainterProps painterProps,
  required String profitAndLossText,
  required double Function(double) quoteToY,
  required double contractMarkerLeftPadding,
  required double pillWidth,
  double animationProgress = 1.0,
}) {
  // Calculate dimensions based on zoom and style
  final double outerRadius = (12 * painterProps.zoom) + (1 * painterProps.zoom);
  final double iconCenterX = contractMarkerLeftPadding + outerRadius;
  final double iconOuterRadius = style.radius + 4;
  final double centerY = quoteToY(contractMarker.quote);

  // Create text painter with opacity based on animation progress
  final TextPainter textPainter = makeTextPainter(
    profitAndLossText,
    style.activeMarkerText.copyWith(
      color: Colors.white.withOpacity(animationProgress.clamp(0.0, 1.0)),
    ),
  );

  final double pillRadius = iconOuterRadius;
  final double arcRightX = iconCenterX + iconOuterRadius;

  // Apply animation to pill width
  final double animatedPillWidth = pillWidth * animationProgress;

  // Build the pill path starting from the right semicircle of the icon
  final double rightEndX = arcRightX + animatedPillWidth;
  final Offset rightEndCenter = Offset(rightEndX - pillRadius, centerY);

  final Path pillPath = Path()
    ..moveTo(iconCenterX, centerY - iconOuterRadius)
    // Right semicircle of icon (from top to bottom)
    ..arcTo(
      Rect.fromCircle(
          center: Offset(iconCenterX, centerY), radius: iconOuterRadius),
      -math.pi / 2,
      math.pi,
      false,
    )
    // Bottom edge to the right rounded end
    ..lineTo(rightEndCenter.dx, centerY + pillRadius)
    // Right rounded end (bottom to top)
    ..arcTo(
      Rect.fromCircle(center: rightEndCenter, radius: pillRadius),
      math.pi / 2,
      -math.pi,
      false,
    )
    // Top edge back to the top of the icon arc
    ..lineTo(iconCenterX, centerY - iconOuterRadius)
    ..close();

  // Pill background (dark container)
  final Color pillFillColor = const Color(0xFF181C25);
  canvas.drawPath(pillPath, Paint()..color = pillFillColor);

  // Pill border uses profit/loss color (exclude the left arc next to the icon)
  final Color borderColor = contractMarker.direction == MarkerDirection.up
      ? style.upColor
      : style.downColor;
  final Path pillBorderPath = Path()
    ..moveTo(iconCenterX, centerY + pillRadius)
    ..lineTo(rightEndCenter.dx, centerY + pillRadius)
    ..arcTo(
      Rect.fromCircle(center: rightEndCenter, radius: pillRadius),
      math.pi / 2,
      -math.pi,
      false,
    )
    ..lineTo(iconCenterX, centerY - pillRadius);
  canvas.drawPath(
    pillBorderPath,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = borderColor,
  );

  // Label: paint while clipping to animated pill area so it reveals smoothly
  canvas.save();
  canvas.clipPath(pillPath);
  paintWithTextPainter(
    canvas,
    painter: textPainter,
    anchor: Offset(arcRightX + style.textLeftPadding, centerY),
    anchorAlignment: Alignment.centerLeft,
  );
  canvas.restore();

  // Calculate tap area to include both the icon and the pill
  final Rect iconArea = Rect.fromCircle(
      center: Offset(iconCenterX, centerY), radius: iconOuterRadius);
  final Rect pillBounds = pillPath.getBounds();
  final Rect tapArea = pillBounds.expandToInclude(iconArea);

  return MarkerPillResult(
    pillRightEdge: arcRightX + animatedPillWidth,
    tapArea: tapArea,
  );
}
