import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:flutter/material.dart';

import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';

import '../active_marker.dart';
import '../marker_icon_painters/marker_icon_painter.dart';

/// Painter that paints a marker which is active.
class ActiveMarkerPainter extends CustomPainter {
  /// initializes a painter that paints a marker which is active.
  ActiveMarkerPainter({
    required this.activeMarker,
    required this.epochToX,
    required this.quoteToY,
    required this.markerIconPainter,
    this.style = const MarkerStyle(),
    this.animationProgress = 1,
  });

  /// The given active marker to paint.
  final ActiveMarker activeMarker;

  /// The `MarkerStyle` to paint the marker with.
  final MarkerStyle style;

  /// The function that calculates an epoch's X value.
  final Function epochToX;

  /// The function that calculates an quote's Y value.
  final Function quoteToY;

  /// The progress value of the animation of active marker painter.
  final double animationProgress;

  ///Painter which draws corresponding marker icon
  final MarkerIconPainter markerIconPainter;

  @override
  void paint(Canvas canvas, Size size) {
    if (animationProgress == 0) {
      return;
    }

    final Offset center = Offset(
      epochToX(activeMarker.epoch),
      quoteToY(activeMarker.quote),
    );
    final Offset anchor = center;

    final TextPainter textPainter =
        makeTextPainter(activeMarker.text, style.activeMarkerText);

    final Rect markerArea = Rect.fromCenter(
      center: center,
      height: style.radius * 2,
      width: style.radius * 2 +
          (style.textLeftPadding + textPainter.width + style.textRightPadding) *
              animationProgress,
    );

    // Marker body.
    canvas.drawRRect(
        RRect.fromRectAndRadius(markerArea, Radius.circular(style.radius)),
        Paint()..color = style.backgroundColor);

    // Label.
    if (animationProgress == 1) {
      paintWithTextPainter(
        canvas,
        painter: textPainter,
        anchor: _buildAnchor(markerArea, center),
        anchorAlignment: Alignment.centerLeft,
      );
    }

    // Circle with icon.
    markerIconPainter.paintMarker(
      canvas,
      center + _getIconShift(markerArea),
      anchor + _getIconShift(markerArea),
      activeMarker.direction,
      style,
    );

    // Update tap area.
    activeMarker.tapArea = markerArea;
  }

  @override
  bool shouldRepaint(ActiveMarkerPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(ActiveMarkerPainter oldDelegate) => false;

  Offset _getIconShift(Rect markerArea) {
    if (activeMarker.isRightLabeled) {
      return Offset(-markerArea.width / 2 + style.radius, 0);
    } else {
      return Offset(markerArea.width / 2 - style.radius, 0);
    }
  }

  Offset _buildAnchor(
          Rect markerArea, Offset center) =>
      activeMarker.isRightLabeled
          ? center +
              _getIconShift(markerArea) +
              Offset(style.radius + style.textLeftPadding, 0)
          : center -
              _getIconShift(markerArea) -
              Offset(style.radius - style.textLeftPadding, 0);
}
