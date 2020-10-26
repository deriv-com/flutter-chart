import 'package:flutter/material.dart';

/// For defining current tick indicator style
class CurrentTickStyle {
  /// Initializes
  const CurrentTickStyle({
    this.color = const Color(0xFFFF444F),
    this.lineThickness = 1,
    this.labelStyle = const TextStyle(
      fontSize: 10,
      height: 1.3,
      fontWeight: FontWeight.normal,
      color: Color(0xFFFFFFFF),
      fontFeatures: [FontFeature.tabularFigures()],
    ),
  });

  /// The color of label, dashed-line and current tick dot.
  final Color color;

  /// Thickness of the dashed line
  final double lineThickness;

  /// The text style of the current tick indicator label on the Y-Axis
  final TextStyle labelStyle;
}
