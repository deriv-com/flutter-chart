import 'package:flutter/material.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'active_marker.dart';
import 'paint_marker.dart';

class ActiveMarkerPainter extends CustomPainter {
  ActiveMarkerPainter({
    this.activeMarker,
    this.style,
    this.epochToX,
    this.quoteToY,
  });

  final ActiveMarker activeMarker;
  final MarkerStyle style;
  final Function epochToX;
  final Function quoteToY;

  @override
  void paint(Canvas canvas, Size size) {
    if (activeMarker == null) {
      return;
    }

    final Offset center = Offset(
      epochToX(activeMarker.epoch),
      quoteToY(activeMarker.quote),
    );
    final Offset anchor = center;

    paintMarker(
      canvas,
      center,
      anchor,
      activeMarker.direction,
      style,
    );
  }

  @override
  bool shouldRepaint(ActiveMarkerPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(ActiveMarkerPainter oldDelegate) => false;
}
