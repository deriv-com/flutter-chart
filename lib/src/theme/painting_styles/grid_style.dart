// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

class GridStyle {
  const GridStyle(
    this.gridLineColor,
    this.labelStyle, {
    this.lineThickness = 1,
  });

  final Color gridLineColor;
  final TextStyle labelStyle;
  final double lineThickness;
}
