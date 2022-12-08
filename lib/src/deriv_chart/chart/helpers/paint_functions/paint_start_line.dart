import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_line.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';

/// Paints start time line
void paintStartLine(
    Canvas canvas, Size size, Marker marker, Offset anchor, MarkerStyle style) {
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
      fontSize: style.activeMarkerText.fontSize,
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
