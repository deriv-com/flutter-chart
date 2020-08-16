import 'package:flutter/material.dart';

class GridStyle {
  const GridStyle(
    this.gridLineColor,
    this.labelStyle, {
    this.gridLineWidth = 1,
  });

  final Color gridLineColor;
  final TextStyle labelStyle;
  final double gridLineWidth;
}
