import 'package:flutter/material.dart';
import 'package:deriv_chart/src/paint/paint_text.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'active_marker.dart';
import 'marker.dart';
import 'paint_marker.dart';

class ActiveMarkerPainter extends CustomPainter {
  ActiveMarkerPainter({
    this.activeMarker,
    this.style,
    this.epochToX,
    this.quoteToY,
    this.animationProgress,
  });

  final ActiveMarker activeMarker;
  final MarkerStyle style;
  final Function epochToX;
  final Function quoteToY;
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
      Paint()
        ..color = activeMarker.direction == MarkerDirection.up
            ? style.upColor
            : style.downColor,
    );

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
