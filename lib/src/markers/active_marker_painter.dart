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

    final Rect markerArea = Rect.fromLTWH(
      center.dx - style.radius,
      center.dy - style.radius,
      style.radius * 2 +
          (style.textLeftPadding + textPainter.width + style.textRightPadding) *
              animationProgress,
      style.radius * 2,
    );
    final Offset iconShift = Offset(-markerArea.width / 2 + style.radius, 0);

    // Marker body.
    canvas.drawRRect(
      RRect.fromRectAndRadius(markerArea, Radius.circular(style.radius)),
      Paint()..color = Colors.white,
    );

    // Label.
    if (animationProgress == 1) {
      paintWithTextPainter(
        canvas,
        painter: textPainter,
        anchor: center + Offset(style.textLeftPadding + style.radius, 0),
        anchorAlignment: Alignment.centerLeft,
      );
    }

    // Circle with icon.
    paintMarker(
      canvas,
      center,
      anchor - Offset(49, 0),
      activeMarker.direction,
      style,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        markerArea.inflate(style.lineWidth / 2 - 0.5),
        Radius.circular(style.radius + style.lineWidth),
      ),
      Paint()
        ..color = Colors.white
        ..strokeWidth = style.lineWidth
        ..style = PaintingStyle.stroke,
    );

    // Update tap area.
    activeMarker.tapArea = markerArea;
  }

  @override
  bool shouldRepaint(ActiveMarkerPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(ActiveMarkerPainter oldDelegate) => false;
}
