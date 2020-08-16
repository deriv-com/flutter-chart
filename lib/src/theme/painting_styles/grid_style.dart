import 'package:flutter/material.dart';

class GridStyle {
  const GridStyle(
    this.gridLineColor,
    this.labelStyle, {
    this.lineThickness = 2,
  });

  final Color gridLineColor;
  final TextStyle labelStyle;
  final double lineThickness;
}
