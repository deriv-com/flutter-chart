import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';

/// Paints start time line
void paintStartLine(Canvas canvas, Size size, WebMarker marker, Offset anchor,
    MarkerStyle style, double zoom) {
  paintVerticalDashedLine(
    canvas,
    anchor.dx,
    10,
    size.height - 10,
    style.backgroundColor,
    1,
    dashWidth: 6,
  );

  if (marker.text != null) {
    final TextStyle textStyle = TextStyle(
      color: style.backgroundColor,
      fontSize: style.activeMarkerText.fontSize! * zoom,
      fontWeight: FontWeight.normal,
    );

    final TextPainter textPainter = makeTextPainter(marker.text!, textStyle);

    final Offset iconShift =
        Offset(anchor.dx - textPainter.width - 5, size.height - 20);

    paintWithTextPainter(
      canvas,
      painter: textPainter,
      anchor: iconShift,
      anchorAlignment: Alignment.centerLeft,
    );
  }
}
