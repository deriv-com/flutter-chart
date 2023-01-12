// ignore_for_file: public_member_api_docs

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';

abstract class LinePainter {
  /// Paint line
  void paintLine(
    Canvas canvas,
    Offset center,
    Offset anchor,
    MarkerDirection direction,
    MarkerStyle style,
  ) {
    final Color color =
        direction == MarkerDirection.up ? style.upColor : style.downColor;

    canvas.drawLine(
      anchor,
      center,
      Paint()
        ..color = color
        ..strokeWidth = 1.5,
    );
  }
}
