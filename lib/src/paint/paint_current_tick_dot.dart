import 'package:flutter/material.dart';

void paintCurrentTickDot(
  Canvas canvas, {
  @required Offset center,
  @required double animationProgress,
}) {
  canvas.drawCircle(
    center,
    12 * animationProgress,
    Paint()..color = Color(0x50FF444F),
  );
  canvas.drawCircle(
    center,
    3,
    Paint()..color = Color(0xFFFF444F),
  );
}
