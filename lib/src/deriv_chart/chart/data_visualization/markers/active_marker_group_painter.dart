import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_marker_pill.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:flutter/material.dart';

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

    // Find the contractMarker or contractMarkerFixed in the active group to anchor the pill and icon
    ChartMarker? contractMarker;
    for (final ChartMarker marker in activeMarkerGroup.markers) {
      if (marker.markerType == MarkerType.contractMarker ||
          marker.markerType == MarkerType.contractMarkerFixed) {
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

    // Calculate pill width for animation
    final String profitLossText = activeMarkerGroup.profitAndLossText ?? '';
    final TextPainter textPainter = makeTextPainter(
      profitLossText,
      style.activeMarkerText,
    );
    final double naturalPillWidth =
        style.textLeftPadding + textPainter.width + style.textRightPadding;

    // Paint the profit/loss pill with animation
    final MarkerPillResult pillResult = paintMarkerPill(
      canvas: canvas,
      contractMarker: contractMarker,
      style: style,
      painterProps: painterProps,
      profitAndLossText: profitLossText,
      quoteToY: quoteToY,
      contractMarkerLeftPadding:
          activeMarkerGroup.props.contractMarkerLeftPadding,
      pillWidth: naturalPillWidth,
      animationProgress: animationProgress,
    );

    // Update the contract marker's tap area
    contractMarker.tapArea = pillResult.tapArea;
  }

  @override
  bool shouldRepaint(covariant ActiveMarkerGroupPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(covariant ActiveMarkerGroupPainter oldDelegate) =>
      false;
}
