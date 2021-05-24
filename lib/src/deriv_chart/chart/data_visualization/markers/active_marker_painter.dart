import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:flutter/material.dart';

import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';

import 'active_marker.dart';
import 'paint_marker.dart';

/// Painter that paints a marker which is active.
class ActiveMarkerPainter extends CustomPainter {
  /// initializes a painter that paints a marker which is active.
  ActiveMarkerPainter({
    this.activeMarker,
    this.style,
    this.epochToX,
    this.quoteToY,
    this.animationProgress,
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

  @override
  void paint(Canvas canvas, Size size) {
    if (activeMarker == null || animationProgress == 0) {
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
    final Offset iconShift = Offset(-markerArea.width / 2 + style.radius, 0);

    // Marker body.
    canvas.drawRRect(
        RRect.fromRectAndRadius(markerArea, Radius.circular(style.radius)),
        Paint()..color = style.backgroundColor);

    // Label.
    if (animationProgress == 1) {
      paintWithTextPainter(
        canvas,
        painter: textPainter,
        anchor: center +
            iconShift +
            Offset(style.radius + style.textLeftPadding, 0),
        anchorAlignment: Alignment.centerLeft,
      );
    }

    // Circle with icon.
    paintMarker(
      canvas,
      center + iconShift,
      anchor + iconShift,
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
}
