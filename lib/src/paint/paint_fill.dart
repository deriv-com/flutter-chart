import 'package:flutter/material.dart';

/// Paints fill between two lines.
void paintFill(
  Canvas canvas,
  Path area,
  Color color,
) =>
    canvas.drawPath(
      area,
      Paint()
        ..style = PaintingStyle.fill
        ..color = color,
    );
