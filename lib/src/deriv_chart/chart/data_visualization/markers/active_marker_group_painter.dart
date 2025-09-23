import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_icon_painters/painter_props.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';

import 'active_marker_group.dart';
import 'marker_icon_painters/marker_group_icon_painter.dart';
import 'chart_marker.dart';

/// Painter that paints an active marker for marker groups.
class ActiveMarkerGroupPainter extends CustomPainter {
  /// Initializes a painter that paints an active marker for marker groups.
  ActiveMarkerGroupPainter({
    required this.activeMarkerGroup,
    required this.epochToX,
    required this.quoteToY,
    required this.markerGroupIconPainter,
    required this.theme,
    required this.painterProps,
    this.animationInfo = const AnimationInfo(),
    this.style = const MarkerStyle(),
    this.animationProgress = 1,
  });

  /// The given active marker group to paint.
  final ActiveMarkerGroup activeMarkerGroup;

  /// The `MarkerStyle` to paint the marker with.
  final MarkerStyle style;

  /// The function that calculates an epoch's X value.
  final EpochToX epochToX;

  /// The function that calculates a quote's Y value.
  final QuoteToY quoteToY;

  /// The progress value of the animation of active marker painter.
  final double animationProgress;

  /// Painter used to draw the icon for the active marker.
  final MarkerGroupIconPainter markerGroupIconPainter;

  /// Chart theme used for painting marker group icons.
  final ChartTheme theme;

  /// Properties for painters (zoom, granularity, msPerPx).
  final PainterProps painterProps;

  /// Animation info passed to marker group painter (defaults to static state).
  final AnimationInfo animationInfo;

  @override
  void paint(Canvas canvas, Size size) {
    if (animationProgress == 0) {
      return;
    }

    // Find the contractMarker in the active group to anchor the pill and icon
    ChartMarker? contractMarker;
    for (final ChartMarker marker in activeMarkerGroup.markers) {
      if (marker.markerType == MarkerType.contractMarker) {
        contractMarker = marker;
        break;
      }
    }

    if (contractMarker == null) {
      return;
    }

    // First, paint the active marker group(icons/lines etc.)
    markerGroupIconPainter.paintMarkerGroup(
      canvas,
      size,
      theme,
      activeMarkerGroup,
      epochToX,
      quoteToY,
      painterProps,
      animationInfo,
    );

    // Positioning rules:
    // - Contract icon is painted by TickMarkerIconPainter at x=20 with an outer border radius of (style.radius + 1)
    // - The profit/loss pill starts as the right semicircle (arc) of that icon and expands rightward to form a pill
    // TODO(behnam): Consider moving style related constants to marker style class.
    final double iconCenterX = 20.0;
    final double iconOuterRadius =
        style.radius + 4; // Matches contract marker outer circle
    final double centerY = quoteToY(contractMarker.quote);

    // Fade text opacity directly with clamped animation progress
    final TextPainter textPainter = makeTextPainter(
      activeMarkerGroup.profitAndLossText ?? '',
      style.activeMarkerText.copyWith(
        color: Colors.white.withOpacity(animationProgress.clamp(0.0, 1.0)),
      ),
    );

    // Make pill height match the icon border circle for a seamless joint
    final double pillRadius = iconOuterRadius;

    // Left reference where the arc meets the horizontal center line
    final double arcRightX = iconCenterX + iconOuterRadius;

    // Total width = full capsule width + animated text width contribution
    final double animatedTextWidth =
        (style.textLeftPadding + textPainter.width + style.textRightPadding) *
            animationProgress;
    final double pillWidth = animatedTextWidth;

    // Build the pill path that starts with the right semicircle of the icon
    final double rightEndX = arcRightX + pillWidth;
    final Offset rightEndCenter = Offset(rightEndX - pillRadius, centerY);

    final Path pillPath = Path()
      // Move to top of the icon circle
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

    // Label: paint while expanding but clip to animated pill area so it reveals smoothly
    canvas.save();
    canvas.clipPath(pillPath);
    paintWithTextPainter(
      canvas,
      painter: textPainter,
      anchor: Offset(arcRightX + style.textLeftPadding, centerY),
      anchorAlignment: Alignment.centerLeft,
    );
    canvas.restore();

    // Expand tap area to include both the icon and the pill
    final Rect iconArea = Rect.fromCircle(
        center: Offset(iconCenterX, centerY), radius: iconOuterRadius);
    final Rect pillBounds = pillPath.getBounds();
    contractMarker.tapArea = pillBounds.expandToInclude(iconArea);
  }

  @override
  bool shouldRepaint(covariant ActiveMarkerGroupPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(covariant ActiveMarkerGroupPainter oldDelegate) =>
      false;
}
