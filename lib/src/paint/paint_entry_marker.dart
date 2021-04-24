// @dart=2.9

import 'package:deriv_chart/src/theme/painting_styles/entry_marker_style.dart';
import 'package:flutter/material.dart';

/// Paints an entry tick marker.
void paintEntryMarker(
  Canvas canvas,
  Offset center,
  EntryMarkerStyle style,
  Color backgroundColor,
) {
  canvas
    ..drawCircle(
      center,
      style.radius,
      Paint()..color = backgroundColor,
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
