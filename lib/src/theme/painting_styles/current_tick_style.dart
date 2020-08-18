// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

class CurrentTickStyle {
  const CurrentTickStyle({
    this.color = const Color(0xFFFF444F),
    this.lineThickness = 1,
    this.labelStyle = const TextStyle(
      fontSize: 10,
      height: 1.3,
      fontWeight: FontWeight.normal,
      color: Color(0xFFFFFFFF)
    ),
  });

  /// The color of label, dashed-line and current tick dot.
  final Color color;

  /// Thickness of the dashed line
  final double lineThickness;

  final TextStyle labelStyle;
}
