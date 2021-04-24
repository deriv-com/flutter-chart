// @dart=2.9

import 'package:flutter/material.dart';

/// Paints a blinking semi-transparent glow around [center].
void paintBlinkingGlow(
  Canvas canvas,
  Offset center,
  double animationProgress,
  Color color,
) =>
    canvas.drawCircle(
      center,
      12 * animationProgress,
      Paint()..color = color.withAlpha(50),
    );

/// Paints a dot on [center].
void paintDot(
  Canvas canvas,
  Offset center,
  Color color,
) =>
    canvas.drawCircle(
      center,
      3,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..strokeWidth = 1,
    );
