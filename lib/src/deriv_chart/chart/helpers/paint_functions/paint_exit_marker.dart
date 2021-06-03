import 'package:deriv_chart/src/theme/painting_styles/exit_marker_style.dart';
import 'package:flutter/material.dart';

/// Paints an exit tick marker.
void paintExitMarker(
  Canvas canvas,
  Offset center,
  ExitMarkerStyle style,
) {
  canvas.drawCircle(
    center,
    style.radius,
    Paint()..color = style.color,
  );
}
