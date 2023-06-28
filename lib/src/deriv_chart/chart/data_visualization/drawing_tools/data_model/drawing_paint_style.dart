import 'package:flutter/material.dart';

/// A class that holds the paint style of the drawings
class DrawingPaintStyle {
  /// Returns the glowy paint style of the line
  Paint glowyLinePaintStyle(Color color, double thickness) => Paint()
    ..color = color
    ..strokeWidth = thickness + 3
    ..strokeCap = StrokeCap.round
    ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 10);

  /// Returns the paint style of the the line
  Paint linePaintStyle(Color color, double thickness) => Paint()
    ..color = color
    ..strokeWidth = thickness;

  /// Returns the paint style of the circle marker
  Paint glowyCirclePaintStyle(Color color) => Paint()
    ..color = color
    ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 10);

  /// Returns the paint style of the circle marker
  Paint transparentCirclePaintStyle() => Paint()..color = Colors.transparent;

  /// Returns the label Paint Style
  Paint labelPaintStyle() => Paint()..color = const Color(0xFFCC2E3D);
}
