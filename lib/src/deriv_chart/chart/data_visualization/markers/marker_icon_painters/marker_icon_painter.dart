import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';

/// Foundation class for painting markers on canvas
abstract class MarkerIconPainter {
  /// Paint circle
  void paintCircle(
    Canvas canvas,
    Offset center,
    Offset anchor,
    MarkerDirection direction,
    MarkerStyle style,
  ) {
    final Color color =
        direction == MarkerDirection.up ? style.upColor : style.downColor;

    canvas
      ..drawLine(
        anchor,
        center,
        Paint()
          ..color = color
          ..strokeWidth = 1.5,
      )
      ..drawCircle(
        anchor,
        3,
        Paint()..color = color,
      )
      ..drawCircle(
        anchor,
        1.5,
        Paint()..color = Colors.black,
      )
      ..drawCircle(
        center,
        style.radius,
        Paint()..color = color,
      )
      ..drawCircle(
        center,
        style.radius - 2,
        Paint()..color = Colors.black.withValues(alpha: 0.32),
      );
  }

  /// Paint marker
  void paintMarker(
    Canvas canvas,
    Offset center,
    Offset anchor,
    MarkerDirection direction,
    MarkerStyle style,
  );
}
