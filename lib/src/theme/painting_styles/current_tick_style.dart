import 'package:flutter/material.dart';

class CurrentTickStyle {
  const CurrentTickStyle({
    this.color,
    this.labelStyle,
    this.lineThickness = 1,
  });

  final Color color;
  final TextStyle labelStyle;
  final double lineThickness;
}
