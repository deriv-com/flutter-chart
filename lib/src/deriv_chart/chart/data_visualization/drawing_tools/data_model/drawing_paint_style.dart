import 'package:flutter/material.dart';

/// A class that holds the paint style of the drawings
class DrawingPaintStyle {
  /// Returns the glowy paint style of the line
  Paint glowyLinePaintStyle(Color color, double thickness) => Paint()
    ..color = color
    ..strokeWidth = thickness + 3
    ..strokeCap = StrokeCap.round;

  /// Returns the paint style of the the line
  Paint linePaintStyle(Color color, double thickness) => Paint()
    ..color = color
    ..strokeWidth = thickness;

  /// Returns the paint style of the circle marker
  Paint glowyCirclePaintStyle(Color color) => Paint()..color = color;

  /// Returns the paint style of the circle marker
  Paint transparentCirclePaintStyle() => Paint()..color = Colors.transparent;
}
