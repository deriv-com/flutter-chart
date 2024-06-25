import 'package:deriv_chart/src/theme/painting_styles/entry_exit_marker_style.dart';
import 'package:flutter/material.dart';

/// Paints the entry or exit markers based on the [style] passed.
void paintEntryExitMarker(
  Canvas canvas,
  Offset center,
  EntryExitMarkerStyle style,
) {
  canvas
    ..drawCircle(
      center,
      style.radius,
      Paint()..color = style.color,
    )
    ..drawCircle(
      center,
      style.radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = style.borderColor
        ..strokeWidth = style.borderWidth,
    );
}
