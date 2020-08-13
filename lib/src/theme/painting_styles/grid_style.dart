import 'package:flutter/material.dart';

class GridStyle {
  GridStyle(
    this.gridLineColor,
    this.labelTextStyle, {
    this.gridLineWidth = 1,
  });

  final Color gridLineColor;
  final TextStyle labelTextStyle;
  final double gridLineWidth;
}
