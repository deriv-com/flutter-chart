// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

class GridStyle {
  const GridStyle({
    this.gridLineColor = const Color(0xFF151717),
    this.labelStyle = const TextStyle(
      fontSize: 10,
      height: 1.3,
      fontWeight: FontWeight.normal,
      color: Color(0xFFC2C2C2),
    ),
    this.lineThickness = 1,
  });

  final Color gridLineColor;
  final TextStyle labelStyle;
  final double lineThickness;
}
